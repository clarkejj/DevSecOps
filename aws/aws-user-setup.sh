#!/bin/bash

# aws-user-setup.sh
# From https://www.slideshare.net/AmazonWebServices/dev301-automating-aws-with-the-aws-cli?from_action=save
# by James Saryerwinnie, AWS Oct 9, 2015
# TODO: Replace y/N answers with defaults. Q&A defeats the purpose of a script. Might as well use the console.

import_key_pair(){
  echo-n "Would you like to import ~/.ssh/id_rsa.pub? [y/N]: "
  read confirmation
  if[["$confirmation"!="y"]]
    then
    return
  fi
  aws ec2 import-key-pair \
    --key-name id_rsa \
    --public-key-material file://~/.ssh/id_rsa.pub
}
create_instance_profile(){
  echo-n "Would you like to create an IAM instance profile? [y/N]: "
  read confirmation
  if[["$confirmation"!="y"]]; then
    return
  fi
  aws iam create-role --role-name dev-ec2-instance \
    --assume-role-policy-document "$TRUST_POLICY"||errexit "Could not create Role"
   # Use a managed policy
  policies=$(aws iam list-policies --scope AWS)
  admin_policy_arn=$(jp -u \
    "Policies[?PolicyName=='AdministratorAccess'].Arn | [0]"<<<"$policies")
  aws iam attach-role-policy \
    --role-name dev-ec2-instance \
    --policy-arn "$admin_policy_arn"||errexit "Could not attach role policy"
    # Then we need to create an instance profile from the role.
  aws iam create-instance-profile \
    --instance-profile-name dev-ec2-instance ||\
  errexit "Could not create instance profile."
  # And add it to the role
  aws iam add-role-to-instance-profile \
    --role-name dev-ec2-instance \
    --instance-profile-name dev-ec2-instance ||\
  errexit "Could not add role to instance profile."
}
compute_key_fingerprint(){
  # Computes the fingerprint of a public SSH key given a private
  # RSA key. This can be used to compare against the output given
  # from aws ec2 describe-key-pair.
  openssl pkey -in ~/.ssh/id_rsa -pubout -outform DER | \
  opensslmd5 -c | \
  cut -d =-f 2| \
    tr -d '[:space:]'
}

do_setup(){
  echo"Checking for required resources..."
  echo""

  # 1. Check if a security group is found for
  # both windows and non-windows tags.
  # If not, we'll eventually give the option to
  # configure this. based on slide 52 of https://www.slideshare.net/AmazonWebServices/dev301-automating-aws-with-the-aws-cli?from_action=save
  if resource_exists "aws ec2 describe-security-groups \
    --filter Name=tag:dev-ec2-instance,Values=non-windows"; then
    echo"Security groups exists."
  else
    echo"Security group not found."
  fi
  echo""
  
  # 2. Make sure the keypair is imported.
  if[[! -f ~/.ssh/id_rsa ]]; then
    echo"Missing ~/.ssh/id_rsa key pair."
    elifhas_new_enough_openssl; then
    fingerprint=$(compute_key_fingerprint ~/.ssh/id_rsa)
    if resource_exists "aws ec2 describe-key-pairs \
      --filter Name=fingerprint,Values=$fingerprint"; then
      echo"Key pair exists."
    else
      echo"~/.ssh/id_rsa key pair does not appear to be imported."
      import_key_pair
    fi
  else
    echo"Can't check if SSH key has been imported."
    echo"You need at least openssl 1.0.0 that has a \"pkey\" command."
    echo"Please upgrade your version of openssl."
  fi
  echo""

  # 3. Check that they have an IAM role called dev-ec2-instance.
  # There is no server side filter for this like we have with the EC2
  # APIs, so we have to manually use a --query option for us.
  if resource_exists "aws iam list-instance-profiles"\
    "length(InstanceProfiles[?InstanceProfileName=='dev-ec2-instance'])"; then
    echo"Instance profile exists."
  else
    echo"Missing IAM instance profile 'dev-ec2-instance'"
    create_instance_profile
  fi
  echo""
}

do_setup
