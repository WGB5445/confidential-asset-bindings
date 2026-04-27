#include <aptos_confidential_asset.h>
#include <cstdint>
#include <cstring>
#include <iostream>

int main() {
  void *solver = confidential_asset_create_solver();
  if (!solver) {
    std::cerr << "create_solver failed\n";
    return 1;
  }

  uint8_t y[32] = {};
  ConfidentialAssetBytesResult res =
      confidential_asset_solver_solve(solver, y, sizeof(y), 16);

  if (res.error.len > 0) {
    std::cerr << "solver error\n";
    confidential_asset_free_buffer(res.value);
    confidential_asset_free_buffer(res.error);
    confidential_asset_free_solver(solver);
    return 1;
  }

  std::cout << "discrete-log demo OK, result bytes=" << res.value.len << "\n";
  confidential_asset_free_buffer(res.value);
  confidential_asset_free_buffer(res.error);
  confidential_asset_free_solver(solver);
  return 0;
}
