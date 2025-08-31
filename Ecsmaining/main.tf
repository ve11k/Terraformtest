provider "aws" {
  region = var.region
}
resource "aws_vpc" "ecs_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "ecs-vpc"
  }
}

resource "aws_internet_gateway" "ecs_igw" {
  vpc_id = aws_vpc.ecs_vpc.id

  tags = {
    Name = "ecs-igw"
  }
}

resource "aws_subnet" "public1" {
  vpc_id                  = aws_vpc.ecs_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "ecs-public-1"
  }
}

resource "aws_subnet" "public2" {
  vpc_id                  = aws_vpc.ecs_vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "ecs-public-2"
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.ecs_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ecs_igw.id
  }

  tags = {
    Name = "ecs-public-rt"
  }
}

resource "aws_route_table_association" "public1_assoc" {
  subnet_id      = aws_subnet.public1.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public2_assoc" {
  subnet_id      = aws_subnet.public2.id
  route_table_id = aws_route_table.public_rt.id
}
resource "aws_security_group" "ecs_sg" {
  name        = "ecs-sg"
  description = "Allow HTTP"
  vpc_id      = aws_vpc.ecs_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["46.151.250.120/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "aws_ecs_cluster" "ecs_cluster" {
  name = "ecs-ec2-cluster"
}
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecsTaskExecutionRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

/*resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}*/
resource "aws_iam_role_policy_attachment" "ecs_instance_role_attach" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}
resource "aws_iam_instance_profile" "ecs_instance_profile" {
  name = "ecsInstanceProfile"
  role = aws_iam_role.ecs_task_execution_role.name
}
data "aws_ami" "ecs_ami" {
  owners      = ["amazon"]
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-ecs-hvm-*-x86_64-ebs"]
  }
}
data "aws_key_pair" "existing" {
  key_name = "test-key-ec" 
}

resource "aws_instance" "ecs_instance" {
  ami                         = data.aws_ami.ecs_ami.id
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.public1.id
  vpc_security_group_ids      = [aws_security_group.ecs_sg.id]
  associate_public_ip_address = true
  key_name                    = data.aws_key_pair.existing.key_name 
  iam_instance_profile        = aws_iam_instance_profile.ecs_instance_profile.name

  user_data = <<-EOF
              #!/bin/bash
              echo ECS_CLUSTER=${aws_ecs_cluster.ecs_cluster.name} >> /etc/ecs/ecs.configz
              systemctl enable --now ecs
              sleep 15
              sudo systemctl restart ecs
              EOF
              

  tags = {
    Name = "ecs-instance"
  }
}
resource "aws_cloudwatch_log_group" "ecs_logs" {
  name              = "/ecs/my-app"
  retention_in_days = 7
}

resource "aws_ecs_task_definition" "app_task" {
  family                   = "my-ecs-task"
  requires_compatibilities = ["EC2"]
  network_mode             = "bridge"
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name      = "app-container"
      image     = "ghcr.io/metal3d/xmrig:latest"
      essential = true
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.ecs_logs.name
          awslogs-region        = "us-east-1"
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])
}

resource "aws_ecs_service" "ecs_service" {
  name            = "my-service"
  cluster         = aws_ecs_cluster.ecs_cluster.id
  task_definition = aws_ecs_task_definition.app_task.arn
  desired_count   = 1
  launch_type     = "EC2"
}

terraform {
  backend "s3" {
    bucket         = "buckettest2875"
    key            = "env/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
  }
}