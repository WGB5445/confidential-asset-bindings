//! Emit a deterministic golden vector for cross-binding parity tests.
//!
//! ```text
//! cargo run --manifest-path rust/Cargo.toml --example emit_binding_golden_vector -p aptos_confidential_asset_core
//! ```
//!
//! Paste the printed JSON into `tests/fixtures/golden_batch_range_proof.json` when inputs change.

use aptos_confidential_asset_core::range_proof::batch_range_proof;
use bulletproofs::PedersenGens;

fn hex(bytes: &[u8]) -> String {
    bytes.iter().map(|b| format!("{:02x}", b)).collect()
}

fn main() {
    let pg = PedersenGens::default();
    let val_base = pg.B.compress().to_bytes().to_vec();
    let rand_base = pg.B_blinding.compress().to_bytes().to_vec();
    let values = vec![42_u64, 7_u64];
    let blindings_flat: Vec<u8> = [[3u8; 32], [4u8; 32]].iter().flatten().copied().collect();
    let rs: Vec<Vec<u8>> = blindings_flat.chunks_exact(32).map(|c| c.to_vec()).collect();
    let out = batch_range_proof(
        values.clone(),
        rs,
        val_base.clone(),
        rand_base.clone(),
        32,
    )
    .expect("golden vector must prove");
    let comms_flat: Vec<u8> = out.comms.iter().flatten().copied().collect();

    println!(
        r#"{{
  "schema_version": 1,
  "comment": "Deterministic batch range proof; bindings must reproduce proof_hex and comms_flat_hex byte-for-byte.",
  "values": [42, 7],
  "blindings_flat_hex": "{}",
  "val_base_hex": "{}",
  "rand_base_hex": "{}",
  "num_bits": 32,
  "proof_hex": "{}",
  "comms_flat_hex": "{}"
}}"#,
        hex(&blindings_flat),
        hex(&val_base),
        hex(&rand_base),
        hex(&out.proof),
        hex(&comms_flat)
    );
}
