resource "aws_s3_bucket" "test" {
  bucket = "virto-floci-smoke-test"
}

module "network" {
  source     = "../../modules/network"
  name       = "virto-floci"
  azs        = ["us-east-1a", "us-east-1b"]
  enable_nat = true
}

module "data" {
  source             = "../../modules/data"
  name               = "virto-floci"
  private_subnet_ids = module.network.private_subnet_ids
  rds_sg_id          = module.network.rds_sg_id
  efs_sg_id          = module.network.efs_sg_id
}

module "compute" {
  source               = "../../modules/compute"
  name                 = "virto-floci"
  db_secret_arn        = module.data.db_secret_arn
  vpc_id               = module.network.vpc_id
  public_subnet_ids    = module.network.public_subnet_ids
  private_subnet_ids   = module.network.private_subnet_ids
  alb_sg_id            = module.network.alb_sg_id
  ecs_sg_id            = module.network.ecs_sg_id
  efs_id               = module.data.efs_id
  efs_access_point_ids = module.data.efs_access_point_ids

  # Floci ke liye fake AMI. Real AWS me ECS-optimized AMI SSM parameter se aayega.
  ami_id        = "ami-00000000000000000"
  desired_count = 0
}

module "frontend" {
  source            = "../../modules/frontend"
  name              = "virto-floci"
  bucket_name       = "virto-floci-frontend"
  alb_dns_name      = module.compute.alb_dns_name
  enable_cloudfront = true
}

module "monitoring" {
  source                  = "../../modules/monitoring"
  name                    = "virto-floci"
  alb_arn_suffix          = module.compute.alb_arn_suffix
  target_group_arn_suffix = module.compute.target_group_arn_suffix
  db_identifier           = module.data.db_identifier
  cluster_name            = module.compute.cluster_name
  service_name            = module.compute.service_name
}
