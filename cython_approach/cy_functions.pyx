# cython: language_level=3
cimport numpy as cnp
from libc.string cimport strncpy

# Import Python C API for initialization
cdef extern from "Python.h":
    void Py_Initialize()
    void Py_Finalize()
    int Py_IsInitialized()

cdef void write_error(char *errbuf, int errbuf_len, const char *msg):
    if errbuf == NULL or errbuf_len <= 0:
        return
    if msg == NULL:
        errbuf[0] = 0
        return
    strncpy(errbuf, msg, errbuf_len - 1)
    errbuf[errbuf_len - 1] = 0

cdef public int cy_initialize():
    """Initialize Python interpreter"""
    if not Py_IsInitialized():
        Py_Initialize()
    # Import array must return an int for error checking
    if cnp.import_array() < 0:
        return -1
    return 0

cdef public int cy_finalize():
    """Finalize Python interpreter"""
    if Py_IsInitialized():
        Py_Finalize()
    return 0

cdef public int cy_sum_array(const double *arr, int n, double *result, char *errbuf, int errbuf_len):
    """Sum array elements using pure C loop"""
    cdef int i
    cdef double sum_val = 0.0
    
    if arr == NULL or result == NULL or n < 0:
        write_error(errbuf, errbuf_len, b"Invalid input arguments")
        return 1
    
    # Pure C computation - no Python objects
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
    
    # Pure C computation - no Python objects
    for i in range(n):
        result[i] = arr[i] * scalar
    
    write_error(errbuf, errbuf_len, b"")
    return 0
