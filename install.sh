#!/usr/bin/env bash
set -o nounset
set -o pipefail
tput setab 2
reset
set -x

create_app_directory() {
  local -r Tgt="$HOME"/qtcreator-app
  echo "Creating QtCreatorApp directory..."  
  [[ -d $Tgt ]] || mkdir $Tgt    
  cd $Tgt  || return 1
}

download_dot_env_file() {
  echo "Downloading .env file..."
  "${Curl[@]}" "$RepoUrl"/qtcreator_app.env -o ./.env
  [[ -e .env ]] && {   
    HOST_TARGET=`lscpu | grep Architecture | awk {'print $2'}`  
    set -a && source .env && set +a
  } || return 1  
}

download_docker_compose_file() {
  echo "Downloading docker-compose.yml..."
  #"${Curl[@]}" "$RepoUrl"/docker-compose.yml -o ./docker-compose.yml
}

pull_docker_images() {
  echo "Pulling docker images"
  docker pull bitnami/git:latest
  docker pull ubuntu:22.04
  docker pull eclipse-temurin:17 
  
  docker image inspect $BITNAMI_GIT >/dev/null 2>&1 && 
  {
    echo "succes pulling '$BITNAMI_GIT'"  
    CONTAINER_NAME_GIT=$(docker ps -aq --filter name=git)  
    if [ -n "${CONTAINER_NAME_GIT}" ]; then
        echo "CONTAINER_NAME_GIT is set"
        docker rm $CONTAINER_NAME_GIT
    fi    
  } || 
  {
    echo "failed to pull '$BITNAMI_GIT'"
    return 1
  }
  
  docker image inspect $UBUNTU_LTS >/dev/null 2>&1 && 
  {
    echo "success pulling '$UBUNTU_LTS'"    
  } || 
  {
    echo "failed to pull '$UBUNTU_LTS'"
    return 1
  }
  
  docker image inspect $TEMURIN_JDK_17  >/dev/null 2>&1 && 
  {
    echo "succes pulling '$TEMURIN_JDK_17'"    
  } || 
  {
    echo "failed to pull '$TEMURIN_JDK_17'"
    return 1
  }
}

function download_scripts(){
  echo "Downloading scripts file..."  
  download_and_chmod "qt5_git_clone.sh"
  download_and_chmod "openssl_git_clone.sh" 
  download_and_chmod "get_androidsdk.sh" 
  download_and_chmod "build_qt5_amd64.sh"
  download_and_chmod "build_qt5_android.sh"
}

download_and_chmod(){
    local fname=$1
    local ext=${fname##*.}

    "${Curl[@]}" "$RepoUrl"/$fname  -o ./$fname
    [[ -e $fname ]] && {   
        echo "success downloading ${fname} with ext == ${ext}"   
        [[ "$ext" = "sh" ]] && chmod +x $fname       
    } || return 1  
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
	   --volume ${SDK_VOLUME_NAME}:/opt/android-sdk \
       -ti --rm --name git bitnami/git:latest /root/openssl_git_clone.sh "https://github.com/KDAB/android_openssl.git" "/opt/android-sdk/android_openssl" >/dev/null 2>&1 && 
    {
        echo "success git clone android_openssl from KDAB"    
    } || 
    {
        echo "failed from git clone android_openssl from KDAB"
        return 1
    }
}

docker_build_toolchain(){     
     docker image inspect ${TOOLCHAIN_IMAGE_NAME} >/dev/null 2>&1 || {
        echo "Build base toolchain..."    
        local LOG_NAME="${TOOLCHAIN_IMAGE_NAME//[:\/]/_}.log"        
        docker build \
	        --build-arg="QT_VERSION=${QT_VERSION_SHORT}" \
	        --build-arg="LANG=ru-RU.UTF-8" \
	        --build-arg="TZ=Europe/Moscow" \
	        --platform=linux/amd64 \
	        --tag=${TOOLCHAIN_IMAGE_NAME} \
	        --progress=plain \
            https://github.com/ZanyXDev/for-Qt5-and-Qtd6-dev.git#main:toolchain 2> ${LOG_NAME}
            return $?   
         }
}

update_android_sdk(){
    docker image inspect ${TOOLCHAIN_IMAGE_NAME} >/dev/null 2>&1 && {
        echo "Update android_sdk with toolchain container..."    
        local LOG_NAME="${TOOLCHAIN_IMAGE_NAME//[:\/]/_}.${HOST_TARGET}_android_sdk.log"   
        docker run \
           --env "USER_ID=$(id -u ${USER})" \
           --env "GROUP_ID=$(id -g ${USER})" \
	       --volume ${SDK_VOLUME_NAME}:/opt/android-sdk \
	       --volume ${SRC_VOLUME_NAME}:/usr/local/src \
	       --volume ./get_androidsdk.sh:/root/get_androidsdk.sh \
	       -ti --rm ${TOOLCHAIN_IMAGE_NAME} /root/get_androidsdk.sh 2>&1 ${LOG_NAME}
           return $?
         }
}

 build_qt5_amd64-target(){
  docker image inspect ${TOOLCHAIN_IMAGE_NAME} >/dev/null 2>&1 && {
  echo "Build ${QT_VERSION} amd64-lts-lgplwith toolchain container..."    
  docker run \
       --env "QT_PATH=/opt/Qt/${QT_VERSION_SHORT}-amd64-lts-lgpl" \
       --env "USER_ID=$(id -u ${USER})"       \
       --env "GROUP_ID=$(id -g ${USER})" \
       --env "CCACHE_DIR=/ccache" \
      --volume ${CCACHE_VOLUME}:/ccache \
      --volume ${SDK_VOLUME_NAME}:/opt/android-sdk \
      --volume ${QT5_OPT_VOLUME_NAME}:/opt/Qt \
      --volume ${SRC_VOLUME_NAME}:/usr/local/src:ro \
      --volume ./build_qt5_amd64.sh:/root/build_qt5_amd64.sh  \
      -ti --rm ${TOOLCHAIN_IMAGE_NAME} /root/build_qt5_amd64.sh  
  return $?
  }
}
 
build_qt5_android-target(){
  docker image inspect ${TOOLCHAIN_IMAGE_NAME} >/dev/null 2>&1 && {
  echo "Build ${QT_VERSION} android-lts-lgpl with toolchain container..."    
  docker run \
       --env "QT_PATH=/opt/Qt/${QT_VERSION_SHORT}-android-lts-lgpl" \
       --env "USER_ID=$(id -u ${USER})"       \
       --env "GROUP_ID=$(id -g ${USER})" \
       --env "CCACHE_DIR=/ccache" \
      --volume ${CCACHE_VOLUME}:/ccache \
      --volume ${SDK_VOLUME_NAME}:/opt/android-sdk \
      --volume ${QT5_OPT_VOLUME_NAME}:/opt/Qt \
      --volume ${SRC_VOLUME_NAME}:/usr/local/src:ro \
      --volume ./build_qt5_android.sh:/root/build_qt5_android.sh  \
      -ti --rm ${TOOLCHAIN_IMAGE_NAME} /root/build_qt5_android.sh 
  return $?
  }
}

docker_build_qt_creator(){     
     docker image inspect ${TOOLCHAIN_IMAGE_NAME} >/dev/null 2>&1 && {
        echo "Build Main image with QtCreator..."    
        local LOG_NAME="${TOOLCHAIN_IMAGE_NAME//[:\/]/_}_qtcreator.log"        
        echo ${LOG_NAME}
        docker build \
	        --build-arg="QT_VERSION=${QT_VERSION_SHORT}" \
            --build-arg="LANG=ru-RU.UTF-8" \
            --build-arg="TZ=Europe/Moscow" \
            --build-arg="QTCREATOR_URL=${QTCREATOR_URL}" \
            --build-arg="USER_ID=$(id -u ${USER})"       \
            --build-arg="GROUP_ID=$(id -g ${USER})"       \
            --platform=linux/amd64 \
	        --tag=${QTCREATOR_IMAGE_NAME} \
	        --progress=plain \
            https://github.com/ZanyXDev/for-Qt5-and-Qtd6-dev.git#main:gui 2> ${LOG_NAME}
            return $?   
         }
}
 
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
    
  download_docker_compose_file || {
    echo 'error downloading Docker Compose file'
    return 13
  }
  
  pull_docker_images || {
    echo 'error pulling Docker images'
    return 14
  }
  
  download_scripts || {
    echo 'error downloading scripts'
    return 15
  }
  
  git_clone_source || {
    echo 'error git clone sources'
    return 16  
  }
  
  docker_build_toolchain || {
    echo 'error build toolchain'
    return 17
  }
  
  update_android_sdk || {
    echo 'error update android sdk'
    return 18
  }
  
  build_qt5_amd64-target || {
    echo 'error build qt5 amd64 target'
    return 19
  }
  build_qt5_android-target || {
    echo 'error build qt5 android target'
    return 20
  }
  docker_build_qt_creator || {
    echo 'error build QtCreator image'
    return 21
  }
  return 0
}

main
Exit=$?
[[ $Exit == 0 ]] || echo "There was an error installing qt-creator in docker. Exit code: $Exit. Please provide these logs when asking for assistance."
exit "$Exit"


#docker exec --env-file .env container-name env  
