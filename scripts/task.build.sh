#!/bin/bash

build-image() {
    stage=${1:-runtime}
    source VERSION
    echo "$MAJOR.$MINOR.$PATCH-$(git rev-parse --short HEAD)" >&2
    echo "${BASH_SOURCE[0]:-$0}" >&2
    containerName=second.brain
    case $stage in
        base|development)
            docker build --target "$stage" -t "$containerName.$stage:latest" -t "$containerName.$stage:$MAJOR.$MINOR.$PATCH-$(git rev-parse --short HEAD)" . \
            && echo "To run the image:" \
            && echo "docker run --rm -it $containerName.$stage:$MAJOR.$MINOR.$PATCH-$(git rev-parse --short HEAD)"
            ;;
        runtime)
            docker build -t $containerName:latest -t "$containerName:$MAJOR.$MINOR.$PATCH-$(git rev-parse --short HEAD)" . \
            && echo "To run the image:" \
            && echo "docker run --rm -it $containerName:$MAJOR.$MINOR.$PATCH-$(git rev-parse --short HEAD)" \
            && echo "or" \
            && echo "docker run --rm -it $containerName:latest"
            ;;
        *)
            echo "Invalid stage: $stage. Can only be 'base|build|lint|test|development|runtime'." >&2            
            return 1
            ;;
    esac
}

build-image "$1"