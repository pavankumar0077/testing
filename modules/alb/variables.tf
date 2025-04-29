variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "public_subnet_ids" {
  description = "IDs of the public subnets"
  type        = list(string)
}

variable "health_check_path" {
  description = "Path for ALB health check"
  type        = string
  default     = "/"
}

variable "container_port" {
  description = "Port exposed by the container"
  type        = number
  default     = 80
}

# Tagging
variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}