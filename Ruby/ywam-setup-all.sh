#!/bin/bash
# This is ywam-setup-all.sh within https://github.com/wilsonmar/git-utilities
# by WilsonMar@gmail.com
# To minimize troubleshooting, this script "types" what the reader is asked to manually type in the tutorial at
# how-to-contribute.md at https://github.com/ipoconnection/ipo-web
# chmod +x git-basics.sh | then copy this command to paste in your terminal:
# bash -c "$(curl -fsSL https://raw.githubusercontent.com/wilsonmar/DevSecOps/master/Ruby/ywam-setup-all.sh)"

# This is free software; see the source for copying conditions. There is NO
# warranty; not even for MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

RUNTYPE=""
       # remove
       # upgrade
       # reset  (to wipe out files saved in git-utilities)
       # reuse (previous version of repository)
 
# A description of these Bash generic code is at https://wilsonmar.github.io/

### Set color variables (based on aws_code_deploy.sh): 
bold="\e[1m"
dim="\e[2m"
underline="\e[4m"
blink="\e[5m"
reset="\e[0m"
red="\e[31m"
green="\e[32m"
blue="\e[34m"

### Generic functions used across bash scripts:
function echo_f() {  # echo fancy comment
  local fmt="$1"; shift
  printf "\\n    >>> $fmt\\n" "$@"
}
function echo_g() {  # echo fancy comment
  local fmt="$1"; shift
  printf "        $fmt\\n" "$@"
}
function echo_c() {  # echo command
  local fmt="$1"; shift
  printf "\\n  $ $fmt\\n" "$@"
}
command_exists() {  # newer than which {command}
  command -v "$@" > /dev/null 2>&1
}

clear

# For Git on Windows, see http://www.rolandfg.net/2014/05/04/intellij-idea-and-git-on-windows/
TIME_START="$(date -u +%s)"
#FREE_DISKBLOCKS_END=$(df | sed -n -e '2{p;q}' | cut -d' ' -f 6) # no longer works
FREE_DISKBLOCKS_START="$(df -P | awk '{print $4}' | sed -n 2p)"  # e.g. 342771200 from:
   # Filesystem    512-blocks      Used Available Capacity  Mounted on
   # /dev/disk1s1   976490568 611335160 342771200    65%    /
LOG_PREFIX=$(date +%Y-%m-%dT%H:%M:%S%z)-$((1 + RANDOM % 1000))
   # ISO-8601 date plus RANDOM=$((1 + RANDOM % 1000))  # 3 digit random number.
   #  LOGFILE="$0.$LOG_PREFIX.log"
echo_f "1.1 $0 within $PWD of user: $(whoami)"
echo_g "starting at $LOG_PREFIX with $FREE_DISKBLOCKS_START blocks free ..."

### OS detection:
echo_c "uname -a"
unamestr=$( uname )
echo "$unamestr"
UNAME_PREFIX="${unamestr%%-*}" 
              platform='unknown'
if [[ "$unamestr" == 'Darwin' ]]; then
              platform='macos'
elif [[ "$unamestr" == 'Linux' ]]; then
              platform='linux'
elif [[ "$unamestr" == 'FreeBSD' ]]; then
              platform='freebsd'
elif [[ "$UNAME_PREFIX" == 'MINGW64_NT' ]]; then  # MINGW64_NT-6.1 or MINGW64_NT-10 for Windows 10
              platform='windows'  # systeminfo on windows https://en.wikipedia.org/wiki/MinGW
fi
echo "Platform: $platform"


if [[ $platform == 'linux' ]]; then

         echo_c "lsb_release -rs"  # Ubuntu release 18.04
      echo -e "$(lsb_release -rs)"

      echo_c "lscpu"
      echo "$(lscpu)"

      echo_c "lshw -short"
      echo "$(lshw -short)"

      echo_c "apt --version"  # package manager for Ubuntu
      echo "$(apt --version)"  # apt 1.6.3ubuntu0.1 (amd64)

      echo_c "git --version" 
      echo "$(git --version)" # git version 2.17.1

      echo_c "free -m" 
      echo "$(free -m)" # git version 2.17.1

      echo_c "vmstat -s"  # Virtual Memory: 
      echo "$(vmstat -s)" # 61944 K free memory

      echo_c "dig +short myip.opendns.com @resolver1.opendns.com"  # public networking IP address
      echo "$(dig +short myip.opendns.com @resolver1.opendns.com)"

      echo_c "grep MemFree /proc/meminfo" 
      echo "$(grep MemFree /proc/meminfo)" # MemFree: 67232 kB
      
fi

####
      echo_c "sudo apt-get update" 
              sudo apt-get update

# instead on using Gemfile:
# sudo apt-get install build-essential libssl-dev libyaml-dev libreadline-dev openssl curl git-core zlib1g-dev bison libxml2-dev libxslt1-dev libcurl4-openssl-dev nodejs libsqlite3-dev sqlite3

      echo_c "sudo apt-get install ruby-build -y" 
              sudo apt-get install ruby-build -y

      echo_c "rbenv install 2.3.7  # CAUTION: Back version to avoid Nokigiri issue." 
              rbenv install 2.3.7

#      echo_c "sudo apt-get install -y ruby-full" 
#              sudo apt-get install -y ruby-full

      echo_c "ruby -v" # ruby 2.5.1p57 (2018-03-29 revision 63029) [x86_64-linux-gnu]
              ruby -v


      echo_c "sudo apt install -y libpq-dev"
              sudo apt install -y libmagickwand-dev

      echo_c "sudo apt install -y libpq-dev"
              sudo apt install -y libmagickwand-dev


      GIT_BRANCH="upgrade-rails-4.0"
      echo_c "Remove folder added by GitHub command:"
      rm -rf "ipo-web"
      
      echo_c "Get from GitHub a specific branch:"
      git clone --branch "$GIT_BRANCH" --single-branch https://github.com/ipoconnection/ipo-web.git  
      cd "$GIT_BRANCH"
      ls

      echo_c "sudo apt-get install -y ruby-bundler"
              sudo apt-get install -y ruby-bundler

      echo_c "bundle install"
      echo "$(bundle install)"

####

FREE_DISKBLOCKS_END="$(df -P | awk '{print $4}' | sed -n 2p)"
DIFF=$(((FREE_DISKBLOCKS_START-FREE_DISKBLOCKS_END)/2048))
# 380691344 / 182G = 2091710.681318681318681 blocks per GB
# 182*1024=186368 MB
# 380691344 / 186368 G = 2042 blocks per MB

TIME_END=$(date -u +%s);
DIFF=$((TIME_END-TIME_START))
MSG="End of script after $((DIFF/60))m $((DIFF%60))s seconds elapsed."
echo_f "$MSG and $DIFF MB disk space consumed."
#say "script ended."  # through speaker
echo_f "---- End of script ----"
