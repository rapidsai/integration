#!/bin/bash
# Copyright (c) 2026, NVIDIA CORPORATION.

# This script installs the latest stable RAPIDS version in a clean conda
# environment for the specified Python and CUDA versions.
#
# The Python version, CUDA version, and RAPIDS version can be specified via
# --python, --cuda, and --rapids, respectively. --python and --cuda are required.

set -euo pipefail

SCRIPT_DIR="$(dirname "${BASH_SOURCE[0]}")"
source "${SCRIPT_DIR}/test_imports.sh"

STABLE_RAPIDS_VERSION="26.4.*"

while [[ $# -gt 0 ]]; do
  case $1 in
    --python)
      shift
      PYTHON_VERSION="$1"
      shift
      ;;
    --rapids)
      shift
      STABLE_RAPIDS_VERSION="$1"
      shift
      ;;
    --cuda)
      shift
      CUDA_VERSION="$1"
      shift
      ;;
    -*)
      rapids-echo-stderr "Unknown flag: $1. Supported flags: --python, --rapids, --cuda"
      exit 1
      ;;
  esac
done

if [[ -z "${PYTHON_VERSION:-}" ]]; then
  rapids-echo-stderr "--python is required"
  exit 1
fi

if [[ -z "${CUDA_VERSION:-}" ]]; then
  rapids-echo-stderr "--cuda is required"
  exit 1
fi

CUDA_VERSION="${CUDA_VERSION%.*}"

. /opt/conda/etc/profile.d/conda.sh

envName="rapids_${PYTHON_VERSION}_${CUDA_VERSION}"

rapids-logger "Testing stable version install with Python $PYTHON_VERSION and CUDA version $CUDA_VERSION"

# use `-O` to override channels so we don't include `rapidsai-nightly`
conda create -n "$envName" -O -c rapidsai -c conda-forge -y \
  rapids="$STABLE_RAPIDS_VERSION" python="$PYTHON_VERSION" "cuda-version==${CUDA_VERSION}"

conda activate "$envName"

# Test imports of all packages included in the rapids metapackage
testImports cudf dask_cudf cuml pylibraft raft_dask cugraph nx_cugraph cuxfilter cuvs cucim rmm

conda deactivate
conda env remove -n "$envName"
