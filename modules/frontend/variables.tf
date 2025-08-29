variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "bucket_name" {
  description = "Name of the S3 bucket for static files"
  type        = string
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}

