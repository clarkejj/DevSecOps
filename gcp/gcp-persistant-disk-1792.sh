#!/bin/bash
# This is gcp-persistant-disk-1792.sh from https://github.com/wilsonmar/DevSecOps/
# by WilsonMar@gmail.com
# Described in https://google.qwiklabs.com/focuses/1792?parent=catalog

# STATUS: NOT TESTED!

# This script is used to verify that scripts can run
# Copy this command (without the #) and paste in your terminal:
# bash -c "$(curl -fsSL https://raw.githubusercontent.com/wilsonmar/DevSecOps/master/gcp-persistant-disk-1792.sh)"

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


REGION="us-central1-c"
echo_r "REGION=$REGION"

DISK_NAME="mydisk1"
echo_r "DISK_NAME=$DISK_NAME"

DEVICE_NAME="mydevice1"
echo_r "DEVICE_NAME=$DEVICE_NAME"


echo_f "Attach a disk:"
echo_c "gcloud compute instances attach-disk gcelab --disk \"$MY_DISK\" --zone \"$REGION\" "
        gcloud compute instances attach-disk gcelab --disk  "$MY_DISK"  --zone  "$REGION"
   # Updated [https://www.googleapis.com/compute/v1/projects/qwiklabs-gcp-d12e3215bb368ac5/zones/us-central1-c/instances/gcelab].

echo_f "SSH into the virtual machine:"
echo_c "gcloud compute ssh gcelab --zone \"$REGION\" "
        gcloud compute ssh gcelab --zone "$REGION" <<< EOF
y


EOF
# When prompted for an RSA key pair passphrase, press __enter __for no passphrase, 
# then press __enter __again to confirm no passphrase.

echo_f "Make a mount point:"
echo_c "sudo mkdir  /mnt/$DISK_NAME"
        sudo mkdir "/mnt/$DISK_NAME"

echo_f "Format the disk using mkfs.ext4:"
sudo mkfs.ext4 -F -E lazy_itable_init=0,lazy_journal_init=0,discard /dev/disk/by-id/scsi-0Google_PersistentDisk_persistent-disk-1


echo_f "Mount the disk to the instance with the discard option enabled:"
sudo mount -o discard,defaults /dev/disk/by-id/scsi-0Google_PersistentDisk_persistent-disk-1 "/mnt/$DISK_NAME"


echo_f "Find the disk device by listing the disk devices in /dev/disk/by-id/"
echo_c "ls -l /dev/disk/by-id/"
        ls -l /dev/disk/by-id/
   # The default name is:
   # scsi-0Google_PersistentDisk_persistent-disk-1.

echo_f "Manually edit /etc/fstab to automatically mount the disk on restart:"
# Open /etc/fstab in nano to edit.
# sudo nano /etc/fstab
# sed to add the following below the line that starts with "UUID=..."
# /dev/disk/by-id/scsi-0Google_PersistentDisk_persistent-disk-1 /mnt/mydisk ext4 defaults 1 1
# UUID=e084c728-36b5-4806-bb9f-1dfb6a34b396 / ext4 defaults 1 1
# /dev/disk/by-id/scsi-0Google_PersistentDisk_persistent-disk-1 /mnt/mydisk ext4 defaults 1 1

# See https://cloud.google.com/compute/docs/disks/local-ssd#create_a_local_ssd

echo "End of script."

