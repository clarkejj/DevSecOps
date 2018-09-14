#!/bin/bash
# This is hello-world.sh from https://github.com/wilsonmar/DevSecOps/
# by WilsonMar@gmail.com
# Described in https://

# This script is used to verify that scripts can run
# Copy this command and paste in your terminal:
# sh -c "$(curl -fsSL https://raw.githubusercontent.com/wilsonmar/DevSecOps/master/hello-world.sh)"

echo "Hello world!"

### OS detection:
platform='unknown'
unamestr=`uname`
if [[ "$unamestr" == 'Linux' ]]; then
   platform='linux'
elif [[ "$unamestr" == 'FreeBSD' ]]; then
   platform='freebsd'
fi
echo "$unamestr = $platform"

if [[ $platform == 'linux' ]]; then
   alias ls='ls --color=auto'
elif [[ $platform == 'freebsd' ]]; then
   alias ls='ls -G'
fi