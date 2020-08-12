#!/bin/bash
set +e
set -x

export HOME=$WORKSPACE 
export PATH="/usr/local/nvidia/bin:/usr/local/cuda/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

# FIXME: "source activate" line should not be needed
source /opt/conda/bin/activate rapids

env
conda list

TESTRESULTS_DIR=${WORKSPACE}/testresults
mkdir -p ${TESTRESULTS_DIR}
SUITEERROR=0

# Install distributed@master (temporarily required due to issues with 2.3.2)
pip install git+https://github.com/dask/distributed.git@master
pip install pytest-asyncio fsspec

# Python tests
cd /rapids/dask-cuda/dask_cuda
py.test --junitxml=${TESTRESULTS_DIR}/pytest.xml -v 
exitcode=$?
if (( ${exitcode} != 0 )); then
   SUITEERROR=${exitcode}
   echo "FAILED: 1 or more tests in /rapids/dask-cuda/dask_cuda/tests"
fi

exit ${SUITEERROR}
