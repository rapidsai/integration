#!/bin/bash
# Copyright (c) 2024-2025, NVIDIA CORPORATION.

set -euo pipefail

RAPIDS_VERSION="25.12"
CUDA_VERSION=${RAPIDS_CUDA_VERSION%.*}

JSON_FILENAME="rapids_cuda${CUDA_VERSION}_py${RAPIDS_PY_VERSION}.json"

rapids-logger "Creating conda environment with rapids=${RAPIDS_VERSION}, python=${RAPIDS_PY_VERSION}, cuda-version=${CUDA_VERSION}"

rapids-conda-retry \
    create \
    -n rapids-${RAPIDS_VERSION} \
    -c rapidsai-nightly \
    -c conda-forge \
    rapids=${RAPIDS_VERSION} \
    python=${RAPIDS_PY_VERSION} \
    cuda-version=${CUDA_VERSION} \
    --dry-run \
    --json \
    --quiet \
    | tee "${JSON_FILENAME}"

rapids-logger "Parsing results from conda dry-run with rapids=${RAPIDS_VERSION}, python=${RAPIDS_PY_VERSION}, cuda-version=${CUDA_VERSION}"

python ci/check_conda_nightly_env.py "${JSON_FILENAME}"
