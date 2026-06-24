# Go bindings (`aptosconfidential`)

Module path: `github.com/aptos-labs/confidential-asset-bindings/bindings/go`

## Quick start

```bash
# 1. Add the dependency
go get github.com/aptos-labs/confidential-asset-bindings/bindings/go

# 2. Download the prebuilt native library (requires internet; only needed once per version)
go generate github.com/aptos-labs/confidential-asset-bindings/bindings/go/aptosconfidential

# 3. Build your project
go build ./...
```

The `go generate` step downloads a prebuilt static library from GitHub Releases and places it in `native/<platform>/`. No Rust toolchain required.

## Usage

```go
import "github.com/aptos-labs/confidential-asset-bindings/bindings/go/aptosconfidential"

// Generate a batch range proof
proof, commsFlat, err := aptosconfidential.BatchRangeProof(values, blindings, valBase32, randBase32, 32)

// Verify a batch range proof
ok, err := aptosconfidential.BatchVerifyProof(proof, commsFlat, valBase32, randBase32, 32)

// Solve a discrete log
solver := aptosconfidential.NewSolver()
value, err := solver.Solve(compressedPoint32, 32)
```

See [examples/go](../../examples/go) for runnable examples.

## Prerequisites

- `CGO_ENABLED=1` (default on native builds)
- A C compiler (Clang on macOS, GCC on Linux, MSVC on Windows)

## Supported platforms

| Platform | Triple |
|---|---|
| macOS arm64 (M1/M2/M3) | `aarch64-apple-darwin` |
| macOS amd64 (Intel) | `x86_64-apple-darwin` |
| Linux amd64 (glibc) | `x86_64-unknown-linux-gnu` |
| Linux amd64 (musl) | `x86_64-unknown-linux-musl` |
| Linux arm64 (glibc) | `aarch64-unknown-linux-gnu` |
| Linux arm64 (musl) | `aarch64-unknown-linux-musl` |
| Windows amd64 | `x86_64-pc-windows-msvc` |

For musl targets, set `CA_MUSL=1` before running `go generate`, or build with `-tags musl`.

## Building from source (no internet)

If you cannot download prebuilt libraries, build from source:

```bash
cargo build -p aptos_confidential_asset_ffi --release --manifest-path rust/Cargo.toml
mkdir -p bindings/go/aptosconfidential/native/aarch64-apple-darwin  # adjust triple
cp rust/target/release/libaptos_confidential_asset_ffi.a bindings/go/aptosconfidential/native/aarch64-apple-darwin/
cp rust/ffi/include/aptos_confidential_asset.h bindings/go/aptosconfidential/native/aarch64-apple-darwin/
```

## Version pinning

The prebuilt library version is stored in [`VERSION`](./VERSION). To use a specific version:

```bash
CA_FFI_VERSION=1.1.1 go generate github.com/aptos-labs/confidential-asset-bindings/bindings/go/aptosconfidential
```
