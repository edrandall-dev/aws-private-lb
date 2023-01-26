resource "aws_security_group" "test_env_webserver_sg" {
  name   = "test_env_webserver_sg"
  vpc_id = aws_vpc.test_env_vpc.id

  # No restrictions on traffic originating from inside the VPC
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["${var.base_cidr_block}"]
    //cidr_blocks = ["0.0.0.0/0"]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "Name"      = "test_env_webserver_sg"
    "Terraform" = true
  }
}

resource "aws_security_group" "test_env_loadbalancer_sg" {
  name   = "test_env_loadbalancer_sg"
  vpc_id = aws_vpc.test_env_vpc.id

  # No restrictions on traffic originating from inside the VPC
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "Name"      = "test_env_loadbalancer_sg"
    "Terraform" = true
  }
}