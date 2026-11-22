variable "region" {
  type    = string
  default = "ap-south-1"
}

variable "frontend_bucket_name" {
  type        = string
  description = "Globally unique S3 bucket name"
}

variable "alert_email" {
  type    = string
  default = ""
}

variable "platform_desired_count" {
  type        = number
  default     = 0
  description = "Platform image ECR me push hone ke baad 1 ya zyada karo"
}
