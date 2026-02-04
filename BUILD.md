# Build Instructions

## Quick Start (with defaults)

```bash
cd c_api_shim
make clean && make
./fortran_calls_python

cd ../cython_approach
make clean && make
./fortran_calls_cython
```

## Configuring for Different Environments

### Command-line Override
Override any variable when calling make:

```bash
# Use Python 3.11 instead of default python3
make PYTHON=python3.11

# Use specific compilers
make CC=gcc FC=gfortran

# Use custom Cython location
make CYTHON=/usr/local/bin/cython

# Combine multiple overrides
make PYTHON=python3.11 CC=gcc FC=gfortran FFLAGS="-O3 -march=native"
```

### Environment Variables
Set environment variables before building:

```bash
export PYTHON=python3.11
export CC=gcc
export FC=gfortran
make
```

## Configuration Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `PYTHON` | `python3` | Python interpreter (must have -config) |
| `CC` | `cc` | C compiler for Python/Cython code |
| `FC` | `gfortran` | Fortran compiler |
| `CYTHON` | `cython` | Cython compiler (cython_approach only) |
| `CFLAGS` | `-O2 -fPIC` | C compiler flags |
| `FFLAGS` | `-O2` | Fortran compiler flags |

## Platform-Specific Examples

### macOS (Homebrew)
```bash
# Default works fine, or specify versions:
make PYTHON=python3.14

# Use Homebrew gcc:
make FC=/opt/homebrew/bin/gfortran
```

### NERSC Perlmutter
```bash
# Load modules first
module load python/3.11
module load gcc/11.2.0

# Build with default Python from modules
make PYTHON=python3

# Or specify full path if needed
make PYTHON=/usr/common/software/python/3.11/bin/python3
```

### Generic Linux
```bash
# With system Python
make PYTHON=python3 CC=gcc FC=gfortran

# With conda environment
conda activate myenv
make PYTHON=$(which python3)
```

## Troubleshooting

### Python library not found at runtime
Set library path:
```bash
export LD_LIBRARY_PATH=$(python3-config --prefix)/lib:$LD_LIBRARY_PATH
./fortran_calls_cython
```

Or add rpath during build:
```bash
make CFLAGS="-O2 -fPIC -Wl,-rpath,$(python3-config --prefix)/lib"
```

### Wrong Python version used
Check what's detected:
```bash
make --dry-run | grep PYTHON
```

Explicitly specify:
```bash
make PYTHON=/path/to/specific/python3.11
```

### Cython not found (cython_approach)
Install for user:
```bash
pip install --user cython
make CYTHON=~/.local/bin/cython
```

Or use system package:
```bash
# Ubuntu/Debian
sudo apt install cython3
make CYTHON=cython3
```

## Clean Builds

```bash
make clean          # Remove build artifacts
make clean all      # Clean and rebuild
```
