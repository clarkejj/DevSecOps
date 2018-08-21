#!/bin/bash

# This is mac-install.sh from https://github.com/wilsonmar/DevSecOps/Kakunin

# Based on https://thesoftwarehouse.github.io/Kakunin/
# https://www.slideshare.net/thesoftwarehouse/kakunin-e2e-framework-showcase
# https://github.com/TheSoftwareHouse/Kakunin  for code
# https://thesoftwarehouse.github.io/Kakunin/  for documentation
# http://kakunin.io/

# This bash script downloads and installs kakunin test rig:
# sh -c "$(curl -fsSL https://raw.githubusercontent.com/wilsonmar/DevSecOps/master/Kakunin/mac-install.sh)"

# This is free software; see the source for copying conditions. There is NO
# warranty; not even for MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.


function fancy_echo() {
   local fmt="$1"; shift
   # shellcheck disable=SC2059
   printf "\\n>>> $fmt\\n" "$@"
}
TIME_START="$(date -u +%s)"
FREE_DISKBLOCKS_START="$(df | sed -n -e '2{p;q}' | cut -d' ' -f 6)"


### Create a container folder based on attribute

            KAKUNIN_PROJECT="$1"  # from 1st argument
if [[ -z "${KAKUNIN_PROJECT// }"  ]]; then  #it's blank so assign default:
            KAKUNIN_PROJECT="kakunin-workshop"
fi

### Cleanup from previous run:

   ### Delete container folder from previous run (or it will cause error), thus the container:
   ### Download again, but things have probably changed anyway:
   cd ~/ 
         if [ -d "$KAKUNIN_PROJECT" ]; then  # found:
            # Delete container folder from previous run (or it will cause error), thus the container:
            fancy_echo "Deleting container folder: $KAKUNIN_PROJECT ..."
            rm -rf "$KAKUNIN_PROJECT"
         fi
         fancy_echo "Creating container folder: $KAKUNIN_PROJECT ..."
         mkdir "$KAKUNIN_PROJECT" && cd "$KAKUNIN_PROJECT"
         fancy_echo "PWD=$PWD"

### Initialize project:
   # instead of npm init new, copy in:
      DOWNLOAD_URL="https://raw.githubusercontent.com/wilsonmar/DevSecOps/master/Kakunin/package.json"
      echo "Downloading $DOWNLOAD_URL ..."
      curl -O "$DOWNLOAD_URL"   # 208 bytes

### install pre-requisites

   npm install cross-env  --save
   npm install webdriver-manager --save
   npm install protractor --save

### Install Kakunin CLI locally because it's experimental:
   module="kakunin"
      fancy_echo "Installing $module ..."
      npm install $module  --save # added 216 packages from 330 contributors and audited 1438 packages in 25.576s
   npm list "$module"  # kakunin@2.1.3 on 21 Aug 2018

### Install Kakunin CLI locally because it's experimental:
   fancy_echo "Running $module init ..."
   npm run kakunin init <<ANSWERS
3
http://localhost:3000
none
ANSWERS
   # Answer what kind of app you're going to test (default: AngularJS) 3 for other.
   # Enter URL where your tested app will be running (default: http://localhost:3000) 
   # What kind of email service checking service (default: none)

   fancy_echo "Verifying $module init ..."
   ls -al
      # comparators       downloads         form_handlers     kakunin.conf.js   package-lock.json regexes           transformers
      # data              emails            generators        matchers          package.json      reports
      # dictionaries      features          hooks             node_modules      pages             step_definitions

   # To avoid errors:
   webdriver-manager update

### Run the tests using Kakunin:
   npm run kakunin
      # Selenium standalone server started at http://192.168.0.190:64586/wd/hub
      # WAIT for pause after I/update - chromedriver: setting permissions to 0755 for /Users/wilsonmar/kakunin-workshop/node_modules/webdriver-manager/selenium/chromedriver_2.41

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

exit

   # Kill kakunin process if it's still running from previous run:
   PID="$(ps -A | grep -m1 'kakunin' | grep -v "grep" | awk '{print $1}')"
      if [ ! -z "$PID" ]; then 
         fancy_echo "kakunin running on PID=$PID. killing it ..."
         kill $PID
      fi


KAKUNIN_IP="$2"       # from 2nd argument
if [[ -z "${KAKUNIN_IP// }"  ]]; then  #it's blank so assign default:
   KAKUNIN_IP="8000"
fi
### TODO: Change the default port from 8000 to 8111 or something else:
fancy_echo "Running base-install.sh to create localhost:$KAKUNIN_IP..."
