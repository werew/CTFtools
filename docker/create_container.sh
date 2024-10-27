#!/bin/sh

cd `dirname $0`

source ./common.sh

rm_container

PRIV=1

HOST_SHARED_DIR="/home/${SUDO_USER:-$USER}/shared"
mkdir -p "$HOST_SHARED_DIR"

if [ $PRIV -eq 1 ]
then
# Priviledged
# Ulimit: https://github.com/greyltc-org/docker-archlinux-aur/issues/7
echo "Creating priviledged container"
docker create \
    --name=$CONTAINER \
    --mount type=tmpfs,destination=/tmp,tmpfs-mode=777 \
    -v "$HOST_SHARED_DIR":"$CONTAINER_HOME/shared" \
    -v "/tmp/.X11-unix:/tmp/.X11-unix" \
    --ulimit nofile=1024:10240 \
    --net=host \
    --cap-add=SYS_PTRACE \
    --security-opt seccomp=unconfined \
    --env="DISPLAY" \
    -e DISPLAY="$DISPLAY" \
    -v "/home/${SUDO_USER:-$USER}/.Xauthority":"/home/$CONTAINER_USERNAME/.Xauthority":rw \
    -i -t $IMAGE

else
# Unpriviledged
# Ulimit: https://github.com/greyltc-org/docker-archlinux-aur/issues/7
echo "Creating unpriviledged container"
docker create \
    --name=$CONTAINER \
    --ulimit nofile=1024:10240 \
    --tmpfs /tmp:exec \
    -v "$HOST_SHARED_DIR":"$CONTAINER_HOME/shared" \
    --net=host \
    -i -t $IMAGE

fi


docker start $CONTAINER
