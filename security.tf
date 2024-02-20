resource "aws_security_group" "test_env_webserver_sg" {
  name   = "${var.env_prefix}-webserver-sg"
  vpc_id = aws_vpc.test_env_vpc.id

  # No restrictions on traffic originating from inside the VPC
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["${var.base_cidr_block}"]
  }

  # No restrictions on outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "Name"      = "${var.env_prefix}-webserver-sg"
    "Terraform" = true
  }
}

resource "aws_security_group" "test_env_loadbalancer_sg" {
  name   = "${var.env_prefix}-loadbalancer-sg"
  vpc_id = aws_vpc.test_env_vpc.id

  # No restrictions on traffic hitting the load balancer on port 80
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # No restrictions on outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "Name"      = "${var.env_prefix}-loadbalancer-sg"
    "Terraform" = true
  }
}

resource "aws_security_group" "test_env_bastion_sg" {
  name   = "${var.env_prefix}-bastion-sg"
  vpc_id = aws_vpc.test_env_vpc.id

  #Allow SSH connectivity to the bastion EC2 instance
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # No restrictions on outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "Name"      = "${var.env_prefix}-bastion-sg"
    "Terraform" = true
  }
}