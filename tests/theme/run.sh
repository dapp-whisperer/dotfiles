#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BATS="$SCRIPT_DIR/../lib/bats-core/bin/bats"

if [[ ! -x "$BATS" ]]; then
    echo "Error: bats-core not found. Run:"
    echo "  git submodule update --init tests/lib/bats-core"
    exit 1
fi

"$BATS" "$SCRIPT_DIR/tests/"
