#!/bin/bash
# Copyright (c) 2023, NVIDIA CORPORATION.

set -euo pipefail

RAPIDS_VERSION="23.12"
CUDA_VERSION=${RAPIDS_CUDA_VERSION%.*}

JSON_FILENAME="rapids_cuda${CUDA_VERSION}_py${RAPIDS_PY_VERSION}.json"

echo "Creating conda environment with rapids=${RAPIDS_VERSION}, python=${RAPIDS_PY_VERSION}, cuda-version=${CUDA_VERSION}"
#rapids-logger "Creating conda environment with rapids=${RAPIDS_VERSION}, python=${RAPIDS_PY_VERSION}, cuda-version=${CUDA_VERSION}"

#rapids-conda-retry \
conda \
    create \
    --solver=libmamba \
    -n rapids-${RAPIDS_VERSION} \
    -c rapidsai-nightly \
    -c conda-forge \
    -c nvidia  \
    rapids=${RAPIDS_VERSION} \
    python=${RAPIDS_PY_VERSION} \
    cuda-version=${CUDA_VERSION} \
    --dry-run \
    --json \
    | tee "${JSON_FILENAME}"

python ci/check_conda_nightly_env.py "${JSON_FILENAME}"
