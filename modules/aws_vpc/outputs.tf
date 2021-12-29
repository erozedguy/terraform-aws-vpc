output "public_subnets_id" {
  value = [ aws_subnet.public_subnets[*].id]
}

output "private_subnets_id" {
  value = [ aws_subnet.private_subnets[*].id ]
}

output "security_groups_id" {
  value = [ for sec in var.security_groups : aws_security_group.sec_groups[sec.name].id ]
}
