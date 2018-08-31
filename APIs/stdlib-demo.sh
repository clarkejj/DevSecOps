#!/bin/bash

# This is stdlib-demo.sh from https://github.com/wilsonmar/DevSecOps/apis
# Described in https://docs.stdlib.com/main/#/quickstart/command-line-interface

# This script installs stdlib and executes a sample "hello world" service.
# Remember to chmod +x stdlib-demo.sh first, then paste this command in your terminal
# sh -c "$(curl -fsSL https://raw.githubusercontent.com/wilsonmar/DevSecOps/master/APIs/stdlib-demo.sh)"

workspace_folder="stdlib-workspace"
workspace_path="~"

npm_module="lib.cli"  # https://www.npmjs.com/package/lib.cli
   # Standard Library is a serverless platform for API development and publishing
npm_command="lib"
RUNTYPE=""
       # update = reinstall
       # remove = delete installer file
       # default is skip = use what has been installed
#runner_url="https://apis.com/"
#PRIVATE-TOKEN="" # 1HEHB_jN-wttCDBQnK2n"  # copy from https://apis.com/{acct}/{project}/settings/ci_cd

### Define utility functions:
function fancy_echo() {
   local fmt="$1"; shift
   # shellcheck disable=SC2059
   printf "\\n>>> $fmt\\n" "$@"
}

command_exists() {
  command -v "$@" > /dev/null 2>&1
}

### Parameters to run this script:
if [ ! -f "$HOME/stdlib-config.conf" ]; then # not there, so move:
   fancy_echo "Copying stdlib-config.conf file in your home folder $HOME ..."
   ls -a
   cp stdlib-config.conf "$HOME/stdlib-config.conf"
   fancy_echo "Please edit file stdlib-config.conf in your acounnt home folder $HOME "
   vim "$HOME/stdlib-config.conf"
fi

   source $HOME/stdlib-config.conf
   fancy_echo "$HOME/stdlib-config.conf contains"
   echo "LIB_ACCOUNT_EMAIL=$LIB_ACCOUNT_EMAIL, LIB_ACCOUNT_NAME=$LIB_ACCOUNT_NAME, LIB_SERVICE_NAME=$LIB_SERVICE_NAME"
   MAC_USERID=$(id -un 2>/dev/null || true)  # example: wilsonmar
   # fancy_echo "MAC_USERID=$MAC_USERID ..."
   if [[ "${LIB_ACCOUNT_NAME}" == "wilsonmar" ]] && [[ "${MAC_USERID}" != "wilsonmar" ]]; then
      fancy_echo "Please edit file stdlib-config.conf in your acounnt home folder $HOME "
      echo "Exiting ..."
      exit
   fi

### Position

TIME_START="$(date -u +%s)"
FREE_DISKBLOCKS_START="$(df | sed -n -e '2{p;q}' | cut -d' ' -f 6)"
THISPGM="mac-runner.sh"
LOG_DATETIME=$(date +%Y-%m-%dT%H:%M:%S%z)-$((1 + RANDOM % 1000)) # ISO-8601 
STARTER="$THISPGM $HOME/$THISPGM.$LOG_DATETIME.log ..."  # used in descriptions to link back to this run.
   # RANDOM is built-in Bash, to use for micro-seconds
fancy_echo="Starting $STARTER"

### TODO: Install prerequisites if needed:
   # node
   # expect

### Install ApiS Runner:

   ### Delete container folder from previous run (or it will cause error), thus the container:
   ### Download again, but things have probably changed anyway:
   cd ~ # "$workspace_path"
         if [ -d "$workspace_folder" ]; then  # directory found:
            fancy_echo "Deleting $workspace_folder folder from prevous run ..." # ominpotent
            rm -rf "$workspace_folder"  
         fi
         # Create container folder again:
         mkdir "$workspace_folder" && cd "$workspace_folder"
         fancy_echo "PWD=$PWD"

#      PID="$(ps x | grep -m1 '$npm_module' | grep -v "grep" | awk '{print $1}')"
#      if [ ! -z "$PID" ]; then # don't
#         fancy_echo "ps $npm_module PID=$PID"
#         apis-runner stop
#      fi

### TODO: Verify dependencies: node

### Login: TODO: Supply password in a secure way:
   fancy_echo "$ lib login with $LIB_ACCOUNT_NAME"
   lib login <<EOF
$LIB_ACCOUNT_NAME
EOF
   # ? E-mail wilsonmar@gmail.com
   # ? Password *************************
   # Response:
   # Logged in successfully! Retrieving default Library Token (API Key)...
   # Active Library Token (API Key) set to: Library Token


###

# Based on https://docs.apis.com/runner/install/osx.html
# Download the binary for macOS in /usr/local/bin/ where git commands are also:

   if [[ "${RUNTYPE}" == "remove" ]]; then
      fancy_echo "Removing $npm_module ..."
      npm uninstall -g $npm_module
      exit
   fi

   fancy_echo "Listing all npm modules ..."
   NPM_LIST=$(npm list -g "$npm_module" | grep "$npm_module") 
   if ! grep -q "$npm_module" "$NPM_LIST" ; then # not installed, so:
   #if grep -q "$(npm list -g "$npm_module" | grep "$npm_module")" "(empty)" ; then  # no reponse, so add:
         fancy_echo "Installing $npm_module globally ..."
         npm install -g $npm_module
   else
      if [[ "${RUNTYPE,,}" == *"update"* ]]; then
         fancy_echo "Update $npm_module globally ..."
         npm update -g "$npm_module"
      fi
   fi

   fancy_echo "Trying to use $npm_command ..."
   "$npm_command" version  # 4.3.2 as of Aug 30, 2018


### Initialize

   # TODO: Check if already init'd.
   #fancy_echo "Checking cd ~  # where .apis-runner is installed ..."
   
      # If not set already:
      fancy_echo "$ lib init ..."
      lib init <<EOF
$LIB_ACCOUNT_NAME
$LIB_ACCOUNT_PASSWORD
EOF
         # Welcome to stdlib! :)
         # To use the stdlib registry, you must have a registered StdLib account.
         # It will allow you to push your services to the cloud and manage environments.
         # It's free to create an account. Let's get started!
         # Please enter your e-mail to login or register.
         # ? E-mail () 

   #A stdlib workspace has already been set.
   #The path of the stdlib workspace is:
   #  /Users/wilsonmar/stdlib-workspace
   # Use lib init --force to override and set a new workspace.

# TODO: Check If a service was not already set:

      fancy_echo "$ lib create $LIB_SERVICE_NAME ..."
      lib create "$LIB_SERVICE_NAME"
         # Awesome! Let's create a stdlib service!
         # Success!
         # Service wilsonmar/helloworld created at:
         #   /Users/wilsonmar/stdlib-workspace/wilsonmar/helloworld
         # Use the following to enter your service directory:
         #   cd wilsonmar/helloworld
         # Type lib help for more commands.

      fancy_echo "$ cd $LIB_ACCOUNT_NAME/$LIB_SERVICE_NAME ..."
      cd "$LIB_ACCOUNT_NAME"
      cd "$LIB_SERVICE_NAME"
      tree  # API.md       env.json     functions/__main__.js    package.json

      fancy_echo "$ lib . --name \"jon snow\" ..."
      lib . --name "jon snow"  # response: "hello jon snow"

exit

### Set token if one is specified:
   if [ -z "$runner_token" ]; then 
      fancy_echo "No Runner token for apis-runner to register ..."
   else
      fancy_echo "apis-runner register token ..."
      # Running in system-mode.

      # Per https://apis.com/help/api/runners.md#register-a-new-runner
      # curl --request POST "https://apis.example.com/api/v4/runners" \
      #    --form "token=$PRIVATE-TOKEN" \
      #    --form "description=$STARTER" \
      #    --form "tag_list=ruby,mysql,tag1,tag2"
      # {
        # "id": "12345",
        # "token": "6337ff461c94fd3fa32ba3b1ff4125"
      # }

      sudo apis-runner register
   # Please enter the apis-ci coordinator URL (e.g. https://apis.com/):
#https://apis.com/
   #Please enter the apis-ci token for this runner:
#$runner_token # ="1HEHB_jN-wttCDBQnK2n"  # copied from https://apis.com/{acct}/{project}/settings/ci_cd
   # Please enter the apis-ci description for this runner:   # runner_url="https://apis.com/"
#$STARTER  # "$HOME/$THISPGM.$LOG_DATETIME.log"
   #Please enter the apis-ci tags for this runner (comma separated):
#none

      # TODO: Get this alternative working with variable substitution:
#      sudo apis-runner register <<EOF
#https://apis.com/
#$PRIVATE-TOKEN
#$STARTER
#none
#EOF
   fi


### End Job metadata:

FREE_DISKBLOCKS_END=$(df | sed -n -e '2{p;q}' | cut -d' ' -f 6) 
DIFF=$(((FREE_DISKBLOCKS_START-FREE_DISKBLOCKS_END)/2048))
fancy_echo "$DIFF MB of disk space consumed during this script run."
# 380691344 / 182G = 2091710.681318681318681 blocks per GB
# 182*1024=186368 MB
# 380691344 / 186368 G = 2042 blocks per MB

TIME_END=$(date -u +%s);
DIFF=$((TIME_END-TIME_START))
MSG="End of script $THISPGM after $((DIFF/60))m $((DIFF%60))s seconds elapsed."
fancy_echo "$MSG"