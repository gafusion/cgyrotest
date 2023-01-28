!-----------------------------------------------------------------
! cgyro_write_timedata.f90
!
! PURPOSE:
!  Output of time-independent (initial) data.
!-----------------------------------------------------------------

subroutine cgyro_write_initdata

  use mpi
  use cgyro_globals

  implicit none

  integer :: p,in,is,it
  real :: kymax,kyrat,dn
  real, external :: spectraldiss

  !----------------------------------------------------------------------------
  ! Runfile to give complete summary to user
  ! 
  ! NOTE: Some of this data is reproduced in other data files.
  !
  if (silent_flag == 0 .and. i_proc == 0) then

     open(unit=io,file=trim(path)//runfile_info,status='old',position='append')

     write(io,*)
     write(io,'(a)') ' n_theta | n_species | n_energy | n_xi '
     write(io,'(t4,i3,t16,i1,t26,i2,t36,i2)') n_theta,n_species,n_energy,n_xi
     if (test_flag == 0) then
        write(io,*) 
        if (nonlinear_flag == 1) then
          write(io,'(a)') ' nc_loc | nv_loc | nsplit | n_jtheta | n_MPI | n_OMP'
          write(io,'(t3,i4,t12,i4,t21,i4,t33,i3,t40,i5,t47,i3)') nc_loc,nv_loc,nsplit,n_jtheta,n_proc,n_omp
        else
          write(io,'(a)') ' nc_loc | nv_loc | nsplit | n_MPI | n_OMP'
          write(io,'(t3,i4,t12,i4,t21,i4,t29,i5,t36,i3)') nc_loc,nv_loc,nsplit,n_proc,n_omp
        endif
     endif

     if (zf_test_mode == 0) then

        ! Compute kymax
        if (n_toroidal == 1) then
           kymax = q/rmin*rho
        else
           kymax = q/rmin*(n_toroidal-1)*rho
        endif

        if (nonlinear_flag == 0) then
           write(io,*)
           write(io,*) '          n    Delta      Max     L/rho'
           write(io,'(a,i4,2x,2(f7.3,2x),2x,f6.2)') ' kx*rho:',&
                n_radial,2*pi*rho/length,2*pi*rho*(n_radial/2-1)/length,length/rho
           write(io,'(a,i4,2x,2(f7.3,2x),2x,f6.2)') ' ky*rho:',&
                n_toroidal,q/rmin*rho,kymax,2*pi/ky
        else

           write(io,*)
           write(io,*) '          n    Delta      Max     L/rho    n_fft'
           write(io,'(a,i4,2x,2(f7.3,2x),2x,f6.2,5x,i4)') ' kx*rho:',&
                n_radial,2*pi*rho/length,2*pi*rho*(n_radial/2-1)/length,length/rho,&
                (3*n_radial)/2
           write(io,'(a,i4,2x,2(f7.3,2x),2x,f6.2,5x,i4)') ' ky*rho:',&
                n_toroidal,q/rmin*rho,kymax,2*pi/ky,(3*(2*n_toroidal-1))/2
        endif

     else

        ! ZONAL FLOW TEST ONLY

        if (n_radial==1) then
           write(io,*)
           write(io,'(t2,a,1pe10.3)') ' kx*rho: ',2*pi*rho/length
        else
           write(io,*) '          n          Delta            Max           L/rho'
           write(io,'(a,i4,2x,2(g0.8,2x),2x,g0.8)') ' kx*rho:',&
                n_radial,2*pi*rho/length,2*pi*rho*(n_radial/2-1)/length,length/rho
        endif

     endif

     ! Dissipation information
     write(io,*)
     write(io,'(t2,3(a,1x,i2,3x),t48,a)') &
          ' D-theta:',2*nup_theta, ' D-radial:',2*nup_radial,' D-alpha:',2*nup_alpha,&
          '[dissipation order]'
     write(io,'(t2,3(a,1x,f3.1,2x),t48,a)') &
          'up_theta:',up_theta , 'up_radial:',up_radial ,'up_alpha:',up_alpha,&
          '[dissipation strength]'
     write(io,'(t2,3(a,1x,f3.1,2x),t48,a)') &
          'C(theta):',maxval(abs(omega_stream))*maxval(vel)*maxval(xi)*delta_t/d_theta/1.6

     write(io,*) 
     write(io,21) 'r/a',rmin,'R/a',rmaj,'q',q,'zmag',zmag,'kappa',kappa   
     write(io,22) 'shift',shift,'s',s,'dzmag',dzmag,'s_kappa',s_kappa
     write(io,*)
     if (abs(shape_cos(0))+abs(shape_s_cos(0)) > 1e-6) then
        write(io,23) 'c0',shape_cos(0),'s_c0',shape_s_cos(0)
     endif
     write(io,23) 'c1',shape_cos(1),'s_c1',shape_s_cos(1),'delta',delta,'s_delta',s_delta
     write(io,23) 'c2',shape_cos(2),'s_c2',shape_s_cos(2),'zeta' ,zeta ,'s_zeta' ,s_zeta
     if (abs(shape_cos(3))+abs(shape_s_cos(3))+abs(shape_sin(3))+abs(shape_s_sin(3)) > 1e-6) then
        write(io,23) 'c3',shape_cos(3),'s_c3',shape_s_cos(3),'s3',shape_sin(3),'s_s3',shape_sin(3)
        write(io,23) 'c4',shape_cos(4),'s_c4',shape_s_cos(4),'s4',shape_sin(4),'s_s4',shape_sin(4)
        write(io,23) 'c5',shape_cos(5),'s_c5',shape_s_cos(5),'s5',shape_sin(5),'s_s5',shape_sin(5)
        write(io,23) 'c6',shape_cos(6),'s_c6',shape_s_cos(6),'s6',shape_sin(6),'s_s6',shape_sin(6)
     endif
     write(io,*)
     write(io,20) 'gamma_e:',gamma_e,   'gamma_p:',gamma_p,     '  mach:',mach,'[rho/a]:',rho
     write(io,20) '  betae:',betae_unit,' beta_*:',beta_star(0),'lamb_*:',lambda_star,'[z_eff]:',z_eff

     write(io,*)
     write(io,'(a)') &
          ' i  z  n/n_norm   T/T_norm   m/m_norm     a/Ln       a/Lt       nu        s(a/Ln)    s(a/Lt)'
     do is=1,n_species
        write(io,'(t1,i2,1x,i2,3(2x,1pe9.3),2(1x,1pe10.3),(2x,1pe9.3),2(1x,1pe10.3))') &
             is,int(z(is)),dens(is),temp(is),mass(is),dlnndr(is),dlntdr(is),nu(is),&
             sdlnndr(is),sdlntdr(is)
     enddo

     if (profile_model == 2) then
        dn = rho/(rhos/a_meters)
        kyrat = abs(q/rmin*rhos/a_meters)
        write(io,*)
        write(io,10) '           a[m]:',a_meters,'  b_unit[T]:',b_unit,  '     rhos/a:',rhos/a_meters,' dn:',dn
        write(io,10) 'n_norm[e19/m^3]:',dens_norm,'v_norm[m/s]:',vth_norm,'T_norm[keV]:',temp_norm
        write(io,*)
        write(io,'(t2,a)') ' n = 1         2         3         4         5         6         7         8'      
        write(io,'(t2,a,8(1pe9.3,1x))') 'KY = ',kyrat,2*kyrat,3*kyrat,4*kyrat,5*kyrat,6*kyrat,7*kyrat,8*kyrat        
        write(io,'(t2,a,8(1pe9.3,1x))') 'LY = ',&
             2*pi/kyrat,&
             2*pi/(2*kyrat),&
             2*pi/(3*kyrat),&
             2*pi/(4*kyrat),&
             2*pi/(5*kyrat),& 
             2*pi/(6*kyrat),& 
             2*pi/(7*kyrat),& 
             2*pi/(8*kyrat) 
     endif
     write(io,*)

     close(io)

  endif
  !----------------------------------------------------------------------------

  !----------------------------------------------------------------------------
  ! Write the initial equilibrium data
  !
  if (silent_flag == 0 .and. i_proc == 0) then

     open(unit=io,file=trim(path)//'out.cgyro.equilibrium',status='replace')
     write (io,fmtstr) rmin
     write (io,fmtstr) rmaj
     write (io,fmtstr) q
     write (io,fmtstr) s
     write (io,fmtstr) shift
     write (io,fmtstr) kappa
     write (io,fmtstr) s_kappa
     write (io,fmtstr) delta
     write (io,fmtstr) s_delta
     write (io,fmtstr) zeta
     write (io,fmtstr) s_zeta
     write (io,fmtstr) zmag
     write (io,fmtstr) dzmag
     write (io,fmtstr) shape_sin(3)
     write (io,fmtstr) shape_s_sin(3)
     !write (io,fmtstr) shape_sin(4)
     !write (io,fmtstr) shape_s_sin(4)
     !write (io,fmtstr) shape_sin(5)
     !write (io,fmtstr) shape_s_sin(5)
     !write (io,fmtstr) shape_sin(6)
     !write (io,fmtstr) shape_s_sin(6)
     write (io,fmtstr) shape_cos(0)
     write (io,fmtstr) shape_s_cos(0)
     write (io,fmtstr) shape_cos(1)
     write (io,fmtstr) shape_s_cos(1)
     write (io,fmtstr) shape_cos(2)
     write (io,fmtstr) shape_s_cos(2)
     write (io,fmtstr) shape_cos(3)
     write (io,fmtstr) shape_s_cos(3)
     !write (io,fmtstr) shape_cos(4)
     !write (io,fmtstr) shape_s_cos(4)
     !write (io,fmtstr) shape_cos(5)
     !write (io,fmtstr) shape_s_cos(5)
     !write (io,fmtstr) shape_cos(6)
     !write (io,fmtstr) shape_s_cos(6)
     write (io,fmtstr) rho
     write (io,fmtstr) ky
     write (io,fmtstr) betae_unit
     write (io,fmtstr) beta_star(0)
     write (io,fmtstr) lambda_star
     write (io,fmtstr) gamma_e
     write (io,fmtstr) gamma_p
     write (io,fmtstr) mach
     write (io,fmtstr) a_meters
     write (io,fmtstr) b_unit
     write (io,fmtstr) dens_norm
     write (io,fmtstr) temp_norm
     write (io,fmtstr) vth_norm
     write (io,fmtstr) mass_norm
     write (io,fmtstr) rho_star_norm
     write (io,fmtstr) gamma_gb_norm
     write (io,fmtstr) q_gb_norm
     write (io,fmtstr) pi_gb_norm
     do is=1,n_species
        write (io,fmtstr) z(is)
        write (io,fmtstr) mass(is)
        write (io,fmtstr) dens(is)
        write (io,fmtstr) temp(is)
        write (io,fmtstr) dlnndr(is)
        write (io,fmtstr) dlntdr(is)
        write (io,fmtstr) nu(is)
     enddo
     close(io)

  endif

  !----------------------------------------------------------------------------

  !----------------------------------------------------------------------------
  ! Write the initial equilibrium geometry data
  !
  if (silent_flag == 0 .and. i_proc == 0) then
     open(unit=io,file=trim(path)//'bin.cgyro.geo',status='replace',access='stream')
     write(io) real(theta,kind=4)
     write(io) real(g_theta_geo,kind=4)
     write(io) real(bmag,kind=4)
     write(io) real(omega_stream(:,1),kind=4)
     write(io) real(omega_trap(:,1),kind=4)
     write(io) real(omega_rdrift(:,1),kind=4)
     write(io) real(omega_adrift(:,1),kind=4)
     write(io) real(omega_aprdrift(:,1),kind=4)
     write(io) real(omega_cdrift(:,1),kind=4)
     write(io) real(omega_cdrift_r(:,1),kind=4)
     write(io) real(omega_gammap(:),kind=4)
     write(io) real(k_perp(ic_c(n_radial/2+1,:)),kind=4)
     close(io)

  endif
  !----------------------------------------------------------------------------

  !----------------------------------------------------------------------------
  ! Write the initial rotation data
  !
  if (silent_flag == 0 .and. i_proc == 0) then
     open(unit=io,file=trim(path)//'out.cgyro.rotation',status='replace')
     do is=1,n_species
        write (io,fmtstr) dens_avg_rot(is)
     enddo
     do is=1,n_species
        write (io,fmtstr) dlnndr_avg_rot(is)
     enddo
     do is=1,n_species
        do it=1,n_theta
           write (io,fmtstr) dens(is)*dens_rot(it,is)
        enddo
     enddo
     close(io)
  endif

  !----------------------------------------------------------------------------
  ! Write the initial grid data 
  !
  if (silent_flag == 0 .and. i_proc == 0) then

     open(unit=io,file=trim(path)//runfile_grids,status='replace')
     write(io,'(i0)') n_toroidal
     write(io,'(i0)') n_species
     write(io,'(i0)') n_field
     write(io,'(i0)') n_radial
     write(io,'(i0)') n_theta
     write(io,'(i0)') n_energy
     write(io,'(i0)') n_xi
     write(io,'(i0)') box_size
     write(io,'(1pe13.6)') length/rho
     write(io,'(i0)') n_global
     write(io,'(i0)') theta_plot
     write(io,'(i0)') px(:)
     write(io,'(1pe13.6)') theta(:)
     write(io,'(1pe13.6)') energy(:)
     write(io,'(1pe13.6)') xi(:)
     write(io,'(1pe13.6)') thetab(:,:)
     if (n_toroidal > 1) then
        write(io,'(1pe13.6)') (rho*q/rmin*in,in=0,n_toroidal-1)
     else
        write(io,'(1pe13.6)') rho*q/rmin
     endif
     write(io,'(1pe13.6)') (spectraldiss((pi/n_toroidal)*in,nup_alpha),in=0,n_toroidal-1)
     write(io,'(1pe13.6)') (spectraldiss((2*pi/n_radial)*p,nup_radial),p=-n_radial/2,n_radial/2-1)
     close(io)

  endif
  !----------------------------------------------------------------------------

10 format(t2,4(a,1x,1pe9.3,2x))  
20 format(t2,4(a,1x,1pe10.3,2x)) 
21 format(t3,a3,1x,f8.5,1x,a5,1x,f8.5,a4,1x,f8.5,a7,1x,f8.5,a9,1x,f8.5)
22 format(t14,             a7,1x,f8.5,a4,1x,f8.5,a7,1x,f8.5,a9,1x,f8.5)
23 format(t2,a3,1x,f8.5,2(a7,1x,f8.5,1x),a8,1x,f8.5)

end subroutine cgyro_write_initdata
