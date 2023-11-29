#!/bin/bash

CONTAINER_NAME=$1
[ -z "$CONTAINER_NAME" ] && CONTAINER_NAME=mmdetection_jetson_test_cont

ln -sf $SSH_AUTH_SOCK ~/.ssh/ssh_auth_sock
docker start $CONTAINER_NAME
docker attach $CONTAINER_NAME
