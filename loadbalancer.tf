resource "aws_lb" "ed_privlb_alb" {
  name               = "ed-privlb-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.ed_loadbalancer_sg.id]
  
  //subnets = concat([for privatesubnet in aws_subnet.ed_privlb_private_subnet : privatesubnet.id],
  //                 [for publicsubnet in aws_subnet.ed_privlb_public_subnet: publicsubnet.id])
  
  subnets = [for publicsubnet in aws_subnet.ed_privlb_public_subnet: publicsubnet.id]

  enable_deletion_protection = true

  tags = {
    "Name"      = "${var.env_prefix}_alb"
    "Creator"   = var.creator
    "Terraform" = true
  }
}

/*
resource "aws_alb_listener" "listener_http" {
  load_balancer_arn = "${aws_alb.ed_privlb_alb.arn}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_alb_target_group.group.arn}"
    type             = "forward"
  }
}
*/