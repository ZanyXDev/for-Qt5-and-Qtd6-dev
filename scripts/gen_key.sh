#!/bin/bash

export ANDROID_NDK_ROOT="/opt/android-sdk/ndk"

export ANDROID_HOME=/opt/android-sdk
export ANDROID_SDK_ROOT=${ANDROID_HOME}
export ANDROID_NDK_ROOT=${ANDROID_HOME}/ndk/${NDK_VERSION}
export ANDROID_NDK_HOST=linux-x86_64
export ANDROID_NDK_PLATFORM=${MIN_NDK_PLATFORM}
export ANDROID_API_VERSION=${SDK_PLATFORM}
export ANDROID_NDK=$ANDROID_NDK_ROOT
export JAVA_HOME=/opt/java/openjdk

[[ -d /home/developer/.android ]] || mkdir /home/developer/.android/

#${JAVA_HOME}/bin/keytool -list -v -alias androiddebugkey -keystore /home/developer/.android/debug.keystore
${JAVA_HOME}/bin/keytool -genkey -keystore /home/developer/.android/debug.keystore -alias androiddebugkey \
    -storepass android -keypass android -keyalg RSA -keysize 2048 -validity 10000 \
    -dname 'CN=Android Debug,O=Android,C=US'

chown -R $USER_ID:$GROUP_ID /home/developer/.android/

