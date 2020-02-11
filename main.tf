resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr_block
  tags = map("Name", var.cluster_name)
}

resource "aws_route53_zone" "domain" {
  name = format("%s.%s",var.cluster_name,var.domain)
  vpc {
    vpc_id = aws_vpc.vpc.id
  }
}

data "aws_availability_zones" "available" {}

resource "aws_subnet" "subnets" {
  count = length(var.networks)
  availability_zone = var.networks[format("%s%s","n",count.index)].availability_zone
  cidr_block        = var.networks[format("%s%s","n",count.index)].cidr_block
  vpc_id            = aws_vpc.vpc.id
  tags = map("Name", var.cluster_name)
}

resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.vpc.id
}

resource "aws_route_table" "route_table" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = var.cluster_name
  }
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }
}

resource "aws_route_table_association" "route_table_association" {
  count = length(var.networks)
  subnet_id     = aws_subnet.subnets.*.id[count.index]
  route_table_id = aws_route_table.route_table.id
}

data "aws_subnet_ids" "subnet_ids" {
  depends_on = [
    aws_subnet.subnets
  ]
  vpc_id = aws_vpc.vpc.id
}