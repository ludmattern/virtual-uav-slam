#!/bin/bash

if [ $# -eq 1 ]
then
  export PX4_SITL_WORLD="$PWD/$1"
  cd /opt/PX4-Autopilot
  make px4_sitl gazebo-classic
fi
