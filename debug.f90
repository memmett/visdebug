module debug_module
  use multifab_module
  use iso_c_binding, only: c_ptr, c_int, c_null_ptr, c_double
  implicit none

  logical, save :: debug = .false.
  type(c_ptr), save :: default_zmq_context = c_null_ptr

  interface
     type(c_ptr) function dzmq_connect() bind(c)
       import :: c_ptr
     end function dzmq_connect

     subroutine dzmq_send(ptr, q, nx) bind(c)
       import :: c_ptr, c_int, c_double
       type(c_ptr), intent(in), value :: ptr
       integer(c_int), intent(in), value :: nx
       real(c_double), intent(in) :: q(nx)
     end subroutine dzmq_send

     subroutine dzmq_send_size(ptr, nx, ny) bind(c)
       import :: c_ptr, c_int
       type(c_ptr), intent(in), value :: ptr
       integer(c_int), intent(in), value :: nx, ny
     end subroutine dzmq_send_size

     subroutine dzmq_close(ptr) bind(c)
       import :: c_ptr
       type(c_ptr), intent(in), value :: ptr
     end subroutine dzmq_close

  end interface

contains

  subroutine dsend(q, box, comp, wait)
    type(multifab), intent(in) :: q
    integer,        intent(in) :: box, comp
    logical,        intent(in) :: wait

    integer :: volume, lo(2), hi(2)
    double precision, pointer, dimension(:,:,:,:) :: qp

    if (get_dim(q) /= 2) then
       stop "ERROR: dsend: Only 2d multifabs are supported."
    end if

    qp => dataptr(q,box)

    lo = lwb(get_pbox(q,box))
    hi = upb(get_pbox(q,box))

    volume = (hi(1) - lo(1) + 1) * (hi(2) - lo(2) + 1)

    call dzmq_send_size(default_zmq_context, hi(1)-lo(1)+1, hi(2)-lo(2)+1)
    call dzmq_send(default_zmq_context, &
         pack(qp(lo(1):hi(1),lo(2):hi(2),1,comp), .true.), volume)

    if (wait) then
       write (*,*) '==> paused:', lo, hi
       read  (*,*)
    end if
  end subroutine dsend

end module debug_module
