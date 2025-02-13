#!/bin/bash
set -e

echo "Starting TurtleBot3 Gazebo test..."

# Run the container and check if the robot spawns correctly
docker run --rm -it tb3_sim bash -c "
    gazebo --verbose /usr/share/gazebo-11/worlds/empty.world &
    sleep 5
    ros2 run gazebo_ros spawn_entity.py -entity tb3 -file /opt/ros/humble/share/turtlebot3_description/urdf/turtlebot3_burger.urdf
"

echo "✅ Test Passed: TurtleBot3 spawned successfully!"
