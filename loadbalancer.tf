resource "aws_lb" "ed_alb" {
  name               = "ed-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.ed_loadbalancer_sg.id]
  
  subnets = [for subnet in aws_subnet.ed_public_subnet: subnet.id]

  tags = {
    "Name"      = "${var.env_prefix}_alb"
    "Creator"   = var.creator
    "Terraform" = true
  }
}

resource "aws_alb_listener" "ed_listener_http" {
  load_balancer_arn = aws_lb.ed_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_lb_target_group.ed_alb_tg.arn}"
    type             = "forward"
  }
}

resource "aws_lb_target_group" "ed_alb_tg" {
  name        = "ed-alb-tg"
  target_type = "alb"
  port        = 80
  protocol    = "TCP"
  vpc_id      = aws_vpc.ed_vpc.id
}

