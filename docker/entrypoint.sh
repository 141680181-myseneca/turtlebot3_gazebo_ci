#!/bin/bash
set -e  # Exit immediately if a command fails

echo "🚀 EntryPoint: Starting TurtleBot3 Gazebo Simulation..."

# Source ROS 2 setup
source /opt/ros/humble/setup.bash

# Set the correct TurtleBot3 model (default: burger)
export TURTLEBOT3_MODEL=${TURTLEBOT3_MODEL:-burger}

# 🔹 Disable all audio processing to prevent ALSA/OpenAL errors
export GAZEBO_AUDIO=0
export SDL_AUDIODRIVER=dummy  # Prevents OpenAL issues
export PULSE_SERVER=""  # Ensures PulseAudio does not start

# 🔹 Force full headless mode in Gazebo
export DISPLAY=:99
export QT_QPA_PLATFORM=offscreen  # Ensure Qt does not require X11
export GAZEBO_RENDERING=0
export GAZEBO_HEADLESS_RENDERING=1
export GAZEBO_GUI=0  # 🔥 Prevent GUI plugins from loading
export SVGA_VGPU10=0  # Prevents crashes in virtualized environments

echo "🛠️ Using TurtleBot3 Model: $TURTLEBOT3_MODEL"

# 🔹 Ensure Xvfb isn't already running
if pgrep Xvfb > /dev/null; then
    echo "⚠️ Xvfb is already running, skipping..."
else
    echo "📡 Starting Xvfb..."
    Xvfb :99 -screen 0 1024x768x24 &
fi

# 🔹 Ensure previous Gazebo processes are killed before starting
echo "🛑 Killing any existing Gazebo processes..."
pkill -f gzserver || true
pkill -f gzclient || true
sleep 2  # Give it time to fully terminate

# Start Gazebo in **strict headless mode**, without `gzclient`
echo "📡 Launching Gazebo in headless mode (no GUI, only server)..."
gzserver --verbose /usr/share/gazebo-11/worlds/empty.world -s libgazebo_ros_init.so -s libgazebo_ros_factory.so &

sleep 5  # Allow Gazebo to initialize

# Verify if Gazebo is running
if ! pgrep -x "gzserver" > /dev/null; then
    echo "❌ ERROR: Gazebo server failed to start!"
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

# 🔹 Remove previous TurtleBot3 instances to prevent duplication
echo "🧹 Removing any existing TurtleBot3 instances..."
ros2 service call /delete_entity gazebo_msgs/srv/DeleteEntity "{name: 'tb3'}" || true
sleep 2

echo "🤖 Spawning TurtleBot3..."
ros2 run gazebo_ros spawn_entity.py -entity tb3 -file "$URDF_PATH"

echo "✅ Simulation Ready! TurtleBot3 is in Gazebo."

# Keep container running interactively
exec "$@"
