# =============================================================================
# Configurable variables - override on command line or via environment
# Examples:
#   make PYTHON=python3.11 CC=gcc FC=gfortran
#   make CYTHON=cython FFLAGS="-O3 -march=native"
# =============================================================================

# Compilers
CC ?= cc
FC ?= gfortran

# Python and Cython
PYTHON ?= python3
CYTHON ?= cython

# Compiler flags
FFLAGS ?= -O2
CFLAGS ?= -O2 -fPIC

# Targets
TARGET = fortran_calls_cython

# =============================================================================
# Auto-detected paths (do not override unless necessary)
# =============================================================================
PY_CFLAGS := $(shell $(PYTHON)-config --cflags)
PY_LDFLAGS := $(shell $(PYTHON)-config --embed --ldflags 2>/dev/null || $(PYTHON)-config --ldflags)
NUMPY_INCLUDE := $(shell $(PYTHON) -c "import numpy; print(numpy.get_include())")

.PHONY: all clean

all: $(TARGET)

# Cython to C compilation
cy_functions_full.c: cy_functions_full.pyx
	$(CYTHON) -3 cy_functions_full.pyx -o cy_functions_full.c

# Compile Cython-generated C to object file
cy_functions_full.o: cy_functions_full.c
	$(CC) $(CFLAGS) $(PY_CFLAGS) -I$(NUMPY_INCLUDE) -c cy_functions_full.c -o cy_functions_full.o

# Create Cython shared library
cy_functions_full.so: cy_functions_full.o
	$(CC) -shared cy_functions_full.o $(PY_LDFLAGS) -o cy_functions_full.so

# Compile C bridge
cy_bridge.o: cy_bridge.c cy_functions_full.h
	$(CC) $(CFLAGS) $(PY_CFLAGS) -I$(NUMPY_INCLUDE) -c cy_bridge.c -o cy_bridge.o

# Compile Fortran program
main.o: main.f90
	$(FC) $(FFLAGS) -c main.f90 -o main.o

# Link executable (with C bridge)
$(TARGET): cy_functions_full.so cy_bridge.o main.o
	$(FC) main.o cy_bridge.o cy_functions_full.so $(PY_LDFLAGS) -Wl,-rpath,'$$ORIGIN' -o $(TARGET)

clean:
	rm -f *.o *.so $(TARGET) cy_functions_full.c cy_functions_full.h
