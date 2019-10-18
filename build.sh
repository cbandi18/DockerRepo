#!/bin/bash

set -e

# Quick verify
echo "Verifying mkdocs config"
docker run --rm -tiv $PWD:/app -w /app node:alpine node verify.js

# Build each language and, you know, multi-arch it!
for language in `find . -type d -maxdepth 1 | grep docs | cut -d '_' -f 2`; do
  echo "Going to build image for $language"
  docker buildx build \
      --platform linux/amd64,linux/arm64,linux/arm/v7,linux/arm/v6 \
      --build-arg LANGUAGE=$language \
      -t dockersamples/101-tutorial:$language \
      --push .
done

# Retag "en" as latest
docker buildx build \
      --platform linux/amd64,linux/arm64,linux/arm/v7,linux/arm/v6 \
      --build-arg LANGUAGE=en \
      -t dockersamples/101-tutorial:latest \
      --push .
