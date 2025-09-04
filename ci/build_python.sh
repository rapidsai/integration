#!/bin/bash
# Copyright (c) 2022-2025, NVIDIA CORPORATION.

set -euo pipefail

source rapids-configure-sccache

source rapids-date-string

RAPIDS_PACKAGE_VERSION=$(rapids-generate-version)
export RAPIDS_PACKAGE_VERSION

source rapids-rattler-channel-string

CONDA_CONFIG_FILE="conda/recipes/versions.yaml"

rapids-print-env

CUDA_MAJOR="${RAPIDS_CUDA_VERSION%%.*}"

# TODO: add rapids-xgboost back when there are CUDA 13 packages
#  ref: https://github.com/rapidsai/xgboost-feedstock/issues/100
if [[ "${CUDA_MAJOR}" == "12" ]]; then
    rapids-logger "Build rapids-xgboost"

    rattler-build build --recipe conda/recipes/rapids-xgboost \
                        --variant-config "${CONDA_CONFIG_FILE}" \
                        "${RATTLER_ARGS[@]}" \
                        "${RATTLER_CHANNELS[@]}"
fi

rapids-logger "Build rapids"

rattler-build build --recipe conda/recipes/rapids \
                    --variant-config "${CONDA_CONFIG_FILE}" \
                    "${RATTLER_ARGS[@]}" \
                    "${RATTLER_CHANNELS[@]}"
