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

# -----------------
# CHAPTER2
# -----------------

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
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.title}-public-subnet"
  }
}

resource "aws_subnet" "private-subnet-1a" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = "10.0.2.0/24"
  availability_zone       = "ap-northeast-1a"
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.title}-private-subnet"
  }
}

resource "aws_internet_gateway" "internet-gateway" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.title}-internet-gateway"
  }
}

resource "aws_route_table" "route-table-public" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet-gateway.id
  }

  tags = {
    Name = "${var.title}-route-table-public"
  }
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.public-subnet-1a.id
  route_table_id = aws_route_table.route-table-public.id
}

# -----------------
# CHAPTER3
# -----------------

resource "aws_security_group" "web-security-group" {
  name        = "${var.title}-web-security-group"
  description = "security-group"
  vpc_id      = aws_vpc.vpc.id

  tags = {
    Name = "${var.title}-web-security-group"
  }
}

resource "aws_security_group_rule" "security-group-role-ingress-SSH" {
  type        = "ingress"
  description = "security-group-role-ingress-SSH"
  from_port   = 22
  to_port     = 22
  protocol    = "tcp"
  cidr_blocks = [
    "0.0.0.0/0"
  ]

  security_group_id = aws_security_group.web-security-group.id
}

resource "aws_security_group_rule" "security-group-role-ingress-HTTP" {
  type        = "ingress"
  description = "security-group-role-ingress-HTTP"
  from_port   = 80
  to_port     = 80
  protocol    = "tcp"
  cidr_blocks = [
    "0.0.0.0/0"
  ]

  security_group_id = aws_security_group.web-security-group.id
}

resource "aws_security_group_rule" "security-group-role-egress-all" {
  type        = "egress"
  description = "security-group-role-egress-all"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = [
    "0.0.0.0/0"
  ]

  security_group_id = aws_security_group.web-security-group.id
}


resource "aws_instance" "web" {
  ami                         = "ami-0329eac6c5240c99d"
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.public-subnet-1a.id
  associate_public_ip_address = true
  key_name                    = "key"
  vpc_security_group_ids = [ aws_security_group.web-security-group.id ]

  tags = {
    Name = "${var.title}-EC2-Web"
  }
}

resource "aws_eip" "elastic-ip" {
  instance = aws_instance.web.id
  vpc      = true
}

# -----------------
# CHAPTER6
# -----------------

resource "aws_security_group" "db-security-group" {
  name        = "${var.title}-db-security-group"
  description = "security-group"
  vpc_id      = aws_vpc.vpc.id

  tags = {
    Name = "${var.title}-db-security-group"
  }
}

resource "aws_security_group_rule" "db-security-group-role-ingress-SSH" {
  type        = "ingress"
  description = "security-group-role-ingress-SSH"
  from_port   = 22
  to_port     = 22
  protocol    = "tcp"
  cidr_blocks = [
    "0.0.0.0/0"
  ]

  security_group_id = aws_security_group.db-security-group.id
}

resource "aws_security_group_rule" "db-security-group-role-ingress-MYSQL" {
  type        = "ingress"
  description = "security-group-role-ingress-MYSQL"
  from_port   = 3306
  to_port     = 3306
  protocol    = "tcp"
  cidr_blocks = [
    "0.0.0.0/0"
  ]

  security_group_id = aws_security_group.db-security-group.id
}

resource "aws_security_group_rule" "db-security-group-role-ingress-ICMP" {
  type        = "ingress"
  description = "security-group-role-ingress-ICMP"
  from_port   = -1
  to_port     = -1
  protocol    = "icmp"
  cidr_blocks = [
    "0.0.0.0/0"
  ]

  security_group_id = aws_security_group.db-security-group.id
}

resource "aws_instance" "db" {
  ami                         = "ami-0329eac6c5240c99d"
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.private-subnet-1a.id
  associate_public_ip_address = false
  key_name                    = "key"
  vpc_security_group_ids = [ aws_security_group.db-security-group.id ]

  tags = {
    Name = "${var.title}-EC2-DB"
  }
}