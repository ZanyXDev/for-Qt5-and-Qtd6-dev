#!/bin/bash
set -Eeuxo pipefail # https://vaneyckt.io/posts/safer_bash_scripts_with_set_euxo_pipefail/

SRC_VOLUME_NAME="source-storage"
SDK_VOLUME_NAME="androidsdk-storage"
QT5_VOLUME_NAME="qt5-binary-storage"

echo docker run \
	   -v  ${SRC_VOLUME_NAME}:/usr/local/src \
       -ti --rm --name git bitnami/git:latest bash -c '
#!/bin/bash
set -e
QT_VERSION="v5.15.10-lts-lgpl"
REPOSRC="https://invent.kde.org/qt/qt/qt5.git"
LOCALREPO="/usr/local/src/qt5"

git clone --depth 1 --branch $QT_VERSION \
		"$REPOSRC" "$LOCALREPO" 2> /dev/null || (git -C "$LOCALREPO" pull)
cd  $LOCALREPO
git -c submodule."qt3d".update=none -c submodule."qtactiveqt".update=none -c submodule."qtcanvas3d".update=none  \
         -c submodule."qtdatavis3d".update=none -c submodule."qtgamepad".update=none -c submodule."qtlottie".update=none    \
         -c submodule."qtmacextras".update=none -c submodule."qtpim".update=none -c submodule."qtquick3d".update=none   \
         -c submodule."qtscript".update=none -c submodule."qtscxml".update=none -c submodule."qtspeech".update=none    \
	 -c submodule."qtvirtualkeyboard".update=none -c submodule."qtwebengine".update=none -c submodule."qtwebglplugin".update=none \
         -c submodule."qtwebsockets".update=none -c submodule."qtwebview".update=none  -c submodule."qtwinextras".update=none  \
         -c submodule."qtxmlpatterns".update=none submodule update --init --recursive
'
echo -e "Clone KDAB android_openssl"
echo docker run \
	  -v  ${SDK_VOLUME_NAME}:/usr/local/src \
      -ti --rm --name git bitnami/git:latest bash -c '
#!/bin/bash
set -e
REPOSRC="https://github.com/KDAB/android_openssl.git"
LOCALREPO="/opt/android-sdk/android_openssl"

git clone --depth 1 "$REPOSRC" "$LOCALREPO" 2> /dev/null || (git -C "$LOCALREPO" pull)
'

IMAGE_NAME="zanyxdev/qt5-toolchain:latest"
echo docker run \
	  -v ${SDK_VOLUME_NAME}:/opt/android-sdk \
	  -v ${QT5_VOLUME_NAME}:/opt/Qt \
	  -v $(pwd)/inline/get_androidsdk.sh:/root/get_androidsdk.sh  \
      -ti --rm ${IMAGE_NAME} /root/get_androidsdk.sh
      
docker run \
	-v ${SRC_VOLUME_NAME}:/usr/local/src:ro \
	-v ${SDK_VOLUME_NAME}:/opt/android-sdk \
	-v ${QT5_VOLUME_NAME}:/opt/Qt \
	-v /home/zanyxdev/git_source/my_src/docker/for-Qt5-and-Qtd6-dev/scripts/inline/build_qt5_android.sh:/root/build_qt.sh \
	-ti --rm ${IMAGE_NAME}  bash

#/root/build_qt.sh

