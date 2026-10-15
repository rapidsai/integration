#!/bin/bash
# Copyright (c) 2026, NVIDIA CORPORATION & AFFILIATES. All rights reserved.

# Installs the latest RAPIDS nightly wheels alongside a PyTorch wheel from
# https://download.pytorch.org/whl/<torch-index> and runs smoke tests.
#
# Extra pins can be added to ci/pytorch/constraints.txt to check whether a
# proposed dependency change would make RAPIDS and PyTorch uninstallable together.
#
# Example: ./ci/pytorch/test_pytorch_pip.sh --torch-index nightly/cu130

set -euo pipefail

RAPIDS_VERSION="26.12"

SCRIPT_DIR="$(dirname "${BASH_SOURCE[0]}")"
source "${SCRIPT_DIR}/../stable_install/test_imports.sh"

while [[ $# -gt 0 ]]; do
  case $1 in
    --torch-index)
      shift
      TORCH_INDEX="$1"
      shift
      ;;
    -*)
      rapids-echo-stderr "Unknown flag: $1. Supported flags: --torch-index"
      exit 1
      ;;
  esac
done

if [[ -z "${TORCH_INDEX:-}" ]]; then
  rapids-echo-stderr "--torch-index is required"
  exit 1
fi

TORCH_INDEX_URL="https://download.pytorch.org/whl/${TORCH_INDEX}"
TORCH_CUDA="${TORCH_INDEX##*/}"
CUDA_SUFFIX="${TORCH_CUDA:0:4}"

TORCH_DOWNLOAD_ARGS=()
if [[ "${TORCH_INDEX}" == nightly/* ]]; then
  TORCH_DOWNLOAD_ARGS+=(--pre)
fi

RAPIDS_PACKAGES=(
    "cucim-${CUDA_SUFFIX}==${RAPIDS_VERSION}.*"
    "cudf-${CUDA_SUFFIX}==${RAPIDS_VERSION}.*"
    "cudf-polars-${CUDA_SUFFIX}==${RAPIDS_VERSION}.*"
    "cugraph-${CUDA_SUFFIX}==${RAPIDS_VERSION}.*"
    "cugraph-pyg-${CUDA_SUFFIX}==${RAPIDS_VERSION}.*"
    "cuml-${CUDA_SUFFIX}==${RAPIDS_VERSION}.*"
    "cuvs-${CUDA_SUFFIX}==${RAPIDS_VERSION}.*"
    "dask-cuda==${RAPIDS_VERSION}.*"
    "dask-cudf-${CUDA_SUFFIX}==${RAPIDS_VERSION}.*"
    "nx-cugraph-${CUDA_SUFFIX}==${RAPIDS_VERSION}.*"
    "pylibwholegraph-${CUDA_SUFFIX}==${RAPIDS_VERSION}.*"
    "raft-dask-${CUDA_SUFFIX}==${RAPIDS_VERSION}.*"
    "rapidsmpf-${CUDA_SUFFIX}==${RAPIDS_VERSION}.*"
    "xgboost-${CUDA_SUFFIX}"
)

INSTALL_DIR=$(mktemp -d)
python -m venv "${INSTALL_DIR}/.venv"
source "${INSTALL_DIR}/.venv/bin/activate"

# torch is downloaded on its own so that --pre (needed for nightlies) does not
# also allow pre-releases of every other dependency.
rapids-logger "Downloading torch from ${TORCH_INDEX_URL}"
rapids-pip-retry download \
  --isolated \
  --no-deps \
  "${TORCH_DOWNLOAD_ARGS[@]}" \
  --index-url "${TORCH_INDEX_URL}" \
  -d "${INSTALL_DIR}" \
  torch

rapids-logger "Installing RAPIDS ${RAPIDS_VERSION} nightlies with $(basename "${INSTALL_DIR}"/torch-*.whl)"
rapids-pip-retry install \
  --isolated \
  --index-url https://pypi.org/simple \
  --extra-index-url https://pypi.anaconda.org/rapidsai-wheels-nightly/simple \
  --extra-index-url "${TORCH_INDEX_URL}" \
  --constraint "${SCRIPT_DIR}/constraints.txt" \
  "${RAPIDS_PACKAGES[@]}" \
  "${INSTALL_DIR}"/torch-*.whl

python -m pip list

# shellcheck disable=SC2034
declare -a IMPORTS=(
  cucim
  cudf
  cudf_polars
  cugraph
  cugraph_pyg
  cuml
  cuvs
  dask_cuda
  dask_cudf
  nx_cugraph
  pylibwholegraph
  raft_dask
  rapidsmpf
  torch
  xgboost
)
testImports IMPORTS

rapids-logger "Checking that torch can use the GPU"
python -c "import torch; assert torch.cuda.is_available(), 'torch.cuda.is_available() is False'"
