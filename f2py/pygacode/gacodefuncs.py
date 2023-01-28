#----------------------------------------------------------------------
# gacodefuncs.py
#
# PURPOSE:
#  Functions used for computing averages, manipulating strings, etc.
#----------------------------------------------------------------------

import numpy as np

# Useful labels
TIME=r'$(c_s/a)\,t$'

#---------------------------------------------------------------
# Generalization of average routine to include variance
def variance(f,t,wmin,wmax):

    n_time = len(t)

    # Manage case with 2 time points (eigenvalue)
    if len(t) == 2:
        tmin = t[-1]
        tmax = tmin
        ave  = f[-1]
        return ave

    tmin = (1.0-wmin)*t[-1]
    tmax = (1.0-wmax)*t[-1]

    t_window = 0.0
    ave      = 0.0 ; av2 = 0.0
    for i in range(n_time-1):
        if t[i] >= tmin and t[i] <= tmax:
            ave = ave+0.5*(f[i]+f[i+1])*(t[i+1]-t[i])
            av2 = av2+0.5*(f[i]**2+f[i+1]**2)*(t[i+1]-t[i])
            t_window = t_window+t[i+1]-t[i]

    ave = ave/t_window
    var = np.sqrt((av2/t_window-ave**2))

    return ave,var
#---------------------------------------------------------------
#---------------------------------------------------------------
def average(f,t,wmin,wmax):

    n_time = len(t)

    # Manage case with 2 time points (eigenvalue)
    if len(t) == 2:
        tmin = t[-1]
        tmax = tmin
        ave  = f[-1]
        return ave

    tmin = (1.0-wmin)*t[-1]
    tmax = (1.0-wmax)*t[-1]

    t_window = 0.0
    ave      = 0.0
    for i in range(n_time-1):
        if t[i] >= tmin and t[i] <= tmax:
            ave = ave+0.5*(f[i]+f[i+1])*(t[i+1]-t[i])
            t_window = t_window+t[i+1]-t[i]

    ave = ave/t_window

    return ave
#---------------------------------------------------------------
#---------------------------------------------------------------
def average_n(f,t,wmin,wmax,n):

    ave = np.zeros(n)

    n_time = len(t)
    tmin = (1.0-wmin)*t[-1]
    tmax = (1.0-wmax)*t[-1]

    t_window = 0.0
    for i in range(n_time-1):
        if t[i] >= tmin and t[i] <= tmax:
            ave[:] = ave[:]+0.5*(f[:,i]+f[:,i+1])*(t[i+1]-t[i])
            t_window = t_window+t[i+1]-t[i]

    ave = ave/t_window

    return ave
#---------------------------------------------------------------
#---------------------------------------------------------------
# Determine index imin,imax for time-averaging window
def iwindow(t,wmin,wmax):

    for i in range(len(t)):
        if t[i] < (1.0-wmin)*t[-1]:
            imin = i+1
        if t[i] <= (1.0-wmax)*t[-1]:
            imax = i

    return imin,imax
#---------------------------------------------------------------

#------------------------------------------------------
# Construct an explicit integer list based on string
def str2list(str):

    nvec = []
    for i in str.split(','):
        if '-' in i:
            v = i.split('-')
            for j in range(int(v[0]),int(v[1])+1):
                nvec.append(j)
        else:
            nvec.append(int(i))

    return nvec
#------------------------------------------------------

#------------------------------------------------------
# Set axis limits
def setlimits(a,fmin,fmax):

    fmin0=a[0]
    fmax0=a[1]

    if fmin != 'auto':
        fmin0=float(fmin)
    if fmax != 'auto':
        fmax0=float(fmax)

    return fmin0,fmax0
#------------------------------------------------------

#---------------------------------------------------------------
# Determine species name (returnval) from mass and charge
def specmap(m_in,z_in):

  # Assume Deuterium normalization
  m = int(m_in*2)
  z = int(z_in)

  if z < 0:
    name = 'e'
  elif m == 1:
     name = 'H'
  elif m == 2:
      name = 'D'
  elif m == 3:
     if z == 1:
        name = 'T'
     elif z == 2:
        name = 'He3'
     else:
        name = '?'
  elif m == 4:
     name = 'He'
  elif m == 7:
     name = 'Li'
  elif m == 9:
     name = 'Be'
  elif m == 12:
     name = 'C'
  elif m == 14:
     name = 'N'
  elif m == 16:
     name = 'O'
  elif m == 20:
     name = 'Ne'
  elif m == 40:
     name = 'Ar'
  elif m > 180:
     name = 'W'
  else:
     name = '?'

  return name
#---------------------------------------------------------------

#---------------------------------------------------------------
def smooth_pro(x,z,p,n,type='log'):

    nx = len(x)
    xf = np.zeros((nx-1)*n+1)
    zf = np.zeros((nx-1)*n+1)
    pf = np.zeros((nx-1)*n+1)
    j = 0
    for i in range(nx-1):
        for m in range(n):
            u = m/(1.0*n)
            xf[j] = x[i]*(1-u)+x[i+1]*u
            zf[j] = z[i]*(1-u)+z[i+1]*u
            j = j+1

    xf[j] = x[nx-1]
    zf[j] = z[nx-1]
    pf[j] = p[nx-1]

    # Exponential integration to obtain smooth profiles
    if type == 'log':
        for i in np.arange(j,0,-1):
            pf[i-1] = pf[i]*np.exp(0.5*(xf[i]-xf[i-1])*(zf[i]+zf[i-1]))
    else:
        for i in np.arange(j,0,-1):
            pf[i-1] = pf[i]-0.5*(xf[i]-xf[i-1])*(zf[i]+zf[i-1])
            
    return xf,pf
#---------------------------------------------------------------

#---------------------------------------------------------------
def extract(d,sd,key,w,spec,moment,norm=False,wmax=0.0,cflux='auto',dovar=False):

   import os
   import re
   from cgyro.data import cgyrodata

   # d        = directory
   # sd       = prefix of subdirectory ('a' for a1,a2,a3)
   # key      = key to scan (for example, 'GAMMA_P')
   # w        = time-averaging width
   # spec     = (0 ...)
   # moment   = (0 ...)
   # norm     = True (density normalization)
   # wmax     = time-averaging minimum
   # cflux    = 'on'/'off'/'auto'
   # dovar    = True/False (variance calculation)

   x = []
   f = []
   for i in range(64):
      sub = d+'/'+sd+str(i)+'/'
      if os.path.isdir(sub) == True:
         # If this is a directory, get the key value
         with open(sub+'/input.cgyro') as in_cgyro:
            for line in in_cgyro.readlines():
               if re.match(key,line):
                  found = float(line.split('=')[1])
         x.append(found)
         # Get the corresponding flux
         sim = cgyrodata(sub+'/')
         sim.getflux(cflux)
         y = np.sum(sim.ky_flux,axis=(2,3))
         # Flux for input (spec,moment) window w
         ave,var = variance(y[spec,moment,:],sim.t,w,wmax)
         if norm == True:
             var = var/sim.dens[spec]
             ave = ave/sim.dens[spec]
         if dovar:
            f.append(var)
         else:
            f.append(ave)
         print('INFO: (extract) Processed data in '+sub)

   # return (scan parameter, flux, variance)
   return np.array(x),np.array(f)
#---------------------------------------------------------------

#---------------------------------------------------------------
# Determine species name (returnval) from mass and charge
def specmap(m_in,z_in):

  # Assume Deuterium normalization
  m = int(m_in*2)
  z = int(z_in)

  if z < 0:
    name = 'e'
  elif m == 1:
     name = 'H'
  elif m == 2:
      name = 'D'
  elif m == 3:
     if z == 1:
        name = 'T'
     elif z == 2:
        name = 'He3'
     else:
        name = '?'
  elif m == 4:
     name = 'He'
  elif m == 7:
     name = 'Li'
  elif m == 9:
     name = 'Be'
  elif m == 12:
     name = 'C'
  elif m > 180:
     name = 'W'
  else:
     name = '?'

  return name
#---------------------------------------------------------------

#---------------------------------------------------------------
# Determine species name (returnval) from mass and charge
def tag_helper(mass,z,moment):

  u=specmap(mass,z)

  # Set filename root and title
  isfield = True
  if (moment == 'n'):
      fdata = '.cgyro.kxky_n'
      title = r'${\delta \mathrm{n}}_'+u+'$'
      isfield = False
  elif (moment == 'e'):
      fdata = '.cgyro.kxky_e'
      title = r'${\delta \mathrm{E}}_'+u+'$'
      isfield = False
  elif (moment == 'phi'):
      fdata = '.cgyro.kxky_phi'
      title = r'$\delta\phi$'
  elif (moment == 'apar'):
      fdata = '.cgyro.kxky_apar'
      title = r'$\delta A_\parallel$'
  elif (moment == 'bpar'):
      fdata = '.cgyro.kxky_bpar'
      title = r'$\delta B_\parallel$'

  return fdata,title,isfield
#---------------------------------------------------------------

#---------------------------------------------------------------
# Get time vector from commmand line option
def time_vector(istr,nt):

   if istr == '-1':
      ivec = [nt]
   elif istr == 'all':
      ivec = list(range(nt))
   else:
      ivec = str2list(istr)

   return ivec
#---------------------------------------------------------------

#---------------------------------------------------------------
def mkfile(ext):

    s=ext.split('.')
    if len(s) == 2:
        pre   = s[0]
        ftype = s[1]
    else:
        pre = ''
        ftype = s[0]

    return pre,ftype
#---------------------------------------------------------------

#---------------------------------------------------------------
def parameter_val(infile,par):

   val = 'null'
   with open(infile,'r') as f:
      for line in f:
         x = line.split()
         if x[1] == par:
            val = x[0]

   return val
#---------------------------------------------------------------

#---------------------------------------------------------------
def quadratic_max(x,g):
    
    # f(x) at 3 points
    f1 = g[-3] ; f2 = g[-2] ; f3 = g[-1]
    x1 = x[-3] ; x2 = x[-2] ; x3 = x[-1]

    # Extrema fs=f(xs) based on 3-point fit to parabola 
    xs = (f1-f3)/2.0/(f3-2*f2+f1)
    xs = x2+xs*(x3-x2)

    fs = f2+(f3-f1)**2/8.0/(2*f2-f3-f1)

    return xs,fs
#---------------------------------------------------------------

#---------------------------------------------------------------
def theta_index(theta,n_theta):
    # Compute index for theta value in pitch angle and energy plots
    i0 = int(round((1.0+theta)*n_theta/2.0))
    if i0 > n_theta-1:
        i0 = n_theta-1

    return i0

#---------------------------------------------------------------
def theta_indx(theta,theta_plot):

   # Select theta index
   if theta_plot == 1:
      itheta = 0
   else:
       # theta=0 check just to be safe
       if theta == 0.0:
           itheta = theta_plot//2
       else:
           itheta = int((theta+1.0)/2.0*theta_plot)

   print('INFO: (theta_indx) Selected index',itheta+1,'of',theta_plot)
   return itheta
#---------------------------------------------------------------

def shift_fourier(f,imin,imax):

    nx = f.shape[0]
    nn = f.shape[1]
    nt = f.shape[2]
    
    y1 = np.zeros([nn])
    y2 = np.zeros([nn])

    ephi  = np.zeros([2*nx,nt],dtype=complex)
    ephip = np.zeros([2*nx,nt],dtype=complex)

    wpos = np.zeros([2*nx])
    wneg = np.zeros([2*nx])
    wneg[nx//2+1:3*nx//2] = 1.0
    wneg[nx//2]  =  0.5
    wneg[3*nx//2] = 0.5
    wpos[:] = 1-wneg[:]
        
    phi  = np.zeros([nx,nt],dtype=complex)
    phip = np.zeros([nx,nt],dtype=complex)

    for n in range(nn):
        for p in range(1,nx):
            phi[p,:] = f[p,n,:]
            phip[p,:] = -(p-nx//2)*f[p,n,:]
            
        ephi[nx//2:3*nx//2,:]  = phi[:,:]
        ephip[nx//2:3*nx//2,:] = phip[:,:]            

        # NOTE: We use *inverse* FFT (ifft) for correct +sign convention of
        #       the exponent. Also note order convention:
        #       - a[0] = p=0
        #       - a[1:nx/2] = p > 0
        #       - a[nx/2:n] = p < 0
         
        phi_T = np.fft.ifft(np.fft.ifftshift(ephi,axes=0),axis=0)
        phip_T = np.fft.ifft(np.fft.ifftshift(ephip,axes=0),axis=0)

        pn_t = np.zeros([2*nx])
        pd_t = np.zeros([2*nx])
        for jt in np.arange(imin,imax+1):
            pn_t[:] = pn_t[:] + np.real(np.conj(phi_T[:,jt])*phip_T[:,jt])
            pd_t[:] = pd_t[:] + np.real(np.conj(phi_T[:,jt])*phi_T[:,jt])

        # Shift in -gamma domain (standard order: p=0 is 0th index)
        pn = np.sum(pn_t[:]*wneg[:])
        pd = np.sum(pd_t[:]*wneg[:])
            
        y2[n] = pn/pd

        # Shift in central domain 
        pn = np.sum(pn_t[:]*wpos[:])
        pd = np.sum(pd_t[:]*wpos[:])
         
        y1[n] = pn/pd

    return y1,y2


def shift_legendre(f,imin,imax):

    import scipy.special as sp

    nx = f.shape[0]
    nn = f.shape[1]
    nt = f.shape[2]
    n0 = nx//2
    nk = 2*n0

    y1 = np.zeros([nn])
    y2 = np.zeros([nn])

    c1 = np.zeros([nk],dtype=complex)
    c2 = np.zeros([nk],dtype=complex)

    mat1 = np.zeros([nk,n0-1])
    mat2 = np.zeros([nk,n0-1])
    kvec = np.arange(nk)
    pvec = np.arange(1,n0)
    z = pvec*np.pi/2
    for k in kvec:
        mat1[k,:]  = sp.spherical_jn(k,z)
        mat2[k,:]  = mat1[k,:]*(-1)**pvec[:]

    ai = 1j**kvec   
    ak = 2*kvec+1   

    c1m = np.zeros(nk,dtype=complex)
    c2m = np.zeros(nk,dtype=complex)

    for n in range(nn):
        n_all1 = n_all2 = 0.0
        d_all1 = d_all2 = 0.0
        for jt in np.arange(imin,imax+1):

            y = f[:,n,jt]

            phim = y[n0-1:0:-1]
            phi0 = y[n0]
            phip = y[n0+1:]

            mp1 = np.matmul(mat1,phip)
            mm1 = np.matmul(mat1,phim)
            mp2 = np.matmul(mat2,phip)
            mm2 = np.matmul(mat2,phim)

            c1[:] = ak[:]*(mp1[:]*ai[:]+mm1[:]*np.conj(ai[:]))
            c2[:] = ak[:]*(mp2[:]*ai[:]+mm2[:]*np.conj(ai[:]))
            
            c1[0] = c1[0]+phi0
            c2[0] = c2[0]+phi0

            c1m[0:2] = c1[0:2]
            c2m[0:2] = c2[0:2]
            for m in range(2,nk):
                c1m[m] = c1m[m-2]+c1[m]
                c2m[m] = c2m[m-2]+c2[m]
               
            n1 = 2*np.sum(c1m[0:nk-1]*np.conj(c1[1:nk]))
            n2 = 2*np.sum(c2m[0:nk-1]*np.conj(c2[1:nk]))
            
            d1 = 2*np.sum((np.abs(c1[:]))**2/ak[:])
            d2 = 2*np.sum((np.abs(c2[:]))**2/ak[:])

            n_all1 = n_all1 + np.imag(n1)
            n_all2 = n_all2 + np.imag(n2)
            d_all1 = d_all1 + d1
            d_all2 = d_all2 + d2

            # Derivative
            # demoninator is <phi | phi> = sum_m 2/(2m+1) |cm|^2 

        y1[n] = n_all1/d_all1*(2.0/np.pi)
        y2[n] = n_all2/d_all2*(2.0/np.pi)

    return y1,y2
