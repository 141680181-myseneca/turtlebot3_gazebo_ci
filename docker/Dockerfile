# Use the official ROS 2 Humble Desktop image with Gazebo
FROM osrf/ros:humble-desktop

# Install required dependencies for TurtleBot3, Gazebo, and headless support
RUN apt-get update && apt-get install -y \
    ros-humble-gazebo-ros-pkgs \
    ros-humble-turtlebot3-gazebo \
    ros-humble-turtlebot3-msgs \
    ros-humble-turtlebot3-simulations \
    ros-humble-turtlebot3-description \
    xvfb \
    lsof && \  # 🔹 Install `lsof` to check for running ports
    rm -rf /var/lib/apt/lists/*

# Install system dependencies separately (including xvfb)
RUN apt-get update && apt-get install -y \
    xvfb \
    x11-utils \
    x11-xserver-utils \
    && rm -rf /var/lib/apt/lists/*

# Set default environment variables for headless mode
ENV TURTLEBOT3_MODEL=burger
ENV DISPLAY=:99
ENV QT_QPA_PLATFORM=offscreen
ENV GAZEBO_RENDERING=0
ENV GAZEBO_HEADLESS_RENDERING=1
ENV SVGA_VGPU10=0

# Copy the entrypoint script into the container
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Ensure ROS 2 setup is sourced in every shell session
SHELL ["/bin/bash", "-c"]

# Set the default entrypoint (Runs automatically on `docker run`)
ENTRYPOINT ["/entrypoint.sh"]
