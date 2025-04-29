aws_region       = "us-east-1"
environment      = "dev"
project_name     = "ecs-app"
cost_center      = "engineering"
owner            = "platform-team"

# Common tags
tags = {
  Environment = "dev"
  CostCenter  = "engineering"
  Owner       = "platform-team"
  ManagedBy   = "terraform"
  Project     = "ecs-app"
}

# Networking
vpc_cidr             = "10.0.0.0/16"
public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnet_cidrs = ["10.0.3.0/24", "10.0.4.0/24"]
availability_zones   = ["us-east-1a", "us-east-1b"]

# ECS - Right-sizing for dev environment
ecs_cluster_name = "app-cluster"
container_image  = "nginx:latest"
container_port   = 80
container_cpu    = 256  # 0.25 vCPU
container_memory = 512  # 0.5 GB
desired_count    = 2
health_check_path = "/"

# Auto scaling - Basic configuration for dev
min_capacity      = 2
max_capacity      = 5
cpu_threshold     = 70
memory_threshold  = 70

# Enhanced autoscaling - Dev environment
enable_scheduled_scaling = false
scale_up_cron            = "0 8 * * MON-FRI"
scale_down_cron          = "0 18 * * MON-FRI"
scheduled_min_capacity   = 2
scheduled_max_capacity   = 4
enable_request_scaling   = true
request_count_threshold  = 800