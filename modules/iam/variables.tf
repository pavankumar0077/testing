variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
}

# Tagging
variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}