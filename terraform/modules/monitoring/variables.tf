variable "name" {
  type = string
}

variable "alb_arn_suffix" {
  type = string
}

variable "target_group_arn_suffix" {
  type = string
}

variable "db_identifier" {
  type = string
}

variable "cluster_name" {
  type = string
}

variable "service_name" {
  type = string
}

# Khaali rakho to email subscription nahi banegi
variable "alert_email" {
  type    = string
  default = ""
}
