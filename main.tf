module "aws_vpc" {
  source          = "./modules/aws-vpc"
  networking      = var.networking
  security_groups = var.security_groups
}