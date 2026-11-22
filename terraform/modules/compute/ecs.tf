resource "aws_ecs_cluster" "this" {
  name = "${var.name}-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

resource "aws_cloudwatch_log_group" "platform" {
  name              = "/ecs/${var.name}/platform"
  retention_in_days = var.log_retention_days
}
