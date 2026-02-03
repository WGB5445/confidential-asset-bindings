# Confidential Asset WASM Bindings

Unified WebAssembly bindings for Aptos confidential assets, combining:
- **Discrete log solver**: TBSGS-k32 algorithm for solving discrete logarithms (used for decryption)
- **Range proofs**: Bulletproofs implementation for zero-knowledge range proofs

## Building

```bash
# Build everything (WASM + npm package)
./scripts/build-all.sh

# Check WASM size
./scripts/wasm-sizes.sh
```

## Package Structure

After building, the npm package is in `aptos-confidential-asset-wasm-bindings/`:

```
aptos-confidential-asset-wasm-bindings/
├── aptos_confidential_asset_wasm_bg.wasm  # The WASM binary (~774 KiB)
├── aptos_confidential_asset_wasm.d.ts     # TypeScript definitions
├── aptos_confidential_asset_wasm-esm.js   # ES module wrapper
├── aptos_confidential_asset_wasm-cjs.js   # CommonJS wrapper
├── index.js -> aptos_confidential_asset_wasm-esm.js
├── index.d.ts -> aptos_confidential_asset_wasm.d.ts
└── package.json
```

## Usage

```typescript
import init, {
  DiscreteLogSolver,
  range_proof,
  verify_proof,
  batch_range_proof,
  batch_verify_proof,
} from "@aptos-labs/confidential-asset-wasm-bindings";

// Initialize WASM
await init();

// Discrete log (for decryption)
const solver = new DiscreteLogSolver();
const x = solver.solve(point, 32); // Solve 32-bit discrete log

// Range proofs
const proof = range_proof(value, blinding, valBase, randBase, numBits);
const valid = verify_proof(proof.proof(), proof.comm(), valBase, randBase, numBits);
```

## Cross-Version Compatibility

The range proofs are generated using bulletproofs v5.0.0 but are compatible with
bulletproofs v4.0.0 verification (as used in aptos-core). This is verified by tests
in `unified/tests/cross_version_compat.rs`.

## Algorithm Selection

The discrete log algorithm can be changed via Cargo features in `unified/Cargo.toml`:

| Feature | Table Size | WASM Size | Notes |
|---------|------------|-----------|-------|
| `tbsgs_k` (default) | ~512 KiB | ~774 KiB | Recommended: best size/performance ratio |
| `bsgs_k` | ~2.0 MiB | ~2.1 MiB | Faster but larger |
| `bsgs` | ~2.0 MiB | ~2.1 MiB | Standard BSGS |
| `bl12` | ~258 KiB | ~268 KiB | Smallest but slower |

## Testing

```bash
# Run cross-version compatibility tests
cd unified && cargo test

# Run all tests including pollard-kangaroo
cargo test --workspace
```
