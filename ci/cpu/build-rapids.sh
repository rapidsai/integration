#!/bin/bash
# Copyright (c) 2020, NVIDIA CORPORATION.
################################################
# rapids meta pkg conda build script for gpuCI #
################################################
set -ex

# Set paths
export PATH=/opt/conda/bin:$PATH
export HOME=$WORKSPACE

# Activate base conda env
source activate base

# Print current env vars
env

# Install gpuCI tools
curl -s https://raw.githubusercontent.com/rapidsai/gpuci-tools/master/install.sh | bash
source ~/.bashrc
cd ~

# Fetch pkgs for upload
gpuci_logger "Install anaconda-client..."
conda install -y anaconda-client

# Print diagnostic information
gpuci_logger "Print conda info..."
conda info
conda config --show-sources
conda list --show-channel-urls

# Build pkg
gpuci_logger "Start conda build..."
conda build -c rapidsai-nightly -c nvidia -c conda-forge --python=${PYTHON_VERSION} conda/recipes/rapids

# Get output location
gpuci_logger "Get conda build output..."
export UPLOADFILE=`conda build -c rapidsai-nightly -c nvidia -c conda-forge --python=${PYTHON_VERSION} conda/recipes/rapids --output`
test -e ${UPLOADFILE}

gpuci_logger "Setting conda label.."
LABEL_OPTION="--label main"
echo "LABEL_OPTION=${LABEL_OPTION}"

if [ -z "$MY_UPLOAD_KEY" ]; then
  gpuci_logger "No upload key found, env var MY_UPLOAD_KEY not set, skipping upload..."
  return 0
fi

gpuci_logger "Upload starting..."
echo ${UPLOADFILE}
anaconda -t ${MY_UPLOAD_KEY} upload -u ${CONDA_USERNAME:-rapidsai-nightly} ${LABEL_OPTION} --force ${UPLOADFILE}
