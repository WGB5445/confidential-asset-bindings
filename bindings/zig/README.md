# Zig demo (`bindings/zig`)

Requires Zig **0.12+** and a prebuilt `libaptos_confidential_asset_ffi.a` (or Windows `.lib`).

```bash
cd ../..   # repo root
cargo build -p aptos_confidential_asset_ffi --release
cd bindings/zig
zig build
zig build run
```

Adjust `build.zig` library paths when cross-compiling (use `rust/target/<triple>/release`).
