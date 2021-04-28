#!/bin/bash
# Copyright (c) 2020, NVIDIA CORPORATION.
###############################################################
# rapids meta/env pkg conda build script for gpuCI            #
#                                                             #
# config set in `ci/axis/*.yml`                               #
#                                                             #
# specifiy build type with env var `BUILD_PKGS`               #
#    - 'meta' - triggers meta-pkg builds                      #
#    - 'env' - triggers env-pkg builds                        #
#    - '' or undefined - trigers both                         #
###############################################################
set -e

# Set paths
export PATH=/conda/bin:$PATH
export HOME=$WORKSPACE

# Set recipe paths
CONDA_XGBOOST_RECIPE="conda/recipes/rapids-xgboost"
CONDA_RAPIDS_RECIPE="conda/recipes/rapids"
CONDA_RAPIDS_BLAZING_RECIPE="conda/recipes/rapids-blazing"
CONDA_RAPIDS_BUILD_RECIPE="conda/recipes/rapids-build-env"
CONDA_RAPIDS_NOTEBOOK_RECIPE="conda/recipes/rapids-notebook-env"
CONDA_RAPIDS_DOC_RECIPE="conda/recipes/rapids-doc-env"
CONDA_BLAZING_BUILD_RECIPE="conda/recipes/blazingsql-build-env"
CONDA_BLAZING_NOTEBOOK_RECIPE="conda/recipes/blazingsql-notebook-env"

# Allow insecure connections for conda-mirror
echo "ssl_verify: False" >> /conda/.condarc

# Activate conda env
source activate base

# Print current env vars
env

# Install gpuCI tools
conda install -y -c gpuci gpuci-tools

# Print diagnostic information
gpuci_logger "Print conda info..."
conda info
conda config --show-sources
conda list --show-channel-urls

# If nightly build, append current YYMMDD to version
if [[ "$BUILD_MODE" = "branch" && "$SOURCE_BRANCH" = branch-* ]] ; then
  export VERSION_SUFFIX=`date +%y%m%d`
fi

function build_pkg {
  # Build pkg
  gpuci_logger "Start conda build for '${1}'..."
  if [[ "${1}" == "${CONDA_BLAZING_NOTEBOOK_RECIPE}" ]]; then
    gpuci_conda_retry build --override-channels -c blazingsql-nightly -c ${CONDA_USERNAME:-rapidsai-nightly} -c nvidia -c pytorch -c conda-forge \
                --python=${PYTHON_VER} -m ${CONDA_CONFIG_FILE} ${1}
  elif [[ "${1}" == *"BLAZING"* ]]; then
    gpuci_conda_retry build --override-channels -c blazingsql-nightly -c ${CONDA_USERNAME:-rapidsai-nightly} -c nvidia -c conda-forge \
                --python=${PYTHON_VER} -m ${CONDA_CONFIG_FILE} ${1}
  else
    gpuci_conda_retry build --override-channels -c ${CONDA_USERNAME:-rapidsai-nightly} -c nvidia -c conda-forge \
                --python=${PYTHON_VER} -m ${CONDA_CONFIG_FILE} ${1}
  fi
}

function run_builds {
  # Kick off main pkg build
  build_pkg $1
}

function upload_builds {
  # Check for upload key
  if [ -z "$MY_UPLOAD_KEY" ]; then
    gpuci_logger "No upload key found, env var MY_UPLOAD_KEY not set, skipping upload..."
  else
    gpuci_logger "Upload key found, starting upload..."
    gpuci_logger "Files to upload..."
    if [[ -n $(ls /conda/conda-bld/linux-64/* | grep -i rapids.*.tar.bz2) ]]; then
      ls /conda/conda-bld/linux-64/* | grep -i rapids.*.tar.bz2
    fi
    if [[ -n $(ls /conda/conda-bld/linux-64/* | grep -i blazingsql.*.tar.bz2) ]]; then
      ls /conda/conda-bld/linux-64/* | grep -i blazingsql.*.tar.bz2
    fi

    gpuci_logger "Starting upload..."
    if [[ -n $(ls /conda/conda-bld/linux-64/* | grep -i rapids.*.tar.bz2) ]]; then
      ls /conda/conda-bld/linux-64/* | grep -i rapids.*.tar.bz2 | xargs gpuci_retry \
        anaconda -t ${MY_UPLOAD_KEY} upload -u ${CONDA_USERNAME:-rapidsai-nightly} --label main --skip-existing
    fi
    if [[ -n $(ls /conda/conda-bld/linux-64/* | grep -i blazingsql.*.tar.bz2) ]]; then
      ls /conda/conda-bld/linux-64/* | grep -i blazingsql.*.tar.bz2 | xargs gpuci_retry \
        anaconda -t ${MY_UPLOAD_KEY} upload -u ${CONDA_USERNAME:-rapidsai-nightly} --label main --skip-existing
    fi
  fi
}

if [[ "$BUILD_PKGS" == "meta" || -z "$BUILD_PKGS" ]] ; then
  # Run builds for meta-pkgs
  run_builds $CONDA_XGBOOST_RECIPE
  run_builds $CONDA_RAPIDS_RECIPE
  run_builds $CONDA_RAPIDS_BLAZING_RECIPE
fi

if [[ "$BUILD_PKGS" == "env" || -z "$BUILD_PKGS" ]] ; then
  # Run builds for env-pkgs
  run_builds $CONDA_RAPIDS_BUILD_RECIPE
  run_builds $CONDA_RAPIDS_NOTEBOOK_RECIPE
  run_builds $CONDA_RAPIDS_DOC_RECIPE
  run_builds $CONDA_BLAZING_BUILD_RECIPE
  run_builds $CONDA_BLAZING_NOTEBOOK_RECIPE
fi

# Upload builds
upload_builds
