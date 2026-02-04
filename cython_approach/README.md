# Cython Approach

Fortran calls compiled Cython extension modules directly.

## Architecture
```
Fortran (ISO_C_BINDING) → Cython-generated C code (compiled) → NumPy C API
```

## Features
- ✅ Compiled to native code for better performance
- ✅ Automatic type conversion via Cython
- ✅ Less boilerplate than raw C API
- ✅ Direct memory access with NumPy arrays (no copies)
- ⚠️ Requires Cython build step
- ⚠️ Still needs Python runtime for NumPy

## Status
🚧 **Work in Progress** - The code compiles but has initialization issues. The Python interpreter initialization from within a Cython module called from Fortran needs additional work. Consider the C API shim approach for production use.

## Build
```bash
make FC=gfortran
```

## Files
- `cy_functions.pyx`: Cython module exposing C functions
- `main.f90`: Fortran program with ISO_C_BINDING interfaces  
- `Makefile`: Build script (no setup.py needed, direct cython compilation)

## Comparison to C API Shim
- **Simpler code**: ~60 lines vs 280 lines for equivalent functionality
- **Type safety**: Cython handles conversions automatically
- **No manual reference counting**: Cython manages Python objects
- **Cleaner syntax**: Python-like code instead of raw C API calls
