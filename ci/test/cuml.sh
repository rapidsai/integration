#!/bin/bash
set +e

export HOME=$WORKSPACE
export LIBCUDF_KERNEL_CACHE_PATH=${WORKSPACE}/.jitcache
export PATH="/opt/conda/bin/usr/local/nvidia/bin:/usr/local/cuda/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

# FIXME: "source activate" line should not be needed
source /opt/conda/bin/activate rapids
env
conda list

TESTRESULTS_DIR=${WORKSPACE}/testresults
mkdir -p ${TESTRESULTS_DIR}
SUITEERROR=0

export CUPY_CACHE_DIR=${WORKSPACE}/tmp
mkdir -p ${CUPY_CACHE_DIR}

# gtests
# FIXME: add /rapids/cuml/cpp/build/test/ml_mg when multi-gpus are available!
for gt in \
      /rapids/cuml/cpp/build/test/ml \
      /rapids/cuml/cpp/build/test/prims ; do
   ${gt} --gtest_output=xml:${TESTRESULTS_DIR}/
   exitcode=$?
   if (( ${exitcode} != 0 )); then
      SUITEERROR=${exitcode}
      echo "FAILED: ${gt}"
   fi
done

# Python tests
py.test --junitxml=${TESTRESULTS_DIR}/pytest.xml -v /rapids/cuml/python/cuml/test -m "not memleak"
exitcode=$?
if (( ${exitcode} != 0 )); then
   SUITEERROR=${exitcode}
   echo "FAILED: 1 or more python tests"
fi

exit ${SUITEERROR}
