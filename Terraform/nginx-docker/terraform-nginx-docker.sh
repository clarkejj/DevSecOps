#!/usr/bin/env bash
# terraform-nginx-docker.sh

# based on https://gist.github.com/brianshumate/09adf967c563731ca1b0c4d39f7bcdc2
# and bash functions by Mark Johnson

# This is free software; see the source for copying conditions. There is NO
# warranty; not even for MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

### Run conditions:
RUN_FOLDER_NEW="yes"      # Delete folder created in prior run and create new folder
RUN_CLEANUP_AFTER="no"    # Remove what this installed at end of run (to save disk space)

### Utility functions in all scripts:

#
# Set Colors
#

bold="\e[1m"
dim="\e[2m"
underline="\e[4m"
blink="\e[5m"
reset="\e[0m"
red="\e[31m"
green="\e[32m"
blue="\e[34m"


#
# Common Output Styles
#

h1() {
  printf "\n${bold}${underline}%s${reset}\n" "$(echo "$@" | sed '/./,$!d')"
}
h2() {
  printf "\n${bold}%s${reset}\n" "$(echo "$@" | sed '/./,$!d')"
}
info() {
  printf "${dim}➜ %s${reset}\n" "$(echo "$@" | sed '/./,$!d')"
}
success() {
  printf "${green}✔ %s${reset}\n" "$(echo "$@" | sed '/./,$!d')"
}
error() {
  printf "${red}${bold}✖ %s${reset}\n" "$(echo "$@" | sed '/./,$!d')"
}
warnError() {
  printf "${red}✖ %s${reset}\n" "$(echo "$@" | sed '/./,$!d')"
}
warnNotice() {
  printf "${blue}✖ %s${reset}\n" "$(echo "$@" | sed '/./,$!d')"
}
note() {
  printf "\n${bold}${blue}Note:${reset} ${blue}%s${reset}\n" "$(echo "$@" | sed '/./,$!d')"
}


# Runs the specified command and logs it appropriately.
#   $1 = command
#   $2 = (optional) error message
#   $3 = (optional) success message
#   $4 = (optional) global variable to assign the output to
runCommand() {
  command="$1"
  info "$1"
  output="$(eval $command 2>&1)"
  ret_code=$?

  if [ $ret_code != 0 ]; then
    warnError "$output"
    if [ ! -z "$2" ]; then
      error "$2"
    fi
    exit $ret_code
  fi
  if [ ! -z "$3" ]; then
    success "$3"
  fi
  if [ ! -z "$4" ]; then
    eval "$4='$output'"
  fi
}

typeExists() {
  if [ $(type -P $1) ]; then
    return 0
  fi
  return 1
}

### Install Homebrew if not installed

### brew install terraform if not installed

# Create folder
#if RUN_FOLDER_NEW="yes"
#$WORK_FOLDER

# Download main.tf
#if RUN_DOWNLOAD_AGAIN="yes"

# if .terraform is not in folder, create it:
terraform init

ls -al

y | terraform plan 

terraform show

# Check if terraform apply  terraform.tfstate
#    See https://www.terraform.io/docs/state/
#    for use in a team environment, Store tfstate in Enterprise "backend" remote state server https://www.terraform.io/docs/backends/
# terraform state list
# docker_container.nginx
# docker_image.nginx
# If the plan is good and without error, apply it:
terraform apply

### Check to see that the container is running:
CONTAINER_ID=$(docker ps -a) | sed -n 2p | awk '{$print $1}' )  # extract first column in line 2
   # CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS                  PORTS                NAMES
   # 60cbf5c72ef4        62f816a209e6        "nginx -g 'daemon of…"   1 second ago        Up Less than a second   0.0.0.0:80->80/tcp   enginecks
if [[ ! -z "${CONTAINER_ID// }" ]]; then  #it's not blank
   # visit http://localhost in your browser and you should see the Welcome to nginx! default page!
   open http://localhost:80  # port 80 is specified in main.tf file.
fi

# if RUN_CLEANUP_AFTER="yes"
# dpcler re,pve
# rm -rf $WORK_FOLDER

docker stop $(docker ps -a -q)


docker rm $(docker ps -a -q)
