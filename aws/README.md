## Installation

Installation creates a folder under your $HOME folder with a file <tt>~/.aws/config</tt>.
Variables in the file are detailed in <a target="_blank" href="https://docs.aws.amazon.com/cli/latest/topic/config-vars.html#cli-aws-help-config-vars">Amazon's Configuration Variables</a>.

https://github.com/aws/aws-cli

http://jmespath.org/
json --query 
from  https://github.com/jmespath/jmespath.py 
http://jamesls.com/how-to-easily-explore-jmespath-on-the-command-line.html

## Sample AWS CLI scripts

Shawn Woodford (in NYC) has a collection of bash shell scripts for automating various tasks with Amazon Web Services using the AWS CLI and jq at <a target="_blank" href="https://github.com/swoodford/aws">https://github.com/swoodford/aws</a>

1. Run <tt>aws configure</tt>
   to define in ~/.aws/config and ~/.aws/credentials

2. Verify state by running <tt>ec2-list.sh</tt> which lists accounts and its regions, users, security groups, S3 buckets, VPCs.

3. Create security groups.

4. Create an S3 IAM user, generate IAM keys, add to IAM group, generate user policy
   https://github.com/swoodford/aws/blob/master/iam-create-s3-users.sh

5. Define VPC

6. set up a new EC2 instance and ssh into it using: https://gist.github.com/Pablosan/803422


## AWS EC2 User Data

To specify actions when Ubuntu boots up with AWS EC2 instance, this is an example of what can be specified in the "User Data" section of the AWS EC2 Console:

<pre>
\#!/bin/bash
yum update -y
yum install -y httpd24 php56 mysql55-server php56-mysqlnd
service httpd start
chkconfig httpd on
groupadd www
usermod -a -G www ec2-user
chown -R root:www /var/www
chmod 2775 /var/www
find /var/www -type d -exec chmod 2775 {} +
find /var/www -type f -exec chmod 0664 {} +
echo "&LT;?php phpinfo(); ?>" > /var/www/html/phpinfo.php
</pre>

This approach of specifying actions has several advantages over creating an Instance Snapshot on AWS:

• I don't have to remember all the nit-picky details of getting a new instance up and configured
• Every minute detail will happen the same way every time
• The script serves as a reminder of every step taken to start and configure the instance
• No AWS charges for Snapshot storage



## Social

https://forums.aws.amazon.com/forum.jspa?forumID=150

## References

* <a target="_blank" href="https://docs.aws.amazon.com/cli/latest/index.html">AWS CLI Command Reference</a> which has at the bottom of the list <a target="_blank" href="https://docs.aws.amazon.com/cli/latest/topic/index.html">Topic Guide</a> 

https://docs.aws.amazon.com/cli/latest/userguide

https://docs.aws.amazon.com/cli/latest/reference

https://docs.aws.amazon.com/cli/latest/topic/s3-config.html#cli-aws-help-s3-config

https://docs.aws.amazon.com/cli/latest/topic/s3-faq.html#cli-aws-help-s3-faq

https://github.com/aws/aws-cli is where the code is kept

Boto3 Talk


## Return Codes

As with all Bash commands, this command returns the result of the previous command:

   <tt>echo $?</tt>

Alternately, with PowerShell, the command is:

   <tt>echo $lastexitcode</tt>

or

   <tt>echo %errorlevel%</tt>

Zero (0) is the normal return code. So check for non-zero.

1 AWS S3 commands return if one or more S3 transfers failed.

2 AWS returns if it cannot parse the previous command due to missing required subcommands or arguments or unknown commands or arguments.
## YouTube Videos about AWS CLI

James Saryerwinnie <js@jamesls.com>

   * <a target="_blank" href="https://www.youtube.com/watch?v=qiPt1NoyZm0">Becoming a Command Line Expert with the AWS CLI (TLS304) | AWS re:Invent 2013</a>

   * <a target="_blank" href="https://www.youtube.com/watch?v=vP56l7qThNs"> AWS re:Invent 2014 | (DEV301) Advanced Usage of the AWS CLI</a> [43:14]

   * <a target="_blank" href="https://www.youtube.com/watch?v=TnfqJYPjD9I">
   AWS re:Invent 2015 | (DEV301) Automating AWS with the AWS CLI</a> has <a target="_blank" href="https://www.slideshare.net/AmazonWebServices/dev301-automating-aws-with-the-aws-cli">slidedeck</a> and <a target="_blank" href="https://github.com/kyleknap/awscli-reinvent-examples">code</a>.

Tom Jones, Partner Amazon

   * <a target="_blank" href="https://www.youtube.com/watch?v=ZbgvG7yFoQI">Deep Dive: AWS Command Line Interface [1:04:11] Apr 10, 2015</a> 

Kyle Knapp, AWS Developer

   * <a target="_blank" href="https://www.youtube.com/watch?v=Xc1dHtWa9-Q">AWS:re:Invent Dec 2016: The Effective AWS CLI User (DEV402)</a> [55:14] with <a target="_blank" href="https://www.slideshare.net/AmazonWebServices/aws-reinvent-2016-the-effective-aws-cli-user-dev402">slidedeck</a>.

   * <a target="_blank" href="https://www.youtube.com/watch?v=W8IyScUGuGI">AWS:re:Invent 2017 and Beyond</a> with <a target="_blank" href="https://github.com/aws-samples/awscli-reinvent-examples/tree/master/2017">code</a>.

Leo Zhadanovsky, Principal Solutions Architect

   * <a target="_blank" href="https://www.youtube.com/watch?v=iC8zVT5r7Jw">AWS:re:Invent 2017 Introduction to AWS CLI</a> [47:47]

* <a target="_blank" href="https://www.youtube.com/watch?v=hdIlcu75_Lw">Creating A Backup Script Using AWS CLI For Your Linux Machines</a> [17:34] Jun 23, 2016 by LinuxAcademy.com

* <a target="_blank" href="https://www.youtube.com/watch?v=aC7F_ntezVk">Introduction to AWS CLI ( AWS Command Line Tool)</a> by Roham Sakhravi

* <a target="_blank" href="https://www.youtube.com/watch?v=WrVqrvIQRAI">Getting Started with AWS S3 CLI</a> by Melvin L

* <a target="_blank" href="https://www.youtube.com/watch?v=7z05U5ShhXg">Be a command line expert with aws cli - TOP 30 commands</a> by dython

* <a target="_blank" href="https://www.youtube.com/watch?v=ZbgvG7yFoQI&t=169s">Deep Dive: AWS Command Line Interface</a>
Amazon Web Services

* <a target="_blank" href="https://www.youtube.com/watch?v=YCSxln-10aQ">
Amazon AWS CLI with roles Sep 19, 2017</a> [34:48]
by AWS Solution Architect Training

