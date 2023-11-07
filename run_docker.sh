#!/bin/bash

CONTAINER_NAME=$1
[ -z "$CONTAINER_NAME" ] && CONTAINER_NAME=mmdetection_ros_jetson_cont

IMAGE_NAME=$2
[ -z "$IMAGE_NAME" ] && IMAGE_NAME=mmdetection_ros_jetson:bionic

# Hook to the current SSH_AUTH_LOCK - since it changes
# https://www.talkingquickly.co.uk/2021/01/tmux-ssh-agent-forwarding-vs-code/
ln -sf $SSH_AUTH_SOCK ~/.ssh/ssh_auth_sock

docker run \
  -it \
  --gpus all \
  --network host \
  --privileged \
  --volume /dev:/dev \
  --volume /tmp/.x11-unix:/tmp/.x11-unix \
  --volume $HOME/bags:/root/bags \
  --volume ~/.ssh/ssh_auth_sock:/ssh-agent \
  --env SSH_AUTH_SOCK=/ssh-agent \
  --env display=$display \
  --env="QT_X11_NO_MITSHM=1" \
  --env XAUTHORITY=${XAUTH} \
  --volume="/dev:/dev" \
  --volume="/tmp/.X11-unix:/tmp/.X11-unix:rw" \
  --volume $XSOCK:$XSOCK:rw \
  --volume $XAUTH:$XAUTH:rw \
  --cap-add=SYS_PTRACE \
  --volume /etc/group:/etc/group:ro \
  --env TERM=xterm-256color \
  --name $CONTAINER_NAME \
  $IMAGE_NAME \
  /bin/bash

  # Create a new container
docker run -it \
