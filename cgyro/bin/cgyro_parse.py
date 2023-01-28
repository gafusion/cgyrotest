from gacodeinput import *
import sys

x = SimpleInput()

x.set_extension('.gen')

# CGYRO input parameters
x.add('N_ENERGY','8')
x.add('N_XI','16')
x.add('N_THETA','24')
x.add('N_RADIAL','4')
x.add('N_TOROIDAL','1')
x.add('N_FIELD','1')
x.add('E_MAX','8.0')
x.add('ALPHA_POLY','0.0')
x.add('E_METHOD','1')
x.add('E_FIX','2')
x.add('DELTA_T_METHOD','0')
x.add('DELTA_T','0.01')
x.add('ERROR_TOL','6e-5')
x.add('MAX_TIME','100.0')
x.add('PRINT_STEP','100')
x.add('RESTART_STEP','10')
x.add('FREQ_TOL','0.001')
x.add('UP_RADIAL','1.0')
x.add('UP_THETA','1.0')
x.add('UP_ALPHA','0.0')
x.add('NUP_RADIAL','3')
x.add('NUP_THETA','3')
x.add('NUP_ALPHA','3')
x.add('N_WAVE','2')
x.add('CONSTANT_STREAM_FLAG','1')
x.add('EXPLICIT_TRAP_FLAG','0')
x.add('KY','0.3')
x.add('BOX_SIZE','1')
x.add('IPCCW','-1.0')
x.add('BTCCW','-1.0')
x.add('SILENT_FLAG','0')
x.add('PROFILE_MODEL','1')
x.add('EQUILIBRIUM_MODEL','2')
x.add('COLLISION_MODEL','4')
x.add('COLLISION_MOM_RESTORE','1')
x.add('COLLISION_ENE_RESTORE','1')
x.add('COLLISION_ENE_DIFFUSION','1')
x.add('COLLISION_KPERP','1')
x.add('COLLISION_FIELD_MODEL','1')
x.add('COLLISION_ION_MODEL','0')
x.add('COLLISION_ELE_SCALE','1.0')
x.add('COLLISION_PRECISION_MODE','0')
x.add('COLLISION_FULL_STRIPES','8')
x.add('Z_EFF','1.0')
x.add('Z_EFF_METHOD','2')
x.add('ZF_TEST_MODE','0')
x.add('NONLINEAR_FLAG','0')
x.add('NONLINEAR_METHOD','2')
x.add('AE_FLAG','0')
x.add('TEMP_AE','1.0')
x.add('DENS_AE','1.0')
x.add('MASS_AE','0.0002724486')
x.add('DLNTDR_AE','1.0')
x.add('DLNNDR_AE','1.0')
x.add('LAMBDA_STAR','0.0')
x.add('H_PRINT_FLAG','0')
x.add('MOMENT_PRINT_FLAG','0')
x.add('GFLUX_PRINT_FLAG','0')
x.add('FIELD_PRINT_FLAG','0')
x.add('AMP0','0.0')
x.add('AMP','0.1')
x.add('GAMMA_E','0.0')
x.add('GAMMA_P','0.0')
x.add('MACH','0.0')
x.add('ROTATION_MODEL','1')
x.add('MPI_RANK_ORDER','2')
x.add('VELOCITY_ORDER','1')
x.add('HIPREC_FLAG','0')
x.add('UDSYMMETRY_FLAG','0')
x.add('SHEAR_METHOD','2')
x.add('N_GLOBAL','4')
x.add('NU_GLOBAL','15.0')
x.add('PROFILE_SHEAR_FLAG','0')
x.add('THETA_PLOT','1')
x.add('GPU_BIGMEM_FLAG','1')
x.add('UPWIND_SINGLE_FLAG','0')
x.add('PX0','0.0')
x.add('STREAM_TERM','0')
x.add('STREAM_FACTOR','1.0')
x.add('CURRENTON','1')
x.add('OLDWEIGHT','1')


x.add('RMIN','0.5')
x.add('RMAJ','3.0')
x.add('Q','2.0')
x.add('S','1.0')
x.add('SHIFT','0.0')
x.add('KAPPA','1.0')
x.add('S_KAPPA','0.0')
x.add('DELTA','0.0')
x.add('S_DELTA','0.0')
x.add('ZETA','0.0')
x.add('S_ZETA','0.0')
x.add('ZMAG','0.0')
x.add('DZMAG','0.0')
x.add('SHAPE_SIN3','0.0')
x.add('SHAPE_S_SIN3','0.0')
x.add('SHAPE_SIN4','0.0')
x.add('SHAPE_S_SIN4','0.0')
x.add('SHAPE_SIN5','0.0')
x.add('SHAPE_S_SIN5','0.0')
x.add('SHAPE_SIN6','0.0')
x.add('SHAPE_S_SIN6','0.0')
x.add('SHAPE_COS0','0.0')
x.add('SHAPE_S_COS0','0.0')
x.add('SHAPE_COS1','0.0')
x.add('SHAPE_S_COS1','0.0')
x.add('SHAPE_COS2','0.0')
x.add('SHAPE_S_COS2','0.0')
x.add('SHAPE_COS3','0.0')
x.add('SHAPE_S_COS3','0.0')
x.add('SHAPE_COS4','0.0')
x.add('SHAPE_S_COS4','0.0')
x.add('SHAPE_COS5','0.0')
x.add('SHAPE_S_COS5','0.0')
x.add('SHAPE_COS6','0.0')
x.add('SHAPE_S_COS6','0.0')
x.add('BETAE_UNIT','0.0')
x.add('N_SPECIES','1')
x.add('NU_EE','0.1')

n = 11
x.add('Z','1.0',n=n)
x.add('MASS','1.0',n=n)
x.add('DENS','0.0',n=n)
x.add('TEMP','1.0',n=n)
x.add('DLNNDR','1.0',n=n)
x.add('DLNTDR','1.0',n=n)
x.add('SDLNNDR','0.0',n=n)
x.add('SDLNTDR','0.0',n=n)
x.add('DLNNDR_SCALE','1.0',n=n)
x.add('DLNTDR_SCALE','1.0',n=n)

x.add('QUASINEUTRAL_FLAG','1')
x.add('LAMBDA_STAR_SCALE','0.0')
x.add('GAMMA_E_SCALE','1.0')
x.add('GAMMA_P_SCALE','1.0')
x.add('MACH_SCALE','1.0')
x.add('BETA_STAR_SCALE','1.0')
x.add('BETAE_UNIT_SCALE','1.0')
x.add('NU_EE_SCALE','1.0')

# Deprecated parameters
x.dep('BETA_STAR','use BETA_STAR_SCALE')

# Perform the parsing
x.read_input('input.cgyro')

x.printmsg()

sys.exit(x.error)

