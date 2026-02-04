# Fortran ↔ Python Interoperability: Two Approaches

This repository demonstrates two stable methods for calling Python from Fortran code.

## Approaches

### 1. [C API Shim](c_api_shim/)
Uses the Python C API to embed a Python interpreter and call Python code at runtime.

**Pros**: 
- Call any Python library at runtime (ML models, matplotlib, etc.)
- No Python code compilation needed
- Most flexible

**Cons**: 
- Requires Python interpreter at runtime
- Manual memory management
- More boilerplate

### 2. [Cython](cython_approach/)
Compiles Python-like code to C extensions that Fortran can call directly.

**Pros**: 
- Better performance (compiled)
- Cleaner code with automatic type conversion
- Can run without interpreter

**Cons**: 
- Requires Cython build step
- Less flexible than runtime Python

## Quick Start

**C API Shim:**
```bash
cd c_api_shim
make FC=gfortran
./fortran_calls_numpy_python
```

**Cython:**
```bash
cd cython_approach
# Coming soon
```

## Use Cases
- **C API Shim**: Call existing Python libraries, ML inference, visualization
- **Cython**: Write new high-performance numerical code with cleaner syntax
