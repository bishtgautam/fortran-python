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

  ! Main program - orchestrates initialization, run, and cleanup
  call model_initialize()
  call model_run()
  call model_cleanup()

contains

  subroutine model_initialize()
    ! Initialize Python and model state
    integer(c_int) :: status
    
    print *, "=== Model Initialization ==="
    status = cy_initialize()
    if (status /= 0_c_int) then
       print *, "ERROR: Failed to initialize Python"
       stop 1
    end if
    print *, "Python initialized successfully"
    print *, ""
  end subroutine model_initialize

  subroutine model_run()
    ! Run model timestepping loop
    integer :: step
    integer(c_int) :: status
    real(c_double), dimension(5) :: state_vector, updated_state
    real(c_double) :: diagnostic
    character(kind=c_char), dimension(256) :: errbuf
    real(c_double) :: dt = 0.1_c_double
    
    print *, "=== Model Run (10 timesteps) ==="
    
    ! Initial state
    state_vector = (/ 1.0_c_double, 2.0_c_double, 3.0_c_double, 4.0_c_double, 5.0_c_double /)
    print *, "Initial state:", state_vector
    print *, ""
    
    ! Timestepping loop
    do step = 1, 10
       print *, "Timestep", step, ":"
       
       ! Compute diagnostic (e.g., total energy/mass)
       status = cy_sum_array(state_vector, size(state_vector), diagnostic, errbuf, size(errbuf))
       if (status /= 0_c_int) then
          print *, "  ERROR: Diagnostic computation failed"
          print *, "  Error:", trim(to_fortran_string(errbuf))
          return
       end if
       print *, "  Diagnostic (sum):", diagnostic
       
       ! Update state using Python function (e.g., apply forcing/decay)
       status = cy_multiply_array(state_vector, size(state_vector), 1.0_c_double + dt, &
                                   updated_state, errbuf, size(errbuf))
       if (status /= 0_c_int) then
          print *, "  ERROR: State update failed"
          print *, "  Error:", trim(to_fortran_string(errbuf))
          return
       end if
       
       ! Update state vector
       state_vector = updated_state
       print *, "  Updated state:", state_vector(1:3), "..."
       print *, ""
    end do
    
    print *, "Final state:", state_vector
    print *, ""
  end subroutine model_run

  subroutine model_cleanup()
    ! Finalize Python and clean up
    integer(c_int) :: status
    
    print *, "=== Model Cleanup ==="
    status = cy_finalize()
    if (status /= 0_c_int) then
       print *, "WARNING: Failed to finalize Python"
    else
       print *, "Python finalized successfully"
    end if
  end subroutine model_cleanup

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
