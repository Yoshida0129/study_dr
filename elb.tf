locals {
  is_production = false
  alb_name = "test-alb"

  is_internal_mode = false
  subnet_id = "${local.is_internal_mode ? 
    [var.subnet_id_pub_A, var.subnet_id_pub_C] :
    [var.subnet_id_pri]}"
}


resource "aws_lb" "alb_test" {
  name               = "${local.alb_name}"
  internal           = "${local.is_internal_mode}"
  load_balancer_type = "application"
  security_groups    = [aws_security_group.test_sg.id]
  subnets            = "${local.subnet_id}"

  enable_deletion_protection = "${local.is_production}"
}

resource "aws_lb_target_group" "alb_test" {
  name = "${local.alb_name}-tg"
  vpc_id = "${var.vpc_id}"

  port        = 80
  protocol    = "HTTP"
  target_type = "ip"

  health_check {
    port = 80
    path = "/"
  }
}

resource "aws_lb_listener" "alb_test" {
  load_balancer_arn = aws_lb.alb_test.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb_test.arn
  }
}

resource "aws_lb_listener_rule" "alb_test" {
  listener_arn = "${aws_lb_listener.alb_test.arn}"

  action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.alb_test.id}"
  }

  condition {
		path_pattern {
      values = ["/static/*"]
    }
  }
}