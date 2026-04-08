#!/bin/bash
# Copyright (c) 2026, NVIDIA CORPORATION.

set -euo pipefail

function testImports {
    unset imports
    while [[ $# -gt 0 ]]; do
        # run standalone import test
        rapids-logger "Standalone import test for $1"
        python -c "import $1" || rapids-logger "Test failed for: $1"
        rapids-logger "Passed"
        # add import to array for combined import test before shifting
        imports+=("$1")
        shift
    done
    import_cmd=$(printf "import %s; " "${imports[@]}")
    rapids-logger "Combined import test for: ${imports[*]}"
    python -c "${import_cmd}" || rapids-logger "Test failed for: ${imports[*]}"
    rapids-logger "Passed"
}
