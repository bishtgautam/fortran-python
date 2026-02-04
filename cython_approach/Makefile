FC ?= gfortran
PYTHON ?= python3.14
CYTHON ?= /opt/homebrew/opt/cython/bin/cython

FFLAGS ?= -O2
CFLAGS ?= -O2 -fPIC
TARGET = fortran_calls_cython

# Get Python and NumPy paths
PY_CFLAGS := $(shell $(PYTHON)-config --cflags)
PY_LDFLAGS := $(shell $(PYTHON)-config --embed --ldflags 2>/dev/null || $(PYTHON)-config --ldflags)
NUMPY_INCLUDE := $(shell $(PYTHON) -c "import numpy; print(numpy.get_include())")

.PHONY: all clean

all: $(TARGET)

cy_functions.c: cy_functions.pyx
	$(CYTHON) -3 cy_functions.pyx -o cy_functions.c

cy_functions.o: cy_functions.c
	$(CC) $(CFLAGS) $(PY_CFLAGS) -I$(NUMPY_INCLUDE) -c cy_functions.c -o cy_functions.o

cy_functions.so: cy_functions.o
	$(CC) -shared cy_functions.o $(PY_LDFLAGS) -o cy_functions.so

main.o: main.f90
	$(FC) $(FFLAGS) -c main.f90 -o main.o

$(TARGET): cy_functions.so main.o
	$(FC) main.o cy_functions.so $(PY_LDFLAGS) -o $(TARGET)

clean:
	rm -f *.o *.so $(TARGET) cy_functions.c
