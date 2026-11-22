variable "name" {
  type = string
}

variable "db_secret_arn" {
  type        = string
  description = "Secrets Manager secret ARN jo task execution role ko padhna hai"
}

variable "vpc_id" {
  type = string
}

variable "public_subnet_ids" {
  type = list(string)
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "alb_sg_id" {
  type = string
}

variable "ecs_sg_id" {
  type = string
}

variable "log_retention_days" {
  type    = number
  default = 14
}

variable "ami_id" {
  type        = string
  description = "ECS-optimized AMI ID"
}

variable "instance_type" {
  type    = string
  default = "t3.medium"
}

variable "image_tag" {
  type    = string
  default = "v1"
}

variable "desired_count" {
  type    = number
  default = 0
}

variable "asg_min" {
  type    = number
  default = 1
}

variable "asg_max" {
  type    = number
  default = 2
}

variable "efs_id" {
  type = string
}

variable "efs_access_point_ids" {
  type = map(string)
}
