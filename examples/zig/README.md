# Zig example

The runnable Zig demo lives under [`bindings/zig`](../../bindings/zig) (same `build.zig` / `src/main.zig`).

```bash
./scripts/build-ffi-for-bindings.sh
cd ../../bindings/zig
zig build
zig build run
```

If your environment sets `CARGO_TARGET_DIR`, use the script above so the static library lands in `rust/target/release/`.
