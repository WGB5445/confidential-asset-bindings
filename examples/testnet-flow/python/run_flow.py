#!/usr/bin/env python3
"""Run the aptos-ts-sdk Testnet confidential-asset demo (same env vars as TS confidential-testnet.ts).

This repo's Python bindings only expose crypto; chain orchestration is delegated to pnpm + tsx.
"""
from __future__ import annotations

import os
import subprocess
import sys
from pathlib import Path


def main() -> int:
    flow_dir = Path(__file__).resolve().parent
    bindings_root = flow_dir.parent.parent.parent
    sdk_root = os.environ.get("APTOS_TS_SDK_ROOT")
    if not sdk_root:
        sdk_root = str(bindings_root.parent / "aptos-ts-sdk")
    target = Path(sdk_root).resolve() / "examples" / "bun-confidential-testnet"
    if not target.is_dir():
        print(f"error: {target} not found. Set APTOS_TS_SDK_ROOT.", file=sys.stderr)
        return 1
    cmd = ["pnpm", "exec", "tsx", "confidential-testnet.ts"]
    return subprocess.call(cmd, cwd=target, env=os.environ)


if __name__ == "__main__":
    raise SystemExit(main())
