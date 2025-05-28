FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive \
    LANG=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8

RUN rm -rf /var/lib/apt/lists/* \
 && apt-get update \
 && apt-get install -y --no-install-recommends \
       locales ca-certificates curl gnupg2 lsb-release \
       git vim sudo wget bash-completion \
 && locale-gen en_US.UTF-8 \
 && update-locale LANG=en_US.UTF-8 \
 && rm -rf /var/lib/apt/lists/*

# Add ROS 2 apt repository
RUN mkdir -p /usr/share/keyrings && \
    wget --no-check-certificate -q -O - https://raw.githubusercontent.com/ros/rosdistro/master/ros.key | gpg --dearmor > /usr/share/keyrings/ros-archive-keyring.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(. /etc/os-release && echo $UBUNTU_CODENAME) main" | tee /etc/apt/sources.list.d/ros2.list > /dev/null

# Install ROS 2 Humble (more minimal installation)
RUN apt-get update && \
    apt-get install -y --no-install-recommends --fix-missing \
    ros-humble-ros-base \
    python3-colcon-common-extensions \
    python3-rosdep && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Initialize rosdep
RUN rosdep init && rosdep update

# Create non-root user
RUN useradd -m ros -s /bin/bash && \
    echo "ros ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/ros

# Set up the workspace
WORKDIR /work
RUN chown ros:ros /work

# Create entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Switch to non-root user
USER ros

# Source ROS 2 setup in .bashrc
RUN echo "source /opt/ros/humble/setup.bash" >> /home/ros/.bashrc

ENTRYPOINT ["/entrypoint.sh"]
CMD ["bash"]