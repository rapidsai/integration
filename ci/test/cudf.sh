#!/bin/bash
set +e
set -x

export HOME="$WORKSPACE"
export LIBCUDF_KERNEL_CACHE_PATH="$WORKSPACE/.cache/rapids/cudf"
export PATH="/opt/conda/bin:/usr/local/nvidia/bin:/usr/local/cuda/bin:/usr/local/sbin:/usr/local/bin:/usr/local/gcc7/bin:/usr/sbin:/usr/bin:/sbin:/bin"

# FIXME: "source activate" line should not be needed
source /opt/conda/bin/activate rapids
env
nvidia-smi
conda list

TESTRESULTS_DIR="$WORKSPACE/testresults"
mkdir -p ${TESTRESULTS_DIR}
SUITEERROR=0

# run gtests
for gt in /rapids/cudf/cpp/build/gtests/*; do
   ${gt} --gtest_output=xml:${TESTRESULTS_DIR}/
   exitcode=$?
   if (( ${exitcode} != 0 )); then
      SUITEERROR=${exitcode}
      echo "FAILED: ${gt}"
   fi
done

cd /rapids/cudf/python/cudf/cudf/tests
pytest -n 6 --junitxml=${TESTRESULTS_DIR}/pytest-cudf.xml -v
exitcode=$?
if (( ${exitcode} != 0 )); then
   SUITEERROR=${exitcode}
   echo "FAILED: 1 or more python tests"
fi

cd /rapids/cudf/python/dask_cudf
pytest -n 6 --junitxml=${TESTRESULTS_DIR}/pytest-dask-cudf.xml -v
exitcode=$?
if (( ${exitcode} != 0 )); then
   SUITEERROR=${exitcode}
   echo "FAILED: 1 or more python tests"
fi

cd /rapids/cudf/python/custreamz
pytest -n 6 --junitxml=${TESTRESULTS_DIR}/pytest-custreamz.xml -v
exitcode=$?
if (( ${exitcode} != 0 )); then
   SUITEERROR=${exitcode}
   echo "FAILED: 1 or more python tests"
fi

exit ${SUITEERROR}
