#!/bin/bash
# This is gcp-java-951.sh from https://github.com/wilsonmar/DevSecOps/
# by WilsonMar@gmail.com
# Described in https://www.qwiklabs.com/focuses/951?parent=catalog

# This script is used to verify that scripts can run
# Copy this command and paste in your terminal:
# sh -c "$(curl -fsSL https://raw.githubusercontent.com/wilsonmar/DevSecOps/master/gcp-java-951.sh)"

echo "Hello world!"

### OS detection:
platform='unknown'
unamestr=$( uname )
if [[ "$unamestr" == 'Darwin' ]]; then
            platform='macos'
elif [[ "$unamestr" == 'Linux' ]]; then
              platform='linux'
elif [[ "$unamestr" == 'FreeBSD' ]]; then
              platform='freebsd'
elif [[ "$unamestr" == 'Windows' ]]; then
              platform='windows'
fi
echo "I'm $unamestr = $platform"


  if [[ $platform == 'macos' ]]; then
   alias ls='ls --color=auto'
elif [[ $platform == 'linux' ]]; then
   alias ls='ls --color=auto'
elif [[ $platform == 'freebsd' ]]; then
   alias ls='ls -G'
elif [[ $platform == 'windows' ]]; then
   alias ls='dir'
fi


### Define utility functions:
function echo_f() {
   local fmt="$1"; shift
   # shellcheck disable=SC2059
   printf "\\n>>> $fmt\\n" "$@"
}
function echo_c() {
  local fmt="$1"; shift
  printf "\\n  $ $fmt\\n" "$@"
}
function echo_r() {
  local fmt="$1"; shift
   # shellcheck disable=SC2059
   printf "$fmt\\n" "$@"
}
command_exists() {
  command -v "$@" > /dev/null 2>&1
}

TIME_START="$( date -u +%s )"
   # 1536771542
FREE_DISKBLOCKS_START="$( df | sed -n -e '2{p;q}' | cut -d' ' -f 6 )"
LOG_PREFIX=$(date +%Y-%m-%dT%H:%M:%S%z)-$( ( 1 + RANDOM % 1000 ) )
   # ISO-8601 date plus RANDOM=$((1 + RANDOM % 1000))  # 3 digit random number.
   #  LOGFILE="$0.$LOG_PREFIX.log"
echo_f "$0 starting at $LOG_PREFIX ..."

uname -a
   # RESPONSE: Linux cs-6000-devshell-vm-e3b7d016-01c1-493c-948c-f9eaac3e163b 4.14.33+ #1 SMP Sat Aug 11 08:05:16 PDT 2018 x86_64 GNU/Linux


echo_f "Delete buckets left over from previous run so can be rerun (within the same session)."


    echo_c "gcloud auth list"
GCP_AUTH=$( gcloud auth list )
echo_r "GCP_AUTH=$GCP_AUTH"
   #           Credentialed Accounts
   # ACTIVE  ACCOUNT
   # *       google462324_student@qwiklabs.net
   # To set the active account, run:
   #    $ gcloud config set account `ACCOUNT`


GCP_PROJECT=$( gcloud config list project | grep project | awk -F= '{print $2}' )
   # awk -F= '{print $2}'  extracts 2nd word in response:
   # project = qwiklabs-gcp-9cf8961c6b431994
   # Your active configuration is: [cloudshell-19147]

     echo_c "gcloud config list project"
PROJECT_ID=$( gcloud config list project --format "value(core.project)" )
   # Your active configuration is: [cloudshell-29462]
   #  qwiklabs-gcp-252d53a19c85b354
 echo_r "GCP_PROJECT=$GCP_PROJECT, PROJECT_ID=$PROJECT_ID"
   # response: "qwiklabs-gcp-9cf8961c6b431994"
RESPONSE=$( gcloud compute project-info describe --project $GCP_PROJECT )
   # Extract from:
   #items:
   #- key: google-compute-default-zone
   # value: us-central1-a
   #- key: google-compute-default-region
   # value: us-central1
   #- key: ssh-keys
#echo_r "RESPONSE=$RESPONSE"
#TODO: Extract value: based on previous line key: "google-compute-default-region"
#  cat "$RESPONSE" | sed -n -e '/Extract from:/,/<\/footer>/ p' | grep -A2 "key: google-compute-default-region" | sed 's/<\/\?[^>]\+>//g' | awk -F' ' '{ print $4 }'; rm -f $outputFile

#selfLink: https://www.googleapis.com/compute/v1/projects/qwiklabs-gcp-252d53a19c85b354
#xpnProjectStatus: UNSPECIFIED_XPN_PROJECT_STATUS


# No reference in this script to REGION="us-central1"
# echo_r "REGION=$REGION"

echo_f "MANUALLY: Enable Google App Engine Admin API:"
# APIs & Services > Library > Type "App Engine Admin API" in search box. Click App Engine Admin API.

echo_f "Download the Hello World app:"
git clone https://github.com/GoogleCloudPlatform/java-docs-samples.git
cd java-docs-samples/appengine/helloworld

echo_c "mvn appengine:devserver"
        mvn appengine:devserver

cd java-docs-samples/appengine/helloworld/src/main/java/com/example/appengine/helloworld
ls -al

cd ~/java-docs-samples/appengine/helloworld
mvn clean package


echo_f "Deploy your app:"
cd src/main/webapp/WEB-INF
# nano appengine-web.xml


cd ~/java-docs-samples/appengine/helloworld
gcloud app create
   # Success! The app is now created. Please use `gcloud app deploy` to deploy your first app.
mvn appengine:update


echo_f "View your application:"
# To launch your browser, enter the following command then click on the link it provides.
echo_c "gcloud app browse"
        gcloud app browse










echo "End of script."

