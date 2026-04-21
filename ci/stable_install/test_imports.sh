#!/bin/bash
# Copyright (c) 2026, NVIDIA CORPORATION.

set -euo pipefail

# Patterns in import output that we want to flag as a failure even when Python exits 0
declare -a IMPORT_ERROR_PATTERNS=(
    "dlopen error"
    "cannot open shared object file"
    "missing cuda symbols"
    "initialization failed"
)
IMPORT_ERROR_PATTERN=$(printf "%s|" "${IMPORT_ERROR_PATTERNS[@]}")
# Strip off the trailing `|` from joining the patterns together
IMPORT_ERROR_PATTERN="${IMPORT_ERROR_PATTERN%|}"

function runImport {
    local cmd="$1"
    local label="$2"
    local output exit_code=0
    output=$(python -c "$cmd" 2>&1) || exit_code=$?
    [[ -n "$output" ]] && echo "$output"
    if [[ $exit_code -ne 0 ]]; then
        rapids-logger "Test failed for: $label"
        return 1
    # here we grep over the combined output to look for errors that we want to
    # flag even if Python would exit cleanly
    # -E is for extended regex support for the pattern1|pattern2 matching
    elif echo "$output" | grep -qi -E "${IMPORT_ERROR_PATTERN}"; then
        rapids-logger "Test failed for: $label (error pattern detected in output)"
        return 1
    else
        rapids-logger "Passed"
        return 0
    fi
}

function testImports {
    local -a imports=()
    local failures=0
    while [[ $# -gt 0 ]]; do
        rapids-logger "Standalone import test for $1"
        runImport "import $1" "$1" || failures=$((failures + 1))
        # add import to array for combined import test before shifting
        imports+=("$1")
        shift
    done
    local import_cmd
    import_cmd=$(printf "import %s; " "${imports[@]}")
    rapids-logger "Combined import test for: ${imports[*]}"
    runImport "${import_cmd}" "${imports[*]}" || failures=$((failures + 1))
    return $failures
}
