#ifndef PY_SHIM_H
#define PY_SHIM_H

#ifdef __cplusplus
extern "C" {
#endif

int pyshim_initialize(void);
int pyshim_finalize(void);
int pyshim_call_sum(const double *arr, int n, double *result, char *errbuf, int errbuf_len);
int pyshim_call_numpy_multiply(const double *arr, int n, double scalar, double *result, char *errbuf, int errbuf_len);

#ifdef __cplusplus
}
#endif

#endif
