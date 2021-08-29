#!/bin/sh

cd `dirname $0`

source ./common.sh

rm_container

docker create \
    --name=$CONTAINER \
    -v $(realpath ../):/ctf_tools \
    --net=host \
    --cap-add=SYS_PTRACE \
    -e DISPLAY="$DISPLAY" \
    -i -t $IMAGE

docker start $CONTAINER
