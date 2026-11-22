output "ecr_repository_url" {
  value = aws_ecr_repository.platform.repository_url
}

output "instance_profile_name" {
  value = aws_iam_instance_profile.ecs_instance.name
}

output "task_execution_role_arn" {
  value = aws_iam_role.task_execution.arn
}

output "task_role_arn" {
  value = aws_iam_role.task.arn
}

output "alb_dns_name" {
  value = aws_lb.this.dns_name
}

output "target_group_arn" {
  value = aws_lb_target_group.platform.arn
}

output "cluster_name" {
  value = aws_ecs_cluster.this.name
}

output "log_group_name" {
  value = aws_cloudwatch_log_group.platform.name
}

output "service_name" {
  value = aws_ecs_service.platform.name
}

output "alb_arn_suffix" {
  value = aws_lb.this.arn_suffix
}

output "target_group_arn_suffix" {
  value = aws_lb_target_group.platform.arn_suffix
}
