locals {
  name_prefix = "${var.project_name}-${var.environment}"
  
  # Common tags to be applied to all resources
  common_tags = merge(
    var.tags,
    {
      Environment = var.environment
      Project     = var.project_name
      ManagedBy   = "terraform"
      CostCenter  = var.cost_center
      Owner       = var.owner
    }
  )
}

module "networking" {
  source = "./modules/networking"

  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  availability_zones   = var.availability_zones
  environment          = var.environment
  project_name         = var.project_name
  tags                 = local.common_tags
}

module "iam" {
  source = "./modules/iam"

  name_prefix = local.name_prefix
  
}

module "alb" {
  source = "./modules/alb"

  name_prefix        = local.name_prefix
  vpc_id             = module.networking.vpc_id
  public_subnet_ids  = module.networking.public_subnet_ids
  health_check_path  = var.health_check_path
  container_port     = var.container_port
  tags               = local.common_tags
}

module "ecs" {
  source = "./modules/ecs"

  name_prefix           = local.name_prefix
  vpc_id                = module.networking.vpc_id
  private_subnet_ids    = module.networking.private_subnet_ids
  ecs_cluster_name      = "${local.name_prefix}-${var.ecs_cluster_name}"
  container_image       = var.container_image
  container_port        = var.container_port
  container_cpu         = var.container_cpu
  container_memory      = var.container_memory
  desired_count         = var.desired_count
  task_execution_role_arn = module.iam.task_execution_role_arn
  task_role_arn         = module.iam.task_role_arn
  alb_target_group_arn  = module.alb.target_group_arn
  min_capacity          = var.min_capacity
  max_capacity          = var.max_capacity
  cpu_threshold         = var.cpu_threshold
  memory_threshold      = var.memory_threshold
  tags                  = local.common_tags
  
  # Enhanced autoscaling parameters
  enable_scheduled_scaling = var.enable_scheduled_scaling
  scale_up_cron            = var.scale_up_cron
  scale_down_cron          = var.scale_down_cron
  scheduled_min_capacity   = var.scheduled_min_capacity
  scheduled_max_capacity   = var.scheduled_max_capacity
  enable_request_scaling   = var.enable_request_scaling
  request_count_threshold  = var.request_count_threshold
}