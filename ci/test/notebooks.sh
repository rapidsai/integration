#!/bin/bash
set +e
set -x
set -o pipefail

export LIBCUDF_KERNEL_CACHE_PATH=${WORKSPACE}/.jitcache

source /opt/conda/bin/activate rapids
env
/test.sh 2>&1 | tee nbtest.log
EXITCODE=$?
python /rapids/utils/nbtestlog2junitxml.py nbtest.log

exit ${EXITCODE}