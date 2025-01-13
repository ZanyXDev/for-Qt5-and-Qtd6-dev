#!/bin/bash

echo "Temp update. not save in image"
apt-get -y update  
apt-get -y upgrade 
apt-get -y install curl unzip
    
ANDROID_SDK_ROOT="/opt/android-sdk"
ANDROID_NDK_ROOT="/opt/android-sdk/ndk"

cd /opt  
yes | sdkmanager --sdk_root=/opt/android-sdk --licenses
sdkmanager --sdk_root=/opt/android-sdk --list; 
sdkmanager --sdk_root=/opt/android-sdk "platforms;android-30" "platform-tools" "build-tools;30.0.2"; 
sdkmanager --sdk_root=/opt/android-sdk "platforms;android-31" "platform-tools" "build-tools;31.0.0"; 
sdkmanager --sdk_root=/opt/android-sdk "ndk;21.3.6528147"; 
sdkmanager --sdk_root=/opt/android-sdk "ndk;22.1.7171670"; 
sdkmanager --sdk_root=/opt/android-sdk "ndk;25.1.8937393";
sdkmanager --sdk_root=/opt/android-sdk 'cmdline-tools;latest'

echo "Install ndk samples in ${ANDROID_NDK_ROOT}/samples"
cd /tmp
curl -sLO https://github.com/android/ndk-samples/archive/master.zip
unzip -q master.zip 
[[ -d ${ANDROID_NDK_ROOT}/samples ]] || mv ndk-samples-master ${ANDROID_NDK_ROOT}/samples

echo "Download buildtool to generate aab packages in ${ANDROID_SDK_ROOT}"

cd ${ANDROID_SDK_ROOT}
[[ -f ${ANDROID_SDK_ROOT}/bundletool-all-1.3.0.jar ]] || curl -sLO https://github.com/google/bundletool/releases/download/1.3.0/bundletool-all-1.3.0.jar
    
chown -R $USER_ID:$GROUP_ID /opt/android-sdk/
chown -R $USER_ID:$GROUP_ID /opt/cmdline-tools/
