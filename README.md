# AWS-VPC-terraform-module
Terraform module to deploy a AWS VPC

## USAGE
```
module "aws_vpc" {
    source          = "./modules/aws_vpc"
    networking      = var.networking
    security_groups = var.security_groups
}
```
