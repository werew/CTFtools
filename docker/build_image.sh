#!/bin/sh

cd `dirname $0`

source ./common.sh

rm_image

docker build . -t $IMAGE --no-cache --build-arg USERNAME=$CONTAINER_USERNAME
