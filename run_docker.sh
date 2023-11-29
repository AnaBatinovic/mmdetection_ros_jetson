#!/bin/bash

CONTAINER_NAME=$1
[ -z "$CONTAINER_NAME" ] && CONTAINER_NAME=mmdetection_jetson_orin_cont

IMAGE_NAME=$2
[ -z "$IMAGE_NAME" ] && IMAGE_NAME=mmdetection_jetson_orin:focal

# Hook to the current SSH_AUTH_LOCK - since it changes
# https://www.talkingquickly.co.uk/2021/01/tmux-ssh-agent-forwarding-vs-code/
ln -sf $SSH_AUTH_SOCK ~/.ssh/ssh_auth_sock

docker run \
  -it \
  --gpus all \
  --network host \
  --privileged \
  --volume /dev:/dev \
  --volume ~/.ssh/ssh_auth_sock:/ssh-agent \
  --env SSH_AUTH_SOCK=/ssh-agent \
  --env display=$display \
  --env TERM=xterm-256color \
  --env XAUTHORITY=${XAUTH} \
  --volume /etc/group:/etc/group:ro \
  --env="QT_X11_NO_MITSHM=1" \
  --cap-add=SYS_PTRACE \
  --name $CONTAINER_NAME \
  $IMAGE_NAME \
  /bin/bash
  # --volume $XSOCK:$XSOCK:rw \
  # --volume $XAUTH:$XAUTH:rw \

  # Create a new container
docker run -it \
