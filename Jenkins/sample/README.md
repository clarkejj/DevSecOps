README.md

The Jenkinsfile in this folder is from
https://github.com/linuxacademy/content-jenkins-java-project
explained at 
https://linuxacademy.com/cp/courses/lesson/course/972/lesson/4/module/118

https://github.com/labmac/

Each Jenkins Pipeline file is text file that configures Jenkins.
It is stored in a versioned source code repository for "configuration as code".

pipeline is directive, a subset of Groovy language.

The coding is Declarative where the desired state of the Pipeline is declared rather than having code which defines steps to make it so.

<tt>agents any</tt>

In each Jenkins file there are several <tt><strong>stages</strong></tt>.

   1. 'Say Hello'
   2. 'Git Information'
   3. 'Unit Tests'
   4. 'build'
   5. 'deploy'
   6. "Running on CentOS"
   7. "Test on Debian"
   8. 'Promote to Green'
   9. 'Promote Development Branch to Master'

There is also a "post" section at the bottom.

"SCM" Source Code Manager = GitHub, GitLab, etc.

## Docker containers

Within the machine, make sure to start out with a clean slate:

   <pre>yum remove docker docker-common container-selinux</pre>

Ensure utilities are installed:

   <pre>yum install -y yum-utils</pre>

Add:

   <pre>yum-config-manager --add-repo  https://download.docker.com/linux/centos/docker-ce.repo</pre>

To view Docker sources in file:

   <pre>cat /etc/yum.repos.d/docker-ce.repo</pre>

Install CentOS Enterprise Linux 7:

   <pre>yes | yum install docker-ce-17.03.0.ce-1.el7.centos</pre>

   Reply Y twice. "Complete!"

Add Jenkins user:

   <pre>gpasswd -a jenkins docker</pre>
      # Adding user jenkins to group docker.

   systemctl start docker

In a new Terminal tab, ssh into Jenkins server. Make sure it's running:

   <pre>systemctl status jenkins</pre>

Login Jenkins as Admin user. 

In Jenkins Add build step "Execute shell" to trigger a command: 

   <pre>docker run hello-world</pre>

Click Save. Build with Parameters. The response includes:

   <pre>your installation appears to be working correctly."</pre>

## Ant install

Download installer:

   wget http://www.us.apache.org/dist/ant/binaries/apache-ant-1.10.1-bin-tar.gz

Unpack within the /opt folder:

   tar xvfvz apache-ant-1.10.1-bin.tar.gz -C /opt

Symlink the installed folder so it can be invoked from folder /opt/ant:

   ln -s /opt/apache-ant-1.10.1/ /opt/ant

Set

   sh -c 'echo ANT_HOME=/opt/ant >> /etc/enviornment'

Link:

   ln -s /opt/ant/bin/ant  /usr/bin/ant

Verify:

   ls -al /usr/bin | grep ant

   to see:

   ant -> opt/ant/bin/ant

Verify version:

   ant -version

      # Apache Ant(TM) version 1.10.1 compiled on Feburary 2 2017

Ant build files are in XML format:

   ant -f build.xml -v

https://github.com/labmac/java-project.git


