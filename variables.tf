variable "region" {
  description = "The AWS region in which the neo4j instances will be deployed"
}

variable "availability_zones" {
  description = "A list containing 2 AZs"
  type        = list(string)
}

variable "base_cidr_block" {
  description = "The base of the address range to be used by the VPC and corresponding Subnets"
}

variable "env_prefix" {
  description = "A prefix which is useful for tagging and naming"
}

variable "instance_count" {
  description = "The number of EC2 instances to be deployed"
  type = number
  default = 4
}