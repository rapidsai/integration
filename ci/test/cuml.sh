#!/bin/bash
set +e

export HOME=$WORKSPACE
export LIBCUDF_KERNEL_CACHE_PATH=${WORKSPACE}/.jitcache

# FIXME: "source activate" line should not be needed
source /opt/conda/bin/activate rapids
# FIXME: Install the master version of dask, distributed, and streamz
pip install "git+https://github.com/dask/distributed.git" --upgrade --no-deps
pip install "git+https://github.com/dask/dask.git" --upgrade --no-deps
pip install "git+https://github.com/python-streamz/streamz.git" --upgrade --no-deps
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
