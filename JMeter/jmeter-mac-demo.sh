#!/usr/bin/env bash

# From https://github.com/wilsonmar/DevSecOps/blob/master/JMeter/jmeter-mac-demo.sh
# described in https://wilsonmar.github.io/jmeter
# by WilsonMar@gmail.com

# This installs and configures JMeter on a Mac using Homebrew.
# Copy the command below (without the #) 
# bash -c "$(curl -fsSL https://raw.githubusercontent.com/wilsonmar/DevSecOps/master/JMeter/jmeter-mac-demo.sh)"

# This is free software; see the source for copying conditions. There is NO
# warranty; not even for MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

function pause(){
  read -p "Press any key to continue..."
}

echo "Hello $0"

# Install Java 8 using jenv:

# InstalL Homebrew if needed:

# Install JMeter using Homebrew:
   brew install jmeter

# Install JMeter add-on libraries:

# Make folder

# Download sample app for JMeter to load test

# Download JMeter files
    https://github.com/wilsonmar/...

# Run JMeter
   java ...

# Process output reports from JMeter

