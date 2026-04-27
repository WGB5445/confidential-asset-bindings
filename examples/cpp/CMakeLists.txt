cmake_minimum_required(VERSION 3.16)
project(confidential_asset_cpp_example LANGUAGES CXX)

set(APTOS_CONFIDENTIAL_ASSET_ROOT "${CMAKE_CURRENT_SOURCE_DIR}/../.." CACHE PATH "")
add_subdirectory("${APTOS_CONFIDENTIAL_ASSET_ROOT}/bindings/cpp" aptos_ffi)

add_executable(demo main.cpp)
target_link_libraries(
  demo
  PRIVATE
  aptos_confidential_asset::static
  aptos_confidential_asset::headers
)
set_property(TARGET demo PROPERTY CXX_STANDARD 17)
