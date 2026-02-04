#include "c_shim.h"

#include <Python.h>
#include <stdio.h>
#include <string.h>

static void write_error(char *errbuf, int errbuf_len, const char *msg) {
    if (!errbuf || errbuf_len <= 0) {
        return;
    }
    if (!msg) {
        errbuf[0] = '\0';
        return;
    }
    strncpy(errbuf, msg, (size_t)(errbuf_len - 1));
    errbuf[errbuf_len - 1] = '\0';
}

static void write_python_exception(char *errbuf, int errbuf_len) {
    if (!errbuf || errbuf_len <= 0) {
        return;
    }
    PyObject *ptype = NULL;
    PyObject *pvalue = NULL;
    PyObject *ptraceback = NULL;

    PyErr_Fetch(&ptype, &pvalue, &ptraceback);
    PyErr_NormalizeException(&ptype, &pvalue, &ptraceback);

    PyObject *py_str = NULL;
    if (pvalue) {
        py_str = PyObject_Str(pvalue);
    } else if (ptype) {
        py_str = PyObject_Str(ptype);
    }

    if (py_str) {
        const char *msg = PyUnicode_AsUTF8(py_str);
        write_error(errbuf, errbuf_len, msg ? msg : "Unknown Python error");
        Py_DECREF(py_str);
    } else {
        write_error(errbuf, errbuf_len, "Unknown Python error");
    }

    Py_XDECREF(ptype);
    Py_XDECREF(pvalue);
    Py_XDECREF(ptraceback);
}

int pyshim_initialize(void) {
    if (!Py_IsInitialized()) {
        Py_Initialize();
        if (!Py_IsInitialized()) {
            return 1;
        }
        PyObject *sys_path = PySys_GetObject("path");
        if (sys_path) {
            PyObject *cwd = PyUnicode_FromString("");
            if (cwd) {
                PyList_Insert(sys_path, 0, cwd);
                Py_DECREF(cwd);
            }
        }
    }
    return 0;
}

int pyshim_finalize(void) {
    if (Py_IsInitialized()) {
        Py_Finalize();
    }
    return 0;
}

int pyshim_call_sum(const double *arr, int n, double *result, char *errbuf, int errbuf_len) {
    if (!arr || !result || n < 0) {
        write_error(errbuf, errbuf_len, "Invalid input arguments");
        return 2;
    }

    if (!Py_IsInitialized()) {
        write_error(errbuf, errbuf_len, "Python not initialized");
        return 3;
    }

    PyObject *pName = PyUnicode_FromString("py_module");
    if (!pName) {
        write_python_exception(errbuf, errbuf_len);
        return 4;
    }

    PyObject *pModule = PyImport_Import(pName);
    Py_DECREF(pName);
    if (!pModule) {
        write_python_exception(errbuf, errbuf_len);
        return 5;
    }

    PyObject *pFunc = PyObject_GetAttrString(pModule, "sum_array");
    if (!pFunc || !PyCallable_Check(pFunc)) {
        Py_XDECREF(pFunc);
        Py_DECREF(pModule);
        write_error(errbuf, errbuf_len, "Function sum_array not found or not callable");
        return 6;
    }

    PyObject *pList = PyList_New(n);
    if (!pList) {
        Py_DECREF(pFunc);
        Py_DECREF(pModule);
        write_python_exception(errbuf, errbuf_len);
        return 7;
    }

    for (int i = 0; i < n; ++i) {
        PyObject *pVal = PyFloat_FromDouble(arr[i]);
        if (!pVal) {
            Py_DECREF(pList);
            Py_DECREF(pFunc);
            Py_DECREF(pModule);
            write_python_exception(errbuf, errbuf_len);
            return 8;
        }
        PyList_SET_ITEM(pList, i, pVal);
    }

    PyObject *pArgs = PyTuple_New(1);
    if (!pArgs) {
        Py_DECREF(pList);
        Py_DECREF(pFunc);
        Py_DECREF(pModule);
        write_python_exception(errbuf, errbuf_len);
        return 9;
    }
    PyTuple_SET_ITEM(pArgs, 0, pList);

    PyObject *pRet = PyObject_CallObject(pFunc, pArgs);
    Py_DECREF(pArgs);
    Py_DECREF(pFunc);
    Py_DECREF(pModule);

    if (!pRet) {
        write_python_exception(errbuf, errbuf_len);
        return 10;
    }

    if (!PyFloat_Check(pRet) && !PyLong_Check(pRet)) {
        Py_DECREF(pRet);
        write_error(errbuf, errbuf_len, "Return value is not a number");
        return 11;
    }

    *result = PyFloat_AsDouble(pRet);
    Py_DECREF(pRet);

    write_error(errbuf, errbuf_len, "");
    return 0;
}
