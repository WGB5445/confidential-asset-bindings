# aptos-confidential-asset-bindings-experimental (Python)

PyO3 / maturin extension wrapping the same Rust core as `@aptos-labs/confidential-asset-bindings`.

## Build (from repo root)

Requires Rust (see repo `.mise.toml`), Python 3.9+. The Rust extension crate lives at [`rust/python`](../../rust/python) inside the workspace.

```bash
cd bindings/python
python -m venv .venv && source .venv/bin/activate
pip install maturin pytest
maturin develop --release
pytest tests/
```

## Publish (maintainers)

Use [maturin](https://www.maturin.rs/) with `manylinux` / `musllinux` / macOS / Windows runners to build wheels; align versions with the npm package when cutting releases.

```bash
maturin build --release
```

Package name on PyPI is intentionally **experimental** (`aptos-confidential-asset-bindings-experimental`); rename when promoting out of experiment.
