#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

python3 "$SCRIPT_DIR/libraries/test_launcher.py" \
    --config-file "$SCRIPT_DIR/variables/pixel9.py" \
    --mode startandstop
