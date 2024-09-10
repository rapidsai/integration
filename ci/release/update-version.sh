#!/bin/bash
# Copyright (c) 2021-2023, NVIDIA CORPORATION.

###############################
# Integration Version Updater #
###############################

## Usage
# bash update-version.sh <new_version>

# Format is YY.MM.PP - no leading 'v' or trailing 'a'
NEXT_FULL_TAG=$1

# Get current version
CURRENT_TAG=$(git tag --merged HEAD | grep -xE '^v.*' | sort --version-sort | tail -n 1 | tr -d 'v')
CURRENT_MAJOR=$(echo $CURRENT_TAG | awk '{split($0, a, "."); print a[1]}')
CURRENT_MINOR=$(echo $CURRENT_TAG | awk '{split($0, a, "."); print a[2]}')
CURRENT_PATCH=$(echo $CURRENT_TAG | awk '{split($0, a, "."); print a[3]}' | tr -d 'a')
CURRENT_SHORT_TAG=${CURRENT_MAJOR}.${CURRENT_MINOR}

# Get <major>.<minor> for next version
NEXT_MAJOR=$(echo $NEXT_FULL_TAG | awk '{split($0, a, "."); print a[1]}')
NEXT_MINOR=$(echo $NEXT_FULL_TAG | awk '{split($0, a, "."); print a[2]}')
NEXT_SHORT_TAG=${NEXT_MAJOR}.${NEXT_MINOR}

echo "Preparing release $CURRENT_TAG => $NEXT_FULL_TAG"

# Inplace sed replace; workaround for Linux and Mac
function sed_runner() {
    sed -i.bak ''"$1"'' $2 && rm -f ${2}.bak
}

sed_runner "/RAPIDS_VER=/ s/[0-9][0-9].[0-9][0-9]/${NEXT_SHORT_TAG}/" ci/conda-pack.sh
sed_runner "/RAPIDS_VERSION=/ s/[0-9][0-9].[0-9][0-9]/${NEXT_SHORT_TAG}/" ci/test_conda_nightly_env.sh

for FILE in .github/workflows/*.yaml; do
  sed_runner "/shared-workflows/ s/@.*/@branch-${NEXT_SHORT_TAG}/g" "${FILE}"
done
