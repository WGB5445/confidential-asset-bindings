#!/bin/bash
#
# Builds the pollard-kangaroo WASM using wasm-pack.
#

set -e

# Get the repo root (parent of scripts/)
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PACKAGE_DIR="$REPO_ROOT/pollard-kangaroo"

echo "Building pollard-kangaroo WASM..."
cd "$PACKAGE_DIR"
wasm-pack build --release --target web -d pkg

echo "WASM build complete. Files are available in $PACKAGE_DIR/pkg:"
ls "$PACKAGE_DIR/pkg"

# Print WASM binary size
WASM_FILE=$(find "$PACKAGE_DIR/pkg" -name "*.wasm" -type f | head -1)
if [ -n "$WASM_FILE" ]; then
    SIZE_BYTES=$(stat -f%z "$WASM_FILE" 2>/dev/null || stat -c%s "$WASM_FILE")
    SIZE_KIB=$((SIZE_BYTES / 1024))
    echo ""
    echo "WASM binary size: ${SIZE_KIB} KiB ($(basename "$WASM_FILE"))"
fi
