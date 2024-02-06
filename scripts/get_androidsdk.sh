#!/bin/bash
set -e
USER_ID=$1
GROUP_ID=$2

echo "Temp update. not save in image"
apt-get -y update  
apt-get -y upgrade 
apt-get -y install wget curl unzip
    
[[ -d /opt/android-sdk/android_openssl ]] || mkdir /opt/android-sdk/android_openssl
    
cp -r /usr/local/src/android_openssl/* /opt/android-sdk/android_openssl

ANDROID_SDK_ROOT="/opt/android-sdk"
ANDROID_NDK_ROOT="/opt/android-sdk/ndk"

cd /opt  
yes | sdkmanager --sdk_root=/opt/android-sdk --licenses
sdkmanager --sdk_root=/opt/android-sdk "platforms;android-31" "platform-tools" "build-tools;31.0.0"; 
sdkmanager --sdk_root=/opt/android-sdk --list; 
sdkmanager --sdk_root=/opt/android-sdk "ndk;22.1.7171670"; 

[[ -d /opt/android-sdk/cmdline-tools ]] || mkdir /opt/android-sdk/cmdline-tools 
ln -fs /opt/cmdline-tools/ /opt/android-sdk/cmdline-tools/latest

# Install ndk samples in ${ANDROID_NDK_ROOT}/samples
cd ${ANDROID_NDK_ROOT}
curl -sLO https://github.com/android/ndk-samples/archive/master.zip
unzip -q master.zip 
rm -v master.zip
mv ndk-samples-master samples

# Download buildtool to generate aab packages in ${ANDROID_SDK_ROOT}
cd ${ANDROID_SDK_ROOT}
curl -sLO https://github.com/google/bundletool/releases/download/1.3.0/bundletool-all-1.3.0.jar
    
chown -R $USER_ID:$GROUP_ID /opt/android-sdk/