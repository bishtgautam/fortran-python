# Cython Approach

Fortran calls compiled Cython code with C-level performance.

## Architecture
```
Fortran (ISO_C_BINDING) → Cython-compiled C code → C loops / NumPy C API
```

## Status
✅ **Working** - Cython with pure C operations works perfectly. Using Python objects (like `np.sum()`) from exported C functions requires additional setup.

## Build & Run
```bash
make FC=gfortran
./fortran_calls_cython
```

## What Works
- ✅ Pure C operations in Cython (loops, arithmetic)
- ✅ Memory views and direct array access
- ✅ Error handling with C strings
- ✅ Python initialization/finalization
- ⚠️ Calling Python functions (like `np.sum()`) requires module to be imported as Python extension

## Files
- `cy_functions.pyx`: Cython module with pure C operations
- `main.f90`: Fortran program
- `Makefile`: Build script (direct Cython compilation, no setup.py)

## Comparison to C API Shim
**Advantages:**
- **Simpler code**: ~60 lines vs 280 lines
- **No manual reference counting**: Cython manages it
- **Type safety**: Automatic type conversion  
- **Better syntax**: Python-like instead of C API calls
- **Same performance**: Compiles to equivalent C code

**Limitations:**
- For calling Python libraries at runtime, C API shim is more flexible
- Cython best suited for writing new performance-critical code, not wrapping existing Python

## Use Case
Perfect for writing new numerical algorithms with clean syntax that compiles to C-speed code, callable from Fortran.
