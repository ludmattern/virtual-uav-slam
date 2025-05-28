FROM ubuntu:22.04

# Prevent interactive prompts during build
ENV DEBIAN_FRONTEND=noninteractive

# Set up locale
RUN apt-get update && apt-get install -y locales && \
	locale-gen en_US en_US.UTF-8 && \
	update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8 && \
	rm -rf /var/lib/apt/lists/*
ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8

# Install basic tools
RUN apt-get update && apt-get install --no-install-recommends -y \
	ca-certificates \
	curl \
	gnupg2 \
	lsb-release \
	git \
	vim \
	sudo \
	wget \
	bash-completion \
	&& rm -rf /var/lib/apt/lists/*

# Add ROS 2 apt repository
RUN mkdir -p /usr/share/keyrings && \
	wget -q -O - https://raw.githubusercontent.com/ros/rosdistro/master/ros.key | gpg --dearmor > /usr/share/keyrings/ros-archive-keyring.gpg && \
	echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(. /etc/os-release && echo $UBUNTU_CODENAME) main" | tee /etc/apt/sources.list.d/ros2.list > /dev/null

# Install ROS 2 Humble
RUN apt-get update && apt-get install --no-install-recommends -y \
	ros-humble-desktop-full \
	python3-colcon-common-extensions \
	python3-rosdep \
	&& apt-get clean \
	&& rm -rf /var/lib/apt/lists/*

# Initialize rosdep
RUN rosdep init && rosdep update

# Create non-root user
RUN useradd -m ros -s /bin/bash && \
	echo "ros ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/ros

# Set up the workspace
WORKDIR /workspace
RUN chown ros:ros /workspace

# Create entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Switch to non-root user
USER ros

# Source ROS 2 setup in .bashrc
RUN echo "source /opt/ros/humble/setup.bash" >> /home/ros/.bashrc

ENTRYPOINT ["/entrypoint.sh"]
CMD ["bash"]
