# cython: language_level=3

import numpy as np
cimport numpy as cnp
from libc.stdio cimport printf
import sys

# Make NumPy arrays available
cnp.import_array()

cdef public int cy_initialize():
    """Initialize function - NumPy already imported at module level"""
    printf("[CYTHON] cy_initialize called\n")
    sys.stdout.flush()
    
    try:
        # Test NumPy is working
        test_arr = np.array([1.0, 2.0, 3.0])
        printf("[CYTHON] NumPy test array created successfully\n")
        sys.stdout.flush()
    except Exception as e:
        printf("[CYTHON ERROR] Failed to create NumPy array: %s\n", str(e).encode('utf-8'))
        sys.stdout.flush()
        return 1
    
    return 0

cdef public int cy_finalize():
    """Finalize function"""
    printf("[CYTHON] cy_finalize called\n")
    sys.stdout.flush()
    return 0

cdef public double cy_sum_array(double *arr, int n):
    """Sum array using NumPy operations"""
    cdef cnp.ndarray[cnp.float64_t, ndim=1] np_arr
    cdef double result
    
    printf("[CYTHON] cy_sum_array: n=%d\n", n)
    sys.stdout.flush()
    
    try:
        # Create NumPy array view of the C array
        np_arr = np.asarray(<cnp.float64_t[:n]>arr)
        
        printf("[CYTHON] cy_sum_array: NumPy array created\n")
        sys.stdout.flush()
        
        # Use NumPy sum
        result = np.sum(np_arr)
        
        printf("[CYTHON] cy_sum_array: result=%f\n", result)
        sys.stdout.flush()
        
        return result
        
    except Exception as e:
        printf("[CYTHON ERROR] cy_sum_array failed: %s\n", str(e).encode('utf-8'))
        sys.stdout.flush()
        return 0.0

cdef public void cy_multiply_array(double *arr, int n, double scalar):
    """Multiply array by scalar using NumPy operations"""
    cdef cnp.ndarray[cnp.float64_t, ndim=1] np_arr
    
    printf("[CYTHON] cy_multiply_array: n=%d, scalar=%f\n", n, scalar)
    sys.stdout.flush()
    
    try:
        # Create NumPy array view of the C array
        np_arr = np.asarray(<cnp.float64_t[:n]>arr)
        
        printf("[CYTHON] cy_multiply_array: NumPy array created\n")
        sys.stdout.flush()
        
        # Use NumPy multiplication
        np_arr[:] = np_arr * scalar
        
        printf("[CYTHON] cy_multiply_array: Done\n")
        sys.stdout.flush()
        
    except Exception as e:
        printf("[CYTHON ERROR] cy_multiply_array failed: %s\n", str(e).encode('utf-8'))
        sys.stdout.flush()
