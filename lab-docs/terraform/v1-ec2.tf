provider "aws" {
  region = "ap-southeast-2"
}

resource "aws_instance" "demo-server" {
  ami           = "ami-00b89387e88d35b2b"
  instance_type = "t2.micro"
  key_name      = "demo-server"
}
