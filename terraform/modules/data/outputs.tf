output "db_secret_arn" {
  value = aws_secretsmanager_secret.db.arn
}

output "db_endpoint" {
  value = aws_db_instance.this.address
}

output "efs_id" {
  value = aws_efs_file_system.this.id
}

output "efs_access_point_ids" {
  value = { for k, v in aws_efs_access_point.this : k => v.id }
}

output "db_identifier" {
  value = aws_db_instance.this.identifier
}
