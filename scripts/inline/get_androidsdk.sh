#!/bin/bash
set -e
cd /opt  
yes | sdkmanager --sdk_root=/opt/android-sdk --licenses
sdkmanager --sdk_root=/opt/android-sdk "platforms;android-31" "platform-tools" "build-tools;31.0.0"; 
sdkmanager --sdk_root=/opt/android-sdk --list; 
sdkmanager --sdk_root=/opt/android-sdk "ndk;22.1.7171670"; 

