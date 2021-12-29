module "aws_vpc" {
  source          = "./modules/aws-vpc"
  networking      = var.networking
}