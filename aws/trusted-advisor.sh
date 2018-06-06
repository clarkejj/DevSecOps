#!/bin/bash

# SCRIPT STATUS: UNDER CONSTRUCTION
# trusted-advisor.sh

# For accounts with premium support:
# Or: "An error occurred (SubscriptionRequiredException) when calling the DescribeTrustedAdvisorChecks operation: AWS Premium Support Subscription is required to use this service.
# region must be us-east-1 as it only when support command works
CHECK_ID=$(aws --region us-east-1 support describe-trusted-advisor-checks \
   --language en --query 'checks[?name==`Service Limits`].{id:id}[0].id' --output text)
fancy_echo "CHECK_ID=$CHECK_ID"  # example: eW7HH0l7J9

fancy_echo "AWS discover service limits ..."
aws support describe-trusted-advisor-check-result \
   --check-id $CHECK_ID \
   --query 'result.sort_by(flaggedResources[?status!="ok"],&metadata[2])[].metadata' \
   --output table --region $AWS_REGION

