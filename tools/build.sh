#!/bin/bash
# 
echo "Building project using Docker..."
rm -rf outputs || true
mkdir outputs

docker build -t git.zontreck.com/packages/switchboard:helper docker/build-helper
docker run -v "$(pwd)":/app/source -v "$(pwd)"/outputs:/app/project/outputs git.zontreck.com/packages/switchboard:helper

sleep 5
docker rmi git.zontreck.com/packages/switchboard:helper -f