#!/bin/bash
set -e  # Exit if any command fails

echo "🚀 Running TurtleBot3 Simulation in a Docker container..."

# Set the model (can be changed via environment variable)
export TURTLEBOT3_MODEL=${TURTLEBOT3_MODEL:-burger}

# Run the container, letting `entrypoint.sh` handle the simulation
docker run --rm -it --name tb3_sim \
    -e TURTLEBOT3_MODEL=${TURTLEBOT3_MODEL} \
    tb3_sim
