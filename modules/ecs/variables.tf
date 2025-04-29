variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "private_subnet_ids" {
  description = "IDs of the private subnets"
  type        = list(string)
}

variable "ecs_cluster_name" {
  description = "Name of the ECS cluster"
  type        = string
}

variable "container_image" {
  description = "Docker image to run in the ECS cluster"
  type        = string
}

variable "container_port" {
  description = "Port exposed by the container"
  type        = number
}

variable "container_cpu" {
  description = "CPU units for the container (1024 = 1 vCPU)"
  type        = number
}

variable "container_memory" {
  description = "Memory for the container in MiB"
  type        = number
}

variable "desired_count" {
  description = "Desired number of containers running"
  type        = number
}

variable "task_execution_role_arn" {
  description = "ARN of the ECS task execution role"
  type        = string
}

variable "task_role_arn" {
  description = "ARN of the ECS task role"
  type        = string
}

variable "alb_target_group_arn" {
  description = "ARN of the ALB target group"
  type        = string
}

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

# Tagging
variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}