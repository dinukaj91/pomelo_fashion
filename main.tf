resource "aws_vpc" "main" {
  cidr_block       = "10.101.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "pomelo_production_vpc"
  }
}
