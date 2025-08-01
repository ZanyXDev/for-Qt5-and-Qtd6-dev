#!/usr/bin/env bash
set -Eeuxo pipefail # https://vaneyckt.io/posts/safer_bash_scripts_with_set_euxo_pipefail/
#-------------------------------------------------------------------------------
download_and_chmod(){
    local fname=$1
    local ext=${fname##*.}

    "${Curl[@]}" "$RepoUrl"/$fname  -o ./$fname
    [[ -e $fname ]] && {   
        echo "success downloading ${fname} with ext == ${ext}"   
        [[ "$ext" = "sh" ]] && chmod +x $fname       
    } || return 1  
}

create_app_directory() {
  local -r Tgt="$HOME"/qtcreator-app
  echo "Creating QtCreatorApp directory..."  
  [[ -d $Tgt ]] || mkdir $Tgt    
  cd $Tgt  || return 1
}

download_dot_env_file() {
[[ -f .env ]] || {
  echo "Downloading .env file..."
  "${Curl[@]}" "$RepoUrl"/qtcreator_app.env -o ./.env
}  
  set -a && source .env && set +a    
  return $?
}

function download_scripts(){
  echo "Downloading scripts file..."  
  download_and_chmod "qt5_git_clone.sh"
  download_and_chmod "openssl_git_clone.sh" 
  download_and_chmod "get_androidsdk.sh" 
  download_and_chmod "build_qt5_amd64.sh"
  download_and_chmod "build_qt5_android.sh"
}

create_docker_run_env(){
  [[ -e run_env.list ]] && rm -f run_env.list
  touch run_env.list
  echo "USER_ID=$(id -u ${USER})" >> run_env.list
  echo "GROUP_ID=$(id -g ${USER})"  >> run_env.list
  echo "CCACHE_DIR=/ccache"  >> run_env.list
  echo "QT_PATH_AMD64=/opt/Qt/${QT_VERSION_SHORT}-amd64-lts-lgpl"  >> run_env.list
  echo "QT_PATH_ANDROID=/opt/Qt/${QT_VERSION_SHORT}-android-lts-lgpl"  >> run_env.list          
  return $? 
}

pull_docker_images() {
  echo "Pulling docker images"
  docker pull ${BITNAMI_GIT} 
  docker pull ${UBUNTU_LTS}
  docker pull ${TEMURIN_JDK_17}    
  docker pull alpine:3.14.2
}

docker_prune_volumes(){
   docker volume rm ${SRC_VOLUME_NAME} || true
   docker volume rm ${OPT_VOLUME_NAME} || true   
   return $?
}

download_to_opt_volume(){
echo "Download other source to opt volume..."  
docker run \
--env-file run_env.list  \
--volume ${OPT_VOLUME_NAME}:/opt \
--volume ${SRC_VOLUME_NAME}:/usr/local/src \
-ti --rm ${UBUNTU_LTS} bash -c '#!/bin/bash
ANDROID_SDK_ROOT="/opt/android-sdk"
ANDROID_NDK_ROOT="/opt/android-sdk/ndk"
CMAKE_URL=$1
QTCREATOR_URL=$2    
CMDTOOLS_URL=$3                             
[[ -d /opt/cmake ]] || mkdir /opt/cmake  
[[ -d /opt/download/ ]] || mkdir /opt/download/
apt-get -y update && apt-get -y upgrade && apt-get -y install wget unzip;
(  
    wget -O /opt/download/cmake.tar.gz ${CMAKE_URL}
    wget -O /opt/download/qtcreator.deb ${QTCREATOR_URL}
    echo "Download ndk samples"
    wget -O /opt/download/master.zip https://github.com/android/ndk-samples/archive/master.zip
    echo "Download buildtool to generate aab packages in ${ANDROID_SDK_ROOT}"
    wget -O ${ANDROID_SDK_ROOT}/bundletool-all-1.3.0.jar https://github.com/google/bundletool/releases/download/1.3.0/bundletool-all-1.3.0.jar
    echo "Download cmdline-tools"
    wget -O /opt/download/commandlinetools.zip ${CMDTOOLS_URL} 
)& 
last_task_pid=$!   
wait  $last_task_pid   
          
tar -xzf /opt/download/cmake.tar.gz  --strip-components=1 -C /opt/cmake     
dpkg --extract  /opt/download/qtcreator.deb /  

echo "Unzip cmdLineTools"
unzip /opt/download/commandlinetools.zip -d /opt

echo "Move ndk samples in ${ANDROID_NDK_ROOT}/samples"
cd /opt/download/
unzip -q master.zip 
[[ -d ${ANDROID_NDK_ROOT}/samples ]] || mkdir -p ${ANDROID_NDK_ROOT}/samples
mv ndk-samples-master ${ANDROID_NDK_ROOT}/samples    

chown -R $USER_ID:$GROUP_ID /opt

' docker_bash ${CMAKE_URL} ${QTCREATOR_URL}  ${CMDTOOLS_URL} 
  return $?   
}

copy_java_to_opt_volume(){
echo "Copy java from container..."   
docker run --volume ${OPT_VOLUME_NAME}:/mnt -ti --rm ${TEMURIN_JDK_17} bash -c '
#!/bin/bash  
mkdir -p  /mnt/java/openjdk
cp -r /opt/java/openjdk /mnt/java/
'
return $? 
}

git_clone_source() {
    echo "Use git for clone sources..."
    
    docker run \
       --volume ./qt5_git_clone.sh:/root/qt5_git_clone.sh  \
	   --volume  ${SRC_VOLUME_NAME}:/usr/local/src \
       -ti --rm --name git bitnami/git:latest /root/qt5_git_clone.sh ${QT_VERSION} "https://invent.kde.org/qt/qt/qt5.git" "/usr/local/src/qt5" >/dev/null 2>&1 && 
    {
        echo "success git clone '$QT_VERSION'"    
    } || 
    {
        echo "failed from git clone '$QT_VERSION'"
        return 1
    }
   
   docker run \
       --volume ./openssl_git_clone.sh:/root/openssl_git_clone.sh  \
	   --volume ${OPT_VOLUME_NAME}:/mnt \
       -ti --rm --name git bitnami/git:latest /root/openssl_git_clone.sh "https://github.com/KDAB/android_openssl.git" "/mnt/android-sdk/android_openssl" >/dev/null 2>&1 && 
    {
        echo "success git clone android_openssl from KDAB"    
    } || 
    {
        echo "failed from git clone android_openssl from KDAB"
        return 1
    }
}

docker_build_builder(){     
if [ -z "$(docker images -q ${BUILDER_IMAGE_NAME} 2> /dev/null)" ]; then
# do build stage_1
docker build --build-arg="QT_VERSION=${QT_VERSION_SHORT}" \
    --build-arg="LANG=ru-RU.UTF-8" \
    --build-arg="TZ=Europe/Moscow" \
    --platform=linux/amd64 \
    --target=stage_1 \
    --tag=${BUILDER_IMAGE_NAME} \
    --progress=plain https://github.com/ZanyXDev/for-Qt5-and-Qtd6-dev.git#main:builder            
fi

if [ -z "$(docker images -q ${QTCREATOR_IMAGE_NAME} 2> /dev/null)" ]; then
# do build stage_2
docker build \
    --build-arg="QT_VERSION=${QT_VERSION_SHORT}" \
    --build-arg="LANG=ru-RU.UTF-8" \
    --build-arg="TZ=Europe/Moscow" \
            --build-arg="USER_ID=$(id -u ${USER})"  \
            --build-arg="GROUP_ID=$(id -g ${USER})" \
	        --platform=linux/amd64 \
	        --target=stage_2 \
	        --tag=${QTCREATOR_IMAGE_NAME} \
	        --progress=plain https://github.com/ZanyXDev/for-Qt5-and-Qtd6-dev.git#main:builder            
fi
    return $?  
}

update_android_sdk(){
echo "Update android_sdk with toolchain container..."            
docker run --env-file run_env.list \
    --volume ${OPT_VOLUME_NAME}:/opt \
    --volume ./get_androidsdk.sh:/root/get_androidsdk.sh \
    -ti --rm ${BUILDER_IMAGE_NAME} /root/get_androidsdk.sh
return $?
}

build_qt5_amd64-target(){
  docker image inspect ${BUILDER_IMAGE_NAME} >/dev/null 2>&1 && {
  echo "Build ${QT_VERSION} amd64-lts-lgplwith toolchain container..."    
  docker run \
      --env-file run_env.list  \
      --cpus=2.5 \
      --volume ${CCACHE_VOLUME}:/ccache \
      --volume ${OPT_VOLUME_NAME}:/opt \
      --volume ${SRC_VOLUME_NAME}:/usr/local/src:ro \
      --volume ./build_qt5_amd64.sh:/root/build_qt5_amd64.sh  \
      -ti --rm ${BUILDER_IMAGE_NAME} /root/build_qt5_amd64.sh  
  return $?
  }
}
 
build_qt5_android-target(){
  docker image inspect ${BUILDER_IMAGE_NAME} >/dev/null 2>&1 && {
  echo "Build ${QT_VERSION} android-lts-lgpl with toolchain container..."    
  docker run \
   --env-file run_env.list  \
   --cpus=2.5 \
      --volume ${CCACHE_VOLUME}:/ccache \
      --volume ${OPT_VOLUME_NAME}:/opt\
      --volume ${SRC_VOLUME_NAME}:/usr/local/src:ro \
      --volume ./build_qt5_android.sh:/root/build_qt5_android.sh  \
      -ti --rm ${BUILDER_IMAGE_NAME} /root/build_qt5_android.sh 
  return $?
  }
}

update_ldconfig(){
docker image inspect ${BUILDER_IMAGE_NAME} >/dev/null 2>&1 && {
  echo "Update ldconfig inside container..."    
  docker run --env-file run_env.list --volume ${OPT_VOLUME_NAME}:/opt -ti --rm ${BUILDER_IMAGE_NAME} /sbin/ldconfig
  return $?
  }
}
setup_darkula(){
docker image inspect ${BUILDER_IMAGE_NAME} >/dev/null 2>&1 && {
  echo "setup darcula theme..."    
  docker run \
    --env-file run_env.list \
    --volume ${SRC_VOLUME_NAME}:/usr/local/src \
    --volume ${OPT_VOLUME_NAME}:/opt \    
    -ti --rm ${BUILDER_IMAGE_NAME} bash -c \
'#!/bin/bash
cd /usr/local/src
git clone https://github.com/dracula/qtcreator.git
cd qtcreator
cp dracula.xml /opt/qt-creator/share/qtcreator/styles
cp drakula.creatortheme /opt/qt-creator/share/qtcreator/themes
cp drakula.figmatokens  /opt/qt-creator/share/qtcreator/themes
chown -R $USER_ID:$GROUP_ID /opt/qt-creator/share/qtcreator/
'
  return $?
  }

}
#-------------------------------------------------------------------------------
# MAIN
main() {
  echo "Starting QTCreator in docker installation..."
  local -a Curl  
  local -r RepoUrl='https://github.com/ZanyXDev/for-Qt5-and-Qtd6-dev/releases/latest/download'   
   
  if command -v curl >/dev/null; then
    Curl=(curl -fsSL)
  else
    echo 'no curl binary found; please install curl [sudo apt install curl] and try again'
    return 10
  fi
 

  create_app_directory || {
    echo 'error creating QtCreator app directory'
    return 11
  }
  
  download_dot_env_file || {
    echo 'error downloading .env'
    return 12
  } 
  
  download_scripts || {
    echo 'error downloading scripts'
    return 13
  }
  create_docker_run_env || {
    echo 'error creating docker run env file'
    return 11
  }
  pull_docker_images || {
    echo 'error pulling Docker images'
    return 14
  }
 
  docker_prune_volumes|| {
    echo 'error remove volumes'
    return 15
  }  
  
  download_to_opt_volume || {
    echo 'error download to opt volume'
    return 16
  }  
  
  copy_java_to_opt_volume || {
    echo 'error copy java to opt volume'
    return 17
  } 
  
   git_clone_source || {
    echo 'error git clone sources'
    return 18 
  }
  
  docker_build_builder || {
    echo 'error build toolchain'
    return 19
  }    
 
  update_android_sdk || {
    echo 'error update android sdk'
    return 20
  }
  
  build_qt5_amd64-target || {    
    echo 'error build qt5 amd64 target'
    return 21
  }
  
  build_qt5_android-target || {
    echo 'error build qt5 android target'
    return 22
  }
  update_ldconfig || {
    echo 'error update ldconfig'
    return 23
  }
  
  setup_darkula || {
    echo 'error git clone and setup darkula theme'
    return 24
  }
  return 0
}

main
Exit=$?
[[ $Exit == 0 ]] || echo "There was an error installing qt-creator in docker. Exit code: $Exit. Please provide these logs when asking for assistance."
exit "$Exit"


#docker exec --env-file .env container-name env  
