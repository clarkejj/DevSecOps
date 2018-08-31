# Stackdriver: Qwik Start (GSP089)
# https://google-run.qwiklab.com/focuses/9?parent=catalog

# After in the Console, click the SSH to open a terminal to your instance:

# Add Apache2 HTTP Server to your instance:
sudo apt-get update

echo Y | sudo apt-get install apache2 php7.0

sudo service apache2 restart

# Copy the external IP address for your VM, don't use the link. 
# Visit http://[external IP] to see the Apache2 default page:

# To use Stackdriver, your project must be in a Stackdriver account. 
# The following steps create a new account that has a free 30-day trial of Stackdriver Premium service.
# In the Google Cloud Platform Console, click on Products and Services to return to the left menu. 
# In the Stackdriver section, click on Monitoring. 

