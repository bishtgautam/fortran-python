program fortran_calls_cython
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

    subroutine cy_bridge_multiply_array(arr, n, scalar) bind(C, name="cy_bridge_multiply_array")
      use, intrinsic :: iso_c_binding, only: c_int, c_double
      real(c_double), intent(inout) :: arr(*)
      integer(c_int), value :: n
      real(c_double), value :: scalar
    end subroutine cy_bridge_multiply_array
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
    status = cy_bridge_init()
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
    real(c_double), dimension(5) :: state_vector
    real(c_double) :: diagnostic
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
       diagnostic = cy_bridge_sum_array(state_vector, size(state_vector))
       print *, "  Diagnostic (sum):", diagnostic
       
       ! Update state using Python function (e.g., apply forcing/decay)
       call cy_bridge_multiply_array(state_vector, size(state_vector), 1.0_c_double + dt)
       
       print *, "  Updated state:", state_vector(1:3), "..."
       print *, ""
    end do
    
    print *, "Final state:", state_vector
    print *, ""
  end subroutine model_run

  subroutine model_cleanup()
    ! Finalize Python and clean up
    
    print *, "=== Model Cleanup ==="
    call cy_bridge_finalize()
    print *, "Python finalized successfully"
  end subroutine model_cleanup

end program fortran_calls_cython
