#!/bin/bash
# filepath: /goinfre/lmattern/virtual-uav-slam/scripts/setup-px4.sh
# PX4 SITL setup script for virtual-uav-slam project
set -e

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
WORK_DIR="/work"
PX4_DIR="${WORK_DIR}/PX4-Autopilot"
BUILD_JOBS=$(nproc)
VERBOSE=0
MODE=""

print_usage() {
	echo "Usage: $(basename $0) [OPTIONS] COMMAND"
	echo ""
	echo "Setup and manage PX4 SITL environment"
	echo ""
	echo "Commands:"
	echo "  clone       Clone PX4-Autopilot repository"
	echo "  build       Build PX4 SITL"
	echo "  run         Run PX4 SITL with Gazebo"
	echo "  clean       Clean PX4 build"
	echo "  full        Clone, build and run (all steps)"
	echo ""
	echo "Options:"
	echo "  -j, --jobs N    Build with N parallel jobs (default: $(nproc))"
	echo "  -v, --verbose   Display more output"
	echo "  -h, --help      Display this help message"
}

clone_px4() {
	echo "[PX4] Cloning PX4-Autopilot repository..."

	if [ -d "${PX4_DIR}" ]; then
		echo "[PX4] Directory already exists. Updating..."
		cd "${PX4_DIR}"
		git pull
	else
		cd "${WORK_DIR}"
		git clone https://github.com/PX4/PX4-Autopilot.git
		cd "${PX4_DIR}"
	fi

	echo "[PX4] Updating submodules..."
	git submodule update --init --recursive
	echo "[PX4] Clone/update complete!"
}

build_px4() {
	echo "[PX4] Building PX4 SITL with Gazebo..."

	cd "${PX4_DIR}"

	# Set cmake build options
	export CMAKE_BUILD_PARALLEL_LEVEL=$BUILD_JOBS

	# Use verbose if requested
	if [ $VERBOSE -eq 1 ]; then
		make px4_sitl_default gazebo -j $BUILD_JOBS VERBOSE=1
	else
		make px4_sitl_default gazebo -j $BUILD_JOBS
	fi

	echo "[PX4] Build complete!"
}

run_px4() {
	echo "[PX4] Running PX4 SITL with Gazebo..."

	cd "${PX4_DIR}"

	# Ensure Gazebo plugin paths are set
	export GAZEBO_PLUGIN_PATH=$GAZEBO_PLUGIN_PATH:${PX4_DIR}/build/px4_sitl_default/build_gazebo
	export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:${PX4_DIR}/build/px4_sitl_default/build_gazebo

	# Run SITL
	make px4_sitl gazebo
}

clean_px4() {
	echo "[PX4] Cleaning PX4 build..."

	if [ -d "${PX4_DIR}" ]; then
		cd "${PX4_DIR}"
		make clean
	else
		echo "[PX4] PX4-Autopilot not found. Nothing to clean."
	fi
}

# Parse options
while [ $# -gt 0 ]; do
	case "$1" in
	-j | --jobs)
		BUILD_JOBS="$2"
		shift 2
		;;
	-v | --verbose)
		VERBOSE=1
		shift
		;;
	-h | --help)
		print_usage
		exit 0
		;;
	clone | build | run | clean | full)
		MODE="$1"
		shift
		;;
	*)
		echo "Unknown option: $1"
		print_usage
		exit 1
		;;
	esac
done

# Execute command
case "$MODE" in
clone)
	clone_px4
	;;
build)
	build_px4
	;;
run)
	run_px4
	;;
clean)
	clean_px4
	;;
full)
	clone_px4
	build_px4
	run_px4
	;;
*)
	print_usage
	exit 1
	;;
esac
