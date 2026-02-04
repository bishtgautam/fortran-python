# =============================================================================
# Configurable variables - override on command line or via environment
# Examples:
#   make PYTHON=python3.11 CC=gcc FC=gfortran
#   make FFLAGS="-O3 -march=native" CFLAGS="-O3 -march=native"
# =============================================================================

# Compilers
CC ?= cc
FC ?= gfortran

# Python
PYTHON ?= python3

# Compiler flags
CFLAGS ?= -O2 -fPIC
FFLAGS ?= -O2

# Target
TARGET = fortran_calls_python

# =============================================================================
# Auto-detected paths (do not override unless necessary)
# =============================================================================
PY_CFLAGS := $(shell $(PYTHON)-config --cflags)
PY_LDFLAGS := $(shell $(PYTHON)-config --embed --ldflags 2>/dev/null || $(PYTHON)-config --ldflags)
NUMPY_INCLUDE := $(shell $(PYTHON) -c "import numpy; print(numpy.get_include())")

all: $(TARGET)

c_shim.o: c_shim.c c_shim.h
	$(CC) $(CFLAGS) $(PY_CFLAGS) -I$(NUMPY_INCLUDE) -c c_shim.c -o c_shim.o

main.o: main.f90
	$(FC) $(FFLAGS) -c main.f90 -o main.o

$(TARGET): c_shim.o main.o
	$(FC) main.o c_shim.o $(PY_LDFLAGS) -o $(TARGET)

clean:
	rm -f *.o $(TARGET)
