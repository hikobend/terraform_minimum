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
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "ap-northeast-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.title}-public-subnet-1a"
  }
}

resource "aws_subnet" "public-subnet-1c" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "ap-northeast-1c"
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.title}-public-subnet-1c"
  }
}

resource "aws_internet_gateway" "internet-gateway" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.title}-internet-gateway"
  }
}

resource "aws_default_route_table" "default-route-table" {
  default_route_table_id = aws_vpc.vpc.default_route_table_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet-gateway.id
  }

  tags = {
    Name = "${var.title}-default-route-table"
  }
}

resource "aws_route_table_association" "public-subnet-1a" {
  subnet_id      = aws_subnet.public-subnet-1a.id
  route_table_id = aws_default_route_table.default-route-table.id
}

resource "aws_route_table_association" "bpublic-subnet-1c" {
  subnet_id      = aws_subnet.public-subnet-1c.id
  route_table_id = aws_default_route_table.default-route-table.id
}

resource "aws_default_security_group" "application-security-group" {
  vpc_id = aws_vpc.vpc.id

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "All Trafic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.title}-default-security-group"
  }
}

resource "aws_instance" "web" {
  ami           = "ami-0ffac3e16de16665e"
  instance_type = "t2.micro"
  associate_public_ip_address = true
  availability_zone = "ap-northeast-1a"
  subnet_id = aws_subnet.public-subnet-1a.id
  
  

  tags = {
    Name = "${var.title}-EC2"
  }
}