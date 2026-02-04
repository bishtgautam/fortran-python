program test_cython_numpy
  use, intrinsic :: iso_c_binding, only: c_int, c_double, c_char, c_null_char
  implicit none

  interface
    integer(c_int) function cy_initialize() bind(C, name="cy_initialize")
      use, intrinsic :: iso_c_binding, only: c_int
    end function cy_initialize

    integer(c_int) function cy_finalize() bind(C, name="cy_finalize")
      use, intrinsic :: iso_c_binding, only: c_int
    end function cy_finalize

    integer(c_int) function cy_sum_array(arr, n, result, errbuf, errbuf_len) bind(C, name="cy_sum_array")
      use, intrinsic :: iso_c_binding, only: c_int, c_double, c_char
      real(c_double), intent(in) :: arr(*)
      integer(c_int), value :: n
      real(c_double), intent(out) :: result
      character(kind=c_char), intent(out) :: errbuf(*)
      integer(c_int), value :: errbuf_len
    end function cy_sum_array

    integer(c_int) function cy_numpy_sum(arr, n, result, errbuf, errbuf_len) bind(C, name="cy_numpy_sum")
      use, intrinsic :: iso_c_binding, only: c_int, c_double, c_char
      real(c_double), intent(in) :: arr(*)
      integer(c_int), value :: n
      real(c_double), intent(out) :: result
      character(kind=c_char), intent(out) :: errbuf(*)
      integer(c_int), value :: errbuf_len
    end function cy_numpy_sum

    integer(c_int) function cy_numpy_multiply(arr, n, scalar, result, errbuf, errbuf_len) bind(C, name="cy_numpy_multiply")
      use, intrinsic :: iso_c_binding, only: c_int, c_double, c_char
      real(c_double), intent(in) :: arr(*)
      integer(c_int), value :: n
      real(c_double), value :: scalar
      real(c_double), intent(out) :: result(*)
      character(kind=c_char), intent(out) :: errbuf(*)
      integer(c_int), value :: errbuf_len
    end function cy_numpy_multiply
  end interface

  integer(c_int) :: status
  real(c_double), dimension(5) :: arr, result_arr
  real(c_double) :: result
  character(kind=c_char), dimension(256) :: errbuf

  arr = (/ 1.0_c_double, 2.0_c_double, 3.0_c_double, 4.0_c_double, 5.0_c_double /)

  ! Initialize Python
  status = cy_initialize()
  if (status /= 0_c_int) then
     print *, "Failed to initialize Python"
     stop 1
  end if

  ! Test pure C sum
  status = cy_sum_array(arr, size(arr), result, errbuf, size(errbuf))
  if (status /= 0_c_int) then
     print *, "Pure C sum failed"
     status = cy_finalize()
     stop 2
  end if
  print *, "Sum (pure C):", result

  ! Test NumPy sum
  status = cy_numpy_sum(arr, size(arr), result, errbuf, size(errbuf))
  if (status /= 0_c_int) then
     print *, "NumPy sum failed, error:", trim(to_fortran_string(errbuf))
     status = cy_finalize()
     stop 3
  end if
  print *, "Sum (NumPy):", result

  ! Test NumPy multiply
  print *, ""
  print *, "Testing NumPy multiplication (arr * 2.5)..."
  status = cy_numpy_multiply(arr, size(arr), 2.5_c_double, result_arr, errbuf, size(errbuf))
  if (status /= 0_c_int) then
     print *, "NumPy multiply failed, error:", trim(to_fortran_string(errbuf))
     status = cy_finalize()
     stop 4
  end if
  print *, "Result (NumPy):", result_arr

  ! Finalize Python
  status = cy_finalize()

contains

  function to_fortran_string(cstr) result(fstr)
    character(kind=c_char), intent(in) :: cstr(*)
    character(len=:), allocatable :: fstr
    integer :: n, i

    n = 0
    do while (cstr(n+1) /= c_null_char)
       n = n + 1
       if (n >= 1000000) exit
    end do

    if (n > 0) then
       allocate(character(len=n) :: fstr)
       fstr = ""
       do i = 1, n
          fstr(i:i) = cstr(i)
       end do
    else
       fstr = ""
    end if
  end function to_fortran_string

end program test_cython_numpy
