"""Golden vector parity — see `docs/bindings.md` (Cross-binding parity)."""

from pathlib import Path

import aptos_confidential_asset as ca


def test_golden_fixture_verify_matches_python(golden_batch_range_proof_path: Path):
    import json

    data = json.loads(golden_batch_range_proof_path.read_text(encoding="utf-8"))
    proof = bytes.fromhex(data["proof_hex"])
    comms_flat = bytes.fromhex(data["comms_flat_hex"])
    val_base = bytes.fromhex(data["val_base_hex"])
    rand_base = bytes.fromhex(data["rand_base_hex"])
    num_bits = data["num_bits"]
    n = len(data["values"])

    assert ca.batch_verify_proof(
        proof,
        comms_flat,
        val_base,
        rand_base,
        num_bits=num_bits,
        comm_count=n,
    )


def test_golden_inputs_prove_then_verify_round_trip(golden_batch_range_proof_path: Path):
    import json

    data = json.loads(golden_batch_range_proof_path.read_text(encoding="utf-8"))
    values = data["values"]
    blindings = bytes.fromhex(data["blindings_flat_hex"])
    val_base = bytes.fromhex(data["val_base_hex"])
    rand_base = bytes.fromhex(data["rand_base_hex"])
    num_bits = data["num_bits"]

    proof, comms_flat = ca.batch_range_proof(
        values, blindings, val_base, rand_base, num_bits
    )
    assert ca.batch_verify_proof(
        proof,
        comms_flat,
        val_base,
        rand_base,
        num_bits=num_bits,
        comm_count=len(values),
    )
