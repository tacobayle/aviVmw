# --- VPC section ---

# VPC

resource "aws_vpc" "vpc" {
  count = length(var.cidrVpc)
  cidr_block = element(var.cidrVpc, count.index)
  enable_dns_hostnames = true
  enable_dns_support = true
}

# Internet gateway

resource "aws_internet_gateway" "internetGateway" {
  count = length(var.cidrVpc)
  vpc_id = aws_vpc.vpc[count.index].id
}

# Route table

resource "aws_route_table" "rt" {
  count = length(var.cidrVpc)
  vpc_id = aws_vpc.vpc[count.index].id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internetGateway[count.index].id
  }
}

# Subnets

data "aws_availability_zones" "available" {
  state = "available"
}

output "az" {
  value = data.aws_availability_zones.available.names
}

resource "aws_subnet" "subnetAviVs" {
  count = length(var.cidrSubnetAviVs)
  vpc_id = aws_vpc.vpc[0].id
  cidr_block = element(var.cidrSubnetAviVs, count.index)
  map_public_ip_on_launch = true
  availability_zone = data.aws_availability_zones.available.names[count.index]
}

resource "aws_subnet" "subnetBackend" {
  count = length(var.cidrSubnetBackend)
  vpc_id = aws_vpc.vpc[0].id
  cidr_block = element(var.cidrSubnetBackend, count.index)
  map_public_ip_on_launch = false
  availability_zone = data.aws_availability_zones.available.names[count.index]
}

resource "aws_subnet" "subnetAviSeMgt" {
  count = length(var.cidrSubnetAviSeMgt)
  vpc_id = aws_vpc.vpc[0].id
  cidr_block = element(var.cidrSubnetAviSeMgt, count.index)
  map_public_ip_on_launch = false
  availability_zone = data.aws_availability_zones.available.names[count.index]
}

# Elastic IP for NAT natGw

resource "aws_eip" "eipForNatGw" {
  vpc = true
  depends_on = [aws_internet_gateway.internetGateway]
}

# NAT gateway

resource "aws_nat_gateway" "natGw" {
  allocation_id = aws_eip.eipForNatGw.id
  subnet_id     = aws_subnet.subnetBackend[0].id
}

resource "aws_route_table" "rtPrivate" {
  count = length(var.cidrVpc)
  vpc_id = aws_vpc.vpc[count.index].id
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.natGw.id
  }
}

# Subnet associations


resource "aws_route_table_association" "subnetAssociationBackend" {
  count = length(var.cidrSubnetBackend)
  subnet_id = aws_subnet.subnetBackend[count.index].id
  route_table_id =aws_route_table.rtPrivate[0].id
}

resource "aws_route_table_association" "subnetAssociationAviSeMgt" {
  count = length(var.cidrSubnetAviSeMgt)
  subnet_id = aws_subnet.subnetAviSeMgt[count.index].id
  route_table_id = aws_route_table.rt[0].id
}

resource "aws_route_table_association" "subnetAssociationAviVs" {
  count = length(var.cidrSubnetAviVs)
  subnet_id = aws_subnet.subnetAviVs[count.index].id
  route_table_id = aws_route_table.rt[0].id
}
