#!/bin/bash
# Copyright (c) 2026, NVIDIA CORPORATION.

# By default, this script attempts to install the latest stable RAPIDS version
# in a clean Python venv for all supported versions of Python and CUDA
#
# The Python version, CUDA version, and RAPIDS version can be overridden by
# supplying the value to test to the appropriate flag (--python, --rapids, and
# --cuda, respectively).
#
# Note that the CUDA version should be specified as a -cu* suffix, e.g. `--cuda cu13`
# and will iterate over all supported minor CUDA versions, so `cu13` will test (13.0, 13.1)

set -euo pipefail

STABLE_RAPIDS_VERSION="26.4.*"
SUPPORTED_PYTHON_VERSIONS=(3.11 3.12 3.13 3.14)
SUPPORTED_CUDA_VERSIONS=("cu12" "cu13")
CUDA12_MINOR_VERSIONS=(12.2 12.9)
CUDA13_MINOR_VERSIONS=(13.0 13.1)

SCRIPT_DIR="$(dirname "${BASH_SOURCE[0]}")"
source "${SCRIPT_DIR}/bootstrap/pip.sh"
source "${SCRIPT_DIR}/test_imports.sh"

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

function createPyEnv {
    PY_VER=$1
    INSTALL_DIR=$(mktemp -d)
    pushd "$INSTALL_DIR"

    rapids-logger "Creating virtualenv for Python $PY_VER"
    uv venv --python="$PY_VER" --seed
    source "${INSTALL_DIR}/.venv/bin/activate"
}


for CUDA_SUFFIX in "${SUPPORTED_CUDA_VERSIONS[@]}"; do

    case "${CUDA_SUFFIX}" in
        cu12) CUDA_MINOR_VERSIONS=("${CUDA12_MINOR_VERSIONS[@]}") ;;
        cu13) CUDA_MINOR_VERSIONS=("${CUDA13_MINOR_VERSIONS[@]}") ;;
    esac



    for cuda_major_minor in "${CUDA_MINOR_VERSIONS[@]}"; do
        rapids-logger "Using cuda-toolkit for CUDA ${cuda_major_minor}"
        PIP_INSTALL_PYPI=(
            "cudf-${CUDA_SUFFIX}==${STABLE_RAPIDS_VERSION}"
            "dask-cudf-${CUDA_SUFFIX}==${STABLE_RAPIDS_VERSION}"
            "cuml-${CUDA_SUFFIX}==${STABLE_RAPIDS_VERSION}"
            "pylibraft-${CUDA_SUFFIX}==${STABLE_RAPIDS_VERSION}"
            "raft-dask-${CUDA_SUFFIX}==${STABLE_RAPIDS_VERSION}"
            "cuda-toolkit[all]==${cuda_major_minor}.*"
        )


      for PY_VER in "${SUPPORTED_PYTHON_VERSIONS[@]}"; do

          createPyEnv "$PY_VER"

          rapids-logger "Downloading NVIDIA PyPI only wheels for Python $PY_VER and CUDA $cuda_major_minor"

          WHEELS_DIR=$(mktemp -d)
          pip download \
            --isolated \
            --index-url https://pypi.nvidia.com \
            --prefer-binary \
            --no-deps \
            -d "${WHEELS_DIR}" \
            "cucim-${CUDA_SUFFIX}==${STABLE_RAPIDS_VERSION}" \
            "cugraph-${CUDA_SUFFIX}==${STABLE_RAPIDS_VERSION}" \
            "cuvs-${CUDA_SUFFIX}==${STABLE_RAPIDS_VERSION}" \
            "cuxfilter-${CUDA_SUFFIX}==${STABLE_RAPIDS_VERSION}" \
            "libcugraph-${CUDA_SUFFIX}==${STABLE_RAPIDS_VERSION}" \
            "libcuvs-${CUDA_SUFFIX}==${STABLE_RAPIDS_VERSION}" \
            "nx-cugraph-${CUDA_SUFFIX}==${STABLE_RAPIDS_VERSION}" \
            "pylibcugraph-${CUDA_SUFFIX}==${STABLE_RAPIDS_VERSION}"

          rapids-logger "Testing stable version install with Python $PY_VER and CUDA $cuda_major_minor"

          pip install \
            --isolated \
            --index-url https://pypi.org/simple \
            --prefer-binary \
            "${PIP_INSTALL_PYPI[@]}" \
            "${WHEELS_DIR}"/*.whl

          testImports cudf dask_cudf cuml pylibraft raft_dask cugraph nx_cugraph cuxfilter cucim cuvs

          popd
        done
    done
done
