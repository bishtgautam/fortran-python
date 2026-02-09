#include <stdio.h>
#include <Python.h>
#include "cy_functions_full.h"

int cy_bridge_init()
{
    printf("[C BRIDGE] cy_bridge_init: Starting Python initialization...\n");
    fflush(stdout);
    
    // Register the Cython module
    PyImport_AppendInittab("cy_functions_full", PyInit_cy_functions_full);
    
    // Initialize Python interpreter
    Py_Initialize();
    
    printf("[C BRIDGE] cy_bridge_init: Py_Initialize() done, importing module...\n");
    fflush(stdout);
    
    // Import the module to make it available
    PyObject* module = PyImport_ImportModule("cy_functions_full");
    if (module == NULL) {
        PyErr_Print();
        printf("[C BRIDGE ERROR] Failed to import cy_functions_full module\n");
        fflush(stdout);
        return -1;
    }
    
    printf("[C BRIDGE] cy_bridge_init: Module imported successfully\n");
    fflush(stdout);
    
    // Call the initialization function
    cy_initialize();
    
    printf("[C BRIDGE] cy_bridge_init: cy_initialize() returned\n");
    fflush(stdout);
    
    return 0;
}

void cy_bridge_finalize()
{
    printf("[C BRIDGE] cy_bridge_finalize: Calling cy_finalize()...\n");
    fflush(stdout);
    
    cy_finalize();
    
    printf("[C BRIDGE] cy_bridge_finalize: Done\n");
    fflush(stdout);
}

double cy_bridge_sum_array(double* arr, int n)
{
    printf("[C BRIDGE] cy_bridge_sum_array: n=%d\n", n);
    fflush(stdout);
    
    double result = cy_sum_array(arr, n);
    
    printf("[C BRIDGE] cy_bridge_sum_array: result=%f\n", result);
    fflush(stdout);
    
    return result;
}

void cy_bridge_multiply_array(double* arr, int n, double factor)
{
    printf("[C BRIDGE] cy_bridge_multiply_array: n=%d, factor=%f\n", n, factor);
    fflush(stdout);
    
    cy_multiply_array(arr, n, factor);
    
    printf("[C BRIDGE] cy_bridge_multiply_array: Done\n");
    fflush(stdout);
}

double cy_bridge_numpy_sum(double* arr, int n)
{
    printf("[C BRIDGE] cy_bridge_numpy_sum: n=%d\n", n);
    fflush(stdout);
    
    double result = cy_numpy_sum(arr, n);
    
    printf("[C BRIDGE] cy_bridge_numpy_sum: result=%f\n", result);
    fflush(stdout);
    
    return result;
}

void cy_bridge_numpy_multiply(double* arr, int n, double factor)
{
    printf("[C BRIDGE] cy_bridge_numpy_multiply: n=%d, factor=%f\n", n, factor);
    fflush(stdout);
    
    cy_numpy_multiply(arr, n, factor);
    
    printf("[C BRIDGE] cy_bridge_numpy_multiply: Done\n");
    fflush(stdout);
}
