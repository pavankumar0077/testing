# Create security group for ECS tasks
resource "aws_security_group" "ecs_tasks" {
  name        = "${var.name_prefix}-ecs-tasks-sg"
  description = "Security group for ECS tasks"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = var.container_port
    to_port     = var.container_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.name_prefix}-ecs-tasks-sg"
    }
  )
}

# Create ECS cluster
resource "aws_ecs_cluster" "main" {
  name = var.ecs_cluster_name

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = merge(
    var.tags,
    {
      Name = var.ecs_cluster_name
    }
  )
}

# Create CloudWatch Log Group
resource "aws_cloudwatch_log_group" "ecs" {
  name              = "/ecs/${var.name_prefix}"
  retention_in_days = 30
  
  tags = merge(
    var.tags,
    {
      Name = "/ecs/${var.name_prefix}"
    }
  )
}

# Create task definition
resource "aws_ecs_task_definition" "app" {
  family                   = "${var.name_prefix}-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.container_cpu
  memory                   = var.container_memory
  execution_role_arn       = var.task_execution_role_arn
  task_role_arn            = var.task_role_arn

  container_definitions = jsonencode([
    {
      name         = "${var.name_prefix}-container"
      image        = var.container_image
      essential    = true
      portMappings = [
        {
          containerPort = var.container_port
          hostPort      = var.container_port
          protocol      = "tcp"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.ecs.name
          "awslogs-region"        = data.aws_region.current.name
          "awslogs-stream-prefix" = "ecs"
        }
      }
      # Right-sizing: Add resource monitoring
      resourceRequirements = [
        {
          type  = "CPU"
          value = tostring(var.container_cpu)
        },
        {
          type  = "MEMORY"
          value = tostring(var.container_memory)
        }
      ]
    }
  ])

  tags = merge(
    var.tags,
    {
      Name = "${var.name_prefix}-task"
    }
  )
}

# Get current AWS region
data "aws_region" "current" {}

# Create ECS service
resource "aws_ecs_service" "app" {
  name            = "${var.name_prefix}-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.app.arn
  desired_count   = var.desired_count
  launch_type     = "FARGATE"

  network_configuration {
    security_groups  = [aws_security_group.ecs_tasks.id]
    subnets          = var.private_subnet_ids
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = var.alb_target_group_arn
    container_name   = "${var.name_prefix}-container"
    container_port   = var.container_port
  }

  lifecycle {
    ignore_changes = [desired_count]
  }

  depends_on = [aws_ecs_task_definition.app]
  
  tags = merge(
    var.tags,
    {
      Name = "${var.name_prefix}-service"
    }
  )
}

# Create Auto Scaling Target
resource "aws_appautoscaling_target" "ecs_target" {
  max_capacity       = var.max_capacity
  min_capacity       = var.min_capacity
  resource_id        = "service/${aws_ecs_cluster.main.name}/${aws_ecs_service.app.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
  
  tags = merge(
    var.tags,
    {
      Name = "${var.name_prefix}-autoscaling-target"
    }
  )
}

# Create Auto Scaling Policy for CPU
resource "aws_appautoscaling_policy" "ecs_policy_cpu" {
  name               = "${var.name_prefix}-cpu-autoscaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value       = var.cpu_threshold
    scale_in_cooldown  = 300
    scale_out_cooldown = 300
  }
}

# Create Auto Scaling Policy for Memory
resource "aws_appautoscaling_policy" "ecs_policy_memory" {
  name               = "${var.name_prefix}-memory-autoscaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageMemoryUtilization"
    }
    target_value       = var.memory_threshold
    scale_in_cooldown  = 300
    scale_out_cooldown = 300
  }
}

# Create Auto Scaling Policy for Request Count (ALB request count per target)
resource "aws_appautoscaling_policy" "ecs_policy_request_count" {
  count              = var.enable_request_scaling ? 1 : 0
  name               = "${var.name_prefix}-request-count-autoscaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ALBRequestCountPerTarget"
      resource_label         = "${split(":", var.alb_target_group_arn)[5]}/${split(":", var.alb_target_group_arn)[1]}/${split(":", var.alb_target_group_arn)[2]}/${split(":", var.alb_target_group_arn)[3]}"
    }
    target_value       = var.request_count_threshold
    scale_in_cooldown  = 300
    scale_out_cooldown = 60  # Faster scale out for request count
  }
}

# Create Scheduled Scaling - Scale Up
resource "aws_appautoscaling_scheduled_action" "scale_up" {
  count              = var.enable_scheduled_scaling ? 1 : 0
  name               = "${var.name_prefix}-scale-up"
  service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace
  resource_id        = aws_appautoscaling_target.ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
  schedule           = var.scale_up_cron

  scalable_target_action {
    min_capacity = var.scheduled_min_capacity
    max_capacity = var.scheduled_max_capacity
  }
}

# Create Scheduled Scaling - Scale Down
resource "aws_appautoscaling_scheduled_action" "scale_down" {
  count              = var.enable_scheduled_scaling ? 1 : 0
  name               = "${var.name_prefix}-scale-down"
  service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace
  resource_id        = aws_appautoscaling_target.ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
  schedule           = var.scale_down_cron

  scalable_target_action {
    min_capacity = var.min_capacity
    max_capacity = var.max_capacity
  }
}