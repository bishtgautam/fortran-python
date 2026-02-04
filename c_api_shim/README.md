# C API Shim Approach

Fortran calls Python via a C shim that uses the Python C API.

## Architecture
```
Fortran (ISO_C_BINDING) → C shim → Python C API → Python interpreter → py_module.py
```

## Features
- ✅ Calls arbitrary Python code at runtime
- ✅ Full access to Python libraries (NumPy, etc.)
- ✅ No compilation of Python code needed
- ⚠️ Requires Python interpreter at runtime
- ⚠️ Manual memory management and reference counting

## Build & Run
```bash
make FC=gfortran
./fortran_calls_numpy_python
```

## Files
- `c_shim.c/h`: C API bridge to Python
- `main.f90`: Fortran program with ISO_C_BINDING interfaces
- `py_module.py`: Python functions to call
- `Makefile`: Build script
