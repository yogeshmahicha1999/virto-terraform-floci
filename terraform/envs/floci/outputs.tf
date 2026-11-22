output "alb_dns_name" {
  value = module.compute.alb_dns_name
}

output "cloudfront_domain" {
  value = module.frontend.cloudfront_domain
}

output "frontend_bucket" {
  value = module.frontend.bucket_name
}

output "ecr_repository_url" {
  value = module.compute.ecr_repository_url
}

output "db_endpoint" {
  value = module.data.db_endpoint
}

output "db_secret_arn" {
  value = module.data.db_secret_arn
}

output "sns_topic_arn" {
  value = module.monitoring.sns_topic_arn
}
