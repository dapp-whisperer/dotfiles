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
            -v "$SCRIPT_DIR:/home/testuser/dotfiles" \
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
