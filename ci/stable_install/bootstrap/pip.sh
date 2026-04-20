#!/bin/bash
# Copyright (c) 2026, NVIDIA CORPORATION.

set -euo pipefail

echo "installing 'uv'"
curl -LsSf https://astral.sh/uv/install.sh | sh
echo "done installing 'uv'"

source "$HOME"/.local/bin/env

rapids-logger "Removing nightly PyPI index"
pip config --global unset global.extra-index-url

rapids-logger "Setting pip global retries to 10"
pip config --global set global.retries 10
