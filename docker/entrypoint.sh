#!/bin/bash
set -e

echo "🚀 EntryPoint: Starting TurtleBot3 Gazebo Simulation..."

source /opt/ros/humble/setup.bash
export TURTLEBOT3_MODEL=${TURTLEBOT3_MODEL:-burger}

# If a command is passed, execute it instead of running Gazebo
if [ "$#" -gt 0 ]; then
    exec "$@"
else
    echo "🛠️ Using TurtleBot3 Model: $TURTLEBOT3_MODEL"
    
    echo "📡 Launching Gazebo with an empty world..."
    gazebo --verbose /usr/share/gazebo-11/worlds/empty.world &
    
    sleep 5
    
    echo "🤖 Spawning TurtleBot3..."
    ros2 run gazebo_ros spawn_entity.py -entity tb3 \
        -file /opt/ros/humble/share/turtlebot3_description/urdf/turtlebot3_${TURTLEBOT3_MODEL}.urdf
    
    echo "✅ Simulation Ready! TurtleBot3 is in Gazebo."

    # Keep container running interactively
    exec bash
fi
