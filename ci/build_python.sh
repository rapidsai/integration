#!/bin/bash
# Copyright (c) 2022-2025, NVIDIA CORPORATION.

set -euo pipefail

source rapids-configure-sccache

source rapids-date-string

source rapids-rattler-channel-string

CONDA_CONFIG_FILE="conda/recipes/versions.yaml"

rapids-print-env

rapids-logger "Build rapids-xgboost"

rattler-build build --recipe conda/recipes/rapids-xgboost \
                    --variant-config "${CONDA_CONFIG_FILE}" \
                    "${RATTLER_ARGS[@]}" \
                    "${RATTLER_CHANNELS[@]}"

rapids-logger "Build rapids"

rattler-build build --recipe conda/recipes/rapids \
                    --variant-config "${CONDA_CONFIG_FILE}" \
                    "${RATTLER_ARGS[@]}" \
                    "${RATTLER_CHANNELS[@]}"
