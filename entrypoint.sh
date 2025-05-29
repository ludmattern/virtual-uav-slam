#!/bin/bash
set -e

# Source ROS 2 setup
source /opt/ros/humble/setup.bash

# Setup PX4 environment variables if directory exists
if [ -d "/work/PX4-Autopilot" ]; then
	# Add PX4 tools to PATH
	export PATH=$PATH:/work/PX4-Autopilot/Tools

	# Configure Gazebo plugin path for PX4 SITL
	if [ -d "/work/PX4-Autopilot/build/px4_sitl_default/build_gazebo" ]; then
		export GAZEBO_PLUGIN_PATH=$GAZEBO_PLUGIN_PATH:/work/PX4-Autopilot/build/px4_sitl_default/build_gazebo
		export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/work/PX4-Autopilot/build/px4_sitl_default/build_gazebo
	fi
fi

# Display welcome message if running interactive shell and script exists
if [ -t 0 ] && [ -f "/work/scripts/welcome.sh" ]; then
	bash /work/scripts/welcome.sh
fi

# Execute the command passed to docker run
exec "$@"
