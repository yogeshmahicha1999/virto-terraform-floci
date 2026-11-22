variable "name" {
  type = string
}

variable "db_username" {
  type    = string
  default = "virto"
}

variable "db_name" {
  type    = string
  default = "virtocommerce3"
}

variable "db_engine_version" {
  type    = string
  default = "17"
}

variable "db_instance_class" {
  type    = string
  default = "db.t4g.micro"
}

variable "db_multi_az" {
  type    = bool
  default = false
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "rds_sg_id" {
  type = string
}

variable "efs_sg_id" {
  type = string
}
