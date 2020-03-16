#!/bin/bash -x

# Allow us to call script from any pwd
SCRIPT_DIR="${0%/*}"

cd "$SCRIPT_DIR"

# Build inspec-target container
make

# Refresh namespace
docker rm -f inspec-target &>/dev/null

# Run container with stub environmental vars
# Override the infinate entry point so users
# can do an interactive debug session with sh
docker run \
    -d \
    -e VAULT_ADDR='http://127.0.0.1:8200' \
    --name inspec-target \
    inspec-target
