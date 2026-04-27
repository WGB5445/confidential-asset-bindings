# C++ consumption (`aptos_confidential_asset_ffi`)

1. Build the static library from the repo root:

   ```bash
   cargo build -p aptos_confidential_asset_ffi --release
   ```

2. In your `CMakeLists.txt`:

   ```cmake
   set(APTOS_CONFIDENTIAL_ASSET_ROOT "/path/to/confidential-asset-bindings" CACHE PATH "")
   add_subdirectory(${APTOS_CONFIDENTIAL_ASSET_ROOT}/bindings/cpp)
   target_link_libraries(my_target PRIVATE aptos_confidential_asset::static aptos_confidential_asset::headers)
   ```

3. Include the header:

   ```cpp
   #include <aptos_confidential_asset.h>
   ```

Cross-compilation: set `APTOS_CONFIDENTIAL_ASSET_ROOT` and ensure `rust/target/<triple>/release/` contains the matching `libaptos_confidential_asset_ffi.a` (or `.lib` on Windows).
