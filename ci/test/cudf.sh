#!/bin/bash
set +e
set -x

export HOME=$WORKSPACE
export LIBCUDF_KERNEL_CACHE_PATH=$WORKSPACE/.cache/rapids/cudf
export PATH="/opt/conda/bin:/usr/local/nvidia/bin:/usr/local/cuda/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

# FIXME: "source activate" line should not be needed
source /opt/conda/bin/activate rapids
env
conda list

TESTRESULTS_DIR=${WORKSPACE}/testresults
mkdir -p ${TESTRESULTS_DIR}
SUITEERROR=0

# build gtests
pushd /rapids/cudf/cpp/build
make build_tests_cudf
SUITEERROR=$((SUITEERROR | $?))
popd

# run gtests
for gt in /rapids/cudf/cpp/build/gtests/*; do
   ${gt} --gtest_output=xml:${TESTRESULTS_DIR}/
   exitcode=$?
   if (( ${exitcode} != 0 )); then
      SUITEERROR=${exitcode}
      echo "FAILED: ${gt}"
   fi
done

# Python tests
export PYTHONPATH=\
/rapids/cudf/python/cudf:\
/rapids/cudf/python/dask_cudf:\
/rapids/cudf/python/custreamz:\
/rapids/cudf/python/nvstrings:\
${PYTHONPATH}

cd /rapids/cudf/python/cudf
py.test --junitxml=${TESTRESULTS_DIR}/pytest-cudf.xml -v
exitcode=$?
if (( ${exitcode} != 0 )); then
   SUITEERROR=${exitcode}
   echo "FAILED: 1 or more python tests"
fi

cd /rapids/cudf/python/dask_cudf
py.test --junitxml=${TESTRESULTS_DIR}/pytest-dask-cudf.xml -v
exitcode=$?
if (( ${exitcode} != 0 )); then
   SUITEERROR=${exitcode}
   echo "FAILED: 1 or more python tests"
fi

cd /rapids/cudf/python/custreamz
py.test --junitxml=${TESTRESULTS_DIR}/pytest-custreamz.xml -v
exitcode=$?
if (( ${exitcode} != 0 )); then
   SUITEERROR=${exitcode}
   echo "FAILED: 1 or more python tests"
fi

exit ${SUITEERROR}
