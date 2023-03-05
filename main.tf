terraform {
  required_version = "1.3.9"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>3.0"
    }
  }
}

variable "title" {
  type = string
}


provider "aws" {
  region = "ap-northeast-1"
}

resource "aws_vpc" "vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${var.title}-vpc"
  }
}

resource "aws_subnet" "public-subnet-1a" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone       = "ap-northeast-1a"
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.title}-public-subnet"
  }
}

# resource "aws_subnet" "private-subnet-1a" {
#   vpc_id     = aws_vpc.vpc.id
#   cidr_block = "10.0.2.0/24"
#   availability_zone       = "ap-northeast-1a"
#   map_public_ip_on_launch = false

#   tags = {
#     Name = "${var.title}-private-subnet"
#   }
# }

resource "aws_internet_gateway" "internet-gateway" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.title}-internet-gateway"
  }
}

resource "aws_route_table" "example" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet-gateway.id
    }

  tags = {
    Name = "example"
  }
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.public-subnet-1a.id
  route_table_id = aws_route_table.example.id
}