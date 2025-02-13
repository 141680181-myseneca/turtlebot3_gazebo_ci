# Use the official ROS 2 Humble Desktop image with Gazebo
FROM osrf/ros:humble-desktop

# Install required dependencies for TurtleBot3 and Gazebo
RUN apt-get update && apt-get install -y \
    ros-humble-gazebo-ros-pkgs \
    ros-humble-turtlebot3-gazebo \
    ros-humble-turtlebot3-msgs \
    ros-humble-turtlebot3-simulations \
    && rm -rf /var/lib/apt/lists/*

# Set default environment variable for TurtleBot3 model (can be overridden)
ENV TURTLEBOT3_MODEL=burger

# Copy the entrypoint script into the container
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Ensure ROS 2 setup is sourced in every shell session
SHELL ["/bin/bash", "-c"]

# Set the default entrypoint (Runs automatically on `docker run`)
ENTRYPOINT ["/entrypoint.sh"]
