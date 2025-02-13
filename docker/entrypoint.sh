#!/bin/bash
set -e

echo "🚀 EntryPoint: Starting TurtleBot3 Gazebo Simulation..."

# Source ROS 2 setup
source /opt/ros/humble/setup.bash

# Set the TurtleBot3 model (default: burger)
export TURTLEBOT3_MODEL=${TURTLEBOT3_MODEL:-burger}

# Disable audio processing to prevent ALSA/OpenAL errors
export GAZEBO_AUDIO=0
export SDL_AUDIODRIVER=dummy         # Prevents OpenAL issues
export PULSE_SERVER=""                # Disables PulseAudio
export ALSA_CONFIG_PATH=/dev/null     # Prevents ALSA configuration errors

# Force full headless mode in Gazebo
export DISPLAY=:99
export QT_QPA_PLATFORM=offscreen      # Ensure Qt does not require X11
export GAZEBO_RENDERING=0
export GAZEBO_HEADLESS_RENDERING=1
export GAZEBO_GUI=0                   # Disable GUI plugins
export SVGA_VGPU10=0                  # Prevents crashes in virtualized environments

echo "🛠️ Using TurtleBot3 Model: $TURTLEBOT3_MODEL"

# Remove stale Xvfb lock file if it exists
if [ -f "/tmp/.X99-lock" ]; then
  echo "🛑 Removing stale Xvfb lock file..."
  rm -f /tmp/.X99-lock
fi

# Kill any existing Xvfb on display :99 (forcefully)
if pgrep -f "Xvfb :99" > /dev/null; then
  echo "⚠️ Killing existing Xvfb on display :99..."
  pkill -9 -f "Xvfb :99"
  sleep 1
fi

echo "📡 Starting Xvfb on display :99..."
Xvfb :99 -screen 0 1024x768x24 &
sleep 2

# Kill any existing Gazebo processes
echo "🛑 Killing any existing Gazebo processes..."
pkill -9 -f gzserver || true
pkill -9 -f gzclient || true
sleep 2

# Set GAZEBO_MASTER_URI based on port availability
if command -v lsof > /dev/null; then
  if lsof -i :11345 > /dev/null; then
    echo "⚠️ Port 11345 in use. Binding Gazebo to port 11346..."
    export GAZEBO_MASTER_URI=http://127.0.0.1:11346
  else
    export GAZEBO_MASTER_URI=http://127.0.0.1:11345
  fi
else
  export GAZEBO_MASTER_URI=http://127.0.0.1:11345
fi

# Launch Gazebo via ROS 2 launch in headless mode (disable GUI)
echo "🔄 Launching ROS 2 Gazebo Bridge in headless mode..."
ros2 launch gazebo_ros gazebo.launch.py gui:=false &
sleep 10

# Ensure the URDF file exists before spawning the robot
URDF_PATH="/opt/ros/humble/share/turtlebot3_description/urdf/turtlebot3_${TURTLEBOT3_MODEL}.urdf"
if [[ ! -f "$URDF_PATH" ]]; then
  echo "❌ ERROR: URDF file not found: $URDF_PATH"
  ls -al /opt/ros/humble/share/turtlebot3_description/urdf
  exit 1
fi

# Wait for /spawn_entity service to become available (timeout after 30 seconds)
echo "🔎 Waiting for /spawn_entity service..."
timeout 30 bash -c 'until ros2 service list | grep -q /spawn_entity; do sleep 1; done' || {
  echo "❌ ERROR: /spawn_entity service not available. Gazebo may not have loaded correctly."
  exit 1
}

# Remove any existing TurtleBot3 instance (attempt multiple times)
echo "🧹 Removing any existing TurtleBot3 instance..."
for i in {1..3}; do
  ros2 service call /delete_entity gazebo_msgs/srv/DeleteEntity "{name: 'tb3'}" && break || sleep 2
done
sleep 5

echo "🤖 Spawning TurtleBot3..."
ros2 run gazebo_ros spawn_entity.py -entity tb3 -file "$URDF_PATH"
sleep 5

echo "✅ Simulation Ready! TurtleBot3 is in Gazebo."

# Kill any stray gzclient process (to prevent duplicate GUI attempts)
pkill -9 -f gzclient || true

echo "✅ Simulation Ready! TurtleBot3 is in Gazebo."
exit 0


# Keep the container alive without launching additional processes
# tail -f /dev/null

# Issue	Fix
# netstat: command not found	Replaced netstat with lsof, which is more widely available
# Xvfb Server Already Running	Check if /tmp/.X99-lock exists & remove it before starting
# Gazebo "Address already in use" error	Kill old Gazebo processes & bind to a new port if needed
# Entity [tb3] already exists	Remove existing TurtleBot3 entities before spawning

# Issue	Fix
# lsof missing (skipping port check)	Install lsof in Dockerfile
# Xvfb Server Already Running	Check if /tmp/.X99-lock exists & remove it before starting
# Gazebo "Address already in use" error	Kill old Gazebo processes & bind to a new port if needed
# Entity [tb3] already exists	Remove existing TurtleBot3 entities before spawning

# an updated version of the entrypoint script that aims to fix the errors by ensuring any 
# stale processes (Xvfb and Gazebo) are killed more forcefully, increasing wait times, 
# and attempting to remove any existing TurtleBot3 entity before spawning a new one:

# Below is the updated entrypoint script that avoids launching duplicate Gazebo GUI 
# processes by using the ROS 2 launch file with the GUI disabled. It no longer manually 
# launches gzserver, so that only one headless Gazebo server is running. After that, 
# it waits for the spawn service and spawns the TurtleBot3 once.   