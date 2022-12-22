resource "aws_vpc" "ed_privlb_vpc" {
  cidr_block           = var.base_cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    "Name"      = "${var.env_prefix}_vpc"
    "Creator"   = var.creator
    "Terraform" = true
  }
}

resource "aws_subnet" "ed_privlb_public_subnet" {
  count = 2 //Three subnets are required (across 3 AZs)

  vpc_id = aws_vpc.ed_privlb_vpc.id
  cidr_block              = cidrsubnet(var.base_cidr_block, 8, count.index + 1)
  availability_zone       = join("", ["${var.region}", "${var.availability_zones[count.index]}"])
  map_public_ip_on_launch = false

  tags = {
    "Name"      = "${var.env_prefix}_public_subnet_${var.availability_zones[count.index]}"
    "Creator"   = var.creator
    "Terraform" = true
  }
}

resource "aws_subnet" "ed_privlb_private_subnet" {
  count = 2 //Three subnets are required (across 3 AZs)

  vpc_id = aws_vpc.ed_privlb_vpc.id
  cidr_block              = cidrsubnet(var.base_cidr_block, 8, count.index + 10)
  availability_zone       = join("", ["${var.region}", "${var.availability_zones[count.index]}"])
  map_public_ip_on_launch = false

  tags = {
    "Name"      = "${var.env_prefix}_private_subnet_${var.availability_zones[count.index]}"
    "Creator"   = var.creator
    "Terraform" = true
  }
}

resource "aws_internet_gateway" "ed-neo4j-igw" {
  vpc_id = aws_vpc.ed_privlb_vpc.id

  tags = {
    "Name"      = "${var.env_prefix}_vpc_igw"
    "Creator"   = var.creator
    "Terraform" = true
  }
}

resource "aws_route_table" "ed_neo4j_public_subnet_rt" {
  vpc_id = aws_vpc.ed_privlb_vpc.id
  tags = {
    "Name"      = "${var.env_prefix}-public-subnet-rt"
    "Creator"   = var.creator
    "Terraform" = true
  }
}

resource "aws_route_table" "ed_neo4j_private_subnet_rt" {
  vpc_id = aws_vpc.ed_privlb_vpc.id
  tags = {
    "Name"      = "${var.env_prefix}-private-subnet-rt"
    "Creator"   = var.creator
    "Terraform" = true
  }
}

/*


resource "aws_route" "ed_neo4j_public_subnet_route" {
  route_table_id         = aws_route_table.ed_neo4j_public_subnet_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.ed-neo4j-igw.id
}

resource "aws_route_table_association" "edr_neo4j_proxy_route_assoc" {
  subnet_id      = aws_subnet.ed_neo4j_public_subnet.id
  route_table_id = aws_route_table.ed_neo4j_public_subnet_rt.id
}

*/