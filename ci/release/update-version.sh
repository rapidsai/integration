#!/bin/bash
###############################
# Integration Version Updater #
###############################

## Usage
# bash update-version.sh <new_version>

# Workaround for MacOS where BSD sed doesn't support the flags
# Install MacOS gsed with `brew install gnu-sed`
unameOut="$(uname -s)"
case "${unameOut}" in
    Linux*)     sedCmd=sed;;
    Darwin*)    sedCmd=gsed;;
    *)          echo "Unknown OS"; exit 1;;
esac


# Format is YY.MM.PP - no leading 'v' or trailing 'a'
NEXT_FULL_TAG=$1

# Get current version
CURRENT_TAG=$(git tag --merged HEAD | grep -xE '^v.*' | sort --version-sort | tail -n 1 | tr -d 'v')
CURRENT_MAJOR=$(echo $CURRENT_TAG | awk '{split($0, a, "."); print a[1]}')
CURRENT_MINOR=$(echo $CURRENT_TAG | awk '{split($0, a, "."); print a[2]}')
CURRENT_PATCH=$(echo $CURRENT_TAG | awk '{split($0, a, "."); print a[3]}' | tr -d 'a')
CURRENT_SHORT_TAG=${CURRENT_MAJOR}.${CURRENT_MINOR}

#Get <major>.<minor> for next version
NEXT_MAJOR=$(echo $NEXT_FULL_TAG | awk '{split($0, a, "."); print a[1]}')
NEXT_MINOR=$(echo $NEXT_FULL_TAG | awk '{split($0, a, "."); print a[2]}')
NEXT_SHORT_TAG=${NEXT_MAJOR}.${NEXT_MINOR}

echo "Preparing release $CURRENT_TAG => $NEXT_FULL_TAG"

# Inplace sed replace; workaround for Linux and Mac
function sed_runner() {
    $sedCmd -i.bak ''"$1"'' $2 && rm -f ${2}.bak
}

# Axis file update
sed_runner "/RAPIDS_VER/{n; s/- .*/- ${NEXT_FULL_TAG}a/}" ci/axis/nightly-env-arm64.yaml
sed_runner "/RAPIDS_VER/{n; s/- .*/- ${NEXT_FULL_TAG}a/}" ci/axis/nightly-env.yaml
sed_runner "/RAPIDS_VER/{n; s/- .*/- ${NEXT_FULL_TAG}a/}" ci/axis/nightly-meta-arm64.yaml
sed_runner "/RAPIDS_VER/{n; s/- .*/- ${NEXT_FULL_TAG}a/}" ci/axis/nightly-meta.yaml
sed_runner "/RAPIDS_VER/{n; s/- .*/- ${NEXT_FULL_TAG}/}" ci/axis/release-arm64.yaml
sed_runner "/RAPIDS_VER/{n; s/- .*/- ${NEXT_FULL_TAG}/}" ci/axis/release.yaml
sed_runner "/RAPIDS_VER/{n; s/- .*/- \"${NEXT_SHORT_TAG}\"/}" ci/axis/tests.yaml
