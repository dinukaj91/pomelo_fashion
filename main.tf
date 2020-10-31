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
  route_table_id = aws_route_table.pomelo_production_private_subnet_route_table.id
}

# AWS Key Pair
resource "aws_key_pair" "pomelo_main_key_pair" {
  key_name   = "main_key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDBJEcdA3PaPfuBF4UEVg3NLZuo1rJv9IU6YauVKjCtAqrSdW3K5H79D0Dk3FNuoG249MrFsJsJdUM4iacADp+bnG57Ot105AyJyv48Dl/P/IRwRc3haZgyeCvfeOvOk7g2BePl09ob02zLni1nVyH3IUVpSy13bH+QEvQzbJW73OTvh1NfZ0iRk5Iv5tx9vLIMavRu9aNmDcwm82dwjkkreuEAuJM4SUbVRxKyZZ5eSxr24asBWWirE38AV9X7YKPV24li9111hzHBkc5G8JTbXOmw/Qud24OyYAW0Tbn0FE2cDtFeYNotcNvXJLgZSIXJfrPMwGIo27h7ij3InddjDa++Dvqk4/MGf/2sXLf1hKy5IXH5G8WngH7y5bahJV395TAB3snk7xB/1wkNqlXAkRcVw+277xWioWrQBgXH2jXhrZ8nTLgTlbFWP76+nEpw4HB1IhyhE9KjfKmqACerX5Xke3LCl7Y+gU0OBYOtI5k9IjMeKB1WdKLbFDhEGd8= root@Dinukajcom"
}

#Configure ec2 Instance and security groups


resource "aws_security_group" "pomelo_production_generic_firewall" {
  name        = "pomelo_production_generic_firewall"
  description = "Generic Firewall Rules"
  vpc_id      = aws_vpc.pomelo_production_vpc.id

  ingress {
    description = "web traffic"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = "0.0.0.0/0"
  }
  ingress {
    description = "web traffic"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = "0.0.0.0/0"
  }
  ingress {
    description = "ssh traffic"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = "0.0.0.0/0"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "pomelo_production_website" {
  ami           = "ami-06e54d05255faf8f6"
  instance_type = "t3.micro"
  key_name = aws_key_pair.pomelo_main_key_pair.id
  subnet_id = aws_subnet.pomelo_production_public_subnet_1.id

  vpc_security_group_ids = [aws_security_group.pomelo_production_generic_firewall.id]

  tags = {
    Name = "pomelo_production_website"
    Application = "website"
    Environment = "production"
  }
}

resource "aws_eip" "pomelo_production_website_eip" {
  vpc = true
}

resource "aws_eip_association" "pomelo_production_website_eip_assoc" {
  instance_id   = aws_instance.pomelo_production_website.id
  allocation_id = aws_eip.pomelo_production_website_eip.id
}
