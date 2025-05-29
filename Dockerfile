# Multi-stage Dockerfile for virtual-uav-slam with PX4 SITL support
# Stage 1: Base image with common tools and locale settings
FROM ubuntu:22.04 AS base

# Prevent interactive prompts and set locale
ENV DEBIAN_FRONTEND=noninteractive \
	LANG=en_US.UTF-8 \
	LC_ALL=en_US.UTF-8

# Install core tools and locale in one layer
RUN apt-get update && apt-get install -y --no-install-recommends \
	locales ca-certificates curl gnupg2 lsb-release \
	git vim sudo wget bash-completion \
	&& locale-gen en_US.UTF-8 \
	&& update-locale LANG=en_US.UTF-8 \
	&& rm -rf /var/lib/apt/lists/*

# Stage 2: Build dependencies image 
FROM base AS build-deps

# Add ROS 2 apt repository
RUN mkdir -p /usr/share/keyrings \
	&& curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key \
	| gpg --dearmor > /usr/share/keyrings/ros-archive-keyring.gpg \
	&& echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] \
	http://packages.ros.org/ros2/ubuntu $(. /etc/os-release && echo $UBUNTU_CODENAME) main" \
	> /etc/apt/sources.list.d/ros2.list

# Install ROS 2 and system build dependencies in a single layer
RUN apt-get update && apt-get install -y --no-install-recommends \
	# ROS 2
	ros-humble-ros-base \
	ros-humble-demo-nodes-cpp \
	python3-colcon-common-extensions python3-rosdep \
	# Build essentials
	build-essential cmake ccache \
	# PX4 build dependencies
	ninja-build python3-pip python3-dev \
	# Minimal Gazebo and simulation dependencies
	libgazebo-dev gazebo \
	# Fast-DDS dependencies
	libasio-dev libtinyxml2-dev \
	# Other PX4 dependencies
	libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev \
	libopencv-dev protobuf-compiler \
	xvfb libglib2.0-dev \
	# Cleanup
	&& rosdep init \
	&& rosdep update \
	&& rm -rf /var/lib/apt/lists/*

# Install Python packages for PX4 
RUN pip3 install --no-cache-dir \
	numpy toml jinja2 pyulog pandas pyserial \
	empy jsonschema kconfiglib packaging \
	px4tools pyros-genmsg

# Stage 3: Final image with runtime environment
FROM build-deps AS runtime

# Create non-root user
RUN useradd -m ros -s /bin/bash \
	&& echo "ros ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/ros

# Configure build cache directories
ENV CCACHE_DIR=/work/.ccache \
	PX4_CCACHE_ENABLED=1 \
	PX4_HOME_LAT=47.397742 \
	PX4_HOME_LON=8.545594 \
	PX4_HOME_ALT=488.0 \
	DISPLAY=:0

# Create workspace directories
RUN mkdir -p /work && chown -R ros:ros /work

# Copy entrypoint and setup scripts
COPY entrypoint.sh /entrypoint.sh
COPY --chmod=755 scripts/setup-px4.sh /usr/local/bin/setup-px4.sh
RUN chmod +x /entrypoint.sh

# Switch to non-root user
USER ros
WORKDIR /work

# Configure environment
RUN echo "source /opt/ros/humble/setup.bash" >> /home/ros/.bashrc \
	&& echo 'export PATH=$PATH:/work/PX4-Autopilot/Tools' >> /home/ros/.bashrc \
	&& echo 'export GAZEBO_PLUGIN_PATH=$GAZEBO_PLUGIN_PATH:/work/PX4-Autopilot/build/px4_sitl_default/build_gazebo' >> /home/ros/.bashrc \
	&& echo 'export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/work/PX4-Autopilot/build/px4_sitl_default/build_gazebo' >> /home/ros/.bashrc

ENTRYPOINT ["/entrypoint.sh"]
CMD ["bash"]
