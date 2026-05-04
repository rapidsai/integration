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

SCRIPT_DIR="$(dirname "${BASH_SOURCE[0]}")"
source "${SCRIPT_DIR}/bootstrap/pip.sh"
source "${SCRIPT_DIR}/test_imports.sh"
source "${SCRIPT_DIR}/install_rapids_doctor.sh"

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

function createPyEnv {
    PY_VER=$1
    INSTALL_DIR=$2
    pushd "$INSTALL_DIR"

    rapids-logger "Creating virtualenv for Python $PY_VER"
    uv venv --python="$PY_VER" --seed
    source "${INSTALL_DIR}/.venv/bin/activate"
}

CUDA_SUFFIX="cu${CUDA_VERSION%%.*}"

# TODO: CTK support for cublas on arm is weird around 12.2 -- we can remove this
# workaround when support for 12.2 is dropped
if [[ "${CUDA_VERSION}" == 12.2* ]] && [[ "$(uname -m)" == "aarch64" ]]; then
    CUDA_TOOLKIT_SPEC="cuda-toolkit>=12.2,<12.4"
else
    CUDA_TOOLKIT_SPEC="cuda-toolkit==${CUDA_VERSION}.*"
fi

rapids-logger "Using cuda-toolkit for CUDA ${CUDA_VERSION}"
PIP_INSTALL_PYPI=(
    "cudf-${CUDA_SUFFIX}==${STABLE_RAPIDS_VERSION}"
    "cudf-polars-${CUDA_SUFFIX}==${STABLE_RAPIDS_VERSION}"
    "cuml-${CUDA_SUFFIX}==${STABLE_RAPIDS_VERSION}"
    "dask-cudf-${CUDA_SUFFIX}==${STABLE_RAPIDS_VERSION}"
    "pylibraft-${CUDA_SUFFIX}==${STABLE_RAPIDS_VERSION}"
    "raft-dask-${CUDA_SUFFIX}==${STABLE_RAPIDS_VERSION}"
    "rapidsmpf-${CUDA_SUFFIX}==${STABLE_RAPIDS_VERSION}"
    "${CUDA_TOOLKIT_SPEC}"
)

INSTALL_DIR=$(mktemp -d)
createPyEnv "$PYTHON_VERSION" "$INSTALL_DIR"

rapids-logger "Downloading NVIDIA PyPI only wheels for Python $PYTHON_VERSION and CUDA $CUDA_VERSION"

WHEELS_DIR=$(mktemp -d)
python -m pip download \
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

rapids-logger "Testing stable version install with Python $PYTHON_VERSION and CUDA $CUDA_VERSION"

python -m pip install \
  --isolated \
  --index-url https://pypi.org/simple \
  --prefer-binary \
  "${PIP_INSTALL_PYPI[@]}" \
  "${WHEELS_DIR}"/*.whl

# shellcheck disable=SC2034
declare -a RAPIDS_IMPORTS=(
  cucim
  cudf
  cudf_polars
  cugraph
  cuml
  cuvs
  cuxfilter
  dask_cudf
  nx_cugraph
  pylibraft
  raft_dask
  rapidsmpf
  rmm
)
testImports RAPIDS_IMPORTS

# Run RAPIDS health checks
installRapidsDoctor

rapids-logger "Running RAPIDS doctor smoke tests"
rapids doctor --verbose

popd

rapids-logger "Removing environment in $INSTALL_DIR/.venv"
rm -rf "$INSTALL_DIR/.venv"
