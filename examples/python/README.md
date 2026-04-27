# Python example

Uses the maturin package under `bindings/python` (Rust crate in `rust/python`).

```bash
cd bindings/python
python -m venv .venv && source .venv/bin/activate
pip install maturin pytest
maturin develop --release
cd ../../examples/python
python smoke.py
```
