#!/bin/bash
set -ex

export CUSPATIAL_HOME=/rapids/cuspatial
export HOME=$WORKSPACE

# FIXME: "source activate" line should not be needed
source /opt/conda/bin/activate rapids
env
conda list

TESTRESULTS_DIR=${WORKSPACE}/testresults
mkdir -p ${TESTRESULTS_DIR}
SUITEERROR=0

# Python tests
cd /rapids/cuspatial
py.test --junitxml=${TESTRESULTS_DIR}/pytest.xml -v python/cuspatial/cuspatial/tests
exitcode=$?
if (( ${exitcode} != 0 )); then
   SUITEERROR=${exitcode}
   echo "FAILED: 1 or more python tests"
fi

exit ${SUITEERROR}
