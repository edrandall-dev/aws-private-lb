resource "aws_lb" "test_env_alb" {
  name               = "${var.env_prefix}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.test_env_loadbalancer_sg.id]

  subnets = [for subnet in aws_subnet.test_env_public_subnet : subnet.id]

  tags = {
    "Name"      = "${var.env_prefix}_alb"
    "Terraform" = true
  }
}

resource "aws_alb_listener" "test_env_listener_http" {
  load_balancer_arn = aws_lb.test_env_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.test_env_alb_tg.arn
    type             = "forward"
  }
}

resource "aws_lb_target_group_attachment" "example" {
  count            = var.webserver_count
  target_group_arn = aws_lb_target_group.test_env_alb_tg.arn
  target_id        = aws_instance.www_instance[count.index].id
  port             = 80
}

resource "aws_lb_target_group" "test_env_alb_tg" {
  name     = "${var.env_prefix}-alb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.test_env_vpc.id
}

