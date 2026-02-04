program fortran_calls_cython
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

    integer(c_int) function cy_multiply_array(arr, n, scalar, result, errbuf, errbuf_len) bind(C, name="cy_multiply_array")
      use, intrinsic :: iso_c_binding, only: c_int, c_double, c_char
      real(c_double), intent(in) :: arr(*)
      integer(c_int), value :: n
      real(c_double), value :: scalar
      real(c_double), intent(out) :: result(*)
      character(kind=c_char), intent(out) :: errbuf(*)
      integer(c_int), value :: errbuf_len
    end function cy_multiply_array
  end interface

  integer(c_int) :: status
  real(c_double), dimension(5) :: arr, result_arr
  real(c_double) :: result
  character(kind=c_char), dimension(256) :: errbuf
  integer :: i

  arr = (/ 1.0_c_double, 2.0_c_double, 3.0_c_double, 4.0_c_double, 5.0_c_double /)

  ! Initialize Python
  status = cy_initialize()
  if (status /= 0_c_int) then
     print *, "Failed to initialize Python"
     stop 1
  end if

  ! Test sum
  status = cy_sum_array(arr, size(arr), result, errbuf, size(errbuf))
  if (status /= 0_c_int) then
     print *, "Cython sum failed, status=", status
     print *, "Error:", trim(to_fortran_string(errbuf))
     status = cy_finalize()
     stop 2
  end if
  print *, "Sum from Cython:", result

  ! Test NumPy array multiplication
  print *, ""
  print *, "Testing Cython array multiplication (arr * 2.5)..."
  status = cy_multiply_array(arr, size(arr), 2.5_c_double, result_arr, errbuf, size(errbuf))
  if (status /= 0_c_int) then
     print *, "Cython multiply failed, status=", status
     print *, "Error:", trim(to_fortran_string(errbuf))
     status = cy_finalize()
     stop 3
  end if
  print *, "Result from Cython:", result_arr

  ! Finalize Python
  status = cy_finalize()
  if (status /= 0_c_int) then
     print *, "Failed to finalize Python"
  end if

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

end program fortran_calls_cython
