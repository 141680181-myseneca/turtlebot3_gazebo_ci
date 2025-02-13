#!/bin/bash
set -e  # Exit immediately if a command fails

echo "🚀 EntryPoint: Starting TurtleBot3 Gazebo Simulation..."

# Source ROS 2 setup
source /opt/ros/humble/setup.bash

# Set the correct TurtleBot3 model (default: burger)
export TURTLEBOT3_MODEL=${TURTLEBOT3_MODEL:-burger}

# Disable rendering for headless mode
export DISPLAY=:99
export QT_QPA_PLATFORM=offscreen
export GAZEBO_RENDERING=0

echo "🛠️ Using TurtleBot3 Model: $TURTLEBOT3_MODEL"

# Start X Virtual Framebuffer (xvfb) to simulate a display
Xvfb :99 -screen 0 1024x768x24 &

# Start Gazebo in headless mode
echo "📡 Launching Gazebo in headless mode..."
gazebo --verbose /usr/share/gazebo-11/worlds/empty.world --headless &

# Wait for Gazebo to fully load
sleep 5

# Ensure the correct URDF file exists before spawning
URDF_PATH="/opt/ros/humble/share/turtlebot3_description/urdf/turtlebot3_${TURTLEBOT3_MODEL}.urdf"

if [[ ! -f "$URDF_PATH" ]]; then
    echo "❌ ERROR: URDF file not found: $URDF_PATH"
    exit 1
fi

echo "🤖 Spawning TurtleBot3..."
ros2 run gazebo_ros spawn_entity.py -entity tb3 -file "$URDF_PATH"

echo "✅ Simulation Ready! TurtleBot3 is in Gazebo."

# Keep container running interactively
exec "$@"
