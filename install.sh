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
    echo "succes pulling '$UBUNTU_LTS'"    
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
download_scripts() {
  echo "Downloading scripts file..."
  
  "${Curl[@]}" "$RepoUrl"/qt5_git_clone.sh -o ./qt5_git_clone.sh  
  [[ -e qt5_git_clone.sh ]] && {   
    echo "succes download 'qt5_git_clone.sh'"   
    chmod +x qt5_git_clone.sh 
  } || return 1  
  
}

git_clone_source() {
    echo "Use git for clone sources..."
    
    docker run \
       -v ./qt5_git_clone.sh:/root/qt5_git_clone.sh  \
	   -v  ${SRC_VOLUME_NAME}:/usr/local/src \
       -ti --rm --name git bitnami/git:latest /root/qt5_git_clone.sh ${QT_VERSION} "https://invent.kde.org/qt/qt/qt5.git" "/usr/local/src/qt5"       
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
  return 0
}

main
Exit=$?
[[ $Exit == 0 ]] || echo "There was an error installing qt-creator in docker. Exit code: $Exit. Please provide these logs when asking for assistance."
exit "$Exit"


#docker exec --env-file .env container-name env  
