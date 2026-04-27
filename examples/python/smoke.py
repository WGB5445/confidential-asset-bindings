"""Smoke test using the installed experimental package."""

import aptos_confidential_asset as ca


def main() -> None:
    bases = bytes([1]) + bytes(31)
    ok = ca.batch_verify_proof(
        b"\x01",
        bytes(32),
        bases,
        bases,
        num_bits=32,
        comm_count=1,
    )
    print("verify (expected False):", ok)


if __name__ == "__main__":
    main()
