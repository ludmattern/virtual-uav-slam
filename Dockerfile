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

# Create non-root user
RUN useradd -m ros -s /bin/bash \
 && echo "ros ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/ros

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
