CC ?= cc
FC ?= gfortran
PYTHON ?= python3

PY_CFLAGS := $(shell $(PYTHON)-config --cflags)
PY_LDFLAGS := $(shell $(PYTHON)-config --embed --ldflags 2>/dev/null || $(PYTHON)-config --ldflags)
NUMPY_INCLUDE := $(shell $(PYTHON) -c "import numpy; print(numpy.get_include())")

CFLAGS ?= -O2 -fPIC
FFLAGS ?= -O2

TARGET = fortran_calls_python

all: $(TARGET)

c_shim.o: c_shim.c c_shim.h
	$(CC) $(CFLAGS) $(PY_CFLAGS) -I$(NUMPY_INCLUDE) -c c_shim.c -o c_shim.o

main.o: main.f90
	$(FC) $(FFLAGS) -c main.f90 -o main.o

$(TARGET): c_shim.o main.o
	$(FC) main.o c_shim.o $(PY_LDFLAGS) -o $(TARGET)

clean:
	rm -f *.o $(TARGET)
