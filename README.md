# 🐢🚀 TurtleBot3 Gazebo CI/CD

![TurtleBot3 Gazebo](https://user-images.githubusercontent.com/your-image-url.png)  
*A fully automated CI/CD pipeline for running TurtleBot3 simulations using Docker and GitHub Actions.*

---

## 📌 Project Overview
This project sets up a **Docker-based CI/CD pipeline** for running **TurtleBot3 simulations in Gazebo** without using `.launch` files. It automates:
- **Building the ROS 2 & Gazebo environment** inside Docker.
- **Spawning the TurtleBot3 robot** in an empty Gazebo world.
- **Running tests** to ensure proper simulation setup.
- **Continuous Integration (CI)** using GitHub Actions.

---

## 🛠️ Setup & Usage
### 🔹 Prerequisites
Before running this project, ensure you have:
- **Docker** installed: [Get Docker](https://docs.docker.com/get-docker/)
- (Optional) **GitHub Actions Runner** if testing locally.

### 🔹 Clone the Repository
```bash
git clone https://github.com/yourusername/turtlebot3_gazebo_ci.git
cd turtlebot3_gazebo_ci

### 🔹 Build & Run the Docker Container
To build and run the simulation inside a Docker container, execute:

```bash
docker build -t tb3_sim ./docker
docker run --rm -it tb3_sim
