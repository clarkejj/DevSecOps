#!/bin/bash

# This is gitlab-runner-mac.sh from https://github.com/wilsonmar/DevSecOps/gitlab
# Described in https://wilsonmar.github.io/gitlab-cicd

# This script installs the gitlab-runner on macOS.
# so you can make changes and see the effect.
# Remember to chmod +x git-basics.sh first, then paste this command in your terminal
# sh -c "$(curl -fsSL https://raw.githubusercontent.com/wilsonmar/DevSecOps/master/gitlab/gitlab-runner-mac.sh)"

RUNTYPE="update"
       # update = reinstall
       # remove = delete installer file
       # default is skip = use what has been installed

package="gitlab-runner"
package_folder="/usr/local/bin/"

runner_url="https://gitlab.com/"
PRIVATE-TOKEN="" # 1HEHB_jN-wttCDBQnK2n"  # copy from https://gitlab.com/{acct}/{project}/settings/ci_cd

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

### Install GitLab Runner:

      PID="$(ps x | grep -m1 '$package' | grep -v "grep" | awk '{print $1}')"
      if [ ! -z "$PID" ]; then # don't
         fancy_echo "ps $package PID=$PID"
         gitlab-runner stop
      fi

# Based on https://docs.gitlab.com/runner/install/osx.html
# Download the binary for macOS in /usr/local/bin/ where git commands are also:

      if [[ "${RUNTYPE}" == "remove" ]]; then
         fancy_echo "Removing $package ..."
         # brew uninstall --force $package
         rm -rf "$package_folder/$package"
         # Show error if package not already installed.
         exit
      fi

      if [ ! -f "$package_folder/$package" ]; then #  NOT found so install:
         if [[ "${RUNTYPE}" == "update" ]]; then
            fancy_echo "Stopping $package for update ..."
            gitlab-runner stop
         fi
            fancy_echo "Dowloading $package ..."
            curl -o /usr/local/bin/gitlab-runner \
               https://gitlab-runner-downloads.s3.amazonaws.com/latest/binaries/gitlab-runner-darwin-amd64
               # Result: 30.4M for 11.2.0 on Aug 28, 2018

            fancy_echo "No verification of download size and hash ..."
            # TODO: Verify download was 30.4M and MD5/SHA?

            fancy_echo "cd ~ ..."
            cd ~

            # Verify config.toml is in .gitlab-runner folder created.

            fancy_echo "sudo chmod +x $package ..."
            sudo chmod +x "$package_folder/$package"

            fancy_echo "$package install ..."
            gitlab-runner install

            # Register the Runner per https://docs.gitlab.com/runner/register/index.html
            fancy_echo "gitlab-runner list ..."
            gitlab-runner list

   # else existing found, don't re-install.
   fi

# To run gitlab runner on MacOSX via a LaunchDaemon instead of a LaunchAgent:
# <string>/Users/gitlab/Bin/gitlab-runner-daemon.sh</string>

gitlab-runner --version
   # Version:      11.2.0
   # Git revision: 35e8515d
   # Git branch:   11-2-stable
   # GO version:   go1.8.7
   # Built:        2018-08-22T15:58:04+00:00
   # OS/Arch:      darwin/amd64

### Start the service:

   fancy_echo "cd ~  # where .gitlab-runner is installed ..."
   cd ~
   fancy_echo "gitlab-runner start ..."
   gitlab-runner start

### Set token if one is specified:
   if [ -z "$runner_token" ]; then 
      fancy_echo "No Runner token for gitlab-runner to register ..."
   else
      fancy_echo "gitlab-runner register token ..."
      # Running in system-mode.

      # Per https://gitlab.com/help/api/runners.md#register-a-new-runner
      # curl --request POST "https://gitlab.example.com/api/v4/runners" \
      #    --form "token=$PRIVATE-TOKEN" \
      #    --form "description=$STARTER" \
      #    --form "tag_list=ruby,mysql,tag1,tag2"
      # {
        # "id": "12345",
        # "token": "6337ff461c94fd3fa32ba3b1ff4125"
      # }

      sudo gitlab-runner register
   # Please enter the gitlab-ci coordinator URL (e.g. https://gitlab.com/):
#https://gitlab.com/
   #Please enter the gitlab-ci token for this runner:
#$runner_token # ="1HEHB_jN-wttCDBQnK2n"  # copied from https://gitlab.com/{acct}/{project}/settings/ci_cd
   # Please enter the gitlab-ci description for this runner:   # runner_url="https://gitlab.com/"
#$STARTER  # "$HOME/$THISPGM.$LOG_DATETIME.log"
   #Please enter the gitlab-ci tags for this runner (comma separated):
#none

      # TODO: Get this alternative working with variable substitution:
#      sudo gitlab-runner register <<EOF
#https://gitlab.com/
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