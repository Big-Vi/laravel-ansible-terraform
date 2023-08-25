variable "subnet_ids" {
  type    = list(string)
  default = ["subnet-7bc7840d", "subnet-f60195af"]
}

variable "vpc_tag" {
  type    = string
  default = "Prod"
}

variable "key_name" {
  type    = string
  default = "2021-10" # EC2 key pair name
}

variable "my_ip" {
  type    = string
  default = "103.163.248.98/32" # Whitelist your IP in security group to connect to it.
}

variable "ec2_name" {
  type        = string
  default     = "laravel"
  description = "Laravel webapp"
}

variable "region" {
  description = "AWS region"
  default     = "ap-southeast-2"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "ami" {
  description = "ami id"
  type        = string
  default     = "ami-0310483fb2b488153"
}

# Mmanaged policy ARN
variable "managed_policy_arn_ssm" {
  default = "arn:aws:iam::aws:policy/AmazonSSMReadOnlyAccess"
}

variable "laravel_domain" {
  default = "example.com"
}

variable "aws_ec2_ssh_private_key" {
  default = "~/.ssh/id_rsa-aws"
}

