#!/bin/bash
# Copyright (c) 2026, NVIDIA CORPORATION.

# By default, this script attempts to install the latest stable RAPIDS version
# in a clean conda environment for all supported versions of Python and CUDA
#
# The Python version, CUDA version, and RAPIDS version can be overridden by
# supplying the value to test to the appropriate flag (--python, --rapids, and
# --cuda, respectively).

set -euo pipefail

SCRIPT_DIR="$(dirname "${BASH_SOURCE[0]}")"
source "${SCRIPT_DIR}/test_imports.sh"

STABLE_RAPIDS_VERSION="26.4.*"
SUPPORTED_PYTHON_VERSIONS=(3.11 3.12 3.13 3.14)
SUPPORTED_CUDA_VERSIONS=("12.2" "12.9" "13.0" "13.1")

while [[ $# -gt 0 ]]; do
  case $1 in
    --python)
      shift
      SUPPORTED_PYTHON_VERSIONS=("$1")
      shift
      ;;
    --rapids)
      shift
      STABLE_RAPIDS_VERSION="$1"
      shift
      ;;
    --cuda)
      shift
      SUPPORTED_CUDA_VERSIONS=("$1")
      shift
      ;;
    -*)
      rapids-echo-stderr "Unknown flag: $1. Supported flags: --python, --rapids, --cuda"
      exit 1
      ;;
  esac
done

. /opt/conda/etc/profile.d/conda.sh

for CUDA_VERSION in "${SUPPORTED_CUDA_VERSIONS[@]}"; do
    for PY_VER in "${SUPPORTED_PYTHON_VERSIONS[@]}"; do
        envName="rapids_${PY_VER}_${CUDA_VERSION}"

        rapids-logger "Testing stable version install with Python $PY_VER and CUDA version $CUDA_VERSION"

        # use `-O` to override channels so we don't include `rapidsai-nightly`
        conda create -n "$envName" -O -c rapidsai -c conda-forge -y \
          rapids="$STABLE_RAPIDS_VERSION" python="$PY_VER" "cuda-version==${CUDA_VERSION}"

        conda activate "$envName"

        testImports cudf dask_cudf cuml pylibraft raft_dask cugraph nx_cugraph cuxfilter cuvs # cucim

        conda deactivate
        conda env remove -n "$envName"
    done
done
