//! Cross-binding parity against `tests/fixtures/golden_batch_range_proof.json`.
//!
//! **Why we verify canonical bytes instead of reproving:** Bulletproofs proof generation uses
//! internal randomness, so the same inputs can yield different valid `proof` byte strings. What
//! must stay consistent across bindings is the **verification** path and (for round-trip) that
//! *a* freshly generated proof verifies. Python tests load the same fixture — see
//! `bindings/python/tests/test_golden_fixture.py`.

use aptos_confidential_asset_core::range_proof::{batch_range_proof, batch_verify_proof};
use serde::Deserialize;

const FIXTURE: &str = include_str!("../../../tests/fixtures/golden_batch_range_proof.json");

#[derive(Deserialize)]
struct GoldenFixture {
    #[allow(dead_code)]
    schema_version: u32,
    values: Vec<u64>,
    blindings_flat_hex: String,
    val_base_hex: String,
    rand_base_hex: String,
    num_bits: usize,
    /// Canonical proof bytes from one generation run — used for cross-binding verify parity only.
    proof_hex: String,
    comms_flat_hex: String,
}

fn hex_decode(s: &str) -> Vec<u8> {
    (0..s.len())
        .step_by(2)
        .map(|i| u8::from_str_radix(&s[i..i + 2], 16).expect("hex"))
        .collect()
}

fn comms_from_flat(comms_flat: &[u8]) -> Vec<Vec<u8>> {
    comms_flat
        .chunks_exact(32)
        .map(|c| c.to_vec())
        .collect()
}

#[test]
fn golden_fixture_verify_matches_core() {
    let f: GoldenFixture = serde_json::from_str(FIXTURE).expect("parse fixture");

    let proof = hex_decode(&f.proof_hex);
    let comms_flat = hex_decode(&f.comms_flat_hex);
    let comms = comms_from_flat(&comms_flat);
    assert_eq!(comms.len(), f.values.len());

    let val_base = hex_decode(&f.val_base_hex);
    let rand_base = hex_decode(&f.rand_base_hex);

    let ok = batch_verify_proof(
        proof,
        comms,
        val_base,
        rand_base,
        f.num_bits,
    )
    .expect("verify");
    assert!(ok, "canonical fixture proof must verify under core");
}

#[test]
fn golden_inputs_prove_and_verify_round_trip() {
    let f: GoldenFixture = serde_json::from_str(FIXTURE).expect("parse fixture");

    let blindings_flat = hex_decode(&f.blindings_flat_hex);
    let rs: Vec<Vec<u8>> = blindings_flat
        .chunks_exact(32)
        .map(|c| c.to_vec())
        .collect();
    assert_eq!(rs.len(), f.values.len());

    let val_base = hex_decode(&f.val_base_hex);
    let rand_base = hex_decode(&f.rand_base_hex);

    let got = batch_range_proof(
        f.values.clone(),
        rs,
        val_base.clone(),
        rand_base.clone(),
        f.num_bits,
    )
    .expect("prove");

    let ok = batch_verify_proof(
        got.proof.clone(),
        got.comms.clone(),
        val_base,
        rand_base,
        f.num_bits,
    )
    .expect("verify fresh proof");
    assert!(ok, "freshly generated proof must verify");
}

