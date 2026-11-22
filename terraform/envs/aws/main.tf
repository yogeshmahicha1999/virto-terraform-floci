locals {
  name = "virto-prod"
}

data "aws_availability_zones" "available" {
  state = "available"
}

# Real AWS me ECS-optimized AMI SSM parameter se aata hai (Floci me nahi)
data "aws_ssm_parameter" "ecs_ami" {
  name = "/aws/service/ecs/optimized-ami/amazon-linux-2023/recommended/image_id"
}

module "network" {
  source     = "../../modules/network"
  name       = local.name
  azs        = slice(data.aws_availability_zones.available.names, 0, 2)
  enable_nat = true
}

module "data" {
  source             = "../../modules/data"
  name               = local.name
  private_subnet_ids = module.network.private_subnet_ids
  rds_sg_id          = module.network.rds_sg_id
  efs_sg_id          = module.network.efs_sg_id
  db_multi_az        = true
}

module "compute" {
  source               = "../../modules/compute"
  name                 = local.name
  db_secret_arn        = module.data.db_secret_arn
  vpc_id               = module.network.vpc_id
  public_subnet_ids    = module.network.public_subnet_ids
  private_subnet_ids   = module.network.private_subnet_ids
  alb_sg_id            = module.network.alb_sg_id
  ecs_sg_id            = module.network.ecs_sg_id
  efs_id               = module.data.efs_id
  efs_access_point_ids = module.data.efs_access_point_ids
  ami_id               = nonsensitive(data.aws_ssm_parameter.ecs_ami.value)
  desired_count        = var.platform_desired_count
}

module "frontend" {
  source            = "../../modules/frontend"
  name              = local.name
  bucket_name       = var.frontend_bucket_name
  alb_dns_name      = module.compute.alb_dns_name
  enable_cloudfront = true
}

module "monitoring" {
  source                  = "../../modules/monitoring"
  name                    = local.name
  alb_arn_suffix          = module.compute.alb_arn_suffix
  target_group_arn_suffix = module.compute.target_group_arn_suffix
  db_identifier           = module.data.db_identifier
  cluster_name            = module.compute.cluster_name
  service_name            = module.compute.service_name
  alert_email             = var.alert_email
}
