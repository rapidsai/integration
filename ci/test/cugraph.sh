#!/bin/bash
set +e
set -x
export HOME=$WORKSPACE
export LIBCUDF_KERNEL_CACHE_PATH=${WORKSPACE}/.jitcache
export PATH="/opt/conda/bin:/usr/local/nvidia/bin:/usr/local/cuda/bin:/usr/local/sbin:/usr/local/bin:/usr/local/gcc7/bin:/usr/sbin:/usr/bin:/sbin:/bin"

# FIXME: "source activate" line should not be needed
source /opt/conda/bin/activate rapids

# Get datasets
cd /rapids/cugraph/datasets
bash ./get_test_data.sh
export RAPIDS_DATASET_ROOT_DIR=/rapids/cugraph/datasets

# Show environment
env
conda list

TESTRESULTS_DIR=${WORKSPACE}/testresults
mkdir -p ${TESTRESULTS_DIR}
SUITEERROR=0

# FIXME: temporarily disabling all C++ tests for 0.16 due to intermittent
# failures from what appears to be an issue with Thrust (which does not appear
# to affect the Python API or notebooks). Re-enable once this issue is resolved
# in 0.17.
# gtests
# for gt in /rapids/cugraph/cpp/build/gtests/*_TEST; do
#    ${gt} --gtest_output=xml:${TESTRESULTS_DIR}/
#    exitcode=$?
#    if (( ${exitcode} != 0 )); then
#       SUITEERROR=${exitcode}
#       echo "FAILED: ${gt}"
#    fi
# done

# Python tests
py.test --junitxml=${TESTRESULTS_DIR}/pytest.xml -v /rapids/cugraph/python
exitcode=$?
if (( ${exitcode} != 0 )); then
   SUITEERROR=${exitcode}
   echo "FAILED: 1 or more tests in /rapids/cugraph/python"
fi

exit ${SUITEERROR}
