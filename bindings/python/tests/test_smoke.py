import aptos_confidential_asset as ca


def test_discrete_log_solver_constructible():
    s = ca.DiscreteLogSolver()
    assert s is not None


def test_batch_verify_rejects_invalid_points():
    """Invalid Pedersen bases must raise (not a valid compressed Ristretto)."""
    proof = b"\x00" * 128
    comms = b"\x00" * 32
    bases = bytes([9]) + bytes(31)
    try:
        ca.batch_verify_proof(
            proof,
            comms,
            bases,
            bases,
            num_bits=32,
            comm_count=1,
        )
    except ValueError:
        return
    raise AssertionError("expected ValueError for invalid bases")
