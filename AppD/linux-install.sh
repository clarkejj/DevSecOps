# linux-install.sh

# From https://cloud.ravellosystems.com/#/hE4lpaLL58tqn8PCDbHOmBkRXrSEDh1kgFNIQHxZUqplcXcQBm7D2NnvFasm210X/apps/3125670382551/vms/?selectedIds=;6489016440455168
#VM_IP=$1
VM_IP="129.146.159.96"

# In a Terminal, after you > YES | ssh ravello@129.146.159.96 and supply password, paste this:
# At [ravello@Java101Template ~]$ 
# sh -c "$(curl -fsSL https://raw.githubusercontent.com/wilsonmar/DevSecOps/master/appd-setup.sh)"

echo $PWD  # /home/ravello
sudo su - tomcat
# echo $PWD  # /home/tomcat

TOMCAT_HOME=/opt/tomcat/apache-tomcat-8.0.30
export TOMCAT_HOME
echo $TOMCAT_HOME
# Need to background start: 
chmod +x $TOMCAT_HOME/bin/*.sh
$TOMCAT_HOME/bin/catalina.sh start  # for Tomcat started.
# Get TOMCAT_PID
TOMCAT_PID="6145"
#TOMCAT_PID=$(ps -ef | grep "opt/tomcat" | ???)
netstat -natp | grep $TOMCAT_PID

# On your local machine: open "http://129.146.159.96/Cars_Sample_App/home.do"
# to see "Supercar trader" page

