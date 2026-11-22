resource "random_password" "db" {
  length  = 24
  special = false
}

# ---------- RDS PostgreSQL ----------
resource "aws_db_subnet_group" "this" {
  name       = "${var.name}-db-subnets"
  subnet_ids = var.private_subnet_ids
}

resource "aws_db_instance" "this" {
  identifier        = "${var.name}-postgres"
  engine            = "postgres"
  engine_version    = var.db_engine_version
  instance_class    = var.db_instance_class
  allocated_storage = 20
  storage_encrypted = true

  db_name  = var.db_name
  username = var.db_username
  password = random_password.db.result

  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [var.rds_sg_id]
  publicly_accessible    = false
  multi_az               = var.db_multi_az

  backup_retention_period = 7
  skip_final_snapshot     = true # sirf lab ke liye, real AWS me false
  deletion_protection     = false
}

# ---------- Secrets Manager ----------
resource "aws_secretsmanager_secret" "db" {
  name                    = "${var.name}/db-credentials"
  description             = "Virto Commerce PostgreSQL credentials"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "db" {
  secret_id = aws_secretsmanager_secret.db.id
  secret_string = jsonencode({
    username          = var.db_username
    password          = random_password.db.result
    dbname            = var.db_name
    host              = aws_db_instance.this.address
    port              = aws_db_instance.this.port
    connection_string = "User ID=${var.db_username};Password=${random_password.db.result};Host=${aws_db_instance.this.address};Port=${aws_db_instance.this.port};Database=${var.db_name};"
  })
}

# ---------- EFS (modules, App_Data, cms-content) ----------
resource "aws_efs_file_system" "this" {
  encrypted = true
  tags      = { Name = "${var.name}-efs" }
}

resource "aws_efs_mount_target" "this" {
  count           = length(var.private_subnet_ids)
  file_system_id  = aws_efs_file_system.this.id
  subnet_id       = var.private_subnet_ids[count.index]
  security_groups = [var.efs_sg_id]
}

# EFS access points (Compose ke 3 volumes ke equivalent)
locals {
  efs_paths = {
    modules     = "/modules"
    app_data    = "/app_data"
    cms_content = "/cms_content"
  }
}

resource "aws_efs_access_point" "this" {
  for_each       = local.efs_paths
  file_system_id = aws_efs_file_system.this.id

  root_directory {
    path = each.value
    creation_info {
      owner_uid   = 0
      owner_gid   = 0
      permissions = "0755"
    }
  }
}
