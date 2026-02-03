#!/bin/bash
#
# Prints the size of the built WASM binary.
#
# This script reads the WASM file that was built by scripts/build-wasm.sh
# and assembled by scripts/gen-npm-pkg.sh into the npm package.
#
# Usage:
#   ./scripts/wasm-sizes.sh
#
# If WASM files are not found, run:
#   ./scripts/build-all.sh

set -e

# Get the repo root (parent of scripts/)
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Path to the npm package
NPM_PKG_DIR="$REPO_ROOT/aptos-confidential-asset-wasm-bindings"

# Function to format bytes as human-readable
humanize_bytes() {
    local bytes=$1
    if (( bytes >= 1048576 )); then
        printf "%.2f MiB" "$(echo "scale=2; $bytes / 1048576" | bc)"
    elif (( bytes >= 1024 )); then
        printf "%.2f KiB" "$(echo "scale=2; $bytes / 1024" | bc)"
    else
        printf "%d bytes" "$bytes"
    fi
}

# Check if npm package directory exists
if [ ! -d "$NPM_PKG_DIR" ]; then
    echo "Error: npm package directory not found at $NPM_PKG_DIR"
    echo ""
    echo "Run ./scripts/build-all.sh first to build the WASM binary."
    exit 1
fi

echo "=============================================="
echo "WASM Binary Size"
echo "=============================================="
echo ""

# Find and print size of WASM file
wasm_file=$(find "$NPM_PKG_DIR" -maxdepth 1 -name "*.wasm" -print -quit)

if [ -z "$wasm_file" ]; then
    echo "Error: No WASM file found in $NPM_PKG_DIR"
    echo ""
    echo "Run ./scripts/build-all.sh first to build the WASM binary."
    exit 1
fi

file_name=$(basename "$wasm_file")
size_bytes=$(stat -f%z "$wasm_file" 2>/dev/null || stat -c%s "$wasm_file")

printf "%-40s %s (%'d bytes)\n" "$file_name" "$(humanize_bytes "$size_bytes")" "$size_bytes"

echo ""
echo "=============================================="
echo "Notes"
echo "=============================================="
echo ""
echo "This unified WASM combines both discrete log and range proof functionality"
echo "into a single module, sharing the curve25519-dalek elliptic curve library."
echo ""
echo "Discrete log algorithm selection (compile-time via Cargo.toml features):"
echo "  - tbsgs_k (default): ~512 KiB table, smallest WASM with good performance"
echo "  - bsgs_k:            ~2.0 MiB table"
echo "  - bsgs:              ~2.0 MiB table"
echo "  - bl12:              ~258 KiB table (smallest, but slower)"
