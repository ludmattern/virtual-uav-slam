#!/bin/bash
# filepath: /goinfre/lmattern/virtual-uav-slam/scripts/welcome.sh

# Colors
GREEN="\033[0;32m"
BLUE="\033[0;34m"
YELLOW="\033[0;33m"
RED="\033[0;31m"
NC="\033[0m" # No Color

# Function to check if PX4 is installed and built
check_px4_status() {
	if [ -d "/work/PX4-Autopilot" ]; then
		if [ -d "/work/PX4-Autopilot/build/px4_sitl_default" ]; then
			echo -e "${GREEN}✓${NC} PX4 SITL is installed and built"
		else
			echo -e "${YELLOW}⚠${NC} PX4 SITL is installed but not built. Run: ${BLUE}setup-px4.sh build${NC}"
		fi
	else
		echo -e "${YELLOW}⚠${NC} PX4 SITL is not installed. Run: ${BLUE}setup-px4.sh clone${NC}"
	fi
}

# Function to display help commands
show_help() {
	echo -e "${YELLOW}Available commands:${NC}"
	echo -e "  ${BLUE}setup-px4.sh clone${NC} - Clone PX4-Autopilot repository"
	echo -e "  ${BLUE}setup-px4.sh build${NC} - Build PX4 SITL target"
	echo -e "  ${BLUE}setup-px4.sh run${NC}   - Run PX4 SITL with Gazebo"
	echo -e "  ${BLUE}setup-px4.sh full${NC}  - Clone, build and run (all steps)"
}

# Main welcome message
echo -e "${GREEN}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║                 ${BLUE}Virtual UAV SLAM${GREEN}                        ║${NC}"
echo -e "${GREEN}║           ${YELLOW}PX4 SITL + Gazebo + ROS 2 Humble${GREEN}            ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════════════╝${NC}"
echo

# Check environment status
check_px4_status
echo

# Show help
show_help
echo

# Show current ROS 2 setup
echo -e "${GREEN}ROS 2 Environment:${NC}"
echo -e "  ROS_DISTRO=${BLUE}${ROS_DISTRO}${NC}"
echo -e "  ROS_VERSION=${BLUE}${ROS_VERSION}${NC}"
echo

# Reminder to source ROS if needed
if [ -z "$ROS_DISTRO" ]; then
	echo -e "${RED}Warning: ROS environment not sourced. Run:${NC}"
	echo -e "${BLUE}source /opt/ros/humble/setup.bash${NC}"
fi
