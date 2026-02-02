#!/bin/bash
#
# Prints the sizes of the built WASM binaries.
#
# This script reads the WASM files that were built by scripts/build-*.sh
# and assembled by scripts/gen-npm-pkg.sh into the unified npm package.
#
# Usage:
#   ./scripts/wasm-sizes.sh
#
# If WASM files are not found, run:
#   ./scripts/build-all.sh

set -e

# Get the repo root (parent of scripts/)
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Path to the unified npm package
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
    echo "Run ./scripts/build-all.sh first to build the WASM binaries."
    exit 1
fi

echo "=============================================="
echo "WASM Binary Sizes"
echo "=============================================="
echo ""

# Find and print sizes of all WASM files
found_any=false
for wasm_file in "$NPM_PKG_DIR"/*/*.wasm; do
    if [ -f "$wasm_file" ]; then
        found_any=true
        # Get the parent directory name (e.g., "pollard-kangaroo")
        parent_dir=$(basename "$(dirname "$wasm_file")")
        # Get the file name
        file_name=$(basename "$wasm_file")
        # Get the size
        size_bytes=$(stat -f%z "$wasm_file" 2>/dev/null || stat -c%s "$wasm_file")
        
        printf "%-20s %s (%'d bytes)\n" "[$parent_dir]" "$(humanize_bytes "$size_bytes")" "$size_bytes"
    fi
done

if [ "$found_any" = false ]; then
    echo "Error: No WASM files found in $NPM_PKG_DIR"
    echo ""
    echo "Run ./scripts/build-all.sh first to build the WASM binaries."
    exit 1
fi

echo ""
echo "=============================================="
echo "Notes"
echo "=============================================="
echo ""
echo "pollard-kangaroo uses TBSGS-k by default (smallest table with good performance)."
echo "To build with a different algorithm, edit pollard-kangaroo/Cargo.toml features."
echo ""
echo "Available pollard-kangaroo features:"
echo "  - tbsgs_k (default): ~512 KiB table, ~592 KiB WASM"
echo "  - bsgs_k:            ~2.0 MiB table, ~2.1 MiB WASM"
echo "  - bsgs:              ~2.0 MiB table, ~2.1 MiB WASM"
echo "  - bl12:              ~258 KiB table, ~268 KiB WASM"
