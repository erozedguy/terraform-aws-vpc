output "public_subnets_id" {
  value = module.aws_vpc.public_subnets_id
}

output "private_subnets_id" {
  value = module.aws_vpc.private_subnets_id
}

output "security_groups_id" {
  value = module.aws_vpc.security_groups_id 
}
