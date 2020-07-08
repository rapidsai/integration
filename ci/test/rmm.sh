#!/bin/bash
set -ex
export HOME=$WORKSPACE
# FIXME: "source activate" line should not be needed
source /opt/conda/bin/activate rapids
env
conda list

TESTRESULTS_DIR=${WORKSPACE}/testresults
mkdir -p ${TESTRESULTS_DIR}
SUITEERROR=0

# gtests
for gt in /rapids/rmm/build/gtests/*; do
   ${gt} --gtest_output=xml:${TESTRESULTS_DIR}/
   exitcode=$?
   if (( ${exitcode} != 0 )); then
      SUITEERROR=${exitcode}
      echo "FAILED: ${gt}"
   fi
done

# Python tests
cd /rapids/rmm/python
py.test --cache-clear --junitxml=${TESTRESULTS_DIR}/rmm_pytest.xml -v
exitcode=$?
if (( ${exitcode} != 0 )); then
   SUITEERROR=${exitcode}
   echo "FAILED: 1 or more tests in /rapids/rmm/python/tests"
fi

exit ${SUITEERROR}
