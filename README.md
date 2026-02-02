# confidential-asset-wasm-bindings

WASM bindings for Aptos confidential assets:
- **pollard-kangaroo**: Discrete log solver for decrypting balances
- **range-proofs**: Batch Bulletproofs for proving values are in range

## Building

### Prerequisites

- Rust toolchain with `wasm32-unknown-unknown` target
- [wasm-pack](https://rustwasm.github.io/wasm-pack/installer/)
- Node.js and npm
- Rollup (`npm install -g rollup`)

### Build all WASM and generate npm package

```bash
./scripts/build-all.sh
```

This mirrors the CI workflow and will:
1. Build range-proofs WASM
2. Build pollard-kangaroo WASM
3. Generate the unified npm package in `aptos-confidential-asset-wasm-bindings/`

### Individual scripts

```bash
# Build only pollard-kangaroo WASM
./scripts/build-pollard-kangaroo.sh

# Build only range-proofs WASM
./scripts/build-range-proofs.sh

# Generate npm package (after building WASM)
./scripts/gen-npm-pkg.sh
```

## Output

After building, the npm package is available at:
```
aptos-confidential-asset-wasm-bindings/
├── package.json
├── index.d.ts
├── pollard-kangaroo/
│   ├── *.wasm
│   ├── *-esm.js
│   ├── *-cjs.js
│   └── *.d.ts
└── range-proofs/
    ├── *.wasm
    ├── *-esm.js
    ├── *-cjs.js
    └── *.d.ts
```

## Docker builds (alternative)

If you prefer reproducible Docker-based builds, use the Dockerfiles in each package directory:

```bash
cd pollard-kangaroo && docker build -t pk-wasm . && docker run --rm -v $(pwd)/pkg:/usr/src/app/pkg pk-wasm
cd range-proofs && docker build -t rp-wasm . && docker run --rm -v $(pwd)/pkg:/usr/src/app/pkg rp-wasm
```
