program test_cython_numpy
  use, intrinsic :: iso_c_binding, only: c_int, c_double, c_char, c_null_char
  implicit none

  interface
    integer(c_int) function cy_bridge_init() bind(C, name="cy_bridge_init")
      use, intrinsic :: iso_c_binding, only: c_int
    end function cy_bridge_init

    subroutine cy_bridge_finalize() bind(C, name="cy_bridge_finalize")
    end subroutine cy_bridge_finalize

    real(c_double) function cy_bridge_sum_array(arr, n) bind(C, name="cy_bridge_sum_array")
      use, intrinsic :: iso_c_binding, only: c_int, c_double
      real(c_double), intent(in) :: arr(*)
      integer(c_int), value :: n
    end function cy_bridge_sum_array

    real(c_double) function cy_bridge_numpy_sum(arr, n) bind(C, name="cy_bridge_numpy_sum")
      use, intrinsic :: iso_c_binding, only: c_int, c_double
      real(c_double), intent(in) :: arr(*)
      integer(c_int), value :: n
    end function cy_bridge_numpy_sum

    subroutine cy_bridge_numpy_multiply(arr, n, scalar) bind(C, name="cy_bridge_numpy_multiply")
      use, intrinsic :: iso_c_binding, only: c_int, c_double
      real(c_double), intent(inout) :: arr(*)
      integer(c_int), value :: n
      real(c_double), value :: scalar
    end subroutine cy_bridge_numpy_multiply
  end interface

  integer(c_int) :: status
  real(c_double), dimension(5) :: arr
  real(c_double) :: result

  arr = (/ 1.0_c_double, 2.0_c_double, 3.0_c_double, 4.0_c_double, 5.0_c_double /)

  ! Initialize Python
  status = cy_bridge_init()
  if (status /= 0_c_int) then
     print *, "Failed to initialize Python"
     stop 1
  end if

  ! Test pure C sum
  result = cy_bridge_sum_array(arr, size(arr))
  print *, "Sum (pure C):", result

  ! Test NumPy sum
  result = cy_bridge_numpy_sum(arr, size(arr))
  print *, "Sum (NumPy):", result

  ! Test NumPy multiply
  print *, ""
  print *, "Testing NumPy multiplication (arr * 2.5)..."
  call cy_bridge_numpy_multiply(arr, size(arr), 2.5_c_double)
  print *, "Result (NumPy):", arr

  ! Finalize Python
  call cy_bridge_finalize()

end program test_cython_numpy
