#!/bin/bash

# SCRIPT STATUS: UNDER CONSTRUCTION
# This uses awscli to list EC2 regions and instances described at:
# https://docs.aws.amazon.com/cloud9/latest/user-guide/sample-aws-cli.html

# To run locally: chmod +x ec2-list.sh; ./ec2-list.sh
# To run on server within AWS: copy this command to run in the console within the cloud:
# sh -c "$(curl -fsSL https://raw.githubusercontent.com/wilsonmar/DevSecOps/master/aws/ec2-list.sh)"

function fancy_echo() {
   local fmt="$1"; shift
   # shellcheck disable=SC2059
   printf "\\n>>> $fmt\\n" "$@"
}

fancy_echo "aws sts get-caller-identity ..."
aws sts get-caller-identity

fancy_echo "aws ec2 describe-regions ..."
#aws ec2 describe-regions --output text | cut -f 3
AWS_REGIONS=$(aws ec2 describe-regions --query 'Regions[].RegionName' --output text)
#echo "AWS_REGIONS=$AWS_REGIONS"
#for R in $AWS_REGIONS ; do \
#   echo $R; aws ec2 describe-id-format --region $R --output text; done

fancy_echo "aws configure get region ..."
AWS_REGION=$(aws configure get region)
echo "AWS_REGION=$AWS_REGION"

fancy_echo "aws iam list-users -Parallel ..."
aws iam list-users --query "Users[].[UserName]" --output text 
   # | \
   # xargs -I {} -P 10 aws iam delete-user --user-name "{}"

   # Block users access to AWS EC2 meta data per https://gist.github.com/sebsto/20e550876db521710186
   # sudo iptables -A OUTPUT -m owner ! --uid-owner root -d 169.254.169.254 -j DROP

fancy_echo "aws ec2 describe-security-groups ..."
aws ec2 describe-security-groups --output text

fancy_echo "aws ec2 describe-instances ..."
aws ec2 describe-instances # --filter Name=instance-type,Values=t2.nano
   # If none:
   # {
   #    "Reservations": []
   # }

fancy_echo "aws s3 ls (buckets) ..."
aws s3 ls 
   # 2018-05-28 05:53:21 wilsonianinstitute.com

# TODO: Extract BUCKETNAME :
   # Thanks to https://gist.github.com/sebsto/947f8cf66b4b4d4e82bc
#BUCKETNAME="wilsonianinstitute.com"  # DEBUGGING
#aws s3api list-objects --bucket "$BUCKETNAME" --query 'sum(Contents[].Size)' | awk '{print $0/1024/1024/1024" GB"}'
# In function sum(), invalid type for value: None, expected one of: ['array-number'], received: "null"

fancy_echo "aws describe-vpcs ..."
# TODO: Extract a vpc from list:
VPC_INSTANCE='vpc-0ccb9311e7c1edb3e'
# Using query language from http://jmespath.org/
aws ec2 describe-vpcs --query 'Vpcs[?VpcId == "$VPC_INSTANCE"].CidrBlock'
   #[
   #    "10.0.0.0/16"
   # ]

fancy_echo " Find all instances without a specific tag / with a specific tag ..."
# From https://gist.github.com/sebsto/eb48357f0bb24db8b2bf
aws ec2 describe-instances --query 'Reservations[?Instances[?length(Tags[?Key==`Environment`]) == `0`]].Instances[].InstanceId'
aws ec2 describe-instances --query 'Reservations[?Instances[?Tags[?Key==`Environment`]]].Instances[].InstanceId'

exit

TODO: List instance IDS:

CIDR=$(aws ec2 describe-vpcs --query "Vpcs[?VpcId == 'vpc-aaa22bbb'].CidrBlock" --output text)
fancy_echo "Create vpc CIDR=\"$CIDR\" "
# Based on https://www.youtube.com/watch?v=Xc1dHtWa9-Q&t=7m0s
aws ec2 create-vpc --cidr-block 10.0.0.0/16 --generate-cli-skeleton output

# Based on https://www.youtube.com/watch?v=Xc1dHtWa9-Q&t=4m37s
VPC_ID=$(aws ec2 create-vpc --cidr-block 10.0.0.0/16 \
   --query Vpc.VpcId --output text )
      echo "VPC_ID=\"$VPC_ID\" "
#    "Vpc": {
#        "VpcId": "vpc-0b31ea56cc80c59f9",
#        "InstanceTenancy": "default",
#        "Tags": [],
#        "CidrBlockAssociationSet": [
#            {
#                "AssociationId": "vpc-cidr-assoc-067942519626ad43e",
#                "CidrBlock": "10.0.0.0/16",
#                "CidrBlockState": {
#                   "State": "associated"
#                }
#            }
#        ],
#        "Ipv6CidrBlockAssociationSet": [],
#        "State": "pending",
#       "DhcpOptionsId": "dopt-9a84aee3",
#       "CidrBlock": "10.0.0.0/16",
#       "IsDefault": false
#    }

# Based on https://www.youtube.com/watch?v=Xc1dHtWa9-Q&t=10m3s
subnet_id=$( aws ec2 create-subnet --cidr-block 10.0.0.0/24 \
  --vpc-id $VPC_ID --generate-cli-skeleton output \
  --query Subnet.SubnetId --output text )

exit

fancy_echo "Creating EC2 instances ..."
aws ec2 start-instances --instance-ids i-4j3423ie i-32u89uf2

#List All Stopped EC2 Instances and Show Why Each One Stopped
aws ec2 describe-instances --filters Name=instance-state-name,Values=stopped \
    --region $REGION \
    --output json  |  jq  -r  .Reservations[].Instances[] .StateReason.Message

fancy_echo "import key"
aws ec2 import-key-pair --key-name id_rsa.pub \
   --public-key-material file :///home/user/.ssh/id_rsa.pub

fancy_echo "wait (block the script until) EBS snapshot completes:"
# See ec2-waiters.sh fro James
aws ec2 wait snapshot-completed --snapshot-ids snap-aabbccdd
echo "EBS snapshot completed"

fancy_echo "sync"
aws ec2 s3 sync . s3://reinvent-cli-blog-demo --acl public-read \
   --delete --profile staticblog

aws route53 create-hosted-zone --name www.reinvent-cli-blog-demo.com \
   --caller-reference reinvent-cli-blog-demo


TEMP_JSON="/tmp/table.json"
fancy_echo "aws dynamodb create-table --generate-cli-skeleton ..."
aws dynamodb create-table --generate-cli-skeleton >$TEMP_JSON
vim $TEMP_JSON  # manually
aws dynamodb create-table --cli-input-json file:///$TEMP_JSON
TABLE_NAME="mytable1"
aws dynamodb describe-table --table-name $TABLE_NAME --oiutput table

# James configure-role.sh
aws configure set profile.prodrole.role_arn arn:aws:iam...
aws configure set profile.prodrole.source_profile dev

fancy_echo "Copy S3 by streaming from stdout without creating ..."
aws s3 cp s3://<em>bucket/key</em> - | \
bzip2 --best | \
aws s3 cp - s3://<em>bucket/key</em>.bz2 


fancy_echo "Output to a single parameter ..."
instance_ids=$(aws ec2 run-instances \
  --image-id ami-13456 \
  --query Instances[].InstanceId \
  --output text) || errexit "Could not run instance"
aws ec2 create-tags \
  --tags Key=purpose,Value=dev \
  --resources "$(instance_ids)" || errexit "<errmsg>"

fancy_echo "One output to N AWS calls ..."
for name in $(aws iam list-users) \
  --query "Users[].[UserName]" --output_text); do
  aws iam delete-user --user-name "$name"
done





# END
