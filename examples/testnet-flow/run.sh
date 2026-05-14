#!/usr/bin/env bash
# Run the same Testnet confidential-asset flow as aptos-ts-sdk TS demo, with identical env vars.
set -euo pipefail

FLOW_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BINDINGS_ROOT="$(cd "${FLOW_DIR}/../.." && pwd)"

if [[ -n "${APTOS_TS_SDK_ROOT:-}" ]]; then
  SDK_ROOT="$(cd "${APTOS_TS_SDK_ROOT}" && pwd)"
else
  SDK_ROOT="$(cd "${BINDINGS_ROOT}/../aptos-ts-sdk" && pwd)"
fi

TARGET_DIR="${SDK_ROOT}/examples/bun-confidential-testnet"
if [[ ! -d "${TARGET_DIR}" ]]; then
  echo "error: ${TARGET_DIR} not found. Set APTOS_TS_SDK_ROOT to your aptos-ts-sdk clone." >&2
  exit 1
fi

cd "${TARGET_DIR}"
exec pnpm exec tsx confidential-testnet.ts
