# Makefile for virtual-uav-slam project with PX4 SITL integration

# Configuration
IMAGE_NAME := virtual-uav-slam
IMAGE_TAG := dev
CONTAINER_NAME := $(IMAGE_NAME)-dev
WORKSPACE_DIR := $(shell pwd)
BUILD_JOBS := $(shell nproc)
DOCKER_BUILD_ARGS := 

# Detect if running in CI
ifeq ($(CI),true)
	DOCKER_RUN_FLAGS := -i
else
	DOCKER_RUN_FLAGS := -it
endif

.PHONY: all help build clean run px4-clone px4-build px4-run px4-clean px4-full

# Default target
all: build

# Help message
help:
	@echo "Virtual UAV SLAM - Development Environment"
	@echo ""
	@echo "Usage:"
	@echo "  make build             Build the Docker image"
	@echo "  make run               Run the development container"
	@echo "  make clean             Remove Docker image and cleanup"
	@echo "  make px4-clone         Clone the PX4-Autopilot repository"
	@echo "  make px4-build         Build the PX4 SITL target"
	@echo "  make px4-run           Run PX4 SITL with Gazebo"
	@echo "  make px4-clean         Clean the PX4 build directory"
	@echo "  make px4-full          Clone, build and run PX4 SITL (all steps)"
	@echo ""
	@echo "Options:"
	@echo "  BUILD_JOBS=n          Set the number of parallel build jobs (default: auto)"
	@echo "  DOCKER_BUILD_ARGS=\"args\"  Additional arguments for docker build"

# Build the Docker image
build:
	docker build -t $(IMAGE_NAME):$(IMAGE_TAG) $(DOCKER_BUILD_ARGS) .

# Run the development container
run:
	docker run $(DOCKER_RUN_FLAGS) --rm \
		--name $(CONTAINER_NAME) \
		-e DISPLAY=$$DISPLAY \
		-v /tmp/.X11-unix:/tmp/.X11-unix \
		-v $(WORKSPACE_DIR):/work \
		--network=host \
		--workdir=/work \
		$(IMAGE_NAME):$(IMAGE_TAG)

# Remove Docker image and cleanup
clean:
	docker rmi -f $(IMAGE_NAME):$(IMAGE_TAG) || true

# PX4 SITL Targets
px4-clone:
	./dev up -c "setup-px4.sh clone"

px4-build:
	./dev up -c "setup-px4.sh build -j $(BUILD_JOBS)"

px4-run:
	./dev up -c "setup-px4.sh run"

px4-clean:
	./dev up -c "setup-px4.sh clean"

px4-full:
	./dev up -c "setup-px4.sh full"
