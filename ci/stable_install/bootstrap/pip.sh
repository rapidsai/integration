#!/bin/bash
# Copyright (c) 2026, NVIDIA CORPORATION.

set -euo pipefail

echo "installing 'uv'"
curl -LsSf https://astral.sh/uv/install.sh | sh
echo "done installing 'uv'"

source "$HOME"/.local/bin/env

# TODO: remove me after updating to 26.06
# this will fail once we pull newer containers that have already moved
# `pip.conf` to the `/etc/pip.conf` location
mv /etc/xdg/pip/pip.conf /etc/pip.conf

rapids-logger "Removing nightly PyPI index"
pip config --global unset global.extra-index-url

rapids-logger "Setting pip global retries to 10"
pip config --global set global.retries 10
