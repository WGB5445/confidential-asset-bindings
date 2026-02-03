#!/bin/bash
#
# Builds the unified WASM package and generates the npm package.
# This mirrors the CI workflow in .github/workflows/build-wasm.yml
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=============================================="
echo "Building WASM package"
echo "=============================================="

echo ""
echo ">>> Building WASM (discrete log + range proofs)..."
"$SCRIPT_DIR/build-wasm.sh"

echo ""
echo ">>> Generating npm package..."
"$SCRIPT_DIR/gen-npm-pkg.sh"

echo ""
echo "=============================================="
echo "Build complete!"
echo "=============================================="
echo "Output: aptos-confidential-asset-wasm-bindings/"
