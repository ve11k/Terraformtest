resource "aws_security_group" "test_sg" {
  name        = "test_sg"
  vpc_id      = aws_vpc.test_vpc.id
  description = "Allow TLS inbound traffic and all outbound traffic"

  ingress {
    description = "SSH from 46.151.250.23"
    from_port   = 22
    to_port     = 22
    protocol    = var.protocol
    cidr_blocks = ["46.151.253.77/32"]
  }

  ingress {
    description = "HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = var.protocol
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all IPv4"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all IPv6"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "test_sg"
  }
}

resource "aws_security_group" "test_private_sg" {
  name        = "test_private_sg"
  vpc_id      = aws_vpc.test_vpc.id
  description = "Allow TLS traffic from vm1"

  ingress {
    description = "SSH from test_sg"
    from_port   = 22
    to_port     = 22
    protocol    = var.protocol
    security_groups = [aws_security_group.test_sg.id]
  }

  ingress {
    description = "HTTP from ALB SG"
    from_port   = 80
    to_port     = 80
    protocol    = var.protocol
    security_groups = [aws_security_group.albforsite_sg.id]
  }

  egress {
    description = "Allow all IPv4"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all IPv6"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "test_private_sg"
  }
}

