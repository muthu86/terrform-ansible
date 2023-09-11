#!/bin/bash
exec >> /root/bootstrap.out
exec 2>&1
yum update -y
amazon-linux-extras install epel -y
yum-config-manager --enable epel
amazon-linux-extras disable ansible2
yum --enablerepo epel install ansible
ansible --version
yum install python2-winrm.noarch
ansible localhost -m ping
useradd ansible-user
echo ictprtkiw@20ty | passwd ansible-user --stdin
mkdir /ansible
mkdir -p /ansible/playbooks
mkdir /ansible/inventories
mkdir -p /ansible/playbooks/roles/win_folder/tasks/
mkdir -p /ansible/playbooks/roles/lin_folder/tasks/
cat <<EOF > /ansible/playbooks/roles/win_folder/tasks/main.yml
---
- name: Create directory structure
  win_file:
    path: C:\Temp\Ansible\Deploy
    state: directory
EOF
cat <<EOF > /ansible/playbooks/roles/lin_folder/tasks/main.yml
---
- name: Create a directory if it does not exist
  ansible.builtin.file:
    path: /etc/ansible/deploy
    state: directory
    mode: '0755'
EOF
cat <<EOF > /ansible/inventories/winhosts.inv
[winserver:children]
winservers

[winservers]
${win_public_ip}

[winserver:vars]
ansible_user=vagrant
ansible_password=password
ansible_connection=winrm
ansible_winrm_port=8320
ansible_winrm_server_cert_validation=ignore
ansible_winrm_transport=ntlm
ansible_winrm_scheme=http
EOF
cat <<EOF > /ansible/inventories/linhosts.inv
[linserver:children]
linservers

[linservers]
${lin_public_ip}

[linserver:vars]
ansible_user=vagrant
ansible_password=password
ansible_connection=ssh
ansible_ssh_port=22
EOF

chown -R ansible-user:ansible-user /ansible
ansible-playbook -i inventories/winhosts.inv playbooks/win_deploy.yml