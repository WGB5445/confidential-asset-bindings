#!/bin/bash
#
# Builds all WASM packages and generates the unified npm package.
# This mirrors the CI workflow in .github/workflows/build-wasm.yml
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=============================================="
echo "Building all WASM packages"
echo "=============================================="

echo ""
echo ">>> Building range-proofs WASM..."
"$SCRIPT_DIR/build-range-proofs.sh"

echo ""
echo ">>> Building pollard-kangaroo WASM..."
"$SCRIPT_DIR/build-pollard-kangaroo.sh"

echo ""
echo ">>> Generating unified npm package..."
"$SCRIPT_DIR/gen-npm-pkg.sh"

echo ""
echo "=============================================="
echo "Build complete!"
echo "=============================================="
echo "Output: aptos-confidential-asset-wasm-bindings/"
