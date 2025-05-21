/*# __________ ELASTIC IP __________
resource "aws_eip" "nat_eip" {
  #vpc = true
   domain   = "vpc"
}


resource "aws_nat_gateway" "nat_test" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.test_pub_1.id     
  depends_on    = [aws_internet_gateway.test_IGW]
}

resource "aws_route_table" "private_rt_for_test" {
  vpc_id = aws_vpc.test_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_test.id
  }
}


resource "aws_route_table_association" "private_assoc_for_test" {
  subnet_id      = aws_subnet.test_priv_1.id
  route_table_id = aws_route_table.private_rt_for_test.id
}*/