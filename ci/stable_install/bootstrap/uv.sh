#!/bin/bash
# Copyright (c) 2026, NVIDIA CORPORATION.

set -euo pipefail

echo "installing 'uv'"
curl -LsSf https://astral.sh/uv/install.sh | sh
echo "done installing 'uv'"

source "$HOME"/.local/bin/env
