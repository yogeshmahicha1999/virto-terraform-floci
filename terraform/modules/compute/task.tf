data "aws_region" "current" {}

resource "aws_ecs_task_definition" "platform" {
  family                   = "${var.name}-platform"
  requires_compatibilities = ["EC2"]
  network_mode             = "awsvpc"
  cpu                      = 1024
  memory                   = 3072
  execution_role_arn       = aws_iam_role.task_execution.arn
  task_role_arn            = aws_iam_role.task.arn

  volume {
    name = "modules"
    efs_volume_configuration {
      file_system_id     = var.efs_id
      transit_encryption = "ENABLED"
      authorization_config {
        access_point_id = var.efs_access_point_ids["modules"]
      }
    }
  }

  volume {
    name = "app_data"
    efs_volume_configuration {
      file_system_id     = var.efs_id
      transit_encryption = "ENABLED"
      authorization_config {
        access_point_id = var.efs_access_point_ids["app_data"]
      }
    }
  }

  volume {
    name = "cms_content"
    efs_volume_configuration {
      file_system_id     = var.efs_id
      transit_encryption = "ENABLED"
      authorization_config {
        access_point_id = var.efs_access_point_ids["cms_content"]
      }
    }
  }

  container_definitions = jsonencode([{
    name      = "platform"
    image     = "${aws_ecr_repository.platform.repository_url}:${var.image_tag}"
    essential = true

    portMappings = [{ containerPort = 80, protocol = "tcp" }]

    environment = [
      { name = "ASPNETCORE_URLS", value = "http://+:80" },
      { name = "DatabaseProvider", value = "PostgreSql" },
      { name = "Search__Provider", value = "Lucene" }
    ]

    secrets = [{
      name      = "ConnectionStrings__VirtoCommerce"
      valueFrom = "${var.db_secret_arn}:connection_string::"
    }]

    mountPoints = [
      { sourceVolume = "modules", containerPath = "/opt/virtocommerce/platform/modules" },
      { sourceVolume = "app_data", containerPath = "/opt/virtocommerce/platform/App_Data" },
      { sourceVolume = "cms_content", containerPath = "/opt/virtocommerce/platform/wwwroot/cms-content" }
    ]

    logConfiguration = {
      logDriver = "awslogs"
      options = {
        "awslogs-group"         = aws_cloudwatch_log_group.platform.name
        "awslogs-region"        = data.aws_region.current.name
        "awslogs-stream-prefix" = "platform"
      }
    }
  }])
}

resource "aws_ecs_service" "platform" {
  name            = "${var.name}-platform"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.platform.arn
  desired_count   = var.desired_count

  capacity_provider_strategy {
    capacity_provider = aws_ecs_capacity_provider.ec2.name
    weight            = 1
  }

  network_configuration {
    subnets         = var.private_subnet_ids
    security_groups = [var.ecs_sg_id]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.platform.arn
    container_name   = "platform"
    container_port   = 80
  }

  health_check_grace_period_seconds = 300

  depends_on = [
    aws_lb_listener.http,
    aws_ecs_cluster_capacity_providers.this
  ]
}
