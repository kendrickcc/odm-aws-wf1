#-------------------------------
# AWS Provider
#-------------------------------
provider "aws" {
  region = var.aws_region
  default_tags {
    tags = {
      Name    = var.repo_name # Important to use capital "N" for Name as this will automatically display in the consoles default tag
      Owner   = var.repo_owner
      Project = var.project
    }
  }
}
#-------------------------------
# S3 Remote State
#-------------------------------
terraform {
  backend "s3" {
    bucket         = "s3-22020215"
    key            = "terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "tbl-22020215"
  }
}
#-------------------------------
# VPC
#-------------------------------
resource "aws_vpc" "odm" {
  cidr_block = var.vpc_cidr_block
}
resource "aws_subnet" "odm_public_subnet" {
  vpc_id            = aws_vpc.odm.id
  cidr_block        = "192.168.1.0/24"
  availability_zone = "us-east-1a"
}
resource "aws_subnet" "odm_private_subnet" {
  vpc_id            = aws_vpc.odm.id
  cidr_block        = "192.168.2.0/24"
  availability_zone = "us-east-1a"
}
#-------------------------------
# Internet Gateway
#-------------------------------
resource "aws_internet_gateway" "odm" {
  vpc_id = aws_vpc.odm.id
}
#-------------------------------
# Route Tables
#-------------------------------
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.odm.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.odm.id
  }
  route {
    ipv6_cidr_block = "::/0"
    gateway_id      = aws_internet_gateway.odm.id
  }
}
resource "aws_route_table_association" "public_1_rt_a" {
  subnet_id      = aws_subnet.odm_public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}
#-------------------------------
# Security Group
#-------------------------------
resource "aws_security_group" "odm" {
  name   = "SSH and ODM"
  vpc_id = aws_vpc.odm.id
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  /*
  ingress {
    description = "NodeODM"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  */
  ingress {
    description = "WebODM"
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  /*
  ingress {
    description = "ClusterODM"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  */
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}
#-------------------------------
# EC2 instance
#-------------------------------
#-------------------------------
# AMI reference
#-------------------------------
data "aws_ami" "ubuntu" {
  most_recent = true
  filter {
    name   = "name"
    values = [lookup(var.ubuntu_image, var.ami_selector)]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["099720109477"] # Canonical
}
data "template_file" "user_data" {
  template = file("odmSetup.yaml")
}
resource "aws_instance" "webodm" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = lookup(var.instance_type, var.type_selector)
  key_name                    = var.pub_key
  subnet_id                   = aws_subnet.odm_public_subnet.id
  private_ip                  = var.ip_webodm
  vpc_security_group_ids      = [aws_security_group.odm.id]
  associate_public_ip_address = true
  user_data                   = data.template_file.user_data.rendered
  root_block_device {
    volume_size = var.rootBlockSize
  }
}