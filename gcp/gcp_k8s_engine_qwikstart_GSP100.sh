#!/bin/bash -e

# To run this script session, copy and paste this command in the local console: 
# sh -c "$(curl -fsSL https://raw.githubusercontent.com/clarkejj/DevSecOps/master/gcp/gcp_k8s_engine_qwikstart_GSP100.sh)"

# SCRIPT STATUS: WORKING. Results obtained after running twice on May 8, 2019.
# This script performs the commands described in the "Kubernetes Engine: Qwik Start" (GSP100) hands-on lab at
#    https://google.qwiklabs.com/focuses/878?parent=catalog
# This lab is part of this quest https://google.qwiklabs.com/quests/29 Kubernetes in the Google Cloud

uname -a
   # RESPONSE: Linux cs-6000-devshell-vm-91a4d64c-2f9d-4102-8c22-ffbc6448e449 3.16.0-6-amd64 #1 SMP Debian 3.16.56-1+deb8u1 (2018-05-08) x86_64 GNU/Linux

# Setting a default compute zone
# Your compute zone is an approximate regional location in which your clusters and their resources live. For example, us-central1-a is a zone in the us-central1 region.

# Start a new session in Cloud Shell and run the following command to set your default compute zone to us-central1-a
gcloud config set compute/zone us-central1-a

# Creating a Kubernetes Engine cluster
# A cluster consists of at least one cluster master machine and multiple worker machines called nodes. Nodes are Compute Engine virtual machine (VM) instances that run the Kubernetes processes necessary to make them part of the cluster.

# To create a cluster, run the following command, replacing [CLUSTER-NAME] with the name you choose for the cluster (for example my-cluster). Cluster names must start with a letter, end with an alphanumeric, and cannot be longer than 40 characters.
CLUSTER-NAME=$(gcloud config list project --format='value(core.project)')

gcloud container clusters create CLUSTER-NAME

# You can ignore any warnings in the output. It might take several minutes to finish creating the cluster. Soon after you should receive a similar output:

# NAME        LOCATION       ...   NODE_VERSION  NUM_NODES  STATUS
#my-cluster  us-central1-a  ...   1.10.9-gke.5  3          RUNNING

# Get authentication credentials for the cluster
# After creating your cluster, you need to get authentication credentials to interact with the cluster.

# To authenticate the cluster run the following command, replacing [CLUSTER-NAME] with the name of your cluster:
gcloud container clusters get-credentials CLUSTER-NAME

# You should receive a similar output:

# Fetching cluster endpoint and auth data.
# kubeconfig entry generated for my-cluster.

# Deploying an application to the cluster
# Now that you have created a cluster, you can deploy a containerized application to it. For this lab you'll run hello-app in your cluster.

# Kubernetes Engine uses Kubernetes objects to create and manage your cluster's resources. Kubernetes provides the Deployment object for deploying stateless applications like web servers. Service objects define rules and load balancing for accessing your application from the Internet.

# Run the following kubectl run command in Cloud Shell to create a new Deployment hello-server from the hello-app container image:
kubectl run hello-server --image=gcr.io/google-samples/hello-app:1.0 --port 8080

# You should receive the following output:
# deployment.apps "hello-server" created

# This Kubernetes command creates a Deployment object that represents hello-app. In this command:
# --image specifies a container image to deploy. In this case, the command pulls the example image from a Google Container Registry bucket. gcr.io/google-samples/hello-app:1.0 indicates the specific image version to pull. If a version is not specified, the latest version is used.
# --port specifies the port that the container exposes.

# Now create a Kubernetes Service, which is a Kubernetes resource that lets you expose your application to external traffic, by running the following kubectl expose command:
kubectl expose deployment hello-server --type="LoadBalancer"

# You should receive the following output:
# service "hello-server" exposed

# Passing in type="LoadBalancer" creates a Compute Engine load balancer for your container.

# Inspect the hello-server Service by running kubectl get:
# kubectl get service hello-server
# NAME         TYPE           CLUSTER-IP     EXTERNAL-IP      PORT(S)    AGE
# my-service   LoadBalancer   10.3.245.137   104.198.205.71   8080/TCP   54s
EXTERNAL_IP=$( kubectl get service hello-server | awk 'FNR == 2' | awk '{print $4}' )

# You should receive a similar output:
# NAME           TYPE           ...   EXTERNAL-IP      PORT(S)          AGE
# hello-server   LoadBalancer   ...   35.184.112.169   8080:30840/TCP   2m

# From this command's output, copy the Service's external IP address from the EXTERNAL IP column.

# View the application from your web browser using the external IP address with the exposed port:
# http://EXTERNAL-IP:8080
curl http://$EXTERNAL_IP:8080

# Run the following to delete the cluster:
gcloud container clusters delete $CLUSTER-NAME

# When prompted, type Y to confirm. Deleting the cluster can take a few minutes. For more information on deleted Google Kubernetes Engine clusters, view the documentation.

# Congratulations!
