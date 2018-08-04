#!/bin/bash

# linux-install.sh

# IP address from https://cloud.ravellosystems.com/#/hE4lpaLL58tqn8PCDbHOmBkRXrSEDh1kgFNIQHxZUqplcXcQBm7D2NnvFasm210X/apps/3125670382551/vms/?selectedIds=;6489016440455168
# In a Terminal, after you > ssh ravello@129.146.152.161 ; yes ; supply password, paste this:
# At [ravello@Java101Template ~]$ 
# sh -c "$(curl -fsSL https://raw.githubusercontent.com/wilsonmar/DevSecOps/master/AppD/linux-install.sh)"
# https://github.com/wilsonmar/DevSecOps/blob/master/AppD/linux-install.sh

cat /etc/issue  # says Debian release 6.7 (Final)

echo $PWD  # says /home/ravello
ls -al  # to see starter files in image


#### Switch back to admin user:
# Load USER_PASSWORD
# echo $USER_PASSWORD | sudo -S su ravello
exit  # until fixed
cd /home/ravello

#### Download Java agent:
FILE_DOWNLOAD="AppServerAgent-4.5.0.23604.zip"
# From https://elephant201808020420052.saas.appdynamics.com:443 saved to my personal Google Drive:
wget -O "$FILE_DOWNLOAD" https://drive.google.com/open?id=1Kz1XlN_0tk3vrptQw1msfCDBeiNVb48L
# TODO: Verify SSH hash
ls -al "$FILE_DOWNLOAD"  # should say 127833
jar xvf "$FILE_DOWNLOAD" # not # tar -xvf "$FILE_DOWNLOAD"  # not or unzip 
tar xvf "$FILE_DOWNLOAD"

#### Download DB agent:
FILE_DOWNLOAD="dbagent-4.5.0.671.zip"
# From https://elephant201808020420052.saas.appdynamics.com:443 saved to my personal Google Drive:
wget -O "$FILE_DOWNLOAD" https://drive.google.com/open?id=12Jf_kU8Xmj7k9GPvvTdLdnYumqO5aw-4
# TODO: Verify SSH hash
ls -al "$FILE_DOWNLOAD"  # should say 127787
jar xvf "$FILE_DOWNLOAD" # not # tar -xvf "$FILE_DOWNLOAD"  # not or unzip 

#### Linux Server againt:
# machineagent-bundle-64bit-linux-4.5.0.1285
# $MACHINE_AGENT_HOME/jre/bin/java -jar 
# $MACHINE_AGENT_HOME/machineagent.jar

#### Bring up Tomcat:
sudo su - tomcat
# echo $PWD  # /home/tomcat

# find / name tomcat 2>/dev/null
TOMCAT_HOME=/opt/tomcat/apache-tomcat-8.0.30
export TOMCAT_HOME
echo $TOMCAT_HOME
# Need to background start: 
chmod +x $TOMCAT_HOME/bin/*.sh
$TOMCAT_HOME/bin/catalina.sh start  # for Tomcat started.
# Get TOMCAT_PID
PID="$(ps x | grep -m1 '/tomcat' | awk '{print $1}')" ; echo $PID
netstat -natp | grep $PID
   # tcp        0      0 ::ffff:127.0.0.1:8005       :::*                        LISTEN      1623/java           
   # tcp        0      0 :::8009                     :::*                        LISTEN      1623/java           
   # tcp        0      0 :::8080                     :::*                        LISTEN      1623/java           

## Configure JMX:
cd $TOMCAT_HOME
cd conf
# Pull in file https://raw.githubusercontent.com/wilsonmar/DevSecOps/master/AppD/setenv.sh)"
wget -O setenv.sh "https://raw.githubusercontent.com/wilsonmar/DevSecOps/master/AppD/setenv.sh)"
chmod 755 setenv.sh
#Catalina:type=JspMonitor,WebModule=//localhost/Cars_Sample_App,name=jsp,J2EEApplication=none,J2EEServer=none
# Background: https://www.mulesoft.com/tcat/tomcat-catalina
# https://tomcat.apache.org/tomcat-6.0-doc/monitoring.html
# Create a file alongside catalina.sh called setenv.sh so all changes are in a separate file.
# Use CATALINA_OPTS rather than JAVA_OPTS since CATALINA_OPTS is only used on start whereas JAVA_OPTS is used on start and stop.

# On your local machine: open http://129.146.152.161/Cars_Sample_App/home.do 
# to see "Supercar trader" page
