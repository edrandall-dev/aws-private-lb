resource "aws_security_group" "ed_webserver_sg" {
  name   = "ed_webserver_sg"
  vpc_id = aws_vpc.ed_privlb_vpc.id

  # No restrictions on traffic originating from inside the VPC
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["${var.base_cidr_block}"]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "Name"      = "ed_privlb_websg"
    "Creator"   = var.creator
    "Terraform" = true
  }
}