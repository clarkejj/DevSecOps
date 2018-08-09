#!/bin/bash

# start.sh

APP_NAME=$1
GITHUB_REPO=$2 

# https://gist.github.com/edgar-humberto/11389366 has Bash Script to deploy app to create and deploy app to Heroku use `./filename [appName]` 

start(){
  echo ">>> Opening..."
  open "http://$APP_NAME.herokuapp.com"
}

start