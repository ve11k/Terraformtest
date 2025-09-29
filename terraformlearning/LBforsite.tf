#resource "aws_s3_bucket" "terraform_bucket" {
#bucket = "buckettest2875"
#lifecycle {
#   prevent_destroy = true
# }

#tags = {
#   Name        = "Terraform test bucket"
#   Environment = "Dev"
# }
#}


/*resource "aws_security_group" "albforsite_sg" {
  name   = "alb_sg"
  vpc_id = aws_vpc.test_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = var.protocol
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb" "lbforsite" {
  name               = "lbforsite"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.albforsite_sg.id]
  subnets            = [aws_subnet.test_pub_1.id, aws_subnet.test_pub_2.id]

  tags = {
    Name = "AppLoadBalancer"
  }
}
resource "aws_lb_target_group" "forsite-tg" {
  name     = "forsite-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.test_vpc.id

  health_check {
    path = "/"
  }
}
resource "aws_lb_target_group_attachment" "private_attach_tg" {
  target_group_arn = aws_lb_target_group.forsite-tg.arn
  target_id        = aws_instance.web_test_private.id
  port             = 80
}
resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.lbforsite.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.forsite-tg.arn
  }
}*/