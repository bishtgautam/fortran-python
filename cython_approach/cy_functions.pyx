# cython: language_level=3
import numpy as np
cimport numpy as cnp
from libc.string cimport strncpy

# Import Python C API for initialization
cdef extern from "Python.h":
    void Py_Initialize()
    void Py_Finalize()
    int Py_IsInitialized()
    object PyImport_ImportModule(const char *name)

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
    if not Py_IsInitialized():
        Py_Initialize()
    # Import numpy to ensure NumPy C API is initialized
    PyImport_ImportModule("numpy")
    cnp.import_array()
    return 0

cdef public int cy_finalize():
    """Finalize Python interpreter"""
    if Py_IsInitialized():
        Py_Finalize()
    return 0

cdef public int cy_sum_array(const double *arr, int n, double *result, char *errbuf, int errbuf_len):
    """Sum array elements"""
    cdef cnp.ndarray[double, ndim=1] np_arr
    
    if arr == NULL or result == NULL or n < 0:
        write_error(errbuf, errbuf_len, b"Invalid input arguments")
        return 1
    
    try:
        # Wrap C array in NumPy array (no copy)
        np_arr = np.asarray(<double[:n]>arr)
        result[0] = np.sum(np_arr)
        write_error(errbuf, errbuf_len, b"")
        return 0
    except Exception as e:
        error_msg = str(e).encode('utf-8')
        write_error(errbuf, errbuf_len, error_msg)
        return 2

cdef public int cy_multiply_array(const double *arr, int n, double scalar, double *result, char *errbuf, int errbuf_len):
    """Multiply array by scalar"""
    cdef cnp.ndarray[double, ndim=1] np_arr
    cdef cnp.ndarray[double, ndim=1] np_result
    
    if arr == NULL or result == NULL or n < 0:
        write_error(errbuf, errbuf_len, b"Invalid input arguments")
        return 1
    
    try:
        # Wrap C arrays in NumPy arrays (no copy)
        np_arr = np.asarray(<double[:n]>arr)
        np_result = np.asarray(<double[:n]>result)
        
        # Perform computation
        np_result[:] = np_arr * scalar
        write_error(errbuf, errbuf_len, b"")
        return 0
    except Exception as e:
        error_msg = str(e).encode('utf-8')
        write_error(errbuf, errbuf_len, error_msg)
        return 2
