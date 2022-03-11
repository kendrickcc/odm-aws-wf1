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
# Comment out this section if testing locally and do not want to use the S3 bucket
# Remove the leading # to disable the backend
#-------------------------------
#/* Begin comment block - only need to remove the leading "#"
terraform {
  backend "s3" {
    key    = "terraform.tfstate"
    region = "us-east-1"
  }
}
#End of comment block */
#-------------------------------
# VPC
#-------------------------------
resource "aws_vpc" "odm" {
  cidr_block = var.vpc_cidr_block
}
resource "aws_subnet" "odm_public_subnet" {
  vpc_id            = aws_vpc.odm.id
  cidr_block        = var.public_subnet
  availability_zone = var.avail_zone
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
   /* Add "#" to the beginning of this line to open port 22 if needed.
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  } # */
  ingress {
    description = "WebODM"
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "ClusterODM"
    from_port   = 8001
    to_port     = 8001
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  /* only if direct access is needed to nodes
  ingress {
    description = "nodeODM"
    from_port = 3000
    to_port = 3000
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # */
  ingress {
    description = "internal"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.public_subnet]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
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
#-------------------------------
# Get cloud-init template file
#-------------------------------
data "template_file" "webodm" {
  template = file("webodm.tpl")
  vars = {
    ssh_key = var.pub_key_data
  }
}
data "template_file" "nodeodm" {
  template = file("nodeodm.tpl")
  vars = {
    ssh_key = var.pub_key_data
  }
}
#-------------------------------
# EC2 instance WebODM
#-------------------------------
resource "aws_instance" "webodm" {
  count                       = var.webodm_count
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = lookup(var.instance_type, var.type_selector)
  key_name                    = var.pub_key
  subnet_id                   = aws_subnet.odm_public_subnet.id
  vpc_security_group_ids      = [aws_security_group.odm.id]
  associate_public_ip_address = true
  user_data                   = data.template_file.webodm.rendered
  root_block_device {
    volume_size = var.rootBlockSize
  }
}
#-------------------------------
# EC2 instance nodeodm
#-------------------------------
resource "aws_instance" "nodeodm" {
  count                       = var.nodeodm_count
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = lookup(var.instance_type, var.type_selector)
  key_name                    = var.pub_key
  subnet_id                   = aws_subnet.odm_public_subnet.id
  vpc_security_group_ids      = [aws_security_group.odm.id]
  associate_public_ip_address = true
  user_data                   = data.template_file.nodeodm.rendered
  root_block_device {
    volume_size = var.rootBlockSize
  }
}