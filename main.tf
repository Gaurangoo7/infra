resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "infra-gw"
    terraform = "true"
  }
}

resource "aws_vpc" "main" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"
  enable_dns_support = true
  enable_dns_hostnames = true

  tags = {
    Name = "infra-vpc"
    terraform = "true"
  }
}

resource "aws_subnet" "public_subnet" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "infra-public-subnet"
    terraform = "true"
  }
}

resource "aws_route_table" "public_rt" { 
  vpc_id     = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
  tags = {
    Name = "infra-public-rt"
    terraform = "true"
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_subnet" "private_subnet" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.2.0/24"

  tags = {
    Name = "infra-private-subnet"
    terraform = "true"
  }
}

resource "aws_route_table" "private_rt" { 
  vpc_id     = aws_vpc.main.id
  tags = {
    Name = "infra-private-rt"
    terraform = "true"
  }
}
resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_subnet" "db_subnet" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.22.0/24"

  tags = {
    Name = "infra-db-subnet"
    terraform = "true"
  }
}
resource "aws_route_table" "db_rt" { 
  vpc_id     = aws_vpc.main.id
  tags = {
    Name = "infra-db-rt"
    terraform = "true"
  }
}
resource "aws_route_table_association" "db" {
  subnet_id      = aws_subnet.db_subnet.id
  route_table_id = aws_route_table.db_rt.id
}
resource "aws_eip" "nat" {
  domain   = "vpc"
}

resource "aws_nat_gateway" "gw" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public_subnet.id
}

resource "aws_route" "private" {
  route_table_id            = aws_route_table.private_rt.id
  destination_cidr_block    = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.gw.id
}
resource "aws_route" "db" {
  route_table_id            = aws_route_table.db_rt.id
  destination_cidr_block    = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.gw.id
}

# SG for RDS
resource "aws_security_group" "allow_rds" {
  name        = "allow_rds"
  description = "Allow RDS inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.main.id


  tags = {
    Name = "infra-gw"
    terraform = "true"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_rds_ipv4" {
  security_group_id = aws_security_group.allow_rds.id  
  cidr_ipv4        = var.cidr_list
  from_port         = var.rds_port
  ip_protocol       = "tcp"
  to_port           = var.rds_port
}

resource "aws_vpc_security_group_ingress_rule" "allow_rds1_ipv4" {
  security_group_id = aws_security_group.allow_rds.id  
  cidr_ipv4        = var.cidr_list1
  from_port         = var.rds_port
  ip_protocol       = "tcp"
  to_port           = var.rds_port
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.allow_rds.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

resource "aws_key_pair" "terraform" {
  key_name   = "terraform-key"
  public_key = file("C:\\Users\\rachi\\terraform.pub")
}

resource "aws_instance" "web" {
  count = 3
  ami           = "ami-0f58b397bc5c1f2e8"
  instance_type = "t2.micro"
  tags = {
    name = var.ec2_names[count.index]
  }
}