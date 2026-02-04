---
title: "Docker Ubuntu Test Environment"
type: feat
date: 2026-02-01
---

# Docker Ubuntu Test Environment

## Overview

Create a Docker-based testing environment to validate the dotfiles install script on a fresh Ubuntu system. This enables rapid iteration and testing of Linux support without needing a real VM or VPS.

## Problem Statement

After adding Ubuntu/Linux support to `install.sh`, we need a way to:
- Test the script on a clean Ubuntu environment
- Validate all tools install correctly
- Interactively use the terminal with the full toolset (yazi, zellij, helix, etc.)
- Iterate quickly without provisioning real infrastructure

## Proposed Solution

A minimal Dockerfile that:
1. Starts from official Ubuntu LTS image
2. Sets up a non-root user (mimics real usage)
3. Mounts the local dotfiles repo
4. Provides interactive terminal access via `docker exec`

## Technical Approach

### Dockerfile

```dockerfile
# Dockerfile.ubuntu-test
FROM ubuntu:24.04

# Avoid interactive prompts during apt install
ENV DEBIAN_FRONTEND=noninteractive

# Install minimal prerequisites (the install.sh will do the rest)
RUN apt-get update && apt-get install -y \
    sudo \
    git \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Create non-root user with sudo access
ARG USERNAME=testuser
ARG USER_UID=1000
ARG USER_GID=$USER_UID

RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME \
    && echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/$USERNAME

# Switch to non-root user
USER $USERNAME
WORKDIR /home/$USERNAME

# Set up shell
ENV SHELL=/bin/bash
CMD ["/bin/bash"]
```

### Helper Script

```bash
# test-ubuntu.sh
#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
IMAGE_NAME="dotfiles-ubuntu-test"
CONTAINER_NAME="dotfiles-test"

case "${1:-run}" in
    build)
        echo "Building Ubuntu test image..."
        docker build -f "$SCRIPT_DIR/Dockerfile.ubuntu-test" -t "$IMAGE_NAME" "$SCRIPT_DIR"
        ;;
    run)
        # Build if image doesn't exist
        if ! docker image inspect "$IMAGE_NAME" &>/dev/null; then
            "$0" build
        fi

        # Remove existing container if any
        docker rm -f "$CONTAINER_NAME" 2>/dev/null || true

        echo "Starting Ubuntu test container..."
        docker run -d \
            --name "$CONTAINER_NAME" \
            -v "$SCRIPT_DIR:/home/testuser/dotfiles:ro" \
            -it "$IMAGE_NAME" \
            sleep infinity

        echo "Container running. Connect with: $0 shell"
        ;;
    shell)
        echo "Connecting to Ubuntu test container..."
        docker exec -it "$CONTAINER_NAME" /bin/bash
        ;;
    stop)
        echo "Stopping container..."
        docker rm -f "$CONTAINER_NAME" 2>/dev/null || true
        ;;
    clean)
        echo "Removing container and image..."
        docker rm -f "$CONTAINER_NAME" 2>/dev/null || true
        docker rmi "$IMAGE_NAME" 2>/dev/null || true
        ;;
    *)
        echo "Usage: $0 {build|run|shell|stop|clean}"
        exit 1
        ;;
esac
```

### Usage Workflow

```bash
# 1. Start the test environment
./test-ubuntu.sh run

# 2. Get a shell into the container
./test-ubuntu.sh shell

# 3. Inside container: run the install script
cd ~/dotfiles
./install.sh

# 4. Test the tools
yazi          # File manager
zellij        # Terminal multiplexer
hx            # Helix editor
nvim          # Neovim with LazyVim

# 5. Exit and stop when done
exit
./test-ubuntu.sh stop

# 6. For a fresh test (removes everything)
./test-ubuntu.sh clean
./test-ubuntu.sh run
```

## Acceptance Criteria

- [x] `./test-ubuntu.sh run` starts an Ubuntu 24.04 container
- [x] `./test-ubuntu.sh shell` provides interactive bash access
- [x] Local dotfiles are mounted read-only at `/home/testuser/dotfiles`
- [x] Non-root user `testuser` has passwordless sudo
- [ ] Running `./install.sh` inside container completes without errors
- [ ] All tools are accessible after install (yazi, zellij, helix, nvim, etc.)
- [x] `./test-ubuntu.sh clean` removes all Docker artifacts

## Files to Create

| File | Purpose |
|------|---------|
| `Dockerfile.ubuntu-test` | Ubuntu 24.04 test image definition |
| `test-ubuntu.sh` | Helper script for build/run/shell/stop/clean |

## Notes

- Mount is read-write so `stow --adopt` and git operations work correctly
- Using `sleep infinity` keeps container running for multiple `docker exec` sessions
- Non-root user ensures install script works without being root
- DEBIAN_FRONTEND=noninteractive prevents apt from prompting during base image setup

## Testing Checklist

After implementation, verify:

1. **Clean install test**
   ```bash
   ./test-ubuntu.sh clean && ./test-ubuntu.sh run
   ./test-ubuntu.sh shell
   # Inside: ./install.sh
   ```

2. **Tool verification**
   ```bash
   # Inside container after install:
   command -v yazi && echo "yazi OK"
   command -v zellij && echo "zellij OK"
   command -v hx && echo "helix OK"
   command -v nvim && echo "nvim OK"
   command -v claude && echo "claude OK"
   ```

3. **Interactive usage**
   - Launch yazi and navigate files
   - Start zellij session
   - Open a file in helix
   - Run `dev` alias if configured

## Future Enhancements

- Add Ubuntu 22.04 LTS variant for broader testing
- Add CI integration (GitHub Actions) for automated testing on PR
- Consider Fedora/Arch variants if those become supported
