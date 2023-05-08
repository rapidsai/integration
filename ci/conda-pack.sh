#!/bin/bash
set -e

RAPIDS_VER="23.06"
VERSION_DESCRIPTOR="a"
CONDA_USERNAME="rapidsai-nightly"

if [ "$GITHUB_REF_TYPE" = "tag" ]; then
    VERSION_DESCRIPTOR=""
    CONDA_USERNAME="rapidsai"
fi
CONDA_ENV_NAME="rapids${RAPIDS_VER}${VERSION_DESCRIPTOR}_cuda${RAPIDS_CUDA_VERSION}_py${RAPIDS_PY_VERSION}"

echo "Install conda-pack"
rapids-mamba-retry install -n base -c conda-forge "conda-pack"

echo "Creating conda environment $CONDA_ENV_NAME"
rapids-mamba-retry create -y -n $CONDA_ENV_NAME \
    -c $CONDA_USERNAME -c conda-forge -c nvidia \
    "rapids=$RAPIDS_VER" \
    "cudatoolkit=$RAPIDS_CUDA_VERSION" \
    "python=$RAPIDS_PY_VERSION"

echo "Packing conda environment"
conda-pack --quiet --ignore-missing-files -n "$CONDA_ENV_NAME" -o "${CONDA_ENV_NAME}.tar.gz"

export AWS_DEFAULT_REGION="us-east-2"
echo "Upload packed conda"
aws s3 cp --only-show-errors --acl public-read "${CONDA_ENV_NAME}.tar.gz" "s3://rapidsai-data/conda-pack/${CONDA_USERNAME}/${CONDA_ENV_NAME}.tar.gz"
