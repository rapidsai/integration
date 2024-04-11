#!/bin/bash
# Copyright (c) 2022-2023, NVIDIA CORPORATION.

set -euo pipefail

rapids-configure-conda-channels
conda config --system --remove channels rapidsai

source rapids-configure-sccache

source rapids-date-string

CONDA_CONFIG_FILE="conda/recipes/versions.yaml"

rapids-print-env

rapids-logger "Build rapids-xgboost"

rapids-conda-retry mambabuild \
  --use-local \
  --variant-config-files "${CONDA_CONFIG_FILE}" \
  conda/recipes/rapids-xgboost

rapids-logger "Build rapids"

rapids-conda-retry mambabuild \
  --use-local \
  --variant-config-files "${CONDA_CONFIG_FILE}" \
  conda/recipes/rapids

rapids-upload-conda-to-s3 python
