# Go bindings (`aptosconfidential`)

**Experimental.** Module path: `github.com/aptos-labs/confidential-asset-bindings/bindings/go`.

## Quick start (external project)

```bash
# 1. Add the dependency
go get github.com/aptos-labs/confidential-asset-bindings/bindings/go@v1.1.2

# 2. Download the prebuilt native library into your project directory
#    (only needed once per version)
go run github.com/aptos-labs/confidential-asset-bindings/bindings/go/aptosconfidential/tools/download@v1.1.2

# 3. Build — point the linker at the downloaded library
CGO_LDFLAGS="-L$(pwd)/native/aarch64-apple-darwin" go build ./...
```

Step 2 downloads a prebuilt static library from GitHub Releases into `native/<triple>/` in your current directory. No Rust toolchain required.

The triple in step 3 matches your platform — see the [platform table](#supported-platforms) below.

## Quick start (in this repo)

```bash
# 1. Build the Rust FFI library
cargo build -p aptos_confidential_asset_ffi --release --manifest-path rust/Cargo.toml

# 2. Stage the built library
TRIPLE=aarch64-apple-darwin  # adjust for your platform
mkdir -p bindings/go/aptosconfidential/native/$TRIPLE
cp rust/target/release/libaptos_confidential_asset_ffi.a bindings/go/aptosconfidential/native/$TRIPLE/

# 3. Test
cd bindings/go && go test ./aptosconfidential/...
```

For musl Linux, use `-tags musl` and set `TRIPLE=x86_64-unknown-linux-musl` (or `aarch64-unknown-linux-musl`).

## Usage

```go
import "github.com/aptos-labs/confidential-asset-bindings/bindings/go/aptosconfidential"

blindingsFlat, err := aptosconfidential.FlattenBlindings([][]byte{r0, r1})
if err != nil { /* ... */ }
proof, commsFlat, err := aptosconfidential.BatchRangeProof(values, blindingsFlat, valBase32, randBase32, 32)
ok, err := aptosconfidential.BatchVerifyProof(proof, commsFlat, valBase32, randBase32, 32)

solver := aptosconfidential.NewSolver()
value, err := solver.Solve(compressedPoint32, 32)
```

`numBits` must be one of `8, 16, 32, 64`. `Solver.Solve` returns an error if `maxNumBits` is invalid, or if the solver is nil or already closed.

For long-running services, call `(*Solver).Close()` explicitly to release native resources deterministically.

See [examples/go](../../examples/go) for runnable examples.

## Supported platforms

| Platform | Triple | Notes |
|---|---|---|
| macOS arm64 (M1/M2/M3) | `aarch64-apple-darwin` | |
| macOS amd64 (Intel) | `x86_64-apple-darwin` | |
| Linux amd64 (glibc) | `x86_64-unknown-linux-gnu` | |
| Linux amd64 (musl) | `x86_64-unknown-linux-musl` | `-tags musl` required |
| Linux arm64 (glibc) | `aarch64-unknown-linux-gnu` | |
| Linux arm64 (musl) | `aarch64-unknown-linux-musl` | `-tags musl` required |
| Windows amd64 | `x86_64-pc-windows-msvc` | |
| Windows arm64 | `aarch64-pc-windows-msvc` | |

## Prerequisites

- `CGO_ENABLED=1` (default on native builds)
- A C compiler (Clang on macOS, GCC on Linux, MSVC on Windows)

## Version pinning

Override the downloaded native library version with the `CA_FFI_VERSION` environment variable:

```bash
CA_FFI_VERSION=1.1.1 go run github.com/aptos-labs/confidential-asset-bindings/bindings/go/aptosconfidential/tools/download@v1.1.2
```

> **Warning:** The Go module ships a header file matching its own release. Overriding `CA_FFI_VERSION` downloads a different library version but keeps the module's original header. Use a matching `@vX.Y.Z` module version to avoid ABI mismatches.
