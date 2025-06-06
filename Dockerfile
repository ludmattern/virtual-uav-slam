# Dockerfile for virtual-uav-slam:dev
FROM ubuntu:22.04

# Prevent interactive prompts
ENV DEBIAN_FRONTEND=noninteractive \
	LANG=en_US.UTF-8 \
	LC_ALL=en_US.UTF-8

# Install core tools + locale in one layer
RUN rm -rf /var/lib/apt/lists/* \
	&& apt-get update \
	&& apt-get install -y --no-install-recommends \
	locales ca-certificates curl gnupg2 lsb-release \
	git vim sudo wget bash-completion \
	&& locale-gen en_US.UTF-8 \
	&& update-locale LANG=en_US.UTF-8 \
	&& rm -rf /var/lib/apt/lists/*

# Add ROS 2 apt repository
RUN mkdir -p /usr/share/keyrings \
	&& curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key \
	| gpg --dearmor > /usr/share/keyrings/ros-archive-keyring.gpg \
	&& echo \
	"deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] \
	http://packages.ros.org/ros2/ubuntu $(. /etc/os-release && echo $UBUNTU_CODENAME) main" \
	> /etc/apt/sources.list.d/ros2.list

# Install ROS 2 Humble base + rosdep
RUN rm -rf /var/lib/apt/lists/* \
	&& apt-get update \
	&& apt-get install -y --no-install-recommends \
	ros-humble-ros-base \
	ros-humble-demo-nodes-cpp \
	python3-colcon-common-extensions python3-rosdep \
	&& rm -rf /var/lib/apt/lists/* \
	&& rosdep init \
	&& rosdep update

# PX4 SITL dependencies
RUN apt-get update && apt-get install -y \
	build-essential \
	cmake \
	python3-dev \
	python3-pip \
	git \
	wget \
	lsb-release \
	gnupg2 \
	python3-jinja2 \
	python3-toml \
	python3-numpy \
	python3-yaml \
	python3-packaging \
	ninja-build \
	ccache \
	libopencv-dev \
	&& rm -rf /var/lib/apt/lists/*

# Install additional PX4 Python dependencies
RUN pip3 install --no-cache-dir \
	kconfiglib \
	jsonschema \
	future \
	pymavlink \
	pyserial \
	empy \
	cerberus \
	pyros-genmsg

# Install Gazebo dependencies
RUN sed -i 's|http://archive.ubuntu.com|http://fr.archive.ubuntu.com|g' /etc/apt/sources.list \
	&& apt-get update && apt-get install -y \
	gazebo \
	libgazebo-dev \
	libprotobuf-dev \
	libprotoc-dev \
	protobuf-compiler \
	libgstreamer1.0-dev \
	libgstreamer-plugins-base1.0-dev \
	gstreamer1.0-plugins-base \
	gstreamer1.0-plugins-good \
	gstreamer1.0-plugins-bad \
	gstreamer1.0-plugins-ugly \
	gstreamer1.0-libav \
	libignition-cmake2-dev \
	libignition-common3-dev \
	libignition-msgs5-dev \
	libignition-transport8-dev \
	&& rm -rf /var/lib/apt/lists/*

# Install X11 dependencies for GUI with Intel GPU support
RUN apt-get update && apt-get install -y \
	libgl1-mesa-glx \
	libgl1-mesa-dri \
	libglu1-mesa \
	mesa-utils \
	mesa-va-drivers \
	mesa-vdpau-drivers \
	x11-apps \
	libxext6 \
	libxrender1 \
	libxtst6 \
	libxi6 \
	libxrandr2 \
	&& rm -rf /var/lib/apt/lists/*

# Disable audio to avoid ALSA warnings
ENV ALSA_DISABLE=1 \
	PULSE_RUNTIME_PATH=/dev/null

# Create non-root user
RUN useradd -m ros -s /bin/bash \
	&& echo "ros ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/ros

# Clone and build PX4-Autopilot
RUN git clone https://github.com/PX4/PX4-Autopilot.git /opt/PX4-Autopilot \
	&& cd /opt/PX4-Autopilot \
	&& git checkout v1.15.4 \
	&& git submodule update --init --recursive

# Build PX4 SITL with Gazebo
RUN cd /opt/PX4-Autopilot \
	&& DONT_RUN=1 make px4_sitl gazebo-classic \
	&& chown -R ros:ros /opt/PX4-Autopilot

# Create workspace mount point
WORKDIR /work
RUN chown ros:ros /work

# Copy and configure entrypoint
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Switch to non-root
USER ros

# Ensure ROS setup in every shell
RUN echo "source /opt/ros/humble/setup.bash" >> /home/ros/.bashrc

ENTRYPOINT ["/entrypoint.sh"]
CMD ["bash"]
