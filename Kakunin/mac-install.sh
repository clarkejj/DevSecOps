#!/usr/local/bin/bash 

# This is mac-install.sh from https://github.com/wilsonmar/DevSecOps/Kakunin

# Based on https://www.slideshare.net/thesoftwarehouse/kakunin-e2e-framework-showcase
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

### Create a container folder based on attribute

            KAKUNIN_PROJECT="$1"  # from 1st argument
if [[ -z "${KAKUNIN_PROJECT// }"  ]]; then  #it's blank so assign default:
            KAKUNIN_PROJECT="kakunin-workshop"
fi

### Cleanup from previous run:

   # Kill kakunin process if it's still running from previous run:
   PID="$(ps -A | grep -m1 'kakunin' | grep -v "grep" | awk '{print $1}')"
      if [ ! -z "$PID" ]; then 
         fancy_echo "kakunin running on PID=$PID. killing it ..."
         kill $PID
      fi

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
   touch hello-kakunin

### Initialize project:
   # instead of npm init new, copy in:
      DOWNLOAD_URL="https://raw.githubusercontent.com/wilsonmar/DevSecOps/master/Kakunin/package.json"
      echo "Downloading $DOWNLOAD_URL ..."
      curl -O "$DOWNLOAD_URL"   # 208 bytes

### install pre-requisites

   npm install webdriver-manager
   npm install protractor

### Install Kakunin CLI locally because it's experimental:
   module="kakunin"
      fancy_echo "Installing $module ..."
      npm install $module
   npm list "$module"  # kakunin@2.1.3 on 21 Aug 2018

exit


KAKUNIN_IP="$2"       # from 2nd argument
if [[ -z "${KAKUNIN_IP// }"  ]]; then  #it's blank so assign default:
   KAKUNIN_IP="8000"
fi
### TODO: Change the default port from 8000 to 8111 or something else:
fancy_echo "Running base-install.sh to create localhost:$KAKUNIN_IP..."
