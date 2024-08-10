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

pull_docker_images() {
  echo "Pulling docker images"
  docker pull bitnami/git:latest
  docker pull ubuntu:22.04
  docker pull eclipse-temurin:17 
  
  docker image inspect $BitamiGit >/dev/null 2>&1 && 
  {
    echo "succes pulling '$BitamiGit'"    
  } || 
  {
    echo "failed to pull '$BitamiGit'"
    return 1
  }
  
  docker image inspect $Ubuntu >/dev/null 2>&1 && 
  {
    echo "succes pulling '$Ubuntu'"    
  } || 
  {
    echo "failed to pull '$Ubuntu'"
    return 1
  }
  
  docker image inspect $Temurin  >/dev/null 2>&1 && 
  {
    echo "succes pulling '$Temurin'"    
  } || 
  {
    echo "failed to pull '$Temurin'"
    return 1
  }
}

git_clone_source() {
    echo "Use git for clone sources..."
}

download_dot_env_file() {
  echo "Downloading .env file..."
  "${Curl[@]}" "$RepoUrl"/qtcreator.env -o ./.env
  [[ -e .env ]] && {   
    set -a && source .env && set +a
  } || return 1
  
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
    return 12
  }
  
  download_dot_env_file || {
    echo 'error downloading .env'
    return 9
  }
  
  exit 7
  
  download_docker_compose_file || {
    echo 'error downloading Docker Compose file'
    return 13
  }
  
  pull_docker_images || {
    echo 'error pulling Docker images'
    return 11
  }
    
  
  
  git_clone_source || {
    echo 'error git clone sources'
    return 15  
  }
  return 0
}

main
Exit=$?
[[ $Exit == 0 ]] || echo "There was an error installing qt-creator in docker. Exit code: $Exit. Please provide these logs when asking for assistance."
exit "$Exit"


#docker exec --env-file .env container-name env  
