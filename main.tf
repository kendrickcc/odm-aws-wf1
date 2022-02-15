terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }
  required_version = ">= 0.14.9"

  backend "s3" {
    bucket         = "s3-22020215"
    key            = "terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "tbl-22020215"
  }
}
provider "aws" {
  profile = "default"
  region  = "us-east-1"
}
data "http" "icanhazip" {
  url = "http://icanhazip.com"
}
data "template_file" "user_data" {
  template = file("odmSetup.yaml")
}
resource "aws_instance" "app_server" {
  ami                    = "ami-08bbc835fa43c979b"
  instance_type          = "t2.micro"
  key_name               = var.pub_key
  vpc_security_group_ids = ["${aws_security_group.allow_traffic.id}"]
  user_data              = data.template_file.user_data.rendered

}
resource "aws_security_group" "allow_traffic" {
  name        = "allow_traffic"
  description = "Allow all traffic"
  /*
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${chomp(data.http.icanhazip.body)}/32"]
  }
*/
  ingress {
    description = "WebODM"
    from_port   = 8000
    to_port     = 8000
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
output "WebODM_provisioned" {
  value = "http://${aws_instance.app_server.public_ip}:8000"
}
output "SSH_access" {
  value = "ssh -q -o UserKnownHostsFile=/dev/null -o StrictHostKeyCheck=no -i ${var.pvt_key} ubuntu@${aws_instance.app_server.public_ip}"
}