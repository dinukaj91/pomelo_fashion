# Specify the provider and access details
provider "aws" {
  region = "us-west-2"
}

resource "aws_vpc" "pomelo_production_vpc" {
  cidr_block       = "10.101.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "pomelo_production_vpc"
  }
}

resource "aws_subnet" "pomelo_production_public_subnet_1" {
  vpc_id     = aws_vpc.pomelo_production_vpc.id
  cidr_block = "10.101.1.0/24"

  tags = {
    Name = "pomelo_production_public_subnet_1"
  }
}

resource "aws_subnet" "pomelo_production_private_subnet_1" {
  vpc_id     = aws_vpc.pomelo_production_vpc.id
  cidr_block = "10.101.4.0/24"

  tags = {
    Name = "pomelo_production_private_subnet_1"
  }
}