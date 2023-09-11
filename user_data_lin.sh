#!/bin/bash
echo ${mas_public_ip}
echo ${lin_public_ip}
sudo yum update -y
sudo amazon-linux-extras install ansible2 -y
ansible --version
ansible localhost -m ping