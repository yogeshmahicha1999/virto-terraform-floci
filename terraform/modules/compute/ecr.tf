resource "aws_ecr_repository" "platform" {
  name                 = "${var.name}/platform"
  image_tag_mutability = "IMMUTABLE" # tag overwrite nahi hoga, rollback safe rehta hai

  image_scanning_configuration {
    scan_on_push = true # vulnerability scanning
  }
}

resource "aws_ecr_lifecycle_policy" "platform" {
  repository = aws_ecr_repository.platform.name
  policy = jsonencode({
    rules = [{
      rulePriority = 1
      description  = "Sirf last 10 images rakho"
      selection = {
        tagStatus   = "any"
        countType   = "imageCountMoreThan"
        countNumber = 10
      }
      action = { type = "expire" }
    }]
  })
}
