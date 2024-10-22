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
  curl -fsSL https://raw.githubusercontent.com/ZanyXDev/for-Qt5-and-Qtd6-dev/refs/heads/main/qtcreator_app.env -o ./.env
  [[ -e .env ]] && {   
    HOST_TARGET=`lscpu | grep Architecture | awk {'print $2'}`  
    set -a && source .env && set +a
  } || return 1  
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
   
docker_update_qt_creator(){     
     docker image inspect ${TOOLCHAIN_IMAGE_NAME} >/dev/null 2>&1 && {
        echo "ReBuild Main image with QtCreator..."    
        local LOG_NAME="${TOOLCHAIN_IMAGE_NAME//[:\/]/_}_qtcreator.log"        
        echo ${LOG_NAME}
        docker build \
            --build-arg="CMAKE_URL=https://github.com/Kitware/CMake/releases/download/v3.30.5/cmake-3.30.5-linux-x86_64.tar.gz" \
            --build-arg="CMDTOOLS_URL=https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip" \
            --build-arg="QTCREATOR_URL=${QTCREATOR_URL}" \
            --build-arg="QT_VERSION=${QT_VERSION_SHORT}" \
            --build-arg="TZ=Europe/Moscow" \
            --build-arg="USER_ID=$(id -u ${USER})"       \
            --build-arg="GROUP_ID=$(id -g ${USER})"       \
            --platform=linux/amd64 \
	        --tag=${QTCREATOR_IMAGE_NAME} \
	        --progress=plain \
            https://github.com/ZanyXDev/for-Qt5-and-Qtd6-dev.git#main:update 2> ${LOG_NAME}
            return $?   
         }
}
 
# MAIN
main() {
  echo "Starting QTCreator in docker installation..."
  local -a Curl   
 
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
  pull_docker_images || {
    echo 'error pulling Docker images'
    return 13
  }

  docker_update_qt_creator || {
    echo 'error update QtCreator image'
    return 21
  }
  return 0
}


main
Exit=$?
[[ $Exit == 0 ]] || echo "There was an error installing qt-creator in docker. Exit code: $Exit. Please provide these logs when asking for assistance."
exit "$Exit"


#docker exec --env-file .env container-name env  
