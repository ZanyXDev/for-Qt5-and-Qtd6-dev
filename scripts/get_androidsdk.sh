#!/bin/bash
cd /opt  
yes | sdkmanager --sdk_root=/opt/android-sdk --licenses
sdkmanager --sdk_root=/opt/android-sdk "platforms;android-30" "platform-tools" "build-tools;30.0.2"; 
sdkmanager --sdk_root=/opt/android-sdk "platforms;android-31" "platform-tools" "build-tools;31.0.0"; 
sdkmanager --sdk_root=/opt/android-sdk --list; 
sdkmanager --sdk_root=/opt/android-sdk "ndk;22.1.7171670"; 
sdkmanager --sdk_root=/opt/android-sdk "ndk;25.1.8937393";    
chown -R $USER_ID:$GROUP_ID /opt/android-sdk/

