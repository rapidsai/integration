#!/bin/bash
set +e
set -x
set -o pipefail

export LIBCUDF_KERNEL_CACHE_PATH="$WORKSPACE/.jitcache"

source /opt/conda/bin/activate rapids

# PyTorch is intentionally excluded from our Docker images due
# to its size, but some notebooks still depend on it.
case "${CUDA_VER}" in
"10.1" | "10.2" | "11.0")
    conda install -y -c pytorch "pytorch=1.7"
    ;;
*)
    echo "Unsupported CUDA version for pytorch."
    echo "Not installing pytorch."
    ;;
esac


env
nvidia-smi
conda list

/test.sh 2>&1 | tee nbtest.log
EXITCODE=$?
python /rapids/utils/nbtestlog2junitxml.py nbtest.log

exit ${EXITCODE}
