//! PyO3 extension: range proofs + discrete log via `aptos_confidential_asset_core`.

use aptos_confidential_asset_core::discrete_log::DiscreteLogSolver;
use aptos_confidential_asset_core::range_proof::{
    batch_range_proof as core_batch_range_proof, batch_verify_proof as core_batch_verify_proof,
};
use pyo3::exceptions::PyValueError;
use pyo3::prelude::*;
use pyo3::types::PyBytes;

fn pyerr(msg: impl Into<String>) -> PyErr {
    PyValueError::new_err(msg.into())
}

fn flatten_comms(comms: &[Vec<u8>]) -> Vec<u8> {
    comms.iter().flatten().copied().collect()
}

#[pyfunction]
#[pyo3(signature = (values, blindings_flat, val_base, rand_base, num_bits=32))]
fn batch_range_proof_py<'py>(
    py: Python<'py>,
    values: Vec<u64>,
    blindings_flat: &[u8],
    val_base: &[u8],
    rand_base: &[u8],
    num_bits: usize,
) -> PyResult<(Bound<'py, PyBytes>, Bound<'py, PyBytes>)> {
    let result = py.allow_threads(|| {
        let rs = blindings_flat
            .chunks_exact(32)
            .map(|c| c.to_vec())
            .collect::<Vec<_>>();
        if rs.len() != values.len() {
            return Err(pyerr(format!(
                "blindings_flat must be {} * 32 bytes, got {}",
                values.len(),
                blindings_flat.len()
            )));
        }
        core_batch_range_proof(
            values,
            rs,
            val_base.to_vec(),
            rand_base.to_vec(),
            num_bits,
        )
        .map_err(|e| pyerr(e))
    })?;
    Ok((
        PyBytes::new(py, &result.proof),
        PyBytes::new(py, &flatten_comms(&result.comms)),
    ))
}

#[pyfunction]
#[pyo3(signature = (proof, comms_flat, val_base, rand_base, num_bits=32, comm_count=None))]
fn batch_verify_proof_py(
    proof: &[u8],
    comms_flat: &[u8],
    val_base: &[u8],
    rand_base: &[u8],
    num_bits: usize,
    comm_count: Option<usize>,
) -> PyResult<bool> {
    let count = match comm_count {
        Some(c) => {
            let expected = c.checked_mul(32).ok_or_else(|| pyerr("comm_count is too large"))?;
            if comms_flat.len() != expected {
                return Err(pyerr(format!(
                    "comms_flat must be exactly comm_count * 32 = {} bytes, got {}",
                    expected,
                    comms_flat.len()
                )));
            }
            c
        }
        None => {
            if comms_flat.len() % 32 != 0 {
                return Err(pyerr(format!(
                    "comms_flat length must be a multiple of 32 when comm_count is omitted (got {})",
                    comms_flat.len()
                )));
            }
            comms_flat.len() / 32
        }
    };

    let comms: Vec<Vec<u8>> = comms_flat.chunks_exact(32).map(|c| c.to_vec()).collect();
    debug_assert_eq!(comms.len(), count);
    core_batch_verify_proof(
        proof.to_vec(),
        comms,
        val_base.to_vec(),
        rand_base.to_vec(),
        num_bits,
    )
    .map_err(|e| pyerr(e))
}

#[pyclass]
struct DiscreteLogSolverPy {
    inner: DiscreteLogSolver,
}

#[pymethods]
impl DiscreteLogSolverPy {
    #[new]
    fn new() -> Self {
        Self {
            inner: DiscreteLogSolver::new(),
        }
    }

    fn solve(&self, y: &[u8], max_num_bits: u8) -> PyResult<u64> {
        self.inner
            .solve(y.to_vec(), max_num_bits)
            .map_err(|e| pyerr(e))
    }
}

#[pymodule]
fn _native(m: &Bound<'_, PyModule>) -> PyResult<()> {
    m.add_function(wrap_pyfunction!(batch_range_proof_py, m)?)?;
    m.add_function(wrap_pyfunction!(batch_verify_proof_py, m)?)?;
    m.add_class::<DiscreteLogSolverPy>()?;
    Ok(())
}
