#!/bin/sh

TAG="ctf"
CONTAINER="werew"
IMAGE="$CONTAINER:$TAG"

CONTAINER_USERNAME="werew"
CONTAINER_HOME="/home/$CONTAINER_USERNAME"

if [ `whoami` != 'root' ]; then
    echo "You must run this script as root" >&2
    exit 1
fi

rm_container(){
    if $(docker ps -a | grep -q $CONTAINER); then
        echo "[*] Removing existing container"
        docker stop $CONTAINER
        docker rm -f $CONTAINER
    fi
}

rm_image(){
    if $(docker images -a | grep -q $TAG ); then
        rm_container
        echo "[*] Removing existing image"
        docker rmi -f $IMAGE
    fi
}
