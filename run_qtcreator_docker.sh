#!/bin/bash
set -e

load_dot_env_file() {
  echo "Loading from .env file..."
  
  [[ -d ${APP_DIR}/home_developer  ]] || mkdir -p ${APP_DIR}/home_developer   
  cd ${APP_DIR}  
  [[ -e .env ]] && {       
    set -a && source .env && set +a
  } || return 1  
}

enable_ssh_x11_forwarding(){
# Enable SSH X11 forwarding inside container (https://stackoverflow.com/q/48235040)
    echo "Enable SSH X11 forwarding inside container..."        
    XSOCK=/tmp/.X11-unix
    XAUTH=/tmp/.docker.xauth
    xauth nlist $DISPLAY | sed -e 's/^..../ffff/' | xauth -f $XAUTH nmerge -
    chmod 777 $XAUTH
    return $?
} 

enable_adb_bridge(){
    adb kill-server
    adb -a nodaemon server start &> /dev/null &
}
run_qtcreator(){
#share pulse audio @sa https://github.com/mviereck/x11docker/wiki/Container-sound:-ALSA-or-Pulseaudio

    docker image inspect ${QTCREATOR_IMAGE_NAME} >/dev/null 2>&1 && {
        echo "Run QtCreator inside container..."            
        docker run \
           	--env XDG_RUNTIME_DIR=/tmp/runtime-developer \
        	--env PULSE_SERVER=unix:${XDG_RUNTIME_DIR}/pulse/native \
        	--env PULSE_COOKIE=/tmp/pulseaudio.cookie \
        	--env XAUTHORITY=$XAUTH \
	        --env "ANDROID_ADB_SERVER_ADDRESS=host.docker.internal" \
        	--env "GPG_TTY=/dev/console"\
        	--env "QT_SELECT=qt5" \
	        --device=/dev/dri:/dev/dri \
        	--add-host=host.docker.internal:host-gateway \
        	--volume ${XDG_RUNTIME_DIR}/pulse/native:${XDG_RUNTIME_DIR}/pulse/native \
        	--volume ~/.config/pulse/cookie:/tmp/pulseaudio.cookie \
        	--volume $XSOCK:$XSOCK \
        	--volume $XAUTH:$XAUTH \
    	    --volume ${SRC_VOLUME_NAME}:/usr/local/src:ro \
        	--volume ${SDK_VOLUME_NAME}:/opt/android-sdk \
        	--volume ${QT5_OPT_VOLUME_NAME}:/opt/Qt \
            --volume ${CCACHE_VOLUME}:/ccache \
        	--mount type=bind,source=${APP_DIR}/home_developer,target=/home/developer \
	        -ti --rm ${QTCREATOR_IMAGE_NAME}  bash 
           return $?
         }
}

# MAIN
main() {
  
  local -r APP_DIR="$HOME"/qtcreator-app
  local -r HOST_ARCH=`lscpu | grep Architecture | awk {'print $2'}` 
  echo "Starting QTCreator in docker container host architecture ${HOST_ARCH}..."  
  
  load_dot_env_file || {
    echo 'error loading env from app directory'
    return 11
  }
  
  enable_ssh_x11_forwarding || {
    echo 'error enable SSH X11 forwarding inside container'
    return 12
  }
  
  enable_adb_bridge || {
  echo 'error enable adb bridge inside container'
    return 14
  }
  
  run_qtcreator|| {
    echo 'error running SSH X11 forwarding inside container'
    return 13
  }
  return 0
}

main
Exit=$?
[[ $Exit == 0 ]] || echo "There was an error installing qt-creator in docker. Exit code: $Exit. Please provide these logs when asking for assistance."
exit "$Exit"
