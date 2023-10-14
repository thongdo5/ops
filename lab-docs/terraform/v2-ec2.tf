provider "aws" {
  region = "ap-southeast-2"
}

resource "aws_instance" "demo-server" {
  ami             = "ami-00b89387e88d35b2b"
  instance_type   = "t2.micro"
  key_name        = "demo-server"
  security_groups = ["demo-sg"]
}

resource "aws_security_group" "demo-sg" {
  name        = "demo-sg"
  description = "SSH access"

  ingress {
    description = "SSH access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "ssh-pro"
  }
}
