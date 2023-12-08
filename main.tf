provider "aws" {
    region = "ap-south-1"
    access_key = ""
    secret_key = ""
  
}
 variable "vpc-block" {}
 variable "env-variable" {}
 variable "availability_zone" {}
 variable "ami-id" {}
 variable "instance-type" {}
 variable "subnet1a-block" {}
 variable "subnet1b-block" {}
 variable "ssh-myip" {}
 variable "key-pair" {}
 variable "script-file" {}

 resource "aws_vpc" "myapp-vpc" {
    cidr_block = var.vpc-block
    tags = {
      Name = "${var.env-variable}-vpc"
    }
 }

 resource "aws_subnet" "myapp-subnet-1a" {
  vpc_id = aws_vpc.myapp-vpc.id
  availability_zone = var.availability_zone
  cidr_block =  var.subnet1a-block
  tags = {
      Name = "${var.env-variable}-subnet-1a"
    }
   
 }
 resource "aws_subnet" "myapp-subnet-1b" {
  vpc_id = aws_vpc.myapp-vpc.id
  availability_zone = var.availability_zone
  cidr_block =  var.subnet1b-block
  tags = {
      Name = "${var.env-variable}-subnet-1b"
    }
   
 }

 resource "aws_internet_gateway" "myapp-igw" {
    vpc_id = aws_vpc.myapp-vpc.id
    tags = {
      Name = "${var.env-variable}-igw"
    }
   
 }

 resource "aws_default_route_table" "myapp-rtb" {
  default_route_table_id = aws_vpc.myapp-vpc.default_route_table_id
  
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.myapp-igw.id
    
  }
  tags = {
      Name = "${var.env-variable}-rtb"
    }
   
 }
 resource "aws_default_security_group" "myapp-sg" {
    vpc_id = aws_vpc.myapp-vpc.id
    ingress {
      from_port = 22
      to_port = 22
      cidr_blocks =  [var.ssh-myip]
      protocol = "tcp"
    }
    ingress {
      from_port = 8080
      to_port = 8080
      cidr_blocks =  ["0.0.0.0/0"]
      protocol = "tcp"
    }
    egress {
      from_port = 0
      to_port = 0
      cidr_blocks =  ["0.0.0.0/0"]
      protocol = "-1"
      
    }
    tags = {
      Name = "${var.env-variable}-sg"
    }
 }

resource "aws_instance" "myapp-ec2" {
  ami = var.ami-id
  instance_type = var.instance-type
  subnet_id = aws_subnet.myapp-subnet-1a.id
  vpc_security_group_ids = [aws_default_security_group.myapp-sg.id]
  key_name = var.key-pair
  associate_public_ip_address = true
  user_data = file("entry-point.sh")
  tags = {
      Name = "${var.env-variable}-ec2"
    }
  
}

output "ec2-instance-ip" {
  value = aws_instance.myapp-ec2.public_ip
  
}
 
