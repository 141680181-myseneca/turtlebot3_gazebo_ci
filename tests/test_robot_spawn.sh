#!/bin/bash
set -e  # Exit immediately if a command fails

echo "🚀 Running TurtleBot3 Spawn Test..."

# Set TurtleBot3 model (optional override)
export TURTLEBOT3_MODEL=${TURTLEBOT3_MODEL:-burger}

# Run the container and check if TurtleBot3 spawns correctly
docker run --rm -it --name tb3_test \
    -e TURTLEBOT3_MODEL=${TURTLEBOT3_MODEL} \
    tb3_sim bash -c "
    source /opt/ros/humble/setup.bash;
    
    echo '📡 Checking if Gazebo is running...';
    pgrep gzserver || (echo '❌ Gazebo is not running!' && exit 1);

    echo '🤖 Spawning TurtleBot3...';
    ros2 run gazebo_ros spawn_entity.py -entity tb3 \
        -file /opt/ros/humble/share/turtlebot3_description/urdf/turtlebot3_${TURTLEBOT3_MODEL}.urdf;

    echo '✅ Spawn test completed successfully!'
"

echo "🎉 TurtleBot3 Spawn Test PASSED!"
