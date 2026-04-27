# Native bindings (Go, Python, C++, Zig)

This document describes **experimental** language bindings built from the same cryptographic core as the npm package (`@aptos-labs/confidential-asset-bindings`).

## Version alignment

- **npm / JS** remains the primary semver surface (`package.json`).
- **PyPI** package name: `aptos-confidential-asset-bindings-experimental` (rename when promoting).
- **Go module**: `github.com/aptos-labs/confidential-asset-bindings/bindings/go` (replace with your fork path if needed).

When cutting coordinated releases, bump versions together and record the mapping in the GitHub Release notes.

## Rust layout

| Crate | Role |
|-------|------|
| [`aptos_confidential_asset_core`](../rust/core) | Pure crypto (Bulletproofs + discrete log) |
| [`aptos_confidential_asset_ffi`](../rust/ffi) | C ABI (`staticlib` / `cdylib`) — **canonical for Go/C++/Zig** |
| [`aptos-confidential-asset-python`](../rust/python) | PyO3 extension (Python wheels via maturin) |
| [`aptos_confidential_asset_mobile`](../rust/mobile) | Android JNI; iOS builds the `ffi` staticlib |

C header (single source for consumers): [`rust/ffi/include/aptos_confidential_asset.h`](../rust/ffi/include/aptos_confidential_asset.h).

## Building the static library

From the repository root, prefer the helper script (it `unset`s a global `CARGO_TARGET_DIR` so artifacts land under `rust/target/release/`, which Go cgo and examples expect):

```bash
./scripts/build-ffi-for-bindings.sh
```

Or manually:

```bash
cargo build -p aptos_confidential_asset_ffi --release --manifest-path rust/Cargo.toml
```

Cross-compilation examples:

```bash
rustup target add aarch64-unknown-linux-gnu
cargo build -p aptos_confidential_asset_ffi --release --target aarch64-unknown-linux-gnu
```

Discrete-log **algorithm** is chosen at Rust compile time via Cargo features on `core` / `ffi` (`tbsgs_k` default). Go/Python in this repo follow that default.

### Cross-binding parity (what we can guarantee)

- **Single implementation:** Python (PyO3), the C ABI (`rust/ffi`), and WASM/JS paths all call **`aptos_confidential_asset_core`** — there is no second copy of the Bulletproofs/discrete-log logic in Go/C++/Zig (those languages call the same Rust static library).
- **You cannot prove “byte-identical proofs” across two `prove` calls:** Bulletproofs generation uses internal randomness; the same inputs may yield different valid `proof` bytes. Parity checks focus on **verification** and **round-trip** (`prove` → `verify`).
- **Shared golden fixture:** [`tests/fixtures/golden_batch_range_proof.json`](../tests/fixtures/golden_batch_range_proof.json) holds canonical inputs plus one sample `proof`/`comms_flat`. Tests: [`rust/core/tests/binding_golden_fixture.rs`](../rust/core/tests/binding_golden_fixture.rs), [`bindings/python/tests/test_golden_fixture.py`](../bindings/python/tests/test_golden_fixture.py), [`bindings/go/aptosconfidential/golden_test.go`](../bindings/go/aptosconfidential/golden_test.go). Regenerate canonical proof/comms: `cargo run --manifest-path rust/Cargo.toml --example emit_binding_golden_vector -p aptos_confidential_asset_core`.
- **Local orchestration:** [`scripts/check-binding-parity.sh`](../scripts/check-binding-parity.sh) runs Rust + Python + Go golden checks (requires `maturin develop` in `bindings/python` for pytest, and `libaptos_confidential_asset_ffi.a` for cgo).

## Go

See [bindings/go/README.md](../bindings/go/README.md) and [examples/go/README.md](../examples/go/README.md).

## Python

- Rust sources: [`rust/python`](../rust/python)
- Packaging / maturin: [`bindings/python`](../bindings/python)

```bash
cd bindings/python
pip install maturin pytest
maturin develop --release
pytest tests/
```

The PyO3 crate uses `abi3-py39` so extension builds are not tied to the host Python patch version.

## C++

See [bindings/cpp/README.md](../bindings/cpp/README.md) and [examples/cpp](../examples/cpp).

## Zig

See [bindings/zig/README.md](../bindings/zig/README.md).

## CI

[`.github/workflows/ci.yml`](../.github/workflows/ci.yml) includes **Bindings (FFI + Go + Python + C++)** (Ubuntu) plus an optional **Bindings (Zig smoke)** job. Together with lint / JS / Rust tests / macOS full build they gate merges to `main`.

## Releases (FFI binaries)

Maintainers publish prebuilt static libraries via **Actions → Bindings release artifacts**:

1. Use the **same semver `X.Y.Z`** as npm `@aptos-labs/confidential-asset-bindings@X.Y.Z`.
2. Run workflow with `version = X.Y.Z`; start with **`draft: true`** to inspect assets before marking the Release public.
3. Download **`SHA256SUMS`** from the Release and verify locally:

   ```bash
   curl -LO "https://github.com/OWNER/REPO/releases/download/vX.Y.Z/SHA256SUMS"
   curl -LO "https://github.com/OWNER/REPO/releases/download/vX.Y.Z/aptos_confidential_asset_ffi-<triple>.tar.gz"
   sha256sum -c SHA256SUMS
   ```

Cross-compilation uses `rust/target/<triple>/release/`; in GitHub Actions the workflows set `CARGO_TARGET_DIR` to `<repo>/rust/target` so outputs stay deterministic.

## Platform matrix (prebuilt artifacts)

The **Bindings release artifacts** workflow cross-builds tier-1 triples (linux gnu/musl x86_64, darwin x86_64/arm64, windows x86_64 MSVC) and uploads them to a GitHub Release. The repository **does not** commit `.a` / `.lib` binaries; consumers download release assets or build from source.

## cbindgen (optional)

Regenerate the C header after API changes:

```bash
cargo install cbindgen
cd rust/ffi
cbindgen --config cbindgen.toml --crate aptos_confidential_asset_ffi --output include/aptos_confidential_asset.h
```

Then sync `ios/Rust/Headers/aptos_confidential_asset.h` if the Swift layer should track the same definitions.
