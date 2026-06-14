#!/usr/bin/env bash

set -ueo pipefail

if [[ ! -f .devcontainer/.env ]]; then
    cp .devcontainer/.env.example .devcontainer/.env
fi

### === ### === ### === ### === ### === ### === ### === ### === ### === ###

rm -rf .devcontainer/features
mkdir -p .devcontainer/features
cp -R src/* .devcontainer/features/
