# VPC and Service Endpoint
resource "aws_vpc" "vpc" {
  cidr_block = var.cidr

  tags = {
    Name = var.name
  }
}

resource "aws_vpc_endpoint" "transfer" {
  vpc_id = aws_vpc.vpc.id
  service_name = "com.amazonaws.${data.aws_region.current.name}.transfer.server"
  vpc_endpoint_type = "Interface"
}

# VPC Subnet
resource "aws_subnet" "public" {
  cidr_block = var.subnet_cidr
  vpc_id = aws_vpc.vpc.id
  availability_zone = var.az

  tags = {
    Name = var.name
  }
}

# Internet Gateway w/ EIP
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = var.name
  }
}

resource "aws_eip" "igw_eip" {
  vpc = true

  tags = {
    Name = var.name
  }
}

resource "aws_route_table" "transfer" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.name}-transfer"
  }
}

# This route will not be created if enable_internet_gateway is set to false
resource "aws_route" "inet_gwy" {
  route_table_id = aws_route_table.transfer.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "transfer_association" {
  subnet_id = aws_subnet.public.id
  route_table_id = aws_route_table.transfer.id
}