provider "aws" {
  profile = var.profile
  region  = var.region
}

resource "aws_vpc" "free_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  tags = {
    Name = "${local.resource_prefix.value}-free-vpc"
  }
}

resource "aws_subnet" "free_subnet" {
  vpc_id                  = aws_vpc.free_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "${var.region}a"
  map_public_ip_on_launch = true
  tags = {
    Name = "${local.resource_prefix.value}-free-subnet"
  }
}

resource "aws_internet_gateway" "free_igw" {
  vpc_id = aws_vpc.free_vpc.id
  tags = {
    Name = "${local.resource_prefix.value}-free-igw"
  }
}

resource "aws_route_table" "free_rtb" {
  vpc_id = aws_vpc.free_vpc.id
  tags = {
    Name = "${local.resource_prefix.value}-free-rtb"
  }
}

resource "aws_route" "free_public_internet" {
  route_table_id         = aws_route_table.free_rtb.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.free_igw.id
}

resource "aws_route_table_association" "free_rtbassoc" {
  subnet_id      = aws_subnet.free_subnet.id
  route_table_id = aws_route_table.free_rtb.id
}

resource "aws_security_group" "free_ssh" {
  name        = "${local.resource_prefix.value}-free-sg"
  description = "Allow SSH access"
  vpc_id      = aws_vpc.free_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "free_linux" {
  ami           = var.ami
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.free_subnet.id
  vpc_security_group_ids = [aws_security_group.free_ssh.id]

  tags = {
    Name = "${local.resource_prefix.value}-free-linux"
  }
}
