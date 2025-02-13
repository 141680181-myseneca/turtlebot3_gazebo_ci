#!/bin/bash
set -e  # Exit immediately if a command fails

echo "🚀 EntryPoint: Starting TurtleBot3 Gazebo Simulation..."

# Source ROS 2 setup
source /opt/ros/humble/setup.bash

# Set the correct TurtleBot3 model (default: burger)
export TURTLEBOT3_MODEL=${TURTLEBOT3_MODEL:-burger}

# Disable audio to prevent ALSA errors
export GAZEBO_AUDIO=0
export SDL_AUDIODRIVER=dummy  # Prevents OpenAL issues

# Ensure full headless mode
export DISPLAY=:99
export QT_QPA_PLATFORM=minimal  # Force Qt to use minimal mode
export GAZEBO_RENDERING=0
export GAZEBO_HEADLESS_RENDERING=1
export SVGA_VGPU10=0  # Prevents crashes in virtualized environments

echo "🛠️ Using TurtleBot3 Model: $TURTLEBOT3_MODEL"

# Start X Virtual Framebuffer (xvfb) to simulate a display
Xvfb :99 -screen 0 1024x768x24 &

# Start Gazebo in **fully headless mode** with the required ROS plugin
echo "📡 Launching Gazebo with ROS plugins in full headless mode..."
gazebo --verbose /usr/share/gazebo-11/worlds/empty.world --headless &

sleep 5  # Allow Gazebo to initialize

# Verify if Gazebo is running
if ! pgrep -x "gzserver" > /dev/null; then
    echo "❌ ERROR: Gazebo failed to start!"
    exit 1
fi

# Ensure the correct URDF file exists before spawning
URDF_PATH="/opt/ros/humble/share/turtlebot3_description/urdf/turtlebot3_${TURTLEBOT3_MODEL}.urdf"

if [[ ! -f "$URDF_PATH" ]]; then
    echo "❌ ERROR: URDF file not found: $URDF_PATH"
    ls -al /opt/ros/humble/share/turtlebot3_description/urdf  # Debugging
    exit 1
fi

# Start ROS 2 Gazebo bridge
echo "🔄 Starting ROS 2 Gazebo Bridge..."
ros2 launch gazebo_ros gazebo.launch.py &

sleep 5  # Allow ROS bridge to start

# Check if `/spawn_entity` service is available before spawning
echo "🔎 Checking if /spawn_entity service is available..."
timeout 30 bash -c 'until ros2 service list | grep -q /spawn_entity; do sleep 1; done' || {
    echo "❌ ERROR: /spawn_entity service not available. Gazebo may not have loaded correctly."
    exit 1
}

echo "🤖 Spawning TurtleBot3..."
ros2 run gazebo_ros spawn_entity.py -entity tb3 -file "$URDF_PATH"

echo "✅ Simulation Ready! TurtleBot3 is in Gazebo."

# Keep container running interactively
exec "$@"
