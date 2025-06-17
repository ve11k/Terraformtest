resource "aws_security_group" "test_sg" {
  name        = "test_sg"
  vpc_id      = aws_vpc.test_vpc.id
  description = "Allow TLS inbound traffic and all outbound traffic"


  tags = {
    Name = "test_sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "test_sg_ipv4" {
  security_group_id = aws_security_group.test_sg.id
  cidr_ipv4         = "46.151.249.187/32"
  from_port         = 22
  ip_protocol       = var.protocol
  to_port           = 22
}

resource "aws_vpc_security_group_ingress_rule" "test_sg_http" {
  security_group_id = aws_security_group.test_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = var.protocol
  to_port           = 80
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.test_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}


resource "aws_vpc_security_group_egress_rule" "allowAllOutbound_ipv6" {
  security_group_id = aws_security_group.test_sg.id
  cidr_ipv6         = "::/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

resource "aws_security_group" "test_private_sg" {
  name        = "test_private_sg"
  vpc_id      = aws_vpc.test_vpc.id
  description = "Allow TLS traffic from vm1"


  tags = {
    Name = "test_private_sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "test_private_sg_ipv4" {
  security_group_id            = aws_security_group.test_private_sg.id
  referenced_security_group_id = aws_security_group.test_sg.id

  from_port   = 22
  ip_protocol = var.protocol
  to_port     = 22

}
resource "aws_vpc_security_group_ingress_rule" "test_private_sg_lb" {
  security_group_id            = aws_security_group.test_private_sg.id
  referenced_security_group_id = aws_security_group.albforsite_sg.id
  from_port                    = 80
  ip_protocol                  = var.protocol
  to_port                      = 80
}
resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4_private" {
  security_group_id = aws_security_group.test_private_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}
resource "aws_vpc_security_group_egress_rule" "allowAllOutbound_ipv6_private" {
  security_group_id = aws_security_group.test_private_sg.id
  cidr_ipv6         = "::/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

