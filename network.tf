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
  count = var.webserver_count //For this example, we need 1 *public* subnet per instance

  vpc_id                  = aws_vpc.test_env_vpc.id
  cidr_block              = cidrsubnet(var.base_cidr_block, 8, count.index + 10)
  availability_zone       = join("", ["${var.region}", "${var.availability_zones[count.index]}"])
  map_public_ip_on_launch = true

  tags = {
    "Name"      = "${var.env_prefix}-public-subnet-${var.availability_zones[count.index]}"
    "Terraform" = true
  }
}

resource "aws_subnet" "test_env_private_subnet" {
  count = var.webserver_count //For this example, we need 1 *private* subnet per instance

  vpc_id                  = aws_vpc.test_env_vpc.id
  cidr_block              = cidrsubnet(var.base_cidr_block, 8, count.index + 100)
  availability_zone       = join("", ["${var.region}", "${var.availability_zones[count.index]}"])
  map_public_ip_on_launch = false

  tags = {
    "Name"      = "${var.env_prefix}-private-subnet-${var.availability_zones[count.index]}"
    "Terraform" = true
  }
}

resource "aws_internet_gateway" "test_igw" {
  vpc_id = aws_vpc.test_env_vpc.id

  tags = {
    "Name"      = "${var.env_prefix}-vpc-igw"
    "Terraform" = true
  }
}

resource "aws_eip" "test_ngw_eip" {
  vpc = true
}

resource "aws_nat_gateway" "test_ngw" {
  allocation_id = aws_eip.test_ngw_eip.id

  //Put the NGW in the first public subnet
  subnet_id = aws_subnet.test_env_public_subnet[0].id

  tags = {
    "Name"      = "${var.env_prefix}-vpc-ngw"
    "Terraform" = true
  }

  //To ensure proper ordering, it is recommended to add an explicit dependency
  //on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.test_igw]
}


resource "aws_route_table" "test_env_public_subnet_rt" {
  vpc_id = aws_vpc.test_env_vpc.id
  tags = {
    "Name"      = "${var.env_prefix}-public-subnet-rt"
    "Terraform" = true
  }
}

resource "aws_route_table" "test_env_private_subnet_rt" {
  vpc_id = aws_vpc.test_env_vpc.id
  tags = {
    "Name"      = "${var.env_prefix}-private-subnet-rt"
    "Terraform" = true
  }
}

resource "aws_route" "test_env_public_subnet_route" {
  route_table_id         = aws_route_table.test_env_public_subnet_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.test_igw.id
}

resource "aws_route_table_association" "testr_public_route_assoc" {
  count          = 2
  subnet_id      = aws_subnet.test_env_public_subnet[count.index].id
  route_table_id = aws_route_table.test_env_public_subnet_rt.id
}

resource "aws_route" "test_env_private_subnet_route" {
  route_table_id         = aws_route_table.test_env_private_subnet_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_nat_gateway.test_ngw.id
}

resource "aws_route_table_association" "test_private_route_assoc" {
  count          = 2
  subnet_id      = aws_subnet.test_env_private_subnet[count.index].id
  route_table_id = aws_route_table.test_env_private_subnet_rt.id
}