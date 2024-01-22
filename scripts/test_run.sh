#!/bin/bash
 docker run --rm -ti\
    --user $UID:$GID \
    --workdir="/home/$USER" \
    --volume="/etc/group:/etc/group:ro" \
    --volume="/etc/passwd:/etc/passwd:ro" \
    --volume="/etc/shadow:/etc/shadow:ro" \
	zanyxdev/cmake-3.28.1:latest bash
