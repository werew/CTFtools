#!/bin/sh

cd `dirname $0`

source ./common.sh

docker commit $CONTAINER "werew:ctf_$(date +%s)"
