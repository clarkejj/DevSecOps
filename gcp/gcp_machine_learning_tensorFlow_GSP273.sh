# In the GCP console click Compute Engine to open the list of VM instances.
# ref https://cloud.google.com/compute/docs/instances/instance-life-cycle
# Click the SSH link to the right of the single VM instance that is listed to connect to the console of the VM via SSH.
# List all instances and their status:
# gcloud compute instances list
# Describe the status of a single instance:
#gcloud compute instances describe example-instance
# gcloud compute instances list --format=text \
    | grep '^networkInterfaces\[[0-9]\+\]\.networkIP:' | sed 's/^.* //g'
gcloud compute instances list | tail -n+2 | awk '{print $1, $4}'  

gcloud compute ssh [INTERNAL_INSTANCE_NAME] --internal-ip

# In the SSH console enter the following commands to update the local aptitude package database details and then upgrade all installed packages to the most recent versions:
sudo apt -y update
sudo apt -y upgrade

# In the SSH console enter the following commands to install git:
sudo apt -y install git

# Use git to clone the source code repository for this lab:
git clone  https://github.com/GoogleCloudPlatform/data-science-on-gcp/

# Enter the following commands to install Python pip:
sudo apt -y install python-pip

# Upgrade pip to the latest version:
sudo pip install --upgrade pip

# Install the Python TensorFlow module:
sudo pip install tensorflow

# Create minimal training and test datasets
# You now create the training data set that will be used to train your experimental models. The source data files that you are starting with here contain aggregated training data developed by processing the raw flight data from the Bureau of Transport Statistics website. The aggregated data includes time-window average delay values that provide much more useful baseline training data on which to develop predictive models of expected flight arrival time. You can learn how to create these aggregated source data files yourself by completing the previous lab in this quest, Processing Time Windowed Data with Apache Beam and Cloud Dataflow (Java).
# Create a working directory:
mkdir -p ~/data/flights

# Define local environment variables:
export PROJECT_ID=$(gcloud info --format='value(config.project)')
export BUCKET=${PROJECT_ID}

# A GCP Project was created for you when the lab was started, and a Cloud storage bucket was created that uses the default lab Project ID as the bucket name. Defining these variables makes it easier to refer to the project and bucket during the lab.
# Create the training data set by extracting about 10000 records from one of the source training data files:
gsutil cp \
  gs://${BUCKET}/flights/chapter8/output/trainFlights-00001*.csv \
  full.csv
head -10003 full.csv > ~/data/flights/train.csv
rm full.csv

# Create the test data set that will be used to evaluate your experimental models by extracting about 10000 records from one of the source test data files:
gsutil cp \
  gs://${BUCKET}/flights/chapter8/output/testFlights-00001*.csv \
  full.csv
head -10003 full.csv > ~/data/flights/test.csv
rm full.csv

# Create a TensorFlow experimental framework in Python

# Create the folder structure for the Python experimental training module:
mkdir ~/tensorflow
cd ~/tensorflow/
mkdir flights
cd flights
mkdir trainer
cd trainer

# Now create the component files.

# The file __init__.py must exist for the module definition, but doesn't contain anything so use touch to create it:
touch __init__.py

# The core machine learning functions will be contained in model.py. Enter the following command to open model.py in the nano text editor.

# nano -w model.py

# In model.py add the initial module imports directive to import the TensorFlow module and define global variables that will be used as the data schema for the source data files. These files contain aggregated data that was produced using the techniques covered in the previous lab in this quest. They contain derived data that presents all of the key variables of interest for this prediction model in an easy to process structure.

# Add the following at the beginning of model.py:

import tensorflow as tf

CSV_COLUMNS  = \
('ontime,dep_delay,taxiout,distance,avg_dep_delay,avg_arr_delay,' + \
 'carrier,dep_lat,dep_lon,arr_lat,arr_lon,origin,dest').split(',')
LABEL_COLUMN = 'ontime'
DEFAULTS     = [[0.0],[0.0],[0.0],[0.0],[0.0],[0.0],\
                ['na'],[0.0],[0.0],[0.0],[0.0],['na'],['na']]

# Add the following at the end of model.py to create the function that will read in the data:

def read_dataset(filename, mode=tf.contrib.learn.ModeKeys.EVAL,
                 batch_size=512, num_training_epochs=10):
      # This is double indented to make a later edit simpler
      if mode == tf.contrib.learn.ModeKeys.TRAIN:
         num_epochs = num_training_epochs
      else:
         num_epochs = 1
      # could be a path to one file or a file pattern.
      input_file_names = tf.train.match_filenames_once(filename)
      filename_queue = tf.train.string_input_producer(
          input_file_names, num_epochs=num_epochs, shuffle=True)
      # Read in and parse the CSV
      reader = tf.TextLineReader()
      _, value = reader.read_up_to(
          filename_queue, num_records=batch_size)
      value_column = tf.expand_dims(value, -1)
      columns = tf.decode_csv(value_column, record_defaults=DEFAULTS)
      features = dict(zip(CSV_COLUMNS, columns))
      label = features.pop(LABEL_COLUMN)
      return features, label

# Press CTRL+X then press Y and Enter to save model.py.

# Now create task.py that you will use to execute the model functions.

nano -w task.py

# Add in code for the import directives and code to handle parsing input arguments. You need to import the built in argument parsing module, model.py that you just created and also TensorFlow.

# Initially you will just have this parse the name of the training data file:

import argparse
import model
import tensorflow as tf
if __name__ == '__main__':
  parser = argparse.ArgumentParser()
  parser.add_argument(
      '--traindata',
      help='Training data file(s)',
      required=True
  )
  # parse args
  args = parser.parse_args()
  arguments = args.__dict__
  traindata = arguments.pop('traindata')

# Now add the following basic commands at the end of the task.py to get model.py to read in some sample data and print out an average computed from that data. Note that these lines are not indented:

# Call read_dataset from model.py
feats, label = model.read_dataset(traindata)
# Find the average of all the labels that were read in
avg = tf.reduce_mean(label)
print avg

# Press CTRL+X then press Y and Enter to save task.py.

# Now run the script to make sure all the parts are correct:

python task.py --traindata ~/data/flights/train.csv

# This will report back with:
# Tensor("Mean:0", shape=(), dtype=float32)
# Note: You will see a deprication warning which can be ignored.

# This is the expected result and tells you that the code you've built so far is OK, but it's not very useful. You now need to make some changes to both model.py and task.py to perform some real machine learning tasks.

# Start by replicating the basic logistic function model developed in an earlier lab using Spark:

# Edit model.py to add functions needed for call to Cloud ML:

nano -w model.py

# At the top of model.py add the following import directives after the existing import tensorflow as tf import directive:

import tensorflow.estimator as tflearn
import tensorflow.contrib.layers as tflayers
import tensorflow.contrib.metrics as tfmetrics
import numpy as np

# The get_features function defines a hash array with TensorFlow real valued columns for numeric features and TensorFlow sparse columns for labels such as carrier and origin airport ID. In this initial version you are replicating the basic linear regression model that was created using Spark and Cloud Dataproc in one of the earlier labs in this quest; Machine Learning with Spark and Cloud Dataproc. At this point only three real value features are extracted from the source data and no sparse features are selected. Later in this lab you will extend the range of features provided by this function in order to be able to evaluate how that affects the predictive performance of the model.

# Add the get_features function definition at the end of the file:

def get_features():
    # Using three basic inputs
    real = {
      colname : tflayers.real_valued_column(colname) \
          for colname in \
            ('dep_delay,taxiout,distance').split(',')
    }
    sparse = {}
    return real, sparse

# Now add the linear_model function that is used to create and return a linear classifier estimator. This will be used with the supplied training data set to train and evaluate an experimental model:

def linear_model(output_dir):
    real, sparse = get_features()
    all = {}
    all.update(real)
    all.update(sparse)
    estimator = tflearn.LinearClassifier(model_dir=output_dir, feature_columns=all.values())
    return estimator

# You need to do some refactoring of the read_dataset function now, so that it defines a callback function as its return value. This is then used to supply the input data functions for the training specification and evaluation specification parameters that will be used by the TensorFlow train_and_evaluate library function that is then used to perform the experimental analysis.

# Insert the callback function definition immediately below the def read_dataset initialization line, above the comment that indicates that the code is double indented:

   # the actual input function passed to TensorFlow
   def _input_fn():

# The original code sample provided earlier was double indented to make this edit simpler at this point in the lab.

# At the end of the read_dataset function definition, insert a new return command:

   # return input function callback.
   return _input_fn

# The read_dataset function should now look like the following:

96e182edcb59569a.png

# Note: It is important that the two lines you just added at the start and end of the original code block for read_dataset are indented at the same level or Python will incorrectly interpret the function definition and throw errors when you run the program.

# When the model is used for predictions it has to be able to receive inputs via REST calls. A serving input function that can handle JSON formatted request data is required. You can use this function to generate the required placeholders using the real and sparse hash arrays returned by the get_features function you defined earlier.

# Insert this at the end of the model.py file:

def serving_input_fn():
    real, sparse = get_features()

    feature_placeholders = {
      key : tf.placeholder(tf.float32, [None]) \
        for key in real.keys()
    }
    feature_placeholders.update( {
      key : tf.placeholder(tf.string, [None]) \
        for key in sparse.keys()
    } )

    features = {
      # tf.expand_dims will insert a dimension 1 into tensor shape
      # This will make the input tensor a batch of 1
      key: tf.expand_dims(tensor, -1)
         for key, tensor in feature_placeholders.items()
    }
    return tf.estimator.export.ServingInputReceiver(
      features,
      feature_placeholders)

# Finally, add the run_experiment function definition at the end of model.py. This brings all of the components together defining training and evaluation data sets, a training specification, and an estimator function that is used to build the model. In this case, the initial estimator function is a simple linear classifier function that uses the three variables; departure delay, taxi out time, and flight distance, that were used in previous labs. This allows you to compare the performance of this model with the previous linear regression models developed in earlier labs.

# The experiment function then uses the train_and_evaluate TensorFlow function to build and evaluate the model using these inputs.

# Add the following at the end of model.py:

def run_experiment(traindata,evaldata,output_dir):
  train_input = read_dataset(traindata,\
                 mode=tf.contrib.learn.ModeKeys.TRAIN)
  # Don't shuffle evaluation data
  eval_input = read_dataset(evaldata)
  train_spec = tf.estimator.TrainSpec(train_input, max_steps=1000)
  eval_spec  = tf.estimator.EvalSpec(eval_input)
  run_config = tf.estimator.RunConfig()
  run_config = run_config.replace(model_dir=output_dir)
  print('model dir {}'.format(run_config.model_dir))
  estimator = linear_model(output_dir)

  tf.estimator.train_and_evaluate(estimator, train_spec, eval_spec)

# Press CTRL+X then press Y and Enter to save the model.py file.

# Now modify task.py to pass the correct initial parameters to the new experiment:

nano -w task.py

# Insert these additional parameter handlers at the top of the file just below the traindata parameter handler code, above the comment # parse args:

  parser.add_argument(
      '--evaldata',
      help='Training data can have wildcards',
      required=True
   )
  parser.add_argument(
      '--output_dir',
      help='Output directory',
      required=True
   )
  parser.add_argument(
      '--job-dir',
      help='required by gcloud',
      default='./junk'
   )

# Add the following lines below traindata = arguments.pop('traindata'):

  evaldata =  arguments.pop('evaldata')
  output_dir = arguments.pop('output_dir')

# Insert the following lines at the end of the file replacing all the lines from # Call the read_dataset to print avg.

tf.logging.set_verbosity(tf.logging.INFO)
model.run_experiment(traindata,evaldata,output_dir)

# Press CTRL+X then press Y and Enter to save task.py.

# Now run task.py to test that the two Python scripts work as expected:

python task.py \
       --traindata ~/data/flights/train.csv \
       --output_dir ./trained_model \
       --evaldata ~/data/flights/test.csv

# You should see progress as the sample input data is processed, and towards the end, output similar to the following detailing the core metrics that have been evaluated:

# INFO:tensorflow:Saving dict for global step 200: accuracy = 0.89453167, accuracy_baseline = 0.72878134, auc = 0.88293874, auc_precision_recall = 0.946697, average_loss = 0.5809859, global_step = 200, label/mean = 0.72878134, loss = 290.5801, precision = 0.90075845, prediction/mean = 0.7678837, recall = 0.9611797
# However, you are developing this code so that you can use Google Cloud ML to perform the experiments. Cloud ML requires that the code can be called as a Python module, not just as a script. To create the Python module framework you will now add PKG-INFO, setup.cfg and setup.py files into the base folder of the module structure. Working examples of these are included in the source code folder for Chapter 9 of Data Science on Google Cloud Platform which you cloned at the start of this lab. The files provide the basic framework to allow the trainer code to be called as a module.

# Run the following to add the files:

pushd ~/data-science-on-gcp/09_cloudml/flights/
cp PKG-INFO ~/tensorflow/flights
cp setup.cfg ~/tensorflow/flights
cp setup.py ~/tensorflow/flights
popd

# Edit the setup.py file to ensure that the module dependency on TensorFlow is explicitly stated:

nano -w ~/tensorflow/flights/setup.py

# Insert the following between the REQUIRED_PACKAGES = [ and ] lines.

   'tensorflow>=1.7'

# The REQUIRED_PACKEGES array definition should now look as follows:

8b017bda8466eb28.png

# Press CTRL+X then press Y and Enter to save setup.py.

# Update the PYTHONPATH environment variable to allow you to call your trainer module without specifying the path every time:

export PYTHONPATH=${PYTHONPATH}:~/tensorflow/flights

# Now execute the trainer task as a call to a module:

cd ~/tensorflow
export DATA_DIR=~/data/flights
python -m trainer.task \
  --output_dir=./trained_model \
  --traindata $DATA_DIR/train* --evaldata $DATA_DIR/test*

# This again produces a lot of informational status data, but just before the point where it reports the final loss value it will show an output line similar to the following:

# INFO:tensorflow:Saving dict for global step 200: accuracy = 0.89453167, accuracy_baseline = 0.72878134, auc = 0.88293874, auc_precision_recall = 0.946697, average_loss = 0.5809859, global_step = 200, label/mean = 0.72878134, loss = 290.5801, precision = 0.90075845, prediction/mean = 0.7678837, recall = 0.9611797
# You note that the output provides a range of evaluation metrics, including accuracy, precision, and recall. The reported metrics also include a metric called AUC, the Area Under the Curve, which is a metric that captures the entire range of probabilities for your predictions. In order to compare the results here with the results from the earlier Spark models that are covered in previous labs, you need to add a custom metric in order to evaluate the root-mean-squared error for the predictions as well.

# Edit model.py to add functions needed for call to Cloud ML:

nano -w ~/tensorflow/flights/trainer/model.py

# Page down until you can see the def linear_model function and insert the following new function definition above it. This function defines a custom metric that is associated with the ontime prediction class:

def my_rmse(labels,predictions):
    predicted_classes = predictions['probabilities'][:,1]
    custom_metric = tf.metrics.root_mean_squared_error(labels, predicted_classes,name="rmse")
    return {'rmse':custom_metric}

# Next edit the def linear_model function to add the new custom metric.

# Insert the following line immediately above return estimator . Make sure you keep the indentation aligned with the existing return command:

    estimator = tf.contrib.estimator.add_metrics(estimator, my_rmse)

# Press CTRL+X then press Y and Enter to save model.py.

# Now remove the previous model data and execute the trainer task again:

rm -rf trained_model/
python -m trainer.task \
  --output_dir=./trained_model \
  --traindata $DATA_DIR/train* --evaldata $DATA_DIR/test*

# Now note that the logged output includes the new rmse custom metric.

# INFO:tensorflow:Saving dict for global step 200: accuracy = 0.89453167, accuracy_baseline = 0.72878134, auc = 0.88293874, auc_precision_recall = 0.946697, average_loss = 0.5809859, global_step = 200, label/mean = 0.72878134, loss = 290.5801, precision = 0.90075845, prediction/mean = 0.7678837, recall = 0.9611797, rmse = 0.3024143
# The results are very inconsistent at this point because you are using a very small data set for development. However, you are now in a position to begin to extend the model code to see how easy it is to provide alternative sets of features.

# At this point you are now ready to submit a job to the Cloud ML Engine to get more consistent and useful results by processing a larger data set. This initial data run compares to the rmse values seen during the evaluation of the linear model developed using Spark in the the Machine Learning with Spark and Cloud Dataproc because the features used by the model at this point match those used in the earlier lab.

# Now let's see how easy it is to modify this experimental framework to evaluate the performance when different sets of features are used.

# Edit model.py to add new feature selection functions.

nano -w ~/tensorflow/flights/trainer/model.py

# Page down and change the name of the get_features function to get_features_ch7

def get_features_ch7():

# Insert the following get_features_raw function definition above the get_features_ch7 function.

def get_features_raw():
    real = {
      colname : tflayers.real_valued_column(colname) \
          for colname in \
            ('dep_delay,taxiout,distance,avg_dep_delay,avg_arr_delay' +
             ',dep_lat,dep_lon,arr_lat,arr_lon').split(',')
    }
    sparse = {
      'carrier': tflayers.sparse_column_with_keys('carrier',
                 keys='AS,VX,F9,UA,US,WN,HA,EV,MQ,DL,OO,B6,NK,AA'.split(',')),

      'origin' : tflayers.sparse_column_with_hash_bucket('origin',
                 hash_bucket_size=1000),

      'dest'   : tflayers.sparse_column_with_hash_bucket('dest',
                 hash_bucket_size=1000)
    }
    return real, sparse

# Note: The use of hash_buckets here for the sparse data keys is not ideal but is sufficient for this lab. A more detailed explanation of why these are used here can be found in Chapter 9, Machine Learning Classifier using TensorFlow, from the Data Science on Google Cloud Platform book.

# Insert the following get_features_ch8 and get_features function definitions below the get_features_ch7 function.

def get_features_ch8():
    # Using the basic three inputs plus calculated time averages
    real = {
      colname : tflayers.real_valued_column(colname) \
          for colname in \
            ('dep_delay,taxiout,distance,avg_dep_delay,avg_arr_delay').split(',')
    }
    sparse = {}
    return real, sparse

def get_features():
    # Select the active get_feature function
    #return get_features_raw()
    #return get_features_ch7()
    return get_features_ch8()

# Press CTRL+X then press Y and Enter to save model.py.

# Now execute the trainer task again. This time the model includes the time-windowed averages that were computed in the last lab in this quest. This additional time-windowed data should improve the accuracy of the data model:

rm -rf trained_model/
python -m trainer.task \
  --output_dir=./trained_model \
  --traindata $DATA_DIR/train* --evaldata $DATA_DIR/test*

# Compare the performance, specifically the value of the rmse custom metric with the previous run.

# INFO:tensorflow:Saving dict for global step 200: accuracy = 0.91682494, accuracy_baseline = 0.72878134, auc = 0.9263404, auc_precision_recall = 0.97024775, average_loss = 0.4588158, global_step = 200, label/mean = 0.72878134, loss = 229.47673, precision = 0.9170757, prediction/mean = 0.7700186, recall = 0.9739369, rmse = 0.26860112
# Since the dataset being used in this lab is very small the results are very noisy and you may not actually see an improvement in these test runs.

# Edit model.py again to select the full feature selection function.

nano -w ~/tensorflow/flights/trainer/model.py

# Modify the get_features function to change the comments to select the get_features_raw feature selection function as shown below to include all of the features available in the derived data set when you deploy the model to cloud:

def get_features():
    return get_features_raw()
    #return get_features_ch7()
    #return get_features_ch8()

# Press CTRL+X then press Y and Enter to save model.py.

# Now execute the trainer task again. This time the model includes all of the available features:

rm -rf trained_model/
python -m trainer.task \
  --output_dir=./trained_model \
  --traindata $DATA_DIR/train* --evaldata $DATA_DIR/test*

# Compare the performance again, specifically noting the value of the rmse custom metric with the previous runs.

# INFO:tensorflow:Saving dict for global step 200: accuracy = 0.93112063, accuracy_baseline = 0.72878134, auc = 0.9574647, auc_precision_recall = 0.98300326, average_loss = 0.30595353, global_step = 200, label/mean = 0.72878134, loss = 153.02266, precision = 0.95542985, prediction/mean = 0.7230981, recall = 0.94979423, rmse = 0.24136068
# As noted previously, the dataset being used in this lab is very small, so the results are very noisy and you may not actually see an improvement in root-mean-squared-error in these test runs. With multiple runs, or if you provide a larger test data set, you will see a steady improvement in error as the range of features used by the model is increased.

# Being able to deploy this code directly to Google Cloud ML Engine without making any other code changes allows you to easily compare models and feature sets using large comprehensive data sets that will allow you to more effectively evaluate the performance of your data modelling choices.

# Deploy the TensorFlow experimental framework to the Google Cloud ML Engine
# First set some environment variables to point to Cloud Storage buckets for the source and output locations for your data and model:

export PROJECT_ID=$(gcloud info --format='value(config.project)')
export BUCKET=$PROJECT_ID
export REGION=us-central1
export OUTPUT_DIR=gs://${BUCKET}/flights/chapter9/output
export DATA_DIR=gs://${BUCKET}/flights/chapter8/output

# The source data for this exercise was created using the techniques described in the previous lab in this series and was copied in to this location for you when the lab was launched.

# You are now ready to submit a job to the Cloud ML Engine using your Python model to process the larger dataset using the distributed cloud resources for TensorFlow available using Google Cloud ML.

# Create a jobname to allow you to identify the job and change to the working directory.

export JOBNAME=flights_$(date -u +%y%m%d_%H%M%S)
cd ~/tensorflow

# Submit the Cloud-ML task providing region, cloud storage buckets for staging and working data, the training package directory, the training module name, and other parameters. The custom parameters for your training job, such as the location of the training and evaluation data are provided as custom parameters after all of the gcloud parameters.

gcloud ml-engine jobs submit training $JOBNAME \
  --module-name=trainer.task \
  --package-path=$(pwd)/flights/trainer \
  --job-dir=$OUTPUT_DIR \
  --staging-bucket=gs://$BUCKET \
  --region=$REGION \
  --scale-tier=STANDARD_1 \
  -- \
  --output_dir=$OUTPUT_DIR \
  --traindata $DATA_DIR/train* --evaldata $DATA_DIR/test*

# Now switch back to the Google Cloud Platform console browser session.

# Click the Navigator menu icon to open the Navigator panel on the left side.

# 2c6bf7fa8a63bc0b.png

# Scroll down and click ML Engine to open the Google Cloud ML Engine management page.

# Click the job named flights-YYMMDD-HHMMSS to open it.

# Monitor the job while it goes through the training process. This will around 5 minutes. Refresh your browser during the process to ensure you're looking at the latest information.

# Once the job is complete click the View Logs link.

# You will see a large number of events, but there will be an event towards the end of the job run with a description that starts with "Saving dict for global step ...".

# Click the event to open the details.

# You will see the full list of analysis metrics listed as shown below:

# Congratulations!
