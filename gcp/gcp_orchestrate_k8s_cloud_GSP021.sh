#!/bin/bash -e

# SCRIPT STATUS: WORKING. Results obtained after running twice on May 2, 2019.
# This performs the commands described in the "Orchestrating the Cloud with Kubernetes" (GSP021) hands-on lab at
#    https://google-run.qwiklab.com/catalog_lab/676 ???
#    https://google-run.qwiklab.com/focuses/725?parent=catalog ???
# This lab is part of this quest https://google.qwiklabs.com/quests/29 Kubernetes in the Google Cloud

# Instead of typing, copy this command to run in the console within the cloud:
# sh -c "$(curl -fsSL https://raw.githubusercontent.com/wilsonmar/DevSecOps/master/gcp/gcp_orchestrate_k8s__GSP021.sh)"

# The script, by Wilson Mar, Wisdom Hambolu, and others,
# adds steps to grep values into variables for variation and verification,
# so you can spend time learning and experimenting rather than typing and fixing typos.
# This script deletes folders left over from previous run so can be rerun (within the same session).

uname -a
   # RESPONSE: Linux cs-6000-devshell-vm-91a4d64c-2f9d-4102-8c22-ffbc6448e449 3.16.0-6-amd64 #1 SMP Debian 3.16.56-1+deb8u1 (2018-05-08) x86_64 GNU/Linux

# Google Kubernetes Engine
# In the cloud shell environment type the following command to set the zone:
gcloud config set compute/zone us-central1-b

# After you set the zone, start up a cluster for use in this lab:
gcloud container clusters create io

# It will take a while to create a cluster - Kubernetes Engine is provisioning a few Virtual Machines behind the scenes for you to play with!

# Get the sample code
#(But first, to make this sesssion idempotent from any previous session, delete the folder:
cd  # position at $HOME folder.
rm -rf $HOME/orchestrate-with-kubernetes

# Clone the GitHub repository from the Cloud Shell command line:
git clone https://github.com/googlecodelabs/orchestrate-with-kubernetes.git
cd orchestrate-with-kubernetes/kubernetes

# List the files to see what you're working with:
ls

# Quick Kubernetes Demo
# The easiest way to get started with Kubernetes is to use the kubectl run command. Use it to launch a single instance of the nginx container:
kubectl run nginx --image=nginx:1.10.0

# Kubernetes has created a deployment -- more about deployments later, but for now all you need to know is that deployments keep the pods up and running even when the nodes they run on fail.
# In Kubernetes, all containers run in a pod. Use the kubectl get pods command to view the running nginx container:
kubectl get pods

# Once the nginx container is running you can expose it outside of Kubernetes using the kubectl expose command:
kubectl expose deployment nginx --port 80 --type LoadBalancer

# So what just happened? Behind the scenes Kubernetes created an external Load Balancer with a public IP address attached to it. Any client who hits that public IP address will be routed to the pods behind the service. In this case that would be the nginx pod.
# List our services now using the kubectl get services command:
kubectl get services

# It may take a few seconds before the ExternalIP field is populated for your service. This is normal -- just re-run the kubectl get services command every few seconds until the field populates.
# Add the External IP to this command to hit the Nginx container remotely:
EXTERNAL_IP=$( kubectl get services | awk 'FNR == 2' | awk '{print $4}' )

curl http://$EXTERNAL_IP:80

# Pods
# At the core of Kubernetes is the Pod.
# Pods represent and hold a collection of one or more containers. Generally, if you have multiple containers with a hard dependency on each other, you package the containers inside a single pod.

# Creating Pods
# Pods can be created using pod configuration files. Let's take a moment to explore the monolith pod configuration file. Run the following:
cat pods/monolith.yaml

# Create the monolith pod using kubectl:
kubectl create -f pods/monolith.yaml

# Examine your pods. Use the kubectl get pods command to list all pods running in the default namespace:
kubectl get pods

# It may take a few seconds before the monolith pod is up and running. The monolith container image needs to be pulled from the Docker Hub before we can run it.
# Once the pod is running, use kubectl describe command to get more information about the monolith pod:
kubectl describe pods monolith

# Interacting with Pods
# By default, pods are allocated a private IP address and cannot be reached outside of the cluster. Use the kubectl port-forward command to map a local port to a port inside the monolith pod.

# From this point on the lab will ask you to work in multiple cloud shell tabs to set up communication between the pods. Any commands that are executed in a second or third command shell will be denoted in the command's instructions.

# Open two Cloud Shell terminals. One to run the kubectl port-forward command, and the other to issue curl commands.

# In the 2nd terminal, run this command to set up port-forwarding:

#cloudshell_open --repo_url "https://github.com/googlecloudplatform/cloudml-samples" \
#   --page "editor" --open_in_editor "census/estimator"
#   # QUESTION: Why --open_in_editor "census/estimator" in a new browser tab?

[create 2nd terminal]
[switch to 2nd terminal]
kubectl port-forward monolith 10080:80

# Now in the 1st terminal start talking to your pod using curl:
curl http://127.0.0.1:10080

# Yes! You got a very friendly "hello" back from your container.

# Now use the curl command to see what happens when you hit a secure endpoint:
curl http://127.0.0.1:10080/secure

# Try logging in to get an auth token back from the monolith:
curl -u user http://127.0.0.1:10080/login

# At the login prompt, use the super-secret password "password" to login.

# Logging in caused a JWT token to print out. Since cloud shell does not handle copying long strings well, create an environment variable for the token.
TOKEN=$(curl http://127.0.0.1:10080/login -u user|jq -r '.token')

# Enter the super-secret password "password" again when prompted for the host password.

# Use this command to copy and then use the token to hit the secure endpoint with curl:
curl -H "Authorization: Bearer $TOKEN" http://127.0.0.1:10080/secure

# At this point you should get a response back from our application, letting us know everything is right in the world again.

# Use the kubectl logs command to view the logs for the monolith Pod.
kubectl logs monolith

# Open a 3rd terminal and use the -f flag to get a stream of the logs happening in real-time:
[create 3rd terminal]
[switch to 3rd terminal]
kubectl logs -f monolith

# Now if you use curl in the 1st terminal to interact with the monolith, you can see the logs updating (in the 3rd terminal):
[switch to 1st terminal]
curl http://127.0.0.1:10080

# Use the kubectl exec command to run an interactive shell inside the Monolith Pod. This can come in handy when you want to troubleshoot from within a container:
kubectl exec monolith --stdin --tty -c monolith /bin/sh

# For example, once we have a shell into the monolith container we can test external connectivity using the ping command:
ping -c 3 google.com

# Be sure to log out when you're done with this interactive shell.
exit

# As you can see, interacting with pods is as easy as using the kubectl command. If you need to hit a container remotely, or get a login shell, Kubernetes provides everything you need to get up and going.

# Services
# Pods aren't meant to be persistent. They can be stopped or started for many reasons - like failed liveness or readiness checks - and this leads to a problem:

# What happens if you want to communicate with a set of Pods? When they get restarted they might have a different IP address.

# That's where Services come in. Services provide stable endpoints for Pods.

# Creating a Service
# Before we can create our services -- let's first create a secure pod that can handle https traffic.

# If you've changed directories, make sure you return to the ~/orchestrate-with-kubernetes/kubernetes directory:

cd ~/orchestrate-with-kubernetes/kubernetes

# Explore the monolith service configuration file:
cat pods/secure-monolith.yaml

# Create the secure-monolith pods and their configuration data:

kubectl create secret generic tls-certs --from-file tls/
kubectl create configmap nginx-proxy-conf --from-file nginx/proxy.conf
kubectl create -f pods/secure-monolith.yaml

# Now that you have a secure pod, it's time to expose the secure-monolith Pod externally.To do that, create a Kubernetes service.

# Explore the monolith service configuration file:
cat services/monolith.yaml

# (Output):
# kind: Service
# apiVersion: v1
# metadata:
#   name: "monolith"
# spec:
#  selector:
#    app: "monolith"
#    secure: "enabled"
#  ports:
#    - protocol: "TCP"
#      port: 443
#      targetPort: 443
#      nodePort: 31000
#  type: NodePort
# Things to note:

# There's a selector which is used to automatically find and expose any pods with the labels "app=monolith" and "secure=enabled"
# Now you have to expose the nodeport here because this is how we'll forward external traffic from port 31000 to nginx (on port 443).
# Use the kubectl create command to create the monolith service from the monolith service configuration file:
kubectl create -f services/monolith.yaml 

# (Output):
# service "monolith" created

# You're using a port to expose the service. This means that it's possible to have port collisions if another app tries to bind to port 31000 on one of your servers.

# Normally, Kubernetes would handle this port assignment. In this lab you chose a port so that it's easier to configure health checks later on.

# Use the gcloud compute firewall-rules command to allow traffic to the monolith service on the exposed nodeport:

gcloud compute firewall-rules create allow-monolith-nodeport \
  --allow=tcp:31000

# Now that everything is setup you should be able to hit the secure-monolith service from outside the cluster without using port forwarding.

# First, get an external IP address for one of the nodes.
gcloud compute instances list

# Now try hitting the secure-monolith service using curl:
curl -k https://$EXTERNAL_IP:31000

# Adding Labels to Pods
# Currently the monolith service does not have endpoints. One way to troubleshoot an issue like this is to use the kubectl get pods command with a label query.

# We can see that we have quite a few pods running with the monolith label.
kubectl get pods -l "app=monolith"

# But what about "app=monolith" and "secure=enabled"?
kubectl get pods -l "app=monolith,secure=enabled"

# Notice this label query does not print any results. It seems like we need to add the "secure=enabled" label to them.

# Use the kubectl label command to add the missing secure=enabled label to the secure-monolith Pod. Afterwards, you can check and see that your labels have been updated.

kubectl label pods secure-monolith 'secure=enabled'
kubectl get pods secure-monolith --show-labels

# Now that our pods are correctly labeled, let's view the list of endpoints on the monolith service:
kubectl describe services monolith | grep Endpoints

# And you have one!

# Let's test this out by hitting one of our nodes again.

gcloud compute instances list
curl -k https://$EXTERNAL_IP:31000

# Deploying Applications with Kubernetes
# The goal of this lab is to get you ready for scaling and managing containers in production. That's where Deployments come in. Deployments are a declarative way to ensure that the number of Pods running is equal to the desired number of Pods, specified by the user.

# Creating Deployments
# We're going to break the monolith app into three separate pieces:

# auth - Generates JWT tokens for authenticated users.
# hello - Greet authenticated users.
# frontend - Routes traffic to the auth and hello services.
# We are ready to create deployments, one for each service. Afterwards, we'll define internal services for the auth and hello deployments and an external service for the frontend deployment. Once finished you'll be able to interact with the microservices just like with Monolith only now each piece will be able to be scaled and deployed, independently!

# Get started by examining the auth deployment configuration file.
cat deployments/auth.yaml

# (Output)
# apiVersion: extensions/v1beta1
# kind: Deployment
# metadata:
#   name: auth
# spec:
#  replicas: 1
#   template:
#     metadata:
#       labels:
#         app: auth
#         track: stable
#     spec:
#        containers:
#         - name: auth
#           image: "kelseyhightower/auth:1.0.0"
#           ports:
#             - name: http
#               containerPort: 80
#             - name: health
#               containerPort: 81
# ...
# The deployment is creating 1 replica, and we're using version 1.0.0 of the auth container.

# When you run the kubectl create command to create the auth deployment it will make one pod that conforms to the data in the Deployment manifest. This means you can scale the number of Pods by changing the number specified in the Replicas field.

# Anyway, go ahead and create your deployment object:
kubectl create -f deployments/auth.yaml

# It's time to create a service for your auth deployment. Use the kubectl create command to create the auth service:
kubectl create -f services/auth.yaml

# Now do the same thing to create and expose the hello deployment:
kubectl create -f deployments/hello.yaml
kubectl create -f services/hello.yaml

# And one more time to create and expose the frontend Deployment.
kubectl create configmap nginx-frontend-conf --from-file=nginx/frontend.conf
kubectl create -f deployments/frontend.yaml
kubectl create -f services/frontend.yaml

# There is one more step to creating the frontend because you need to store some configuration data with the container.

# Interact with the frontend by grabbing it's External IP and then curling to it:

EXTERNAL_IP=$( kubectl get services frontend | awk 'FNR == 2' | awk '{print $4}' )
curl -k https://EXTERNAL-IP


#gcloud auth list
   #           Credentialed Accounts
   # ACTIVE  ACCOUNT
   #*       google462324_student@qwiklabs.net
   #To set the active account, run:
   #    $ gcloud config set account `ACCOUNT`

GCP_PROJECT=$(gcloud config list project | grep project | awk -F= '{print $2}' )
   # awk -F= '{print $2}'  extracts 2nd word in response:
   # project = qwiklabs-gcp-9cf8961c6b431994
   # Your active configuration is: [cloudshell-19147]
PROJECT_ID=$(gcloud config list project --format "value(core.project)")
echo ">>> GCP_PROJECT=$GCP_PROJECT, PROJECT_ID=$PROJECT_ID"  # response: "qwiklabs-gcp-9cf8961c6b431994"
RESPONSE=$(gcloud compute project-info describe --project $GCP_PROJECT)
   # Extract from:
   #items:
   #- key: google-compute-default-zone
   # value: us-central1-a
   #- key: google-compute-default-region
   # value: us-central1
   #- key: ssh-keys
#echo ">>> RESPONSE=$RESPONSE"
#TODO: Extract value: based on previous line key: "google-compute-default-region"
#  cat "$RESPONSE" | sed -n -e '/Extract from:/,/<\/footer>/ p' | grep -A2 "key: google-compute-default-region" | sed 's/<\/\?[^>]\+>//g' | awk -F' ' '{ print $4 }'; rm -f $outputFile
REGION="us-central1"
echo ">>> REGION=$REGION"

# NOTE: It's not necessary to look at the Python code to run this lab, but if you are interested, 
# you can poke around the repo in the Cloud Shell editor.
#cloudshell_open --repo_url "https://github.com/googlecloudplatform/cloudml-samples" \
#   --page "editor" --open_in_editor "census/estimator"
#   # QUESTION: Why --open_in_editor "census/estimator" in a new browser tab?
#To make idempotent, delete folder:
cd  # position at $HOME folder.
rm -rf $HOME/cloudml-samples
git clone https://github.com/googlecloudplatform/cloudml-samples --depth=1
cd cloudml-samples
cd census/estimator
echo ">>> At $(pwd) above "trainer" folder after cloning..."
ls -al

# TODO: Verify I'm in pwd = /home/google462324_student/cloudml-samples/census/estimator

# Download from Cloud Storage into new data folder:
mkdir data
gsutil -m cp gs://cloudml-public/census/data/* data/
   # Copying gs://cloudml-public/census/data/adult.data.csv...
   # Copying gs://cloudml-public/census/data/adult.test.csv...
   # \ [2/2 files][  5.7 MiB/  5.7 MiB] 100% Done
   # Operation completed over 2 objects/5.7 MiB.

# Set the TRAIN_DATA and EVAL_DATA variables to your local file paths by running the following commands:
TRAIN_DATA=$(pwd)/data/adult.data.csv
EVAL_DATA=$(pwd)/data/adult.test.csv

echo ">>> View data of 10 rows:"
head data/adult.data.csv
   # 42, Private, 159449, Bachelors, 13, Married-civ-spouse, Exec-managerial, Husband, White, Male, 5178, 0, 40, United-States, >50K

# Install dependencies (Tensorflow):
sudo pip install tensorflow==1.4.1  # yeah, I know it's old
   # PROTIP: This takes several minutes:
   #   Found existing installation: tensorflow 1.8.0
   # Successfully installed tensorflow-1.4.1 tensorflow-tensorboard-0.4.0

# Run a local trainer in Cloud Shell to load your Python training program and starts a training process in an environment that's similar to that of a live Cloud ML Engine cloud training job.
MODEL_DIR=output  # folder name
# Delete the contents of the output directory in case data remains from a previous training run:
rm -rf $MODEL_DIR/*

echo "gcloud ml-engine local train ..."
gcloud ml-engine local train \
    --module-name trainer.task \
    --package-path trainer/ \
    -- \
    --train-files $TRAIN_DATA \
    --eval-files $EVAL_DATA \
    --train-steps 1000 \
    --job-dir $MODEL_DIR \
    --eval-steps 100
# The above trains a census model to predict income category given some information about a person.

# RESPONSE: INFO:tensorflow:SavedModel written to: output/export/census/temp-1527139269/saved_model.pb
# RESPONSE: # RESPONSE: ERROR: sh: 103: cannot open timestamp: No such file

# Launch the TensorBoard server to view jobs running ... into background ...:
# TODO: tensorboard --logdir=output --port=8080  &
   # RESPONSE: TensorBoard 0.4.0 at http://cs-6000-devshell-vm-91a4d64c-2f9d-4102-8c22-ffbc6448e449:8080 (Press CTRL+C to quit)

# Now manually Select "Preview on port 8080" from the Web Preview menu at the top of the Cloud Shell.
# TODO ???: open 127.0.0.1:8080
# Manually shut down TensorBoard at any time by typing ctrl+c on the command-line.

#The output/export/census directory holds the model exported as a result of running training locally. List that directory to see the generated timestamp subdirectory:
TIMESTAMP=$(ls output/export/census/)
   # RESPONSE: 1527139435 # linux epoch time stamp.
echo ">>> TIMESTAMP=$TIMESTAMP"
gcloud ml-engine local predict \
  --model-dir output/export/census/$TIMESTAMP \
  --json-instances ../test.json
# RESPONSE: You should see a result that looks something like the following:
# CLASS_IDS  CLASSES  LOGISTIC                LOGITS                PROBABILITIES
# [0]        [u'0']   [0.06775551289319992]  [-2.6216893196105957]  [0.9322444796562195, 0.06775551289319992]
# Where class 0 means income \<= 50k and class 1 means income >50k.

# Set up a Google Cloud Storage bucket:
# The Cloud ML Engine services need to access Google Cloud Storage (GCS) to read and write data during model training and batch prediction.
# Set some variables:
export PROJECT_ID=$(gcloud config list project --format "value(core.project)")
export BUCKET_NAME=${PROJECT_ID}-mlengine
echo ">>> BUCKET_NAME=$BUCKET_NAME"
   # BUCKET_NAME=qwiklabs-gcp-3e97ef84b39c2914-mlengine
#REGION=us-central1

# Delete bucket to avoid "ServiceException: 409 Bucket qwiklabs-gcp-be0b040e11b87eca-mlengine already exists."

# If the bucket name looks okay, create the bucket:
gsutil mb -l $REGION gs://$BUCKET_NAME
   # Creating gs://qwiklabs-gcp-3e97ef84b39c2914-mlengine/...

# Upload the data files to your Cloud Storage bucket, and 
# set the TRAIN_DATA and EVAL_DATA variables to point to the files:
gsutil cp -r data gs://$BUCKET_NAME/data
TRAIN_DATA=gs://$BUCKET_NAME/data/adult.data.csv
EVAL_DATA=gs://$BUCKET_NAME/data/adult.test.csv
   # Copying file://data/adult.data.csv [Content-Type=text/csv]...
   # Copying file://data/adult.test.csv [Content-Type=text/csv]...
   # \ [2 files][  5.7 MiB/  5.7 MiB]
   # Operation completed over 2 objects/5.7 MiB.

# Run a single-instance trainer in the cloud:
export JOB_NAME=census1
export OUTPUT_PATH="gs://$BUCKET_NAME/$JOB_NAME"
echo ">>> JOB_NAME=$JOB_NAME, OUTPUT_PATH=$OUTPUT_PATH"
gcloud ml-engine jobs submit training $JOB_NAME \
   --job-dir $OUTPUT_PATH \
   --runtime-version 1.4 \
   --module-name trainer.task \
   --package-path trainer/ \
   --region $REGION \
   -- \
   --train-files $TRAIN_DATA \
   --eval-files $EVAL_DATA \
   --train-steps 5000 \
   --verbosity DEBUG

   # RESPONSE: Job [census1] submitted successfully.
   # Your job is still active. You may view the status of your job with the command
   #  $ gcloud ml-engine jobs describe census1
   # or continue streaming the logs with the command
   #  $ gcloud ml-engine jobs stream-logs census1
   # jobId: census1
   # state: QUEUED
   # ... (output may contain some warning messages that you can ignore for the purposes of this lab).
   # Job completed successfully.

# Monitor the progress of training job by watching the logs on the command line via:
gcloud ml-engine jobs stream-logs $JOB_NAME
   # also monitor jobs in the Console. In the left menu, in the Big Data section, navigate to ML Engine > Jobs.

echo ">>> Inspect output in Google Cloud Storage OUTPUT_PATH=\"$OUTPUT_PATH\" ..."
gsutil ls -r $OUTPUT_PATH
   # Or tensorboard --logdir=$OUTPUT_PATH --port=8080

# Scroll through the output to find the value of $OUTPUT_PATH/export/census/<timestamp>/. 
   # EXAMPLE: gs://qwiklabs-gcp-92c4fc643f9860be-mlengine/census1/export/census/1527178062/saved_model.pb
# Select the exported model to use, by looking up the full path of your exported trained model binaries.
RESPONSE="$(gsutil ls -r $OUTPUT_PATH/export | grep 'saved_model.pb' )"
   #- description: 'Deployment directory gs://qwiklabs-gcp-be0b040e11b87eca-mlengine/census1/export/census/1527175436/
echo ">>> RESPONSE=$RESPONSE"  #debugging
dir=${RESPONSE%/*}    # strip last slash
echo ">>> dir=$dir"  #debugging
TIMESTAMP=${dir##*/}  # remove everything before the last / remaining
echo ">>> TIMESTAMP=$TIMESTAMP captured from gsutil ls -r $OUTPUT_PATH/export ..."


# After "Job completed successfully" appears,
# Deploy model to serve prediction requests from CMLE (Cloud Machine Learning Engine):

export MODEL_NAME=census
echo ">>> Delete Cloud ML Engine MODEL_NAME=\"$MODEL_NAME\" in $REGION ..."
echo Y | gcloud ml-engine models delete $MODEL_NAME
   # TODO: Check if model exists and skip creation instead of deleting? Wisdom?
echo ">>> Create Cloud ML Engine MODEL_NAME=\"$MODEL_NAME\" in $REGION ..."
gcloud ml-engine models create $MODEL_NAME --regions=$REGION
   # Created ml engine model [projects/qwiklabs-gcp-be0b040e11b87eca/models/census].

# Copy timestamp and add it to the following command to set the environment variable MODEL_BINARIES to its value:
export MODEL_BINARIES="$OUTPUT_PATH/export/census/$TIMESTAMP/"
echo ">>> MODEL_BINARIES=$MODEL_BINARIES"

# Create a version of your model:
gcloud ml-engine versions create v1 \
   --model $MODEL_NAME \
   --origin $MODEL_BINARIES \
   --runtime-version 1.4
   # RESPONSE: Creating version (this might take a few minutes)....../

echo ">>> ml-engine models list:"
gcloud ml-engine models list
   # NAME    DEFAULT_VERSION_NAME
   # census

# Send a prediction request to your deployed model:
gcloud ml-engine predict \
   --model $MODEL_NAME \
   --version v1 \
   --json-instances ../test.json
# The response includes the predicted labels of the example(s) in the request:
# CLASS_IDS  CLASSES  LOGISTIC                LOGITS                PROBABILITIES
# [0]        [u'0']   [0.029467318207025528]  [-3.494563341140747]  [0.9705326557159424, 0.02946731448173523]
# CLASS_IDS  CLASSES  LOGISTIC               LOGITS                PROBABILITIES
# [0]        [u'0']   [0.03032654896378517]   [-3.464935779571533]  [0.9696734547615051, 0.03032655268907547]
   # Where class 0 means income \<= 50k and class 1 means income >50k.

# Congratulations.
© 2019 GitHub, Inc.
Terms
Privacy
Security
Status
Help
Contact GitHub
Pricing
API
Training
Blog
About
