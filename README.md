## Install terraform
https://developer.hashicorp.com/terraform/downloads

## Install aws cli
https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html

## Store aws credentials into config file(~/.aws/credentials)
```
[default]
aws_access_key_id = ""
aws_secret_access_key = "
```

Add your ip to `var.my_ip` in `variable.tf` file. This ip will be added to EC2 security group.

## Ansible
brew install ansible
ansible-galaxy collection install cloud.terraform

openssl rsa -in ~/.ssh/2021-10.pem -out id_rsa-laravel
chmod 600 ~/.ssh/id_rsa-laravel

## Terraform commands
terraform init
terraform fmt
terraform validate
terraform plan
terraform apply
terraform destroy

## Inventory & Playbook
ansible-inventory -i inventory.yml --graph --vars
ansible-playbook -i inventory.yml playbook.yml -vvv
