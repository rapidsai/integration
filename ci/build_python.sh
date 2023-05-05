#!/bin/bash
# Copyright (c) 2022-2023, NVIDIA CORPORATION.

set -euo pipefail

source rapids-env-update

CONDA_CONFIG_FILE="conda/recipes/versions.yaml"

rapids-print-env

rapids-logger "Build rapids-xgboost"

rapids-mamba-retry mambabuild \
  --no-test \
  --variant-config-files "${CONDA_CONFIG_FILE}" \
  conda/recipes/rapids-xgboost

rapids-logger "Build rapids"

rapids-mamba-retry mambabuild \
  --no-test \
  --variant-config-files "${CONDA_CONFIG_FILE}" \
  conda/recipes/rapids

rapids-logger "Build rapids-build-env"

rapids-mamba-retry mambabuild \
  --no-test \
  --variant-config-files "${CONDA_CONFIG_FILE}" \
  conda/recipes/rapids-build-env

rapids-logger "Build rapids-notebook-env"

rapids-mamba-retry mambabuild \
  --no-test \
  --variant-config-files "${CONDA_CONFIG_FILE}" \
  conda/recipes/rapids-notebook-env

if [ "$(uname -m)" != "aarch64" ]; then

  rapids-logger "Build rapids-doc-env"

  rapids-mamba-retry mambabuild \
    --no-test \
    --variant-config-files "${CONDA_CONFIG_FILE}" \
    conda/recipes/rapids-doc-env
fi

rapids-upload-conda-to-s3 python
