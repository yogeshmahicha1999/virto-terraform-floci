output "bucket_name" {
  value = aws_s3_bucket.site.id
}

output "cloudfront_domain" {
  value = try(aws_cloudfront_distribution.this[0].domain_name, null)
}
