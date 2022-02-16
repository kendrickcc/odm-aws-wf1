variable "repo_name" {
  default = "odm-aws-wf1"
}
variable "repo_owner" {
  default = "kendrickcc"
}
variable "project" {
  default = "OpenDroneMap"
}
variable "pub_key" {
  default = "id_rsa_webodm"
}
variable "aws_region" {
  description = "geographical location of infrastructure"
  type        = string
  default     = "us-east-1"
}
variable "instance_type" {
  default = "t2.micro"
}
variable "vpc_cidr_block" {
  description = "Main VPC CIDR Block"
  default     = "192.168.0.0/16"
}