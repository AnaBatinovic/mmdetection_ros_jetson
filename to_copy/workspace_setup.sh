#!/bin/bash
# Author: lovro.markovic@fer.hr
# Exit immediatelly if a command exits with a non-zero status
set -e

# Executes a command when DEBUG signal is emitted in this script - should be after every line
trap 'last_command=$current_command; current_command=$BASH_COMMAND' DEBUG

# Executes a command when ERR signal is emmitted in this script
trap 'echo "$0: \"${last_command}\" command failed with exit code $?"' ERR

distro=`lsb_release -r | awk '{ print $2 }'`
[ "$distro" = "18.04" ] && ROS_DISTRO="melodic"
[ "$distro" = "20.04" ] && ROS_DISTRO="noetic"

# get the path to this script
APP_PATH=`dirname "$0"`
APP_PATH=`( cd "$APP_PATH" && pwd )`

if [ "$#" -ne 1 ]; then
  WORKSPACE_NAME=uav_ws
else
  WORKSPACE_NAME=$1
fi

WORKSPACE_PATH=~/$WORKSPACE_NAME

echo "$0: creating $WORKSPACE_PATH/src"
mkdir -p $WORKSPACE_PATH/src

cd $WORKSPACE_PATH
source /opt/ros/$ROS_DISTRO/setup.bash
command catkin init

echo "$0: setting up build profiles"
command catkin config --profile debug --cmake-args -DCMAKE_BUILD_TYPE=Debug -DCMAKE_EXPORT_COMPILE_COMMANDS=ON -DCMAKE_CXX_FLAGS='-std=c++17'
command catkin config --profile release --cmake-args -DCMAKE_BUILD_TYPE=Release -DCMAKE_EXPORT_COMPILE_COMMANDS=ON -DCMAKE_CXX_FLAGS='-std=c++17'
command catkin config --profile reldeb --cmake-args -DCMAKE_BUILD_TYPE=RelWithDebInfo -DCMAKE_EXPORT_COMPILE_COMMANDS=ON -DCMAKE_CXX_FLAGS='-std=c++17'
command catkin config --profile deploy --install --cmake-args -DCMAKE_BUILD_TYPE=Release -DCMAKE_EXPORT_COMPILE_COMMANDS=ON -DCMAKE_CXX_FLAGS='-std=c++17'

# normal installation
[ -z "$TRAVIS_CI" ] && command catkin profile set reldeb

# TRAVIS CI build
# set debug for faster build
[ ! -z "$TRAVIS_CI" ] && command catkin profile set debug

cd $WORKSPACE_PATH
source /opt/ros/$ROS_DISTRO/setup.bash
command catkin build -c

SNAME=$( echo "$SHELL" | grep -Eo '[^/]+/?$' )
BASHRC=~/.$(echo $SNAME)rc

line="source $WORKSPACE_PATH/devel/setup.$SNAME"
num=`cat $BASHRC | grep "$line" | wc -l`
if [ "$num" -lt "1" ]; then

  # set bashrc
  echo "
$line" >> $BASHRC
fi
