#!/bin/bash
# Copyright (c) 2026, NVIDIA CORPORATION.
#
# This script expects N arguments, each the import name of an installed RAPIDS
# library in the currently active virtualenv or conda environment.

set -euo pipefail

while [[ $# -gt 0 ]]; do
    rapids-logger "Import test for $1"
    python -c "import $1"
    shift
done
