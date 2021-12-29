resource "aws_vpc" "custom_vpc" {
  cidr_block = var.networking.cidr_block

  tags = {
    Name = var.networking.vpc_name
  }
}

# PUBLIC SUBNETS
resource "aws_subnet" "public_subnets" {
  count                   = var.networking.public_subnets == null ? 0 : length(var.networking.public_subnets)
  vpc_id                  = aws_vpc.custom_vpc.id
  cidr_block              = var.networking.public_subnets[count.index]
  availability_zone       = var.networking.azs[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "public_subnet-${count.index}"
  }
}

# PRIVATE SUBNETS
resource "aws_subnet" "private_subnets" {
  count                   = var.networking.private_subnets == null ? 0 : length(var.networking.private_subnets)
  vpc_id                  = aws_vpc.custom_vpc.id
  cidr_block              = var.networking.private_subnets[count.index]
  availability_zone       = var.networking.azs[count.index]
  map_public_ip_on_launch = false

  tags = {
    Name = "private_subnet-${count.index}"
  }
}

# INTERNET GATEWAY
resource "aws_internet_gateway" "i_gateway" {
  vpc_id = aws_vpc.custom_vpc.id

  tags = {
    Name = "i_gateway"
  }
}

# EIPs
resource "aws_eip" "elastic_ip" {
  count      = var.networking.private_subnets == null || var.networking.nat_gateways == false ? 0 : length(var.networking.private_subnets)
  vpc        = true
  depends_on = [aws_internet_gateway.i_gateway]

  tags = {
    Name = "eip-${count.index}"
  }
}

# NAT GATEWAYS
resource "aws_nat_gateway" "nats" {
  count             = var.networking.private_subnets == null || var.networking.nat_gateways == false ? 0 : length(var.networking.private_subnets)
  subnet_id         = aws_subnet.public_subnets[count.index].id
  connectivity_type = "public"
  allocation_id     = aws_eip.elastic_ip[count.index].id
  depends_on        = [aws_internet_gateway.i_gateway]
}

# PUBLIC ROUTE TABLE
resource "aws_route_table" "public_table" {
  vpc_id = aws_vpc.custom_vpc.id
}

resource "aws_route" "public_routes" {
  route_table_id         = aws_route_table.public_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.i_gateway.id
}

resource "aws_route_table_association" "assoc_public_routes" {
  count          = length(var.networking.public_subnets)
  subnet_id      = aws_subnet.public_subnets[count.index].id
  route_table_id = aws_route_table.public_table.id
}

# PRIVATE ROUTE TABLES
resource "aws_route_table" "private_tables" {
  count  = length(var.networking.azs)
  vpc_id = aws_vpc.custom_vpc.id
}

resource "aws_route" "private_routes" {
  count                  = length(var.networking.private_subnets)
  route_table_id         = aws_route_table.private_tables[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nats[count.index].id
}

resource "aws_route_table_association" "assoc_private_routes" {
  count          = length(var.networking.private_subnets)
  subnet_id      = aws_subnet.private_subnets[count.index].id
  route_table_id = aws_route_table.private_tables[count.index].id
}

# SECURITY GROUPS
resource "aws_security_group" "sec_groups" {
  for_each    = { for sec in var.security_groups : sec.name => sec }
  name        = each.value.name
  description = each.value.description
  vpc_id      = aws_vpc.custom_vpc.id

  dynamic "ingress" {
    for_each = { for ingress in var.security_groups : ingress.ingress.from_port => ingress }
    content {
      description      = ingress.value.ingress.description
      from_port        = ingress.value.ingress.from_port
      to_port          = ingress.value.ingress.to_port
      protocol         = ingress.value.ingress.protocol
      cidr_blocks      = ingress.value.ingress.cidr_blocks
      ipv6_cidr_blocks = ingress.value.ingress.ipv6_cidr_blocks
    }
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}
