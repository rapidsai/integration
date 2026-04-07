#!/bin/bash
# Copyright (c) 2026, NVIDIA CORPORATION.

set -euo pipefail

apt update && apt install -y curl

echo "installing 'gha-tools'"
curl -fsSL https://github.com/rapidsai/gha-tools/releases/latest/download/tools.tar.gz | tar -xz -C /usr/local/bin/
echo "done installing 'gha-tools' to '/usr/local/bin'"

echo "installing 'uv'"
curl -LsSf https://astral.sh/uv/install.sh | sh
echo "done installing 'uv'"

source "$HOME"/.local/bin/env
