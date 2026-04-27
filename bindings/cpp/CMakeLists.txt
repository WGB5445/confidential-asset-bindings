# CMake package for consuming aptos_confidential_asset_ffi (static library + header).
# Typical use (after building the Rust staticlib, see docs/bindings.md):
#
#   set(APTOS_CONFIDENTIAL_ASSET_ROOT "${CMAKE_CURRENT_SOURCE_DIR}/path/to/repo")
#   add_subdirectory(${APTOS_CONFIDENTIAL_ASSET_ROOT}/bindings/cpp aptos_ffi_build)
#   target_link_libraries(my_target PRIVATE aptos_confidential_asset::static)

cmake_minimum_required(VERSION 3.16)
project(aptos_confidential_asset_cpp NONE)

set(APTOS_CONFIDENTIAL_ASSET_ROOT "${CMAKE_CURRENT_LIST_DIR}/../.." CACHE PATH "Repository root (contains rust/ffi)")

add_library(aptos_confidential_asset_headers INTERFACE)
target_include_directories(
  aptos_confidential_asset_headers
  INTERFACE
  "${APTOS_CONFIDENTIAL_ASSET_ROOT}/rust/ffi/include"
)

add_library(aptos_confidential_asset_static STATIC IMPORTED GLOBAL)
set(_aptos_lib_dir "${APTOS_CONFIDENTIAL_ASSET_ROOT}/rust/target/release")
if(WIN32)
  set_target_properties(
    aptos_confidential_asset_static
    PROPERTIES
      IMPORTED_LOCATION "${_aptos_lib_dir}/aptos_confidential_asset_ffi.lib"
      INTERFACE_LINK_LIBRARIES ""
  )
else()
  set_target_properties(
    aptos_confidential_asset_static
    PROPERTIES
      IMPORTED_LOCATION "${_aptos_lib_dir}/libaptos_confidential_asset_ffi.a"
  )
endif()

add_library(aptos_confidential_asset::headers ALIAS aptos_confidential_asset_headers)
add_library(aptos_confidential_asset::static ALIAS aptos_confidential_asset_static)
