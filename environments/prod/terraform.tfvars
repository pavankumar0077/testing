aws_region       = "us-east-1"
environment      = "prod"
project_name     = "ecs-app"
cost_center      = "engineering"
owner            = "platform-team"

# Common tags
tags = {
  Environment = "prod"
  CostCenter  = "engineering"
  Owner       = "platform-team"
  ManagedBy   = "terraform"
  Project     = "ecs-app"
  Criticality = "high"
}

# Networking
vpc_cidr             = "10.0.0.0/16"
public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24", "10.0.5.0/24"]
private_subnet_cidrs = ["10.0.3.0/24", "10.0.4.0/24", "10.0.6.0/24"]
availability_zones   = ["us-east-1a", "us-east-1b", "us-east-1c"]

# ECS - Right-sizing for production environment
ecs_cluster_name = "app-cluster"
container_image  = "nginx:latest"
container_port   = 80
container_cpu    = 1024  # 1 vCPU
container_memory = 2048  # 2 GB
desired_count    = 3
health_check_path = "/"

# Auto scaling - Production configuration
min_capacity      = 3
max_capacity      = 15
cpu_threshold     = 60  # More aggressive scaling for production
memory_threshold  = 60

# Enhanced autoscaling - Production environment
enable_scheduled_scaling = true
scale_up_cron            = "0 7 * * MON-FRI"  # 7 AM UTC Monday-Friday
scale_down_cron          = "0 19 * * MON-FRI" # 7 PM UTC Monday-Friday
scheduled_min_capacity   = 5
scheduled_max_capacity   = 10
enable_request_scaling   = true
request_count_threshold  = 500  # Lower threshold for faster scaling