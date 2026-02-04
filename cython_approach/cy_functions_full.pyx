# cython: language_level=3
import numpy as np
cimport numpy as cnp
from libc.string cimport strncpy

# Import Python C API
cdef extern from "Python.h":
    void Py_Initialize()
    void Py_Finalize()
    int Py_IsInitialized()

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
    """Sum array using NumPy (demonstrates calling Python from Cython)"""
    cdef double[:] memview
    
    if arr == NULL or result == NULL or n < 0:
        write_error(errbuf, errbuf_len, b"Invalid input arguments")
        return 1
    
    try:
        # Create NumPy array from memory view
        memview = <double[:n]>arr
        np_arr = np.asarray(memview)
        result[0] = np.sum(np_arr)
        write_error(errbuf, errbuf_len, b"")
        return 0
    except Exception as e:
        error_msg = str(e).encode('utf-8')
        write_error(errbuf, errbuf_len, error_msg)
        return 2

cdef public int cy_numpy_multiply(const double *arr, int n, double scalar, double *result, char *errbuf, int errbuf_len):
    """Multiply using NumPy (demonstrates calling Python from Cython)"""
    cdef double[:] memview_in
    cdef double[:] memview_out
    
    if arr == NULL or result == NULL or n < 0:
        write_error(errbuf, errbuf_len, b"Invalid input arguments")
        return 1
    
    try:
        # Create NumPy arrays from memory views
        memview_in = <double[:n]>arr
        memview_out = <double[:n]>result
        
        np_arr = np.asarray(memview_in)
        np_result = np.asarray(memview_out)
        
        # NumPy operation
        np_result[:] = np_arr * scalar
        write_error(errbuf, errbuf_len, b"")
        return 0
    except Exception as e:
        error_msg = str(e).encode('utf-8')
        write_error(errbuf, errbuf_len, error_msg)
        return 2
