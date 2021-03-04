#!/bin/bash
set -ex

export CUSPATIAL_HOME=/rapids/cuspatial
export HOME=$WORKSPACE
export PATH="/opt/conda/bin:/usr/local/nvidia/bin:/usr/local/cuda/bin:/usr/local/sbin:/usr/local/bin:/usr/local/gcc7/bin:/usr/sbin:/usr/bin:/sbin:/bin"

# FIXME: "source activate" line should not be needed
source /opt/conda/bin/activate rapids
env
nvidia-smi
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
