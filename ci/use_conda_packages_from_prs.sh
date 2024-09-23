#!/bin/bash

LIBRMM_CHANNEL=$(rapids-get-pr-conda-artifact rmm 1678 cpp)
RMM_CHANNEL=$(rapids-get-pr-conda-artifact rmm 1678 python)

CUDF_CPP_CHANNEL=$(rapids-get-pr-conda-artifact cudf 16806 cpp)
CUDF_PYTHON_CHANNEL=$(rapids-get-pr-conda-artifact cudf 16806 python)

UCXX_CHANNEL=$(rapids-get-pr-conda-artifact ucxx 278 cpp)

LIBRAFT_CHANNEL=$(rapids-get-pr-conda-artifact raft 2433 cpp)
RAFT_CHANNEL=$(rapids-get-pr-conda-artifact raft 2433 python)

LIBCUSPATIAL_CHANNEL=$(rapids-get-pr-conda-artifact cuspatial 1441 cpp)
CUSPATIAL_CHANNEL=$(rapids-get-pr-conda-artifact cuspatial 1441 python)

LIBCUML_CHANNEL=$(rapids-get-pr-conda-artifact cuml 6071 cpp)
CUML_CHANNEL=$(rapids-get-pr-conda-artifact cuml 6071 python)

# NOTE: cloning private repos with rapids-get-pr-conda-artifact doesn't work,
#       so need to explicitly set the SHA to use
CUMLPRIMS_CHANNEL=$(
    RAPIDS_SHA=6f9f474 rapids-get-pr-conda-artifact cumlprims_mg 211 cpp 6f9f474
)

conda config --system --add channels "${LIBRMM_CHANNEL}"
conda config --system --add channels "${RMM_CHANNEL}"
conda config --system --add channels "${CUDF_CPP_CHANNEL}"
conda config --system --add channels "${CUDF_PYTHON_CHANNEL}"
conda config --system --add channels "${UCXX_CHANNEL}"
conda config --system --add channels "${LIBRAFT_CHANNEL}"
conda config --system --add channels "${RAFT_CHANNEL}"
conda config --system --add channels "${LIBCUSPATIAL_CHANNEL}"
conda config --system --add channels "${CUSPATIAL_CHANNEL}"
conda config --system --add channels "${LIBCUML_CHANNEL}"
conda config --system --add channels "${CUML_CHANNEL}"
conda config --system --add channels "${CUMLPRIMS_CHANNEL}"
