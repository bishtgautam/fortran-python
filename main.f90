program fortran_calls_python
  use, intrinsic :: iso_c_binding, only: c_int, c_double, c_char, c_null_char
  implicit none

  interface
    integer(c_int) function pyshim_initialize() bind(C, name="pyshim_initialize")
      use, intrinsic :: iso_c_binding, only: c_int
    end function pyshim_initialize

    integer(c_int) function pyshim_finalize() bind(C, name="pyshim_finalize")
      use, intrinsic :: iso_c_binding, only: c_int
    end function pyshim_finalize

    integer(c_int) function pyshim_call_sum(arr, n, result, errbuf, errbuf_len) bind(C, name="pyshim_call_sum")
      use, intrinsic :: iso_c_binding, only: c_int, c_double, c_char
      real(c_double), intent(in) :: arr(*)
      integer(c_int), value :: n
      real(c_double), intent(out) :: result
      character(kind=c_char), intent(out) :: errbuf(*)
      integer(c_int), value :: errbuf_len
    end function pyshim_call_sum
  end interface

  integer(c_int) :: status
  real(c_double), dimension(5) :: arr
  real(c_double) :: result
  character(kind=c_char), dimension(256) :: errbuf
  integer :: i

  arr = (/ 1.0_c_double, 2.0_c_double, 3.0_c_double, 4.0_c_double, 5.0_c_double /)

  status = pyshim_initialize()
  if (status /= 0_c_int) then
     print *, "Failed to initialize Python"
     stop 1
  end if

  status = pyshim_call_sum(arr, size(arr), result, errbuf, size(errbuf))
  if (status /= 0_c_int) then
     print *, "Python call failed, status=", status
     print *, "Error:", trim(to_fortran_string(errbuf))
      status = pyshim_finalize()
     stop 2
  end if

  print *, "Sum from Python:", result

  status = pyshim_finalize()
  if (status /= 0_c_int) then
     print *, "Failed to finalize Python"
  end if

contains

  function to_fortran_string(cstr) result(fstr)
    character(kind=c_char), intent(in) :: cstr(*)
    character(len=:), allocatable :: fstr
    integer :: n
    integer :: i

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

end program fortran_calls_python
