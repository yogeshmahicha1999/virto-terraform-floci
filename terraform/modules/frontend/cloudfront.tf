locals {
  cf_enabled = var.enable_cloudfront ? 1 : 0
  s3_origin  = "s3-site"
  alb_origin = "alb-platform"

  # AWS managed policy IDs
  cache_disabled   = "4135ea2d-6df8-44a3-9df3-4b5a84be39ad" # CachingDisabled
  cache_optimized  = "658327ea-f89d-4fab-a63d-7e88639e58f6" # CachingOptimized
  origin_all_viewr = "216adef6-5c7f-47e4-b989-5492eafa07d3" # AllViewer
}

resource "aws_cloudfront_origin_access_control" "site" {
  count                             = local.cf_enabled
  name                              = "${var.name}-site-oac"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# SPA routing: extension wale paths (.js, .css) ko chhod ke baaki /index.html
resource "aws_cloudfront_function" "spa" {
  count   = local.cf_enabled
  name    = "${var.name}-spa-rewrite"
  runtime = "cloudfront-js-2.0"
  publish = true
  code    = <<-JS
    function handler(event) {
      var request = event.request;
      var last = request.uri.split('/').pop();
      if (last.indexOf('.') === -1) {
        request.uri = '/index.html';
      }
      return request;
    }
  JS
}

resource "aws_cloudfront_distribution" "this" {
  count               = local.cf_enabled
  enabled             = true
  default_root_object = "index.html"
  comment             = "${var.name} storefront + platform"
  price_class         = "PriceClass_100"
  wait_for_deployment = false # Floci me deploy status ka wait nahi

  origin {
    origin_id                = local.s3_origin
    domain_name              = aws_s3_bucket.site.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.site[0].id
  }

  origin {
    origin_id   = local.alb_origin
    domain_name = var.alb_dns_name

    custom_origin_config {
      http_port  = 80
      https_port = 443
      # Lab me ALB pe sirf HTTP. Real AWS me "https-only" + ACM certificate
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  default_cache_behavior {
    target_origin_id       = local.s3_origin
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    cache_policy_id        = local.cache_optimized
    compress               = true

    function_association {
      event_type   = "viewer-request"
      function_arn = aws_cloudfront_function.spa[0].arn
    }
  }

  dynamic "ordered_cache_behavior" {
    for_each = var.backend_path_patterns
    content {
      path_pattern             = ordered_cache_behavior.value
      target_origin_id         = local.alb_origin
      viewer_protocol_policy   = "redirect-to-https"
      allowed_methods          = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
      cached_methods           = ["GET", "HEAD"]
      cache_policy_id          = local.cache_disabled
      origin_request_policy_id = local.origin_all_viewr
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    # Real AWS me custom domain + ACM certificate (us-east-1)
    cloudfront_default_certificate = true
  }
}

# Bucket policy: sirf is distribution ko S3 padhne do
data "aws_iam_policy_document" "site" {
  count = local.cf_enabled

  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.site.arn}/*"]

    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = [aws_cloudfront_distribution.this[0].arn]
    }
  }
}

resource "aws_s3_bucket_policy" "site" {
  count  = local.cf_enabled
  bucket = aws_s3_bucket.site.id
  policy = data.aws_iam_policy_document.site[0].json
}
