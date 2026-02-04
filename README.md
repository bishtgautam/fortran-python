# Fortran → Python (C API shim) minimal example

## Files
- `c_shim.c` / `c_shim.h`: C API shim that calls Python.
- `main.f90`: Fortran program that calls the shim.
- `py_module.py`: Python module with `sum_array`.
- `Makefile`: build script.

## Build
```bash
make
```

## Run
```bash
./fortran_calls_python
```

If the Python module is not found, run from this directory or set `PYTHONPATH` to include it.
