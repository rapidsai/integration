#!/bin/bash

LIBRMM_CHANNEL=$(rapids-get-pr-conda-artifact rmm 1678 cpp)
RMM_CHANNEL=$(rapids-get-pr-conda-artifact rmm 1678 python)

CUDF_CPP_CHANNEL=$(rapids-get-pr-conda-artifact cudf 16806 cpp)
CUDF_PYTHON_CHANNEL=$(rapids-get-pr-conda-artifact cudf 16806 python)

UCXX_CHANNEL=$(rapids-get-pr-conda-artifact ucxx 278 cpp)

LIBCUSPATIAL_CHANNEL=$(rapids-get-pr-conda-artifact cuspatial 1441 cpp)
CUSPATIAL_CHANNEL=$(rapids-get-pr-conda-artifact cuspatial 1441 python)

LIBRAFT_CHANNEL=$(rapids-get-pr-conda-artifact raft 2433 cpp)
RAFT_CHANNEL=$(rapids-get-pr-conda-artifact raft 2433 python)

LIBCUGRAPH_CHANNEL=$(rapids-get-pr-conda-artifact cugraph 4655 cpp)
CUGRAPH_CHANNEL=$(rapids-get-pr-conda-artifact cugraph 4655 python)

conda config --system --add channels "${LIBRMM_CHANNEL}"
conda config --system --add channels "${RMM_CHANNEL}"
conda config --system --add channels "${CUDF_CPP_CHANNEL}"
conda config --system --add channels "${CUDF_PYTHON_CHANNEL}"
conda config --system --add channels "${UCXX_CHANNEL}"
conda config --system --add channels "${LIBCUSPATIAL_CHANNEL}"
conda config --system --add channels "${CUSPATIAL_CHANNEL}"
conda config --system --add channels "${LIBRAFT_CHANNEL}"
conda config --system --add channels "${RAFT_CHANNEL}"
conda config --system --add channels "${LIBCUGRAPH_CHANNEL}"
conda config --system --add channels "${CUGRAPH_CHANNEL}"
