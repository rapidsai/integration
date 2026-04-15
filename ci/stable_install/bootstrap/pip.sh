#!/bin/bash
# Copyright (c) 2026, NVIDIA CORPORATION.

set -euo pipefail

echo "installing 'uv'"
curl -LsSf https://astral.sh/uv/install.sh | sh
echo "done installing 'uv'"

source "$HOME"/.local/bin/env

# Nuke existing config (pip config --global doesn't touch this file for some reason)
rapids-logger "Nuking existing global pip config to remove nightly index"
rm /etc/xdg/pip/pip.conf

rapids-logger "Setting pip global retries to 10"
pip config --global set global.retries 10
