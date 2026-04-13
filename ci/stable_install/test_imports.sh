#!/bin/bash
# Copyright (c) 2026, NVIDIA CORPORATION.

set -euo pipefail

function testImports {
    local -a imports=()
    local failures=0
    while [[ $# -gt 0 ]]; do
        # run standalone import test
        rapids-logger "Standalone import test for $1"
        if python -c "import $1"; then
            rapids-logger "Passed"
        else
            rapids-logger "Test failed for: $1"
            failures=$((failures + 1))
        fi
        # add import to array for combined import test before shifting
        imports+=("$1")
        shift
    done
    import_cmd=$(printf "import %s; " "${imports[@]}")
    rapids-logger "Combined import test for: ${imports[*]}"
    if python -c "${import_cmd}"; then
        rapids-logger "Passed"
    else
        rapids-logger "Combined import test failed"
        failures=$((failures + 1))
    fi
    return $failures
}
