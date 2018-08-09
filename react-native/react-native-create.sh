# react-native-create.sh

# Expo (formerly Exponent) is like "Rails" for React.
# Intro video: https://www.youtube.com/watch?v=IQI9aUlouMI
# Video: https://www.youtube.com/watch?v=yuaE8_nXmeY
# https://www.youtube.com/watch?v=UNMOc6dDaDI - 7 Advantages of Expo vs React Native by Tim
# Unsure Programmer's https://www.youtube.com/watch?v=Y-HvC0AHeF8 - #1 React Native Beginner - Why React Native and Expo .io
   #2 https://www.youtube.com/watch?v=Rl8kSCZoXEk
   #3 https://www.youtube.com/watch?v=_XZqafNubyQ

WORKDIR="react-native"
APPNAME="my-app"

# Install video: https://www.youtube.com/watch?v=Rl8kSCZoXEk
# https://docs.expo.io/versions/latest/
   # Expo XDE installer xde-2.24.4.dmg

echo ">>> soft and hard $(launchctl limit maxfiles)" 
	# 	maxfiles    256            unlimited   
echo ">>> TODO: Stop for Reboot if not"
    # /usr/bin/ulimit: line 4: ulimit: open files: cannot modify limit: Invalid argument
# See https://git.io/v5vcn for more information, either install watchman or run the following snippet:
# See man launchd.plist for use by 
# cat /etc/launchd.conf  # was in until Yosemite.
  sudo sysctl -w kern.maxfiles=5242880
     # kern.maxfiles: 49152 -> 5242880
  sudo sysctl -w kern.maxfilesperproc=524288
     # kern.maxfilesperproc: 24576 -> 524288
# if -f /etc/launchd.conf then sudo echo "limit maxfiles 65536 200000" >/etc/launchd.conf

ulimit -n 65536 200000  # launchctl limit maxfiles
# https://docs.basho.com/riak/kv/2.2.3/using/performance/open-files-limit/#mac-os-x-el-capitan


cd ~/gits/wilsonmar
rm -rf $WORKDIR
mkdir $WORKDIR
cd $WORKDIR 

# From https://github.com/react-community/create-react-native-app
npm install -g create-react-native-app
   # /usr/local/bin/create-react-native-app -> /usr/local/lib/node_modules/create-react-native-app/build/index.js
   # + create-react-native-app@1.0.0
   # updated 1 package in 3.33s

create-react-native-app $APPNAME
cd $APPNAME
npm start
   # Your app is now running at URL: exp://10.0.0.4:19000

# Sign-up at https://expo.io
# Install iOS/Android app "Expo client" which has a QR scanner.
   # https://docs.expo.io/versions/latest/guides/publishing.html
