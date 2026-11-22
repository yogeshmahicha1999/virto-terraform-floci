variable "name" {
  type = string
}

variable "bucket_name" {
  type = string
}

variable "alb_dns_name" {
  type = string
}

variable "enable_cloudfront" {
  type    = bool
  default = true
}

# Platform ko jaane wale paths (local nginx.conf ke jaise)
variable "backend_path_patterns" {
  type = list(string)
  default = [
    "/api/*",
    "/connect/*",
    "/graphql",
    "/cms-content/*",
    "/.well-known/*",
    "/revoke/*",
    "/ucp/*",
    "/externalsignin/*",
    "/signin-oidc*",
    "/signin-google*"
  ]
}
