# Specify the provider and access details
provider "aws" {
  region = "us-west-2"
}

terraform {
  backend "s3" {
    bucket = "pomelo-production-terraform-state"
    key    = "terraform.tfstate"
    region = "us-west-2"
  }
}

# Creating VPC
resource "aws_vpc" "pomelo_production_vpc" {
  cidr_block       = "10.101.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "pomelo_production_vpc"
  }
}

# Creating Public Subnet
resource "aws_subnet" "pomelo_production_public_subnet_1" {
  vpc_id     = aws_vpc.pomelo_production_vpc.id
  cidr_block = "10.101.1.0/24"

  tags = {
    Name = "pomelo_production_public_subnet_1"
  }
}

# Creating Private Subnet
resource "aws_subnet" "pomelo_production_private_subnet_1" {
  vpc_id     = aws_vpc.pomelo_production_vpc.id
  cidr_block = "10.101.4.0/24"

  tags = {
    Name = "pomelo_production_private_subnet_1"
  }
}

# Creating Internet Gateway
resource "aws_internet_gateway" "pomelo_production_igw" {
  vpc_id = aws_vpc.pomelo_production_vpc.id

  tags = {
    Name = "pomelo_production_vpc_igw"
  }
}

# Creating Nat gateway
resource "aws_eip" "pomelo_production_ngw_eip" {
  vpc = true
}

resource "aws_nat_gateway" "pomelo_production_ngw" {
  allocation_id = aws_eip.pomelo_production_ngw_eip.id
  subnet_id     = aws_subnet.pomelo_production_public_subnet_1.id

  tags = {
    Name = "pomelo_production_ngw"
  }
}

# Default Route for Default Route Table
resource "aws_route" "pomelo_production_default_rt_default_route" {
  route_table_id         = aws_vpc.pomelo_production_vpc.default_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.pomelo_production_igw.id
}

resource "aws_route_table_association" "pomelo_production_public_subnet_1_associate_rt" {
  subnet_id      = aws_subnet.pomelo_production_public_subnet_1.id
  route_table_id = aws_vpc.pomelo_production_vpc.default_route_table_id
}

# New Route Table and Routes for Private Subnet
resource "aws_route_table" "pomelo_production_private_subnet_route_table" {
  vpc_id = aws_vpc.pomelo_production_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.pomelo_production_ngw.id
  }

  tags = {
    Name = "pomelo_production_vpc_private_subnet_route_table"
  }
}

resource "aws_route_table_association" "pomelo_production_private_subnet_1_associate_rt" {
  subnet_id      = aws_subnet.pomelo_production_private_subnet_1.id
  route_table_id = aws_vpc.pomelo_production_private_subnet_1.id
}