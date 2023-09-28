# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}

terraform {
  backend "s3" {
    bucket         = "terraforms3state"
    key            = "terraform/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
 }
}

data "aws_ami" "al" {
  most_recent = true

  filter {
    name   = "name"
    values = ["al2023-ami-2023.1.20230912.0-kernel-6.1-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["137112412989"] # Canonical
}


resource "aws_instance" "web" {
  ami           = data.aws_ami.al.id
  instance_type = "t2.micro"
  vpc_security_group_ids = [ aws_security_group.allow_ssh_http.id ]
  key_name = "deployer-key"
  user_data = file("user_data.sh")
}

resource "aws_eip" "ec2_eip" {
  instance = aws_instance.web.id
}

data "aws_vpc" "vpc" {
}

resource "aws_security_group" "allow_ssh_http" {
  name        = "allow_ssh_http"
  description = "Allow inbound traffic"
  vpc_id      = data.aws_vpc.vpc.id

  ingress {
    description      = "SSH"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description      = "HTTP"
    from_port        = 8080
    to_port          = 8080
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_db_instance" "rds_instance" {
  allocated_storage      = 20
  db_name                = "mydb"
  engine                 = "mysql"
  engine_version         = "5.7"
  instance_class         = "db.t2.micro"
  username               = "wordpress_user"
  password               = "wordpress"
  parameter_group_name   = "default.mysql5.7"
  skip_final_snapshot    = true
  vpc_security_group_ids = [aws_security_group.allow_to_db.id]
}

resource "aws_security_group" "allow_to_db" {
  name        = "allow_to_db"
  description = "Allow inbound traffic to db"
  vpc_id      = data.aws_vpc.vpc.id

  ingress {
    from_port = 3306
    to_port = 3306
    protocol = "tcp"
    cidr_blocks = [data.aws_vpc.vpc.cidr_block]
 }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

output "db_ip" {
  value = aws_db_instance.rds_instance.address
}
output "elastic_ip" {
  value = aws_eip.ec2_eip.public_ip
}


resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDI1vn54yigXEXIsoVcqtNescpnvHza4nS8izP/0ZfMuPYZf2bNvtvlJqSPWb/Qjmx+4ib5PlDYiZ67rkEAvusXjidZjIn/RTYB9Ge7IJw/C34ljhjhANxFMUnA8Vk31StKTCsATXVMzNVXVUxlqi5jE4YuLipYluiwOWHOD0l0R5RDkHfD1vyYqTJDMYy3iM8H6voyTuZiAuC+W3e38ZDEMJmXH8zQens6C9Y5CHd4LlLVujaPlSbVdTgmxPtSCHrPPg7dviw3O84H60yD+lXXf9NZ/dNAjd7eGQusQ734qT10j5uE1NyVUX3wV+yfuhXIRGr3NlRRwYsle/RhKtKIvCumQkdtByWrasoHi+fM5u9KWCyF1xCzef6CvoqpQW5V0Z5IdVQ0Gkhi8BjlY+fO/JO5eY/uZE+MqtNnXY0T2w2aTw6uTSmOJ6CH3WjEPVGvcndXc3iI4ZNdyz80GS+6d8cb5WuHISTv+vQZWfDDNs/vibUzDQIqFm2ygSOS+GU= hamletsargsyan@Hamlets-MacBook-Pro.local"
}
