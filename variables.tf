variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "ecs-app"
}

# Cost tracking tags
variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

variable "cost_center" {
  description = "Cost center for billing and cost tracking"
  type        = string
  default     = "engineering"
}

variable "owner" {
  description = "Owner of the resources for cost tracking"
  type        = string
  default     = "platform-team"
}

# Networking variables
variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for the public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for the private subnets"
  type        = list(string)
  default     = ["10.0.3.0/24", "10.0.4.0/24"]
}

variable "availability_zones" {
  description = "Availability zones to use for subnets"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

# ECS variables
variable "ecs_cluster_name" {
  description = "Name of the ECS cluster"
  type        = string
  default     = "app-cluster"
}

variable "container_image" {
  description = "Docker image to run in the ECS cluster"
  type        = string
  default     = "nginx:latest"
}

variable "container_port" {
  description = "Port exposed by the container"
  type        = number
  default     = 80
}

variable "container_cpu" {
  description = "CPU units for the container (1024 = 1 vCPU)"
  type        = number
  default     = 256
}

variable "container_memory" {
  description = "Memory for the container in MiB"
  type        = number
  default     = 512
}

variable "desired_count" {
  description = "Desired number of containers running"
  type        = number
  default     = 2
}

variable "health_check_path" {
  description = "Path for ALB health check"
  type        = string
  default     = "/"
}

# Auto scaling variables
variable "min_capacity" {
  description = "Minimum number of tasks"
  type        = number
  default     = 2
}

variable "max_capacity" {
  description = "Maximum number of tasks"
  type        = number
  default     = 10
}

variable "cpu_threshold" {
  description = "CPU threshold for scaling"
  type        = number
  default     = 70
}

variable "memory_threshold" {
  description = "Memory threshold for scaling"
  type        = number
  default     = 70
}

# Enhanced autoscaling variables
variable "enable_scheduled_scaling" {
  description = "Enable scheduled scaling for predictable workloads"
  type        = bool
  default     = false
}

variable "scale_up_cron" {
  description = "Cron expression for scaling up (UTC)"
  type        = string
  default     = "0 8 * * MON-FRI"  # 8 AM UTC Monday-Friday
}

variable "scale_down_cron" {
  description = "Cron expression for scaling down (UTC)"
  type        = string
  default     = "0 18 * * MON-FRI"  # 6 PM UTC Monday-Friday
}

variable "scheduled_min_capacity" {
  description = "Minimum capacity for scheduled scaling"
  type        = number
  default     = 2
}

variable "scheduled_max_capacity" {
  description = "Maximum capacity for scheduled scaling"
  type        = number
  default     = 5
}

variable "enable_request_scaling" {
  description = "Enable request count based scaling"
  type        = bool
  default     = false
}

variable "request_count_threshold" {
  description = "Request count threshold per target for scaling"
  type        = number
  default     = 1000
}