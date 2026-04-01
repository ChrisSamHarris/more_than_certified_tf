resource "aws_ecr_repository" "logic-ecr" {
  name         = var.ecr_repo_name
  force_delete = true
}

resource "terraform_data" "login" {
  provisioner "local-exec" {
    command = <<EOT
        docker login ${local.ecr_url} \
        --username ${local.ecr_token.user_name} \
        --password ${local.ecr_token.password}
        EOT
  }
}

resource "terraform_data" "build" {
  depends_on = [terraform_data.login]
  provisioner "local-exec" {
    command = <<EOT
        docker build --platform linux/amd64 -t ${local.ecr_url} ${path.module}/apps/${var.app_ui}
        EOT
  }
}

resource "terraform_data" "push" {
  triggers_replace = [
    var.image_version
  ]
  depends_on = [terraform_data.login, terraform_data.build]
  provisioner "local-exec" {
    command = <<EOT
        docker image tag ${local.ecr_url} ${local.ecr_url}:${var.image_version}
        docker image tag ${local.ecr_url} ${local.ecr_url}:latest
        docker push ${local.ecr_url}:${var.image_version}
        docker push ${local.ecr_url}:latest
        EOT
  }
}

resource "aws_ecs_task_definition" "logic-ecs-task" {
  family                   = "${var.app_name}-task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = var.execution_role_arn
  container_definitions = jsonencode([
    {
      name      = var.app_name
      image     = "${local.ecr_url}:latest"
      cpu       = 256
      memory    = 512
      essential = true
      portMappings = [
        {
          containerPort = var.port
          hostPort      = var.port
        }
      ]
    }
  ])
}

resource "aws_ecs_service" "logic-ecs-service" {
  name            = "${var.app_name}-service"
  cluster         = var.cluster_arn
  task_definition = aws_ecs_task_definition.logic-ecs-task.arn
  launch_type     = "FARGATE"
  desired_count   = 2

  network_configuration {
    subnets          = var.subnets
    security_groups  = var.ecs_app_sg_id
    assign_public_ip = var.is_public
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.logic-target-group.arn
    container_name   = var.app_name
    container_port   = var.port
  }
}

resource "aws_lb_target_group" "logic-target-group" {
  name        = "mtc-ecs-tg"
  port        = var.port
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = var.vpc_id
}

resource "aws_lb_listener_rule" "static" {
  listener_arn = var.alb_listener_arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.logic-target-group.arn
  }

  condition {
    path_pattern {
      values = [var.path_pattern]
    }
  }
}