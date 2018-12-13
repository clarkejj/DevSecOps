#!/bin/bash
# This is pulumi-sample.sh at https://github.com/wilsonmar/DevSecOps/aws/pulumi-sample.md
# by WilsonMar@gmail.com who explains this at https://wilsonmar.github.io/pulumi
# To install on Macs what packages are necessary,
# then 

# STATUS: Experimental - does not completely work yet
# 1) Edit the run values below for your needs.
# 2) Run this bash script on MacOS 
#    $ chmod +x pulumi-sample.sh
#    $ ./pulumi-sample.sh
# to serve an HTML file in an NGINX container 

# spun up within https://aws.amazon.com/fargate/
# based on manual instructions in https://pulumi.io/quickstart/cloudfx/tutorial-service.html
# explained in https://github.com/pulumi/examples/tree/master/cloud-js-containers
# This example can be deplpoyed to AWS (on either Fargate or ECS) or to Azure (on ACI).

# set -o verbose  # or set -v echoes all commands before executing, for debugging
    
echo "### Define run values statically:"
         GOPATH="$HOME/gopkgs"   # edit this if you want.
         GOHOME="$HOME/golang1"  # where you store custom go source code
MY_PULUMI_FOLDER="$HOME/.pulumi" # default by sh installer.
MY_PULUMI_USER="wilsonmar"
MY_FOLDER="fargate-pulumi"
MY_DOCKER_IMAGE="nginx"
MY_STACK_NAME="fargate-pulumi-aws-dev"  # generated?
MY_AWS_REGION="us-west-2"
RUNTYPE="normal"  # "runonly" or "upgrade" 
DESTROY_AT_END_OF_RUN="true"  # "true" or "false"
BASHFILE="$HOME/.bash_profile"  # on Macs

# https://twitter.com/funcOfJoe/status/1046129151592128512

### Generic functions:
function fancy_echo() {
   local fmt="$1"; shift
   # shellcheck disable=SC2059
   printf "\\n>>> $fmt\\n" "$@"
}
command_exists() {
  command -v "$@" > /dev/null 2>&1
}
function BASHFILE_EXPORT() {
   # example: BASHFILE_EXPORT "gitup" "open -a /Applications/GitUp.app"
   name=$1
   value=$2

   if grep -q "export $name=" "$BASHFILE" ; then    
      fancy_echo "$name alias already in $BASHFILE"
   else
      fancy_echo "Adding $name in $BASHFILE..."
      # Do it now:
            export "$name=$value" 
      # For after a Terminal is started:
      echo "export $name='$value'" >>"$BASHFILE"
   fi
}


### Start of run metadata:
TIME_START="$(date -u +%s)"
FREE_DISKBLOCKS_START="$(df | awk '{print $4}' | cut -d' ' -f 6)"
THISPGM=$0
LOG_DATETIME=$(date +%Y-%m-%dT%H:%M:%S%z)-$((1 + RANDOM % 1000))
   # ISO-8601 plus RANDOM=$((1 + RANDOM % 1000))  # 3 digit random number.
#LOGFILE="$HOME/$THISPGM.$LOG_DATETIME.log"

clear  # screen
echo "$THISPGM starting at $LOG_DATETIME ..."


### Installation sequence: xcode-cli, homebrew, VSCode, git, Python3 > aws & azure-cli,  Node.js, Go,  Docker, Pulumi,

echo "### Ensure Homebrew is installed:"  # See https://wilsonmar.github.io/homebrew
   if ! command_exists brew ; then
       fancy_echo "Installing homebrew using Ruby..."
       ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
       brew tap caskroom/cask
   else
       # Upgrade if run-time attribute RUNTYPE contains "upgrade":
       if [[ "$RUNTYPE" == upgrade ]]; then
          fancy_echo "Brew upgrading ..."
          brew --version
          brew upgrade  # upgrades all modules.
       fi
   fi
   fancy_echo "$(brew --version)"
      # Homebrew/homebrew-core (git revision 35df; last commit 2018-12-13)
      # Homebrew/homebrew-cask (git revision bca77d; last commit 2018-12-13)

   brew analytics off  # see https://github.com/Homebrew/brew/blob/master/docs/Analytics.md


echo "### Ensure latest vscode is installed:"  # See https://wilsonmar.github.io/text-editors/#visual-studio-code
   if ! command_exists code ; then
      rm -rf "$HOME/Applications/Visual Studio Code.app"
      fancy_echo "Installing latest vscode for specific OS using brew..."
      brew cask install visual-studio-code
      git config --global core.editor code
   else
      if [[ "$RUNTYPE" == upgrade ]]; then
         fancy_echo "Upgrading visual-studio-code to latest ..."
         brew cask upgrade visual-studio-code
      fi
   fi
   fancy_echo "visual-studio-code: $(code --version)"  # 1.29.1 / bc24f98b5f70467bc689abf41cc5550ca637088e / x64


echo "### Ensure latest git is installed:"  # See https://wilsonmar.github.io/git
   if ! command_exists git ; then
      fancy_echo "Installing latest git for specific OS using brew..."
      brew install git   # /usr/local/Cellar/git/2.20.0: 1,526 files, 41.4MB
   else
      if [[ "$RUNTYPE" == upgrade ]]; then
         fancy_echo "Upgrading git latest ..."
         brew upgrade git  
      fi
   fi
   fancy_echo "$(git --version)"  # git version 2.17.2 (Apple Git-113)


echo "### Python3 is a pre-requisite for aws & azure:"
   if ! command_exists python3 ; then
      fancy_echo "Installing python3 (for specific os version) using brew..."
      brew install python3
   else
       if [[ "$RUNTYPE" == upgrade ]]; then
          fancy_echo "Upgrading python3 latest ..."
          brew upgrade python3
       fi
   fi
   fancy_echo "$(python3 --version)"  # Example: Python 3.7.1


echo "### Ensure pip3 install aws-sdk is installed:"
   if ! command_exists aws ; then
      fancy_echo "Installing awscli using PIP3 ..."
      pip3 install awscli --upgrade --user
   else
      if [[ "$RUNTYPE" == upgrade ]]; then
         fancy_echo "Upgrading awscli ..."
         aws --version  # aws-cli/1.16.70 Python/3.7.1 Darwin/18.2.0 botocore/1.12.60
         pip3 upgrade awscli --upgrade --user
      fi
   fi
   echo "$(aws --version)"  # aws-cli/1.11.160 Python/2.7.10 Darwin/17.4.0 botocore/1.7.18


echo "### Ensure Azure CLI is installed:" # https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-macos?view=azure-cli-latest
   if ! command_exists az ; then
      fancy_echo "Installing azure-cli (for specific os version) using brew..."
      brew install azure-cli  # /usr/local/Cellar/azure-cli/2.0.52: 19,791 files, 87.8MB
   else
       if [[ "$RUNTYPE" == upgrade ]]; then
          fancy_echo "Upgrading azure-cli latest ..."
          brew upgrade azure-cli
       fi
   fi
   fancy_echo "$(az -v | grep "azure-cli")"  # Example: azure-cli (2.0.52)

   ### az login delayed until need is known.


echo "### Ensure latest Node.js is installed:"  # See https://wilsonmar.github.io/node
   if ! command_exists node ; then
       fancy_echo "Installing latest node using brew..."
       brew install node
   else
       if [[ "$RUNTYPE" == upgrade ]]; then
          fancy_echo "Upgrading node latest ..."
          brew upgrade node
       fi
   fi
   fancy_echo "Node: $(node --version)"  # v9.11.1


echo "### Ensure Go is installed:"  # See https://wilsonmar.github.io/golang
   if ! command_exists go ; then
      fancy_echo "Installing go (for specific os version) using brew..."
      brew install go
         # RESPONSE: /usr/local/Cellar/go/1.11.2: 9,282 files, 404MB
      if grep -q "GOROOT=" "$BASHFILE" ; then    
         fancy_echo "export GOROOT already in $BASHFILE"
      else
         fancy_echo "Adding PATH to $GOROOT/bin in $BASHFILE..."
         printf "\nexport PATH=\"\$PATH:$GOROOT/bin\"\n" >>"$BASHFILE"
         # You may wish to add the GOROOT-based install location to your PATH:
         BASHFILE_EXPORT "GOROOT" "/usr/local/opt/go/libexec/bin"
         source "$BASHFILE"  # to activate changes.
      fi


      # A GOPATH folder is hold libraries requested by `go get` commands:
      if grep -q "GOPATH=" "$BASHFILE" ; then
         fancy_echo "export GOPATH= already in $BASHFILE"
      else
         # Make folder to Store Go packages:
         if [ ! -d "$GOPATH" ]; then
            fancy_echo "Creating folder $GOPATH ..."
            pushd "$HOME" >/dev/null
            mkdir "$GOPATH"
            popd >/dev/null
         fi
         BASHFILE_EXPORT "GOPATH" "$GOPATH"
         source "$BASHFILE"  # to activate changes.

         fancy_echo "Populating $GOPATH with the most popular Go library ..."
            # per https://medium.com/google-cloud/analyzing-go-code-with-bigquery-485c70c3b451
         go get github.com/stretchr/testify
         ls "$GOPATH/src/github.com/stretchr/testify"
         # PROTIP: Other libraries https://github.com/avelino/awesome-go
      fi


      # $GOHOME to hold custom Go code (Git folders):
      if grep -q "GOHOME=" "$BASHFILE" ; then
         fancy_echo "export GOHOME= already in $BASHFILE"
      else
         # GOHOME="$HOME/golang1"  # where you store custom go source code
            # export GOHOME="$HOME/gits/wilsonmar/golang-samples"

         # Make folder to Store Go packages:
         if [ ! -d "$GOHOME" ]; then
            fancy_echo "Creating folder $GOHOME ..."
            pushd "$HOME" >/dev/null
            mkdir "$GOHOME"
            cd    "$GOHOME"
            # option: populate by git clone https://github.com/wilsonmar/golang-samples"
            git clone https://github.com/mmcgrana/gobyexample --depth=1
               # Receiving objects: 100% (1075/1075), 2.17 MiB | 1.43 MiB/s, done.
            git clone https://github.com/mikhailshilkov/pulumi-aws-serverless-examples --depth=1
            popd >/dev/null
         fi
         BASHFILE_EXPORT "GOHOME" "$GOHOME"
         source "$BASHFILE"  # to activate changes.
      fi

      ### Configure debugging: https://github.com/Microsoft/vscode-go/wiki/Debugging-Go-code-using-VS-Code

      ### Install Visual Studio Code
      # brew cask install vscode
      ### Install Visual Studio Code extension for Go: https://code.visualstudio.com/docs/editor/extension-gallery#_command-line-extension-management
      # Blog: https://rominirani.com/setup-go-development-environment-with-visual-studio-code-7ea5d643a51a
      # RESULT="$(code --list-extensions)"
      # if within $RESULT
         # Download https://github.com/Microsoft/vscode-go
         # code --install-extension ms-vscode.cpptools
         # code --uninstall-extension ms-vscode.csharp
      # fi
      #  open Visual Studio Code. Press Ctrl+Shift+X or Cmd+Shift+X to open the Extensions pane. 
      # PROTIP: So sad that they did not have --update-extension.

   else
       if [[ "$RUNTYPE" == upgrade ]]; then
          fancy_echo "Upgrading go (for current OS) ..."
          brew upgrade go
       fi
   fi
   fancy_echo "$(go version)"  # Example: go version go1.11.2 darwin/amd64


echo "### Ensure Pulumi is installed:"  # See https://wilsonmar.github.io/pulumi
   if ! command_exists pulumi ; then
      fancy_echo "Installing pulumi using brew..."
      brew install pulumi
   else
       if [[ "$RUNTYPE" == upgrade ]]; then
          fancy_echo "Upgrading pulumi ..."
          brew upgrade pulumi
       fi
   fi
   fancy_echo "Pulumi: $(pulumi version)"  # v0.16.7

echo "### Populate MY_PULUMI_FOLDER $MY_PULUMI_FOLDER with examples and templates repo:"

      if [ -d "$MY_PULUMI_FOLDER" ]; then
         fancy_echo "MY_PULUMI_FOLDER $MY_PULUMI_FOLDER already exists."
      else
         fancy_echo "Creating $MY_PULUMI_FOLDER ..."
         mkdir "$MY_PULUMI_FOLDER"
      fi


      # TODO: and empty
      if [ -d "$MY_PULUMI_FOLDER/examples" ]; then
         fancy_echo "MY_PULUMI_FOLDER/examples already exists. Updating..."
         pushd "$MY_PULUMI_FOLDER/examples" >/dev/null
         git remote -v
         git pull 
         echo ">>> Last commit:"
         git log -n 1
         echo ">>> List folders and files:"
         ls 
         popd >/dev/null
      else
         fancy_echo "Creating $MY_PULUMI_FOLDER/examples ..."
         pushd "$MY_PULUMI_FOLDER" >/dev/null
         # mkdir "$MY_PULUMI_FOLDER" is done by clone:
         git clone https://github.com/pulumi/examples  # using master and other branches
         cd examples
         echo ">>> Last commit:"
         git log -n 1
         echo ">>> List folders and files:"
         ls 
         popd >/dev/null
      fi


      if [ -d "$MY_PULUMI_FOLDER/templates" ]; then
         fancy_echo "MY_PULUMI_FOLDER/templates already exists. Updating..."
         pushd "$MY_PULUMI_FOLDER/templates" >/dev/null
         git remote -v
         git pull 
         echo ">>> Last commit:"
         git log -n 1
         echo ">>> List folders and files:"
         ls 
         popd >/dev/null
      else
         fancy_echo "Creating $MY_PULUMI_FOLDER/templates ..."
         pushd "$MY_PULUMI_FOLDER" >/dev/null
         # mkdir "$MY_PULUMI_FOLDER" is done by clone:
         git clone https://github.com/pulumi/templates  --depth=1  # using master branch only
         cd templates
         echo ">>> Last commit:"
         git log -n 1
         echo ">>> List folders and files:"
         ls 
         popd >/dev/null
      fi


echo "### Ensure Docker app is installed:"  # See https://wilsonmar.github.io/docker
   if ! command_exists docker ; then
      fancy_echo "Installing docker app using brew..."
      brew cask install docker  # to $HOME/Applications/
          # Docker whale icon should now appear in your mac's top status menu.
          # PROTIP: The GUI app cask install includes docker command line utilities.
      docker run hello-world

      brew install bash-completion  # for specific os version
         # /usr/local/Cellar/bash-completion/1.3_3: 189 files, 607.8KB
      brew install docker-completion
         # /usr/local/Cellar/docker-completion/18.09.0: 7 files, 294.8KB, built in 55 seconds
      brew install docker-compose-completion
      brew install docker-machine-completion
   else
      if [[ "$RUNTYPE" == upgrade ]]; then
         fancy_echo "Upgrading docker app ..."
         brew cask upgrade docker

         brew upgrade bash-completion
         brew upgrade docker-completion
         brew upgrade docker-compose-completion
         brew upgrade docker-machine-completion
       fi
   fi
   fancy_echo "$(docker -v)"  # Docker version 17.09.0-ce, build afdb6d4
      # PROTIP: $(docker version) displays more detail


echo "### Ensure Docker app is running:"
   fancy_echo "Docker stats --no-stream ..."
   # Alternately, check for the existence of /var/run/docker.pid ?
   if (! docker stats --no-stream ); then # not running, so:
      open "$HOME/Applications/Docker.app" # on macOS, no response if good.
      # Loop and wait until Docker daemon/app is initialized with "Docker is running" displayed:
      while (! docker stats --no-stream ); do
         # Docker takes a few seconds to initialize
         echo "Waiting for Docker to launch ..."
         sleep 5
      done
   # else RESPONSE:
      # CONTAINER           CPU %               MEM USAGE / LIMIT     MEM %               NET I/O             BLOCK I/O           PIDS
      # 1137f5a5a568        0.00%               1.945MiB / 1.952GiB   0.10%               1.5kB / 0B          0B / 0B             2
   fi


echo "### Ensure Docker container is running:"
# Based on https://docs.docker.com/engine/reference/commandline/ps/
# check if an exited container blocks, so you can remove it first prior to run the container:

   fancy_echo "Docker images:"
   docker images
      # RESPONSE SAMPLE:
      # REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
      # nginx               latest              568c4670fa80        2 weeks ago         109MB
      # hello-world         latest              4ab4c602aa5e        3 months ago        1.84kB   

   fancy_echo "Docker run $MY_DOCKER_IMAGE ..."
   #docker run "$MY_DOCKER_COMMAND" &
      # SUCH AS: docker run -p 8080:80 nginx 
   docker run -p 8080:80 "$MY_DOCKER_IMAGE"  &
      # RESPONSE is ps ID such as [1] 24467
   fancy_echo "open http://localhost:80 ..."
   open http://localhost:8080  # in default browser

   fancy_echo "ps -al | grep docker ..."
   ps -al | grep docker

   fancy_echo "docker ps ..."
   MY_DOCKER_CONTAINERS="$(docker ps)"
   echo "$MY_DOCKER_CONTAINERS"
      # SAMple rsponse;
      # CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS              PORTS                  NAMES
      # 89f8e3a79e22        nginx               "nginx -g 'daemon ..."   15 seconds ago      Up 14 seconds       0.0.0.0:8080->80/tcp   laughing_bardeen
   MY_DOCKER_CONTAINER_ID="$(docker ps) | grep $MY_DOCKER_IMAGE"
   echo "MY_DOCKER_CONTAINER_ID=$MY_DOCKER_CONTAINER_ID"
exit

echo "### Run pulumi new to create new container:"

   pulumi new javascript --dir "$MY_DOCKER_CONTAINER_ID" --yes
   		# Installing dependencies ...
   		#      Type                 Name                                       Plan       
 		# +   pulumi:pulumi:Stack  fargate-pulumi-aws-fargate-pulumi-aws-dev  create     
    		# Do you want to perform this update? > yes
   cd "$MY_DOCKER_CONTAINER"
   echo "Now at $PWD"
ls -al
exit

echo "### pulumi login:"
RESULT="$(pulumi login)"
      # RESPONSE: Logged into pulumi.com as wilsonmar (https://app.pulumi.com/wilsonmar)

### Verify Pulumi credentials
MY_PULUMI_ID=$(pulumi whoami)
# if MY_PULUMI_ID= blank
echo "MY_PULUMI_ID=$MY_PULUMI_ID"

echo "### list stacks associated with login:"
pulumi stack ls

echo "### Delete stack from prior run:"
pulumi stack rm "$MY_STACK_NAME" >>ANSWER
"$MY_STACK_NAME" 
ANSWER
   # This will permanently remove the 'fargate-pulumi-aws-dev' stack!
   # Please confirm that this is what you'd like to do by typing ("fargate-pulumi-aws-dev"): 
   # Stack 'fargate-pulumi-aws-dev' has been removed!
### Initialize in Pulumi cloud console at # https://app.pulumi.com/welcome/cli
pulumi stack init "$MY_STACK_NAME"
   # RESPONSE: Created stack 'fargate-pulumi-aws-dev'
	# error: stack 'fargate-pulumi-aws' already exists
		
exit

### Configure Pulumi to use AWS Fargate, which is currently only available in us-east-1, us-east-2, us-west-2, and eu-west-1:
pulumi config set aws:region "$MY_AWS_REGION"

pulumi config set cloud-aws:useFargate true

exit

### Restore NPM modules via npm install or yarn install.
### Preview and deploy the app via pulumi up. 
pulumi up
	# error: no Pulumi.yaml project file found
	# The preview will take a few minutes, as it builds a Docker container. A total of 19 resources are created.


### View the endpoint URL, and run curl:
pulumi stack output
#Current stack outputs (1)
#    OUTPUT                  VALUE
#    hostname                http://***.elb.us-west-2.amazonaws.com

echo "### Display code using curl command:"
curl $(pulumi stack output hostname)
   #<html>
   #    <head><meta charset="UTF-8">
   #    <title>Hello, Pulumi!</title></head>
   #<body>
   #    <p>Hello, S3!</p>
   #    <p>Made with ❤️ with <a href="https://pulumi.com">Pulumi</a></p>
   #</body></html>

### To view the runtime logs from the container:
pulumi logs --follow
	# Collecting logs for stack container-quickstart-dev since 2018-05-22T14:25:46.000-07:00.
	# 2018-05-22T15:33:22.057-07:00[                  pulumi-nginx] 172.31.13.248 - - [22/May/2018:22:33:22 +0000] "GET / HTTP/1.1" 200 189 "-" "curl/7.54.0" "-"

### Clean up resources:
# and answer the confirmation question at the prompt.
pulumi destroy --yes


### Delete stack
pulumi stack rm "$MY_STACK_NAME" <<ANSWERS
"$MY_STACK_NAME" 
ANSWERS
