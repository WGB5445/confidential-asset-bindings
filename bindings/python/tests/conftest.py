"""Shared pytest paths for bindings tests."""

from pathlib import Path

import pytest


def _repo_root() -> Path:
    # bindings/python/tests/conftest.py -> parents[3] = repository root
    return Path(__file__).resolve().parents[3]


@pytest.fixture(scope="session")
def repo_root() -> Path:
    return _repo_root()


@pytest.fixture(scope="session")
def fixtures_dir(repo_root: Path) -> Path:
    return repo_root / "tests" / "fixtures"


@pytest.fixture(scope="session")
def golden_batch_range_proof_path(fixtures_dir: Path) -> Path:
    p = fixtures_dir / "golden_batch_range_proof.json"
    if not p.is_file():
        pytest.skip(f"missing fixture: {p}")
    return p
