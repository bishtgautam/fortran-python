# Cython Approach

Fortran calls compiled Cython code with C-level performance.

## Architecture
```
Fortran (ISO_C_BINDING) → Cython-compiled C code → Direct C loops
```

## Status
✅ **Working** - Cython functions callable from Fortran work perfectly using pure C operations.

## Build & Run
```bash
# Standard version (pure C)
make FC=gfortran
./fortran_calls_cython

# Test with "NumPy" functions (still using C loops underneath)
make test-numpy FC=gfortran
./test_cython_numpy
```

## What Works
- ✅ Pure C operations in Cython (loops, arithmetic)
- ✅ Memory views and direct array access
- ✅ Error handling with C strings
- ✅ Python initialization/finalization
- ✅ NumPy C API array wrapping (for reference, though pure C is more reliable)

## Key Insight
When exporting Cython functions via `cdef public` to be called from C/Fortran:
- **Use pure C operations** (loops, pointer arithmetic) - most reliable
- **Avoid Python objects** (`np.sum()`, `np.asarray()`) - requires full Python context
- **NumPy C API** works but pure C loops are simpler and just as fast

## Files
- `cy_functions.pyx`: Main Cython module with pure C operations
- `cy_functions_full.pyx`: Extended version showing NumPy C API patterns
- `main.f90`: Fortran program (basic test)
- `test_numpy.f90`: Fortran program (extended test)
- `Makefile`: Build script (direct Cython compilation)

## Comparison to C API Shim
**Advantages:**
- **Simpler code**: ~60 lines vs 280 lines
- **No manual reference counting**: Cython manages it
- **Type safety**: Automatic type conversion  
- **Better syntax**: Python-like instead of C API calls
- **Same performance**: Compiles to equivalent C code

**Trade-offs:**
- For calling arbitrary Python libraries at runtime, C API shim is more flexible
- Cython best suited for writing new performance code, not wrapping existing Python

## Use Case
Perfect for writing new numerical algorithms with clean syntax that compiles to C-speed code, callable from Fortran.
