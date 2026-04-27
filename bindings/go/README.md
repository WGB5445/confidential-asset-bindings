# Go bindings (`aptosconfidential`)

**Experimental.** Module path: `github.com/aptos-labs/confidential-asset-bindings/bindings/go`.

## Prerequisites

- `CGO_ENABLED=1` and a C compiler (Clang/GCC/MSVC).
- Prebuilt static library from this repo:

  ```bash
  cargo build -p aptos_confidential_asset_ffi --release
  # cross-target: add --target aarch64-apple-darwin etc.
  ```

The `cgo_*.go` files pin `rust/target/<Rust-triple>/release/libaptos_confidential_asset_ffi.a` (or `aptos_confidential_asset_ffi.lib` on Windows).

## Use in another module

```go
import "github.com/aptos-labs/confidential-asset-bindings/bindings/go/aptosconfidential"

proof, comms, err := aptosconfidential.BatchRangeProof(values, blindings, valBase32, randBase32, 32)
```

See [examples/go](../../examples/go).

## Platforms covered in-tree

Non-musl builds link `rust/target/release/libaptos_confidential_asset_ffi.a` (or `rust/target/release/aptos_confidential_asset_ffi.lib` on Windows) — i.e. `cargo build -p aptos_confidential_asset_ffi --release` **without** `--target`, on the same machine that runs `go build` / `go test`.

| File | When it applies |
|------|-----------------|
| `cgo_linux_amd64.go` | Linux, amd64, glibc |
| `cgo_linux_arm64.go` | Linux, arm64, glibc |
| `cgo_linux_amd64_musl.go` | Linux, amd64, musl — expects `rust/target/x86_64-unknown-linux-musl/release/...` |
| `cgo_linux_arm64_musl.go` | Linux, arm64, musl — expects `rust/target/aarch64-unknown-linux-musl/release/...` |
| `cgo_darwin_amd64.go` / `cgo_darwin_arm64.go` | macOS (host `target/release`) |
| `cgo_windows_amd64.go` / `cgo_windows_arm64.go` | Windows MSVC (host `target/release`) |

For **cross-compiled** Rust (different `--target`), copy or symlink the `.a` into `rust/target/release/` or add another `cgo_*.go` with the correct path.
