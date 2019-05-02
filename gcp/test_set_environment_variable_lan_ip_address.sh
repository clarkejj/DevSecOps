#!/bin/bash -e

# To run this script session, copy and paste this command in the local console: 
# sh -c "$(curl -fsSL https://raw.githubusercontent.com/clarkejj/DevSecOps/master/gcp/test_set_environment_variable_lan_ip_address.sh)"

uname -a
   # RESPONSE: Linux cs-6000-devshell-vm-91a4d64c-2f9d-4102-8c22-ffbc6448e449 3.16.0-6-amd64 #1 SMP Debian 3.16.56-1+deb8u1 (2018-05-08) x86_64 GNU/Linux

#confirm we are in the 
[ "$PWD" = '/home/clarkej' ] && echo '>>> PWD verify current directory is /home/clarkej'
[ "$HOME" = '/home/clarkej' ] && echo '>>> verify HOME directory is /home/clarkej'
[ "$USER" = 'clarkej' ] && echo '>>> verify USER is clarkej'

# set an environment variable IP_LOCAL
IP_LOCAL=$( ifconfig | grep -m 1 inet | awk '{print $2}')
echo ">>> IP_LOCAL=$IP_LOCAL"  # response: "192.168.0.104"
#confirm IP address is valid
if [[ $IP_LOCAL =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then   echo ">>> ip seems valid"; else   echo ">>> ip seems to be invalid"; fi
# unset the environment variable IP_LOCAL
IP_LOCAL=

# create then remove a directory to represent idempotency state - ie leave file system as it was before the script ran

#To preserve idempotent state for a subsequent session, delete folder:
cd  # go to $HOME current directory

git clone https://github.com/googlecloudplatform/cloudml-samples --depth=1
cd cloudml-samples/census/estimator
echo ">>> At $(pwd) above "trainer" folder after cloning..."
#confirm the path
[ "$PWD" = '/home/clarkej/cloudml-samples/census/estimator' ] && echo '>>> verify current directory is /home/clarkej/cloudml-samples/census/estimator'
cd
rm -rf $HOME/cloudml-samples
# test to confirm that directory has been removed
[ -d 'cloud-samples' ] && echo '>>> cloudml-sample no longer found'

#create a file
touch aTemporaryTestFile
#confirm the file exists
[ -f 'aTemporaryTestFile' ] && echo '>>> aTemporaryTestFile found'
#delete the file
rm aTemporaryTestFile
[ ! -f 'aTemporaryTestFile' ] &&  echo '>>> aTemporaryTestFile no longer found'
