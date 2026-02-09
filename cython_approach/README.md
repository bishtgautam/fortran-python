# Cython Approach with NumPy

Fortran calls Cython code that uses NumPy operations through a C bridge layer.

## Architecture
```
Fortran (ISO_C_BINDING) → C Bridge (PyImport_ImportModule) → Cython Module → NumPy Operations
```

## Status
✅ **Working** - NumPy operations successfully callable from Fortran using PyImport_ImportModule pattern.

## Build & Run
```bash
# Build (requires NumPy installation)
make PYTHON=python3.14 FC=/opt/homebrew/bin/mpif90 CC=/opt/homebrew/bin/gcc-14

# Run with NumPy
PYTHONPATH=/opt/homebrew/lib/python3.14/site-packages ./fortran_calls_cython
```

## What Works
- ✅ NumPy operations (`np.sum()`, array multiplication)
- ✅ NumPy array views from C pointers
- ✅ Full Python context via PyImport_ImportModule
- ✅ Error handling with try/except
- ✅ Python initialization/finalization through C bridge
- ✅ Memory views and direct array modification

## Key Insight
To use NumPy operations from C/Fortran-called Cython code:
- **Use PyImport_ImportModule pattern** - creates proper Python runtime context
- **Avoid `cdef public` direct binding** - lacks Python context for NumPy
- **C bridge layer essential** - handles module initialization correctly
- **PYTHONPATH required** - embedded Python needs to find NumPy

## Files
- `cy_functions_full.pyx`: Cython module with NumPy operations
- `cy_bridge.c`: C bridge for Python module initialization
- `main.f90`: Fortran program with timestepping example
- `Makefile`: Build script

## Architecture Details

### C Bridge Pattern
The C bridge (`cy_bridge.c`) uses `PyImport_ImportModule()` to create a proper Python module context:
```c
PyImport_AppendInittab("cy_functions_full", PyInit_cy_functions_full);
Py_Initialize();
PyImport_ImportModule("cy_functions_full");
```

This differs from direct `cdef public` exports which lack the Python context needed for NumPy.

### NumPy Operations
Functions create NumPy array views from C pointers:
```python
np_arr = np.asarray(<cnp.float64_t[:n]>arr)
result = np.sum(np_arr)  # Works with proper Python context!
```

## Comparison to cdef public Pattern
**Advantages of PyImport_ImportModule:**
- ✅ Full Python runtime context available
- ✅ NumPy operations work correctly
- ✅ Can use Python libraries and objects
- ✅ Better error handling with exceptions

**Trade-offs:**
- Requires C bridge layer (adds ~80 lines)
- Needs PYTHONPATH set at runtime
- Slightly more complex initialization

## Use Case
Ideal for calling Python/NumPy scientific computing code from legacy Fortran applications, enabling use of modern ML/data science libraries.
