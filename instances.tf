resource "aws_instance" "www_instance" {
  count = var.instance_count
  ami   = data.aws_ami.latest_amazon_linux.id

  instance_type = "t3.micro"

  subnet_id              = element(aws_subnet.test_env_private_subnet.*.id, count.index % 2)
  vpc_security_group_ids = ["${aws_security_group.test_env_webserver_sg.id}"]

  user_data = file("userdata.sh")

  tags = {
    "Name"      = "${var.env_prefix}-webserver"
    "Terraform" = true
  }
}