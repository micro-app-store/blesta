#!/usr/bin/env bash

docker buildx create --name container-builder --driver docker-container --bootstrap --use
docker build --builder container-builder --platform linux/amd64,linux/arm64,linux/arm/v7 --push -t ghcr.io/micro-app-store/blesta:latest .
