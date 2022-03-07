variable "repo_name" {
  default = "odm-aws-wf1"
}
variable "repo_owner" {
  default = "kendrickcc"
}
variable "project" {
  default = "ODM 1600 S Hwy UU"
}
variable "pub_key" {
  description = "The public key generated using ssh-keygen and upload to EC2 Key Pairs. The key name must match."
  default     = "id_rsa_webodm"
}
variable "pub_key_data" {
  description = "The contents of the public key are stored in GitHub as a secret"
}
variable "aws_region" {
  description = "geographical location of infrastructure"
  type        = string
  default     = "us-east-1"
}
variable "avail_zone" {
  default = "us-east-1a"
}
variable "webodm_count" {
  description = "Number of WebODM instances"
  default     = 1
}
variable "nodeodm_count" {
  description = "Number of nodeODM instances"
  default     = 0
}
variable "rootBlockSize" {
  description = "root volume size in GiB"
  default     = "100"
}
variable "vpc_cidr_block" {
  description = "Main VPC CIDR Block"
  default     = "192.168.0.0/16"
}
variable "ip_webodm" {
  description = "The assigned IP address for WebODM server, from the public subnet"
  default     = "192.168.1.10"
}
variable "public_subnet" {
  default = "192.168.1.0/24"
}
variable "private_subnet" {
  default = "192.168.2.0/24"
}
variable "ami_selector" {
  description = "Ubuntu version to use. Bionic 18.04 LTS or Focal 20.04 LTS"
  default     = "bionic"
}
variable "ubuntu_image" {
  type = map(any)
  default = {
    bionic = "ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"
    focal  = "ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"
  }
}
variable "type_selector" {
  description = "Select the instance type size."
  #default     = "t3a-large"
  default = "m5a-4xlarge"
}
variable "instance_type" {
  description = "AWS instance types pulled February 2022. AMDs are a little cheaper to run."
  type        = map(string)
  default = {
    # t2
    t2-micro   = "t2.micro"   # Free tier eligible, 1 vCPUs, 1 GiB, 0.0116 USD per Hour
    t2-small   = "t2.small"   # 1 vCPUs, 2 GiB, 0.023 USD per Hour
    t2-medium  = "t2.medium"  # 2 vCPUs, 4 GiB, 0.0464 USD per Hour
    t2-large   = "t2.large"   # 2 vCPUs, 8 GiB, 0.0928 USD per Hour
    t2-xlarge  = "t2.xlarge"  # 4 vCPUs, 16 GiB, 0.1856 USD per Hour
    t2-2xlarge = "t2.2xlarge" # 8 vCPUs, 32 GiB, 0.3712 USD per Hour
    # t3
    t3-small   = "t3.small"   # 2 vCPUs, 2 GiB, 0.0208 USD per Hour
    t3-medium  = "t3.medium"  # 2 vCPUs, 4 GiB, 0.0416 USD per Hour
    t3-large   = "t3.large"   # 2 vCPUs, 8 GiB, 0.0832 USD per Hour
    t3-xlarge  = "t3.xlarge"  # 4 vCPUs, 16 GiB, 0.1664 USD per Hour
    t3-2xlarge = "t3.2xlarge" # 8 vCPUs, 32 GiB, 0.3328 USD per Hour
    # t3 AMD
    t3a-small   = "t3a.small"   # AMD 2 vCPUs, 2 GiB, 0.0188 USD per Hour
    t3a-medium  = "t3a.medium"  # AMD 2 vCPUs, 4 GiB, 0.0376 USD per Hour
    t3a-large   = "t3a.large"   # AMD 2 vCPUs, 8 GiB, 0.0752 USD per Hour
    t3a-xlarge  = "t3a.xlarge"  # AMD 4 vCPUs, 16 GiB, 0.1504 USD per Hour
    t3a-2xlarge = "t3a.2xlarge" # AMD 8 vCPUs, 32 GiB, 0.3008 USD per Hour
    # m5 AMD
    m5a-large    = "m5a.large"    # AMD 2 vCPUs, 8 GiB, 0.086 USD per Hour
    m5a-xlarge   = "m5a.xlarge"   # AMD 4 vCPUs, 16 GiB, 0.172 USD per Hour
    m5a-2xlarge  = "m5a.2xlarge"  # AMD 8 vCPUs, 32 GiB, 0.344 USD per Hour
    m5a-4xlarge  = "m5a.4xlarge"  # AMD 16 vCPUs, 64 GiB, 0.688 USD per Hour
    m5a-8xlarge  = "m5a.8xlarge"  # AMD 32 vCPUs, 128 GiB, 1.376 USD per Hour
    m5a-12xlarge = "m5a.12xlarge" # AMD 48 vCPUs, 192 GiB, 2.064 USD per Hour
    m5a-16xlarge = "m5a.16xlarge" # AMD 64 vCPUs, 256 GiB, 2.752 USD per Hour
    m5a-24xlarge = "m5a.24xlarge" # AMD 96 vCPUs, 384 GiB, 4.128 USD per Hour
    # m5 AMD D
    m5ad-large    = "m5ad.large"    # AMD 2 vCPUs, 8 GiB, 0.103 USD per Hour
    m5ad-xlarge   = "m5ad.xlarge"   # AMD 4 vCPUs, 16 GiB, 0.206 USD per Hour
    m5ad-2xlarge  = "m5ad.2xlarge"  # AMD 8 vCPUs, 32 GiB, 0.412 USD per Hour
    m5ad-4xlarge  = "m5ad.4xlarge"  # AMD 16 vCPUs, 64 GiB, 0.824 USD per Hour
    m5ad-8xlarge  = "m5ad.8xlarge"  # AMD 32 vCPUs, 128 GiB, 1.648 USD per Hour
    m5ad-12xlarge = "m5ad.12xlarge" # AMD 48 vCPUs, 192 GiB, 2.472 USD per Hour
    m5ad-16xlarge = "m5ad.16xlarge" # AMD 64 vCPUs, 256 GiB, 3.296 USD per Hour
    m5ad-24xlarge = "m5ad.24xlarge" # AMD 96 vCPUs, 384 GiB, 4.944 USD per Hour
  }
}