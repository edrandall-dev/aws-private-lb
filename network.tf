resource "aws_vpc" "test_env_vpc" {
  cidr_block           = var.base_cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    "Name"      = "${var.env_prefix}-vpc"
    "Terraform" = true
  }
}

resource "aws_subnet" "test_env_public_subnet" {
  count = var.instance_count //For this example, we need 1 *public* subnet per instance

  vpc_id                  = aws_vpc.test_env_vpc.id
  cidr_block              = cidrsubnet(var.base_cidr_block, 8, count.index + 1)
  availability_zone       = join("", ["${var.region}", "${var.availability_zones[count.index]}"])
  map_public_ip_on_launch = true

  tags = {
    "Name"      = "${var.env_prefix}_public_subnet_${var.availability_zones[count.index]}"
    "Terraform" = true
  }
}

resource "aws_subnet" "test_env_private_subnet" {
  count = var.instance_count //For this example, we need 1 *private* subnet per instance

  vpc_id                  = aws_vpc.test_env_vpc.id
  cidr_block              = cidrsubnet(var.base_cidr_block, 8, count.index + 10)
  availability_zone       = join("", ["${var.region}", "${var.availability_zones[count.index]}"])
  map_public_ip_on_launch = false

  tags = {
    "Name"      = "${var.env_prefix}_private_subnet_${var.availability_zones[count.index]}"
    "Terraform" = true
  }
}

resource "aws_internet_gateway" "ed-igw" {
  vpc_id = aws_vpc.test_env_vpc.id

  tags = {
    "Name"      = "${var.env_prefix}_vpc_igw"
    "Terraform" = true
  }
}

resource "aws_eip" "ed-ngw-eip" {
  vpc = true
}

resource "aws_nat_gateway" "ed-ngw" {
  allocation_id = aws_eip.ed-ngw-eip.id

  //Put the NGW in the first public subnet
  subnet_id = aws_subnet.test_env_public_subnet[0].id

  tags = {
    "Name"      = "${var.env_prefix}_vpc_ngw"
    "Terraform" = true
  }

  //To ensure proper ordering, it is recommended to add an explicit dependency
  //on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.ed-igw]
}


resource "aws_route_table" "test_env_public_subnet_rt" {
  vpc_id = aws_vpc.test_env_vpc.id
  tags = {
    "Name"      = "${var.env_prefix}_public_subnet_rt"
    "Terraform" = true
  }
}

resource "aws_route_table" "test_env_private_subnet_rt" {
  vpc_id = aws_vpc.test_env_vpc.id
  tags = {
    "Name"      = "${var.env_prefix}_private_subnet_rt"
    "Terraform" = true
  }
}

resource "aws_route" "test_env_public_subnet_route" {
  route_table_id         = aws_route_table.test_env_public_subnet_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.ed-igw.id
}

resource "aws_route_table_association" "edr_public_route_assoc" {
  count          = 2
  subnet_id      = aws_subnet.test_env_public_subnet[count.index].id
  route_table_id = aws_route_table.test_env_public_subnet_rt.id
}

resource "aws_route" "test_env_private_subnet_route" {
  route_table_id         = aws_route_table.test_env_private_subnet_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_nat_gateway.ed-ngw.id
}

resource "aws_route_table_association" "edr_private_route_assoc" {
  count          = 2
  subnet_id      = aws_subnet.test_env_private_subnet[count.index].id
  route_table_id = aws_route_table.test_env_private_subnet_rt.id
}
