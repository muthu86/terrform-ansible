provider "aws" {
  access_key = "AKIAZ7ZCB3QRI5KV6HUW"
  secret_key = "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"
  region = "ap-southeast-1"
}
locals {
      mas_public_ip  = aws_instance.master.public_ip
      lin_public_ip  = aws_instance.linux.public_ip
      win_public_ip  = aws_instance.windows.public_ip
}
resource "aws_security_group" "allow_ssh" {
  name        = "allow_ansible_ssh"
  description = "Allow ssh & ansible"

  ingress {
    description = "ssh allow"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}  

resource "aws_security_group" "allow_rdp" {
  name        = "allow_ansible_rdp"
  description = "Allow rdp & ansible"

  ingress {
    description = "rdp allow"
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "http allow"
    from_port   = 5985
    to_port     = 5985
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "https allow"
    from_port   = 5986
    to_port     = 5986
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}  

resource "aws_instance" "master" {
  ami = "ami-0e047ce9149262f82"
  security_groups = ["allow_ansible_ssh"]
  instance_type = "t2.micro"
  key_name = "ec2first"
  associate_public_ip_address = true
  user_data_replace_on_change = true
  user_data_base64 = base64encode("${templatefile("${path.module}/user_data_mas.sh", {
    lin_public_ip   = local.lin_public_ip
    win_public_ip    = local.win_public_ip
  })}")
  depends_on = [
    aws_instance.linux
  ]
}
resource "aws_instance" "linux" {
  ami = "ami-0e047ce9149262f82"
  instance_type = "t2.micro"
  security_groups = ["allow_ansible_ssh"]
  key_name = "ec2first"
  associate_public_ip_address = true
  user_data_replace_on_change = true
  user_data = file("user_data_lin.sh")
  depends_on = [
    aws_instance.windows
  ]
}
resource "aws_instance" "windows" {
  ami = "ami-062508d30d9f2cb68"
  instance_type = "t2.micro"
  security_groups = ["allow_ansible_rdp"]
  key_name = "win_key"
  associate_public_ip_address = true
  user_data = file("user_data_win.ps1")
}
output "instance_ip_linux" {
  description = "The public ip for ssh access"
  value       = aws_instance.linux.public_ip
}
output "instance_ip_windows" {
  description = "The public ip for rdp access"
  value       = aws_instance.windows.public_ip
}