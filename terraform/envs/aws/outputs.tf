output "alb_dns_name" {
  value = module.compute.alb_dns_name
}

output "cloudfront_domain" {
  value = module.frontend.cloudfront_domain
}

output "ecr_repository_url" {
  value = module.compute.ecr_repository_url
}
