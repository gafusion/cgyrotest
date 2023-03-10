subroutine cgyro_check_memory(datafile)

  use cgyro_globals

  implicit none

  character (len=*), intent(in) :: datafile
  integer :: mult
  
  if (i_proc == 0) then

     open(unit=io,file=datafile,status='replace')

     total_memory = 0
     write(io,*) ' == Non-Distributed =='

     write(io,*)
     write(io,*) 'Pointers'
     write(io,*)    
     call cgyro_alloc_add(io,nv*4.0,'ie_v')
     call cgyro_alloc_add(io,nv*4.0,'ix_v')
     call cgyro_alloc_add(io,nc*4.0,'ir_c')
     call cgyro_alloc_add(io,nc*4.0,'it_c')
     call cgyro_alloc_add(io,n_radial*n_theta*4.0,'ic_c')
     call cgyro_alloc_add(io,n_energy*n_xi*n_species*4.0,'iv_v')
     call cgyro_alloc_add(io,nc*(2*nup_theta+1)*4.0,'icd_c')
     call cgyro_alloc_add(io,nc*(2*nup_theta+1)*16.0,'dtheta')
     call cgyro_alloc_add(io,nc*(2*nup_theta+1)*16.0,'dtheta_up')

     write(io,*)
     write(io,*) 'Fields and field solve'
     write(io,*)
     call cgyro_alloc_add(io,n_field*nc*16.0,'field')
     call cgyro_alloc_add(io,n_field*nc*16.0,'field_dot')
     call cgyro_alloc_add(io,n_field*nc*16.0,'field_loc')
     call cgyro_alloc_add(io,n_field*nc*16.0,'field_old')
     call cgyro_alloc_add(io,n_field*nc*16.0,'field_old2')
     call cgyro_alloc_add(io,n_field*nc*16.0,'field_old3')
     call cgyro_alloc_add(io,n_field*nc*8.0,'fcoef')
     if (n_field < 3) then
        call cgyro_alloc_add(io,n_field*nc*8.0,'gcoef')
     else
        call cgyro_alloc_add(io,5*nc*8.0,'gcoef')
     endif
     call cgyro_alloc_add(io,nc*8.0,'sum_den_x')
     call cgyro_alloc_add(io,nc*8.0,'sum_cur_x')

     if (nonlinear_flag == 1) then
        write(io,*)
        write(io,*) 'Nonlinear'
        write(io,*)
        ! nsplit * n_toroidal = nv_loc * n_theta
        if (nonlinear_method /= 1) then
           nx0 = n_radial
           ny0 = 2*n_toroidal-1
           nx = (3*nx0)/2
           ny = (3*ny0)/2
#ifndef _OPENACC
           call cgyro_alloc_add(io,(ny/2+1)*nx*16.0*n_omp,'fx')
           call cgyro_alloc_add(io,(ny/2+1)*nx*16.0*n_omp,'gx')
           call cgyro_alloc_add(io,(ny/2+1)*nx*16.0*n_omp,'fy')
           call cgyro_alloc_add(io,(ny/2+1)*nx*16.0*n_omp,'gy')
           call cgyro_alloc_add(io,ny*nx*8.0*nsplit,'ux')
           call cgyro_alloc_add(io,ny*nx*8.0*n_omp,'vx')
           call cgyro_alloc_add(io,ny*nx*8.0*nsplit,'uy')
           call cgyro_alloc_add(io,ny*nx*8.0*n_omp,'vy')
           call cgyro_alloc_add(io,ny*nx*8.0*n_omp,'uv')
#else
           call cgyro_alloc_add(io,(ny/2+1)*nx*16.0*nsplit,'fx')
           call cgyro_alloc_add(io,(ny/2+1)*nx*16.0*nsplit,'gx')
           call cgyro_alloc_add(io,(ny/2+1)*nx*16.0*nsplit,'fy')
           call cgyro_alloc_add(io,(ny/2+1)*nx*16.0*nsplit,'gy')
           call cgyro_alloc_add(io,ny*nx*8.0*nsplit,'ux')
           call cgyro_alloc_add(io,ny*nx*8.0*nsplit,'vx')
           call cgyro_alloc_add(io,ny*nx*8.0*nsplit,'uy')
           call cgyro_alloc_add(io,ny*nx*8.0*nsplit,'vy')
           call cgyro_alloc_add(io,ny*nx*8.0*nsplit,'uv')
#endif
        endif
     endif

     write(io,*)
     write(io,*) 'TOTAL'
     write(io,10) total_memory/1e6,' MB [persistent memory per MPI process]'
     write(io,*)

     total_memory = 0
     write(io,*) ' == Distributed =='

     write(io,*)
     write(io,*) 'Distribution-like arrays'
     write(io,*)
!     call cgyro_alloc_add(io,4*nc*nv_loc*16.0,'rhs')

     ! call cgyro_alloc_add(io,10*nc*nv_loc*16.0,'rhs')

     select case(delta_t_method)
     case(1)
        call cgyro_alloc_add(io,nc*nv_loc*16.0,'h0_old')
        call cgyro_alloc_add(io,6*nc*nv_loc*16.0,'rhs')
     case(2)
        call cgyro_alloc_add(io,nc*nv_loc*16.0,'h0_old')
        call cgyro_alloc_add(io,7*nc*nv_loc*16.0,'rhs')
     case(3)
        call cgyro_alloc_add(io,nc*nv_loc*16.0,'h0_old')
        call cgyro_alloc_add(io,9*nc*nv_loc*16.0,'rhs')
     case default
        ! Normal timestep
        call cgyro_alloc_add(io,4*nc*nv_loc*16.0,'rhs')
     end select

     call cgyro_alloc_add(io,n_field*nc*nv_loc*16.0,'omega_s')
     call cgyro_alloc_add(io,n_field*nc*nv_loc*16.0,'omega_ss')
     call cgyro_alloc_add(io,nc*nv_loc*16.0,'omega_cap_h')
     call cgyro_alloc_add(io,nc*nv_loc*16.0,'omega_h')
     call cgyro_alloc_add(io,nc*nv_loc*16.0,'h_x')
     call cgyro_alloc_add(io,nc*nv_loc*16.0,'h0_x')
     call cgyro_alloc_add(io,nc*nv_loc*16.0,'g_x')
     call cgyro_alloc_add(io,nc*nv_loc*16.0,'h0_x')
     call cgyro_alloc_add(io,nc*nv_loc*16.0,'cap_h_c')
     call cgyro_alloc_add(io,nc*nv_loc*16.0,'cap_h_ct')
     call cgyro_alloc_add(io,nc*nv_loc*16.0,'cap_h_c_dot')
     call cgyro_alloc_add(io,nc*nv_loc*16.0,'cap_h_c_old')
     call cgyro_alloc_add(io,nc*nv_loc*16.0,'cap_h_c_old2')
     call cgyro_alloc_add(io,nc_loc*nv*16.0,'cap_h_v')
     call cgyro_alloc_add(io,n_field*nc*nv_loc*8.0,'jvec_c')
     if (nonlinear_flag == 1) call cgyro_alloc_add(io,n_field*n_radial*n_jtheta*nv_loc*n_toroidal*8.0,'jvec_c_nl')
     call cgyro_alloc_add(io,n_field*nc_loc*nv*8.0,'jvec_v')
     call cgyro_alloc_add(io,n_field*nc*nv_loc*8.0,'jxvec_c')
     call cgyro_alloc_add(io,nc*nv_loc*8.0,'upfac1')
     call cgyro_alloc_add(io,nc*nv_loc*8.0,'upfac2')

     if (nonlinear_flag == 1) then
        write(io,*)
        write(io,*) 'Nonlinear bracket'
        write(io,*)
        ! nsplit * n_toroidal = nv_loc * n_theta
        call cgyro_alloc_add(io,n_radial*nsplit*n_toroidal*16.0,'f_nl')
        call cgyro_alloc_add(io,n_field*n_radial*n_jtheta*n_toroidal*16.0,'g_nl')
        call cgyro_alloc_add(io,n_radial*nsplit*n_toroidal*16.0,'fpack')
        call cgyro_alloc_add(io,n_field*n_radial*n_jtheta*n_toroidal*16.0,'gpack')
     endif

     write(io,*)
     write(io,*) 'Collision operator'
     write(io,*)

     if(collision_model == 5) then
        call cgyro_alloc_add(io,(8.0*n_xi)*n_xi*n_species*n_energy*n_theta,'cmat')
     else
        if (collision_precision_mode == 0) then
           call cgyro_alloc_add(io,(8.0*nv)*nv*nc_loc,'cmat')
        else
           call cgyro_alloc_add(io,(4.0*nv)*nv*nc_loc,'cmat_fp32')
           call cgyro_alloc_add(io,(8.0*nv)*(collision_full_stripes*2+1)*nc_loc,'cmat_stripes')
        endif
#ifdef _OPENACC
        if (gpu_bigmem_flag /= 1) then
           write(io,*) 'Note: cmat is not in GPU memory'
        endif
#endif
     endif

     write(io,*)
     write(io,*) 'TOTAL'
     if (test_flag == 1) then
        write(io,10) total_memory/1e9,&
             ' GB [per toroidal mode ; halved with every doubling of MPI processes]'
        write(io,*) ' '
        do mult=2,16,2
           write(io,20) total_memory/1e9/mult,' GB ',mult*n_toroidal,' MPI processes'
        enddo           
     else
        write(io,10) total_memory/1e9,' GB [per MPI process]'
     endif    
     close(io)

  end if

10 format(t2,f8.3,a,3x,a)
20 format(t2,f8.3,a,i5,a)

end subroutine cgyro_check_memory

!------------------------------------------------
! cgyro_alloc_add.f90
!
! PURPOSE:
!  Primitive allocation addition routine.
!------------------------------------------------

subroutine cgyro_alloc_add(my_io,bytes,name)

  use cgyro_globals

  implicit none
  !
  integer, intent(in) :: my_io
  real, intent(in) :: bytes
  character (len=*), intent(in) :: name
 
  if (i_proc == 0) then
     
     total_memory = total_memory+bytes

     if (bytes < 1e8) then 
        write(my_io,10) bytes/1e6,' MB',name
     else
        write(my_io,10) bytes/1e9,' GB',name
     endif
     
  endif

10 format(t2,f8.3,a,3x,a)
  
end subroutine cgyro_alloc_add
