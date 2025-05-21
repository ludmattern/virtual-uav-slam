#!/bin/bash
set -e

# Source ROS 2 setup
source /opt/ros/humble/setup.bash

# Execute the command passed to docker run
exec "$@"
