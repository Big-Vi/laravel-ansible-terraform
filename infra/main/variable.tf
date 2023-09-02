variable "subnet_ids" {
  type    = list(string)
  default = ["<subnet-id-1>", "<subnet-id-2>"]
}

variable "vpc_tag" {
  type    = string
  default = "Prod"
}

variable "key_name" {
  type    = string
  default = "aws_ssk_key" # EC2 key pair name. Get it from EC2 console.
}

variable "my_ip" {
  type    = string
  default = "<ip-address>" # Whitelist your IP in security group to connect to it.
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
  default     = "<ami-id>"
}

# Mmanaged policy ARN
variable "managed_policy_arn_ssm" {
  default = "arn:aws:iam::aws:policy/AmazonSSMReadOnlyAccess"
}

variable "laravel_domain" {
  default = "example.com"
}

variable "aws_ec2_ssh_private_key" {
  default = "~/.ssh/aws_ssk_key.pem"
}

