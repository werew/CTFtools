#!/bin/sh

cd `dirname $0`

source ./common.sh


docker start $CONTAINER
docker exec -it  $CONTAINER /bin/zsh
