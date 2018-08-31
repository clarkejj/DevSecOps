#!/usr/bin/python

# SCRIPT STATUS: IN PROGRESS. 
# This performs the commands in "Hands-on Lab: Deploying to AWS with Ansible and Terraform" at
#    https://linuxacademy.com/cp/livelabs/view/id/488
# described by diagram at https://www.lucidchart.com/documents/view/c1ceaa2b-647c-49bd-9dca-bcaffc04be3b/0

# Instead of typing, copy this command to run in the console within the cloud:
# sh -c "$(curl -fsSL https://raw.githubusercontent.com/wilsonmar/DevSecOps/master/aws/aws-terraform-ansible-wordpress.sh)"
# by Wilson Mar, Wisdom Hambolu, and others.

# This adds steps to grep values into variables for verification,
# so you can spend time learning rather than typing and fixing typos.
# This script deletes folders left over from previous run so can be rerun.
# https://medium.com/@Montana/bash-script-for-qwiklabs-ftw-f981a1a21369

# After login as user/123456, provide new password.

python --version
   # Python 2.7.12
sudo apt-get update
echo y | sudo apt-get install git
git clone https://github.com/linuxacademy/terransible --depth=1
cd terransible
cd lab_scripts

   # pip install instructions: https://pip.pypa.io/en/stable/installing/
apt install python-pip

sudo pip install --upgrade pip

sudo pip install aws-cli --upgrade

aws --version

# TODO: Construct config file or
# Answer Default region name, us-east-1
aws configure 


sudo curl -O https://releases.hashicorp.com/terraform/0.11.3/terraform_0.11.3

sudo apt-get install unzip

sudo mkdir /bin/terraform
sudo unzip terraform_0.11.3_linux_amd64.zip -d /bin/terraform
export PATH=$PATH:/bin/terraform

# Verify:
terraform --version

echo y | sudo apt-get install software-properties-common

sudo apt-add-repository ppa:ansible/ansible
# Enter

sudo apt-get install update
sudo apt-get update
echo y | sudo apt-get install ansible

ansible --version

# TODO: Un-comment # host_key_checking = False in /etc/ansible/ansible.cfg 

# TODO: ssh-keygen Enter all

ssh-agent bash
ssh-add ~/.ssh/id_rsa
ssh-add -l 

terraform init

terraform plan
# for var.localip = 0.0.0.0/0

echo yes | terraform apply
# for var.localip = 0.0.0.0/0
    # wait for about 10 minutes







