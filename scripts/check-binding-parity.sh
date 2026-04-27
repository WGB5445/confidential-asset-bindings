#!/usr/bin/env bash
# Run cross-binding golden parity checks (Rust core + Python + Go).
# From repo root; requires built Python extension for pytest (see bindings/python README).
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

echo "== Rust: aptos_confidential_asset_core binding_golden_fixture =="
cargo test -p aptos_confidential_asset_core --test binding_golden_fixture --manifest-path rust/Cargo.toml

echo "== Python: golden fixture tests =="
if [[ -x "$ROOT/bindings/python/.venv/bin/python" ]]; then
  PY="$ROOT/bindings/python/.venv/bin/python"
elif command -v python3 >/dev/null 2>&1; then
  PY="python3"
else
  PY="python"
fi
"$PY" -m pytest "$ROOT/bindings/python/tests/test_golden_fixture.py" -v

echo "== Go: aptosconfidential golden tests (requires CGO + FFI staticlib) =="
export CGO_ENABLED=1
if [[ ! -f "$ROOT/rust/target/release/libaptos_confidential_asset_ffi.a" ]]; then
  echo "Building FFI staticlib for cgo..."
  cargo build -p aptos_confidential_asset_ffi --release --manifest-path rust/Cargo.toml
fi
(cd "$ROOT/bindings/go" && go test -v ./aptosconfidential -count=1 -run 'Golden')

echo "OK: binding parity checks passed."
