# setenv.sh
# This is for Tomcat v__
# See https://geekflare.com/enable-jmx-tomcat-to-monitor-administer/

CATALINA_OPTS="-Dcom.sun.management.jmxremote -Dcom.sun.management.jmxremote.port=9000 -Dcom.sun.management.jmxremote.ssl=false -Dcom.sun.management.jmxremote.authenticate=false"
