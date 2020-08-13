#!/bin/bash
set -ex
export HOME=${WORKSPACE}
export LIBCUDF_KERNEL_CACHE_PATH=${WORKSPACE}/.jitcache
export PATH="/opt/conda/bin/usr/local/nvidia/bin:/usr/local/cuda/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

. /opt/conda/etc/profile.d/conda.sh
conda activate rapids

gpuci_logger "Show env and current conda list"
env
conda list

export TESTRESULTS_DIR=${WORKSPACE}/testresults
mkdir -p ${TESTRESULTS_DIR}
SUITEERROR=0

gpuci_logger "Install conda packages needed by tests in rapids environment"
gpuci_conda_retry --condaretry_max_retries=10 install -y --freeze-installed requests

gpuci_logger "Install integration tests"
ls -la /
cd /rapids
git clone https://github.com/rapidsai/integration

gpuci_logger "Run Python tests"
py.test --junitxml=${TESTRESULTS_DIR}/pytest.xml -v /rapids/integration/test
exitcode=$?
if (( ${exitcode} != 0 )); then
   SUITEERROR=${exitcode}
   gpuci_logger "FAILED: 1 or more tests in /rapids/integration/test"
fi

exit ${SUITEERROR}
