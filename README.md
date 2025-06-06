# UAV 3‑D Scan Simulator

[![CI](https://github.com/ludmattern/virtual-uav-slam/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/ludmattern/virtual-uav-slam/actions/workflows/ci.yml)

**Virtual drone + real‑time 3‑D room scanning, entirely in simulation.**
Powered by **Gazebo**, **PX4 SITL**, **ROS 2 Humble**, and **RTAB‑Map**.

---

## Architecture (high level)

```plaintext
┌──────────────┐   MAVLink   ┌──────────────┐
│    Gazebo    │ ───────────▶│   PX4  SITL  │
│    world +   │             └──────┬───────┘
│    sensors   │                    │ uORB ↔ DDS
└──────────────┘     sensor_msgs    ▼
                      /scan, /imu
                  ┌──────────────┐   pointcloud2   ┌────────────┐
                  │     ROS 2    │ ───────────────▶│  RTAB‑Map  │
                  │     nodes    │                 └────┬───────┘
                  └──────────────┘                      │ map
                                                     ┌──▼──┐
                                                     │ RViz│
                                                     └─────┘
```

---

## Prerequisites

- **Docker ≥ 24**
- **Git**
- Linux host with **8 GB RAM** minimum (Intel/AMD or Apple Silicon via Colima)

---

## Quick start

```bash
# 1. Clone
git clone https://github.com/ludmattern/virtual-uav-slam.git
cd virtual-uav-slam

# 2. Build the development image (first time only)
./dev build

# 3. Launches Docker + Gazebo + ROS 2 shell
./dev up        # launches Docker + Gazebo + ROS 2 shell

# 4. Run a command in the container without starting an interactive shell
./dev up -c "ros2 topic list"  # runs a command and exits

# 5. Execute commands in a running container (optional)
./dev exec ros2 topic list  # run ROS 2 commands in the container

# 6. In the container, start the full stack
ros2 launch launch/full_stack.launch.py
```

Within a few seconds **Gazebo** should open, the drone will lift off, and a live 3‑D point‑cloud will appear in **RViz**.

## Verify the environment

To verify that your development environment is working correctly:

```bash
# Inside the container (after running ./dev up)
source /opt/ros/humble/setup.bash
# Run the talker demo in background
ros2 run demo_nodes_cpp talker &
# Run the listener demo
ros2 run demo_nodes_cpp listener
# You should see "I heard: [Hello World: N]" messages
# Press Ctrl+C to stop the listener, then
pkill -f talker
```

If you see the messages being passed between nodes, your ROS 2 environment is working correctly.

---

## Project layout

```plaintext
.
├── simulation_env/   # Gazebo worlds, models, PX4 params
├── ros_ws/           # ROS 2 Humble workspace (src/, install/)
├── docs/             # Diagrams, research notes, design docs
├── scripts/          # Helper CLI tools, CI scripts
├── .github/workflows # CI pipeline (Docker build, headless SITL tests)
└── dev               # Dev helper script (build, up, exec)
```

---

## Contributing / Project board

All tasks are tracked in the **[GitHub Project board](https://github.com/users/ludmattern/projects/3)** (Kanban + sprints).

1. Pick an open issue in _Iteration N_.
2. Create a feature branch (`feature/short-desc`).
3. Commit with conventional messages (`feat: …`, `fix: …`).
4. Open a PR and link the issue (`Fixes #12`).

---

## Repository

Find the project on GitHub: [ludmattern/virtual-uav-slam](https://github.com/ludmattern/virtual-uav-slam)

---

## License

This project is released under the **MIT License**. See [`LICENSE`](LICENSE) for details.

---

> _“Simulate first, fly safe later.”_
