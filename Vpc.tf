resource "aws_vpc" "test_vpc" {
  cidr_block           = "10.0.0.0/16"
  instance_tenancy     = "default"
  enable_dns_support   = "true"
  enable_dns_hostnames = "true"
  tags = {
    Name = "test_vpc"
  }
}

resource "aws_subnet" "test_pub_1" {
  vpc_id                  = aws_vpc.test_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = "true"
  availability_zone       = "us-east-1a"
  tags = {
    Name = "test_pub_1"
  }
}

resource "aws_subnet" "test_pub_2" {
  vpc_id                  = aws_vpc.test_vpc.id
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = "true"
  availability_zone       = "us-east-1b"
  tags = {
    Name = "test_pub_2"
  }
}

resource "aws_subnet" "test_priv_1" {
  vpc_id                  = aws_vpc.test_vpc.id
  cidr_block              = "10.0.4.0/24"
  map_public_ip_on_launch = "true"
  availability_zone       = "us-east-1a"
  tags = {
    Name = "test_priv_1"
  }
}

resource "aws_subnet" "test_priv_2" {
  vpc_id                  = aws_vpc.test_vpc.id
  cidr_block              = "10.0.5.0/24"
  map_public_ip_on_launch = "true"
  availability_zone       = "us-east-1b"
  tags = {
    Name = "test_priv_2"
  }
}

resource "aws_internet_gateway" "test_IGW" {
  vpc_id = aws_vpc.test_vpc.id
  tags = {
    Name = "test_IGW"
  }
}

resource "aws_route_table" "test_pub_RT" {
  vpc_id = aws_vpc.test_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.test_IGW.id
  }

  tags = {
    Name = "test_pub_RT"
  }
}

resource "aws_route_table_association" "test_pub_1_a" {
  subnet_id      = aws_subnet.test_pub_1.id
  route_table_id = aws_route_table.test_pub_RT.id
}

resource "aws_route_table_association" "test_pub_2_a" {
  subnet_id      = aws_subnet.test_pub_2.id
  route_table_id = aws_route_table.test_pub_RT.id
}
