#!/bin/bash
# Copyright (c) 2023, NVIDIA CORPORATION.

set -euo pipefail

RAPIDS_VERSION="24.10"
CUDA_VERSION=${RAPIDS_CUDA_VERSION%.*}

JSON_FILENAME="rapids_cuda${CUDA_VERSION}_py${RAPIDS_PY_VERSION}.json"

rapids-logger "Creating conda environment with rapids=${RAPIDS_VERSION}, python=${RAPIDS_PY_VERSION}, cuda-version=${CUDA_VERSION}"

echo "::group::conda dry-run output"

rapids-conda-retry \
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

echo "::endgroup::"

rapids-logger "Parsing results from conda dry-run with rapids=${RAPIDS_VERSION}, python=${RAPIDS_PY_VERSION}, cuda-version=${CUDA_VERSION}"

python ci/check_conda_nightly_env.py "${JSON_FILENAME}"
