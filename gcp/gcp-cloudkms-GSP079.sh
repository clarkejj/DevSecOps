#!/bin/bash -e

# SCRIPT STATUS: IN THE WORKS. Results obtained after running twice on Sep 12, 2018.
# This performs the commands described in the "Getting Started with Cloud KMS" (GSP079) hands-on lab at
#    https://google.qwiklabs.com/focuses/1713?parent=catalog
# which is part of quest ???

# Instead of typing, copy this command to run in the console within the cloud:
# sh -c "$(curl -fsSL https://raw.githubusercontent.com/wilsonmar/DevSecOps/master/gcp/gcp-cloudkms-GSP079.sh)"

# The script, by Wilson Mar, Wisdom Hambolu, and others,
# adds steps to grep values into variables for variation and verification,
# so you can spend time learning and experimenting rather than typing and fixing typos.
# This script deletes folders left over from previous run so can be rerun (within the same session).

uname -a
   # RESPONSE: Linux cs-6000-devshell-vm-91a4d64c-2f9d-4102-8c22-ffbc6448e449 3.16.0-6-amd64 #1 SMP Debian 3.16.56-1+deb8u1 (2018-05-08) x86_64 GNU/Linux

echo_c "gcloud auth list"
GCP_AUTH=$( gcloud auth list )
echo ">>> $GCP_AUTH"
   #           Credentialed Accounts
   # ACTIVE  ACCOUNT
   #*       google462324_student@qwiklabs.net
   #To set the active account, run:
   #    $ gcloud config set account `ACCOUNT`
exit

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
