#!/bin/sh

cd `dirname $0`

source ./common.sh

rm_container

HOST_SHARED_DIR="/home/${SUDO_USER:-$USER}/shared"
mkdir -p "$HOST_SHARED_DIR"

docker create \
    --name=$CONTAINER \
    -v $(realpath ../):"$CONTAINER_HOME/ctf_tools" \
    -v "$HOST_SHARED_DIR":"$CONTAINER_HOME/shared" \
    -v "/tmp/.X11-unix:/tmp/.X11-unix" \
    --net=host \
    --cap-add=SYS_PTRACE \
    --security-opt seccomp=unconfined \
    --env="DISPLAY" \
    -e DISPLAY="$DISPLAY" \
    -v "$HOME/.Xauthority":"/home/$USER/.Xauthority":rw \
    -i -t $IMAGE

docker start $CONTAINER
