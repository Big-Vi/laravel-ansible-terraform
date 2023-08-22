terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    ansible = {
      version = "~> 1.1.0"
      source  = "ansible/ansible"
    }
  }

  required_version = ">= 1.5.5"
}

provider "aws" {
  region = var.region
}

data "aws_vpc" "vpc_prod" {
  filter {
    name   = "tag:Name"
    values = [var.vpc_tag]
  }
}

resource "aws_security_group" "laravel_server_sg" {
  name        = "${var.ec2_name}-server_sg"
  vpc_id      = data.aws_vpc.vpc_prod.id
  description = "Laravel server security group"
  tags = {
    "Name" = "${var.ec2_name}-server_sg"
  }

  ingress = [
    {
      cidr_blocks      = ["0.0.0.0/0"]
      description      = "HTTP"
      from_port        = 80
      to_port          = 80
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "tcp"
      security_groups  = []
      self             = false
    },
    {
      cidr_blocks      = ["0.0.0.0/0"]
      description      = "HTTPS"
      from_port        = 443
      to_port          = 443
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "tcp"
      security_groups  = []
      self             = false
    },
    {
      description      = "SSH"
      from_port        = 22
      to_port          = 22
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "tcp"
      cidr_blocks      = [var.my_ip]
      security_groups  = []
      self             = false
    }
  ]

  egress = [{
    cidr_blocks      = ["0.0.0.0/0"]
    description      = ""
    from_port        = 0
    to_port          = 0
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    protocol         = "-1"
    security_groups  = []
    self             = false
  }]
}

data "aws_ssm_parameter" "db_password" {
  name = "laravel_DB_PASSWORD"
}
data "aws_ssm_parameter" "db_username" {
  name = "laravel_DB_USERNAME"
}
data "aws_ssm_parameter" "db_name" {
  name = "laravel_DB_DATABASE"
}

resource "aws_security_group" "rds" {
  name        = "${var.ec2_name}-rds_sg"
  vpc_id      = data.aws_vpc.vpc_prod.id
  description = "Laravel db security group"
  tags = {
    "Name" = "${var.ec2_name}-rds_sg"
  }

  ingress {
    from_port = 5432
    to_port   = 5432
    protocol  = "tcp"
    security_groups = [
      "${aws_security_group.laravel_server_sg.id}",
    ]
  }

  egress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_subnet_group" "laraveldb" {
  name       = "laraveldb"
  subnet_ids = [for subnet in var.subnet_ids : subnet]

  tags = {
    Name = "LaravelDB"
  }
}

resource "aws_db_parameter_group" "laraveldb" {
  name   = "laraveldb"
  family = "postgres14"

  parameter {
    name  = "log_connections"
    value = "1"
  }
}

resource "aws_db_instance" "laraveldb" {
  identifier             = "laraveldb"
  instance_class         = "db.t3.micro"
  allocated_storage      = 5
  engine                 = "postgres"
  engine_version         = "14.5"
  username               = data.aws_ssm_parameter.db_username.value
  db_name                = data.aws_ssm_parameter.db_name.value
  password               = data.aws_ssm_parameter.db_password.value
  db_subnet_group_name   = aws_db_subnet_group.laraveldb.name
  vpc_security_group_ids = [aws_security_group.rds.id]
  parameter_group_name   = aws_db_parameter_group.laraveldb.name
  publicly_accessible    = true
  skip_final_snapshot    = true
}

resource "aws_ssm_parameter" "db_endpoint" {
  name  = "laravel_DB_HOST"
  type  = "SecureString"
  value = aws_db_instance.laraveldb.endpoint
}

resource "aws_iam_role" "laravel_checkin_role" {
  name = "laravelCheckinEC2Role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_instance_profile" "laravel_checkin_instance_profile" {
  name = "laravelChecinEC2InstanceProfile"
  role = aws_iam_role.laravel_checkin_role.name
}

resource "aws_iam_role_policy_attachment" "laravel_checkin_policy_attachment" {
  policy_arn = var.managed_policy_arn_ssm
  role       = aws_iam_role.laravel_checkin_role.name
}

resource "aws_instance" "server" {
  ami                         = var.ami
  instance_type               = var.instance_type
  key_name                    = var.key_name
  associate_public_ip_address = true
  subnet_id                   = var.subnet_ids[0]
  iam_instance_profile        = aws_iam_instance_profile.laravel_checkin_instance_profile.name

  vpc_security_group_ids = [aws_security_group.laravel_server_sg.id]
  tags = {
    Name = "${var.ec2_name}-server"
  }
}

## Setting up sub domain and point to EC2 instance IP.
resource "aws_route53_record" "subdomain" {
  zone_id = var.laravel_zone_id
  name    = "test.ulearn.nz"
  type    = "A"

  ttl = "300"

  records = [aws_instance.server.public_ip]

  depends_on = [aws_instance.server]
}
resource "aws_route53_record" "subdomain_www" {
  zone_id = var.laravel_zone_id
  name    = "www.test.ulearn.nz"
  type    = "A"

  ttl = "300"

  records = [aws_instance.server.public_ip]

  depends_on = [aws_instance.server]
}

# Ansible host details
resource "ansible_host" "laravel-ansible-server" {
  name   = aws_instance.server.public_dns
  groups = ["nginx"]
  variables = {
    ansible_user                 = "ubuntu",
    ansible_ssh_private_key_file = "~/.ssh/id_rsa-uLearn",
    ansible_python_interpreter   = "/usr/bin/python3"
  }
}
