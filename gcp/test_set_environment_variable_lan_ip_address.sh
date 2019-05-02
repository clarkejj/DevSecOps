#!/bin/bash -e

# Copy this command to run in the local console session:
# sh -c "$(curl -fsSL https://raw.githubusercontent.com/clarkejj/DevSecOps/master/gcp/test_set_environment_variable_lan_ip_address.sh)"

uname -a
   # RESPONSE: Linux cs-6000-devshell-vm-91a4d64c-2f9d-4102-8c22-ffbc6448e449 3.16.0-6-amd64 #1 SMP Debian 3.16.56-1+deb8u1 (2018-05-08) x86_64 GNU/Linux

IP_LOCAL=$(ifconfig | grep -m 1 inet | awk "{print $2}")
