locals {
  ecs_name = "nginx_test"
}


resource "aws_ecs_cluster" "nginx_cluster" {
  name = "${local.ecs_name}"
}

resource "aws_ecs_task_definition" "nginx_task" {
  family = "${local.ecs_name}"
  requires_compatibilities = ["FARGATE"]
  cpu    = "256"
  memory = "512"
  network_mode = "awsvpc"
  execution_role_arn        = aws_iam_role.ecs_role.arn
  task_role_arn             = aws_iam_role.ecs_role.arn
  container_definitions = <<EOL
[
  {
    "name": "nginx",
    "image": "nginx:1.14",
    "portMappings": [
      {
        "containerPort": 80,
        "hostPort": 80
      }
    ],
    "essentials": true,
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-region": "ap-northeast-1",
        "awslogs-stream-prefix": "nginx_task",
        "awslogs-group": "/ecs/project/nginx_test"
      }
    }
  }
]
EOL
}

resource "aws_ecs_service" "test_service" {
  name = "${local.ecs_name}"
  depends_on = [aws_lb_listener_rule.alb_test]
  cluster = "${aws_ecs_cluster.nginx_cluster.name}"
  launch_type = "FARGATE"
  desired_count = "1"
  task_definition = "${aws_ecs_task_definition.nginx_task.arn}"

  network_configuration {
    subnets         = [var.subnet_id_pub_A, var.subnet_id_pub_C]
    security_groups = [aws_security_group.test_sg.id]
    assign_public_ip = true
  }

  # ECSタスクの起動後に紐付けるELBターゲットグループ
  load_balancer {
    target_group_arn = "${aws_lb_target_group.alb_test.arn}"
    container_name   = "nginx"
    container_port   = "80"
  }

}