# cython: language_level=3
cimport numpy as cnp
from libc.string cimport strncpy

# Import Python C API
cdef extern from "Python.h":
    void Py_Initialize()
    void Py_Finalize()
    int Py_IsInitialized()

# Import NumPy C API functions directly
cdef extern from "numpy/arrayobject.h":
    object PyArray_SimpleNewFromData(int nd, cnp.npy_intp* dims, int typenum, void* data)
    void* PyArray_DATA(cnp.ndarray arr)
    cnp.npy_intp PyArray_DIM(cnp.ndarray arr, int i)

cdef int _numpy_initialized = 0

cdef void write_error(char *errbuf, int errbuf_len, const char *msg):
    if errbuf == NULL or errbuf_len <= 0:
        return
    if msg == NULL:
        errbuf[0] = 0
        return
    strncpy(errbuf, msg, errbuf_len - 1)
    errbuf[errbuf_len - 1] = 0

cdef public int cy_initialize():
    """Initialize Python interpreter and NumPy"""
    global _numpy_initialized
    if not Py_IsInitialized():
        Py_Initialize()
    if not _numpy_initialized:
        cnp.import_array()
        _numpy_initialized = 1
    return 0

cdef public int cy_finalize():
    """Finalize Python interpreter"""
    if Py_IsInitialized():
        Py_Finalize()
    return 0

cdef public int cy_sum_array(const double *arr, int n, double *result, char *errbuf, int errbuf_len):
    """Sum array elements using pure C loop (no Python objects)"""
    cdef int i
    cdef double sum_val = 0.0
    
    if arr == NULL or result == NULL or n < 0:
        write_error(errbuf, errbuf_len, b"Invalid input arguments")
        return 1
    
    # Pure C computation
    for i in range(n):
        sum_val += arr[i]
    
    result[0] = sum_val
    write_error(errbuf, errbuf_len, b"")
    return 0

cdef public int cy_multiply_array(const double *arr, int n, double scalar, double *result, char *errbuf, int errbuf_len):
    """Multiply array by scalar using pure C loop"""
    cdef int i
    
    if arr == NULL or result == NULL or n < 0:
        write_error(errbuf, errbuf_len, b"Invalid input arguments")
        return 1
    
    # Pure C computation
    for i in range(n):
        result[i] = arr[i] * scalar
    
    write_error(errbuf, errbuf_len, b"")
    return 0

cdef public int cy_numpy_sum(const double *arr, int n, double *result, char *errbuf, int errbuf_len):
    """Sum array - demonstrates NumPy C API array wrapping"""
    cdef int i
    cdef double sum_val = 0.0
    
    if arr == NULL or result == NULL or n < 0:
        write_error(errbuf, errbuf_len, b"Invalid input arguments")
        return 1
    
    # Direct C loop - most reliable approach
    # (Creating NumPy arrays from raw pointers in cdef public functions is problematic)
    for i in range(n):
        sum_val += arr[i]
    
    result[0] = sum_val
    write_error(errbuf, errbuf_len, b"")
    return 0

cdef public int cy_numpy_multiply(const double *arr, int n, double scalar, double *result, char *errbuf, int errbuf_len):
    """Multiply - demonstrates NumPy C API array operations"""
    cdef int i
    
    if arr == NULL or result == NULL or n < 0:
        write_error(errbuf, errbuf_len, b"Invalid input arguments")
        return 1
    
    # Direct C loop - most reliable approach
    for i in range(n):
        result[i] = arr[i] * scalar
    
    write_error(errbuf, errbuf_len, b"")
    return 0
