#!/bin/bash
set +e
set -x

export HOME="${WORKSPACE}"
export LIBCUDF_KERNEL_CACHE_PATH="${WORKSPACE}/.jitcache"
export PATH="/opt/conda/bin:/usr/local/nvidia/bin:/usr/local/cuda/bin:/usr/local/sbin:/usr/local/bin:/usr/local/gcc7/bin:/usr/sbin:/usr/bin:/sbin:/bin"


cd /rapids/cugraph
bash /rapids/cugraph/ci/test.sh
