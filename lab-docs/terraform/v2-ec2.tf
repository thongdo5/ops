provider "aws" {
  region = "ap-southeast-2"
}

resource "aws_instance" "ei-server" {
  ami           = "ami-0d02292614a3b0df1"
  instance_type = "t2.micro"
  key_name      = "ei-server"
  # security_groups = ["ei-sg"]
  vpc_security_group_ids = [aws_security_group.ei-sg.id]
  subnet_id              = aws_subnet.ei-apple-public-subnet.id
  for_each               = toset(["jenkins-master", "build-slave", "ansible"])
  tags = {
    Name = "${each.key}"
  }
}

resource "aws_security_group" "ei-sg" {
  name        = "ei-sg"
  description = "SSH access"
  vpc_id      = aws_vpc.ei-vpc.id

  ingress {
    description = "SSH access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Jenkins port"
    from_port   = 8080
    to_port     = 8080
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

resource "aws_vpc" "ei-vpc" {
  cidr_block = "10.1.0.0/16"
  tags = {
    Name = "ei-vpc"
  }
}

resource "aws_subnet" "ei-apple-public-subnet" {
  vpc_id                  = aws_vpc.ei-vpc.id
  cidr_block              = "10.1.1.0/24"
  map_public_ip_on_launch = "true"
  availability_zone       = "ap-southeast-2a"
  tags = {
    Name = "ei-apple-public-subnet"
  }
}

resource "aws_subnet" "ei-melon-public-subnet" {
  vpc_id                  = aws_vpc.ei-vpc.id
  cidr_block              = "10.1.2.0/24"
  map_public_ip_on_launch = "true"
  availability_zone       = "ap-southeast-2b"
  tags = {
    Name = "ei-melon-public-subnet"
  }
}

resource "aws_internet_gateway" "ei-igw" {
  vpc_id = aws_vpc.ei-vpc.id
  tags = {
    Name = "ei-igw"
  }
}

resource "aws_route_table" "ei-public-rt" {
  vpc_id = aws_vpc.ei-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ei-igw.id
  }
}

resource "aws_route_table_association" "ei-apple-rta-public-subnet" {
  subnet_id      = aws_subnet.ei-apple-public-subnet.id
  route_table_id = aws_route_table.ei-public-rt.id
}

resource "aws_route_table_association" "ei-melon-rta-public-subnet" {
  subnet_id      = aws_subnet.ei-melon-public-subnet.id
  route_table_id = aws_route_table.ei-public-rt.id
}
