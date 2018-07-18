#/usr/bin/python

# STATUS: UNTESTED
# This assumes enviornment variables for AWS ACCESS_KEY and SECRET_KEY have been established.
# Based on https://gist.github.com/sebsto/9a958ff1c761b8c7c90d

import json, boto

# Connect to IAM with boto
iam = boto.connect_iam(ACCESS_KEY, SECRET_KEY)

# Create user
user_response = iam.create_user('aws-user')

# Create Policy
policy = { 'Version' : '2012-10-17'}
policy['Statement'] = [{'Sid' : 'AwsIamUserPython', 
                        'Effect': 'Allow', 
                        'Action': 's3:*', 
                        'Resource': 'arn:aws:s3:::class-rocks/*'}]
policy_json = json.dumps(policy, indent=2)

iam.put_user_policy('aws-user', 'allow_access_class-rocks', policy_json)

# Generate new access key pair for 'aws-user'
key_response = iam.create_access_key('aws-user')
