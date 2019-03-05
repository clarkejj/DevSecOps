#!/bin/bash
# This is git-basics.sh within https://github.com/wilsonmar/git-utilities
# by WilsonMar@gmail.com
# To minimize troubleshooting, this script "types" what the reader is asked to manually type in the tutorial at
# https://wilsonmar.github.io/git-basics
# chmod +x git-basics.sh | then copy this command to paste in your terminal:
# bash -c "$(curl -fsSL https://raw.githubusercontent.com/wilsonmar/git-utilities/master/git-basics.sh)"

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
echo_f "1.1 $0 within $PWD "
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

####
# Ruby

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
