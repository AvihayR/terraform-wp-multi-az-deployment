resource "aws_ecs_cluster" "wp-cluster" {
  name = "wp-cluster"
}

resource "aws_ecs_task_definition" "wp-task" {
  family = "wp-tasks"
  container_definitions = jsonencode([
    {
      "name"      = "Wordpress-Container",
      "image"     = "${var.repo_url}:latest",
      "cpu"       = 512,
      "memory"    = 512,
      "essential" = true,
      "portMappings" = [
        {
          "containerPort" = 80,
          "hostPort"      = 80,
          "protocol"      = "tcp"
        }
      ],
      "environment" = [
        {
          "name"  = "WORDPRESS_DB_HOST"
          "value" = "${var.db_url}"
        },
        {
          "name"  = "WORDPRESS_DB_USER"
          "value" = "${var.db_user}"
        },
        {
          "name"  = "WORDPRESS_DB_PASSWORD"
          "value" = "${var.db_password}"
        },
        {
          "name"  = "WORDPRESS_DB_NAME"
          "value" = "${var.db_name}"
        },
        {
          "name"  = "WORDPRESS_TABLE_PREFIX"
          "value" = "wp"
        },
      ],
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.ecs_logs.name
          awslogs-region        = "eu-central-1"
          awslogs-stream-prefix = "wp-ecs"
        }
      }
    }
  ])
}

resource "aws_ecs_service" "wp-service" {
  name            = "wp-service"
  cluster         = aws_ecs_cluster.wp-cluster.id
  task_definition = aws_ecs_task_definition.wp-task.arn
  desired_count   = 2

  deployment_controller {
    type = "CODE_DEPLOY"
  }
}

resource "aws_cloudwatch_log_group" "ecs_logs" {
  name              = aws_ecs_service.wp-service.name
  retention_in_days = 2
}

output "name" {
  value = aws_ecs_cluster.wp-cluster.name
}

output "td_arn" {
  value = aws_ecs_task_definition.wp-task.arn
}
