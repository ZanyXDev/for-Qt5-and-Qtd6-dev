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
       -v ./qt5_git_clone.sh:/root/qt5_git_clone.sh  \
	   -v  ${SRC_VOLUME_NAME}:/usr/local/src \
       -ti --rm --name git bitnami/git:latest /root/qt5_git_clone.sh ${QT_VERSION} "https://invent.kde.org/qt/qt/qt5.git" "/usr/local/src/qt5" >/dev/null 2>&1 && 
    {
        echo "success git clone '$QT_VERSION'"    
    } || 
    {
        echo "failed from git clone '$QT_VERSION'"
        return 1
    }
   
   docker run \
       -v ./openssl_git_clone.sh:/root/openssl_git_clone.sh  \
	   -v ${SDK_VOLUME_NAME}:/opt/android-sdk \
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
     echo "Build base toolchain..."
     
     docker build \
	    --build-arg="QT_VERSION=${QT_VERSION_SHORT}" \
	    --build-arg="LANG=ru-RU.UTF-8" \
	    --build-arg="TZ=Europe/Moscow" \
	    --platform=linux/amd64 \
	    --tag=${TOOLCHAIN_IMAGE_NAME} \
	    --progress plain \
         https://github.com/ZanyXDev/for-Qt5-and-Qtd6-dev.git#main:toolchain      
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
  return 0
}

main
Exit=$?
[[ $Exit == 0 ]] || echo "There was an error installing qt-creator in docker. Exit code: $Exit. Please provide these logs when asking for assistance."
exit "$Exit"


#docker exec --env-file .env container-name env  
