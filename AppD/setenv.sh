#!/bin/bash
# setenv.sh
# This is for Tomcat MBean

# See https://geekflare.com/enable-jmx-tomcat-to-monitor-administer/
CATALINA_OPTS="-Dcom.sun.management.jmxremote -Dcom.sun.management.jmxremote.port=9000 -Dcom.sun.management.jmxremote.ssl=false -Dcom.sun.management.jmxremote.authenticate=false"

# https://docs.appdynamics.com/display/PRO44/Monitor+JMX
Catalina:type=JspMonitor,WebModule=//localhost/Cars_Sample_App,name=jsp,J2EEApplication=none,J2EEServer=none
netstat –anlp | grep 9000 
ps –ef |grep jmx

# ./jconsole
