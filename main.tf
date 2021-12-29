module "aws_vpc" {
  source          = "./modules/aws_vpc"
  networking      = var.networking
  security_groups = var.security_groups
}
