#!/bin/bash
# Copyright (c) 2026, NVIDIA CORPORATION.

function installRapidsDoctor {
    # Clone and install `rapids-cli`
    git clone https://github.com/rapidsai/rapids-cli rapids-cli
    pushd rapids-cli || exit 1
    python -m pip install .
    popd || exit 1
}
