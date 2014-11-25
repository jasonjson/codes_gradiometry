#!/usr/bin/env python
#create GPS_raw.dat for sparse codes

from obspy import read
from numpy import arange,array
import numpy as np
from os import system
import re
from math import sin,cos,pi,atan2,sqrt

#calculate peak time window
f_master = open('master_sta','r')
f_azi = open('master_azi','r')
master_info = f_master.read().split()
master_tr = read(master_info[0])[0]
master_azi = float(f_azi.read())
master_lat = master_info[3] #use the latitude of master station to find corresponding strain, amp and vel
master_dist = float(master_info[1])
f_master.close()
f_azi.close()
peak_time = int(master_tr.data.argmax() * master_tr.stats.delta)
f_loc = open('loc_sta','r') #location of stations within this folder
lines = f_loc.readlines()
f_loc.close()
st1 = read('shift.*.z') #read amplitude data
st2 = read('vel.*.z') #read velocity data
Uzxx = []
Uzyy = []
Ux_y = []
Vx_y = []
for t in arange(peak_time-100,peak_time+102,2):
    #find amplitude information
    amp_data = []
    for tr in st1:
        amp_data.append(tr.data[int(t/tr.stats.delta)]*1000000)
    per_error = max(amp_data) * 0.005 
    damping = (max(amp_data) * 0.04 / 6.371) ** 2
    #produce GPS_raw_x.dat and GPS_raw_y.dat
    f_raw_x = open('GPS_raw_x.dat','w')
    f_raw_y = open('GPS_raw_y.dat','w')
    f_raw_x.write('lon lat Ve Vn Se Sn Cen Site Ref \n')
    f_raw_y.write('lon lat Ve Vn Se Sn Cen Site Ref \n')
    i = 0 
    for line in lines:  #put location information and amplitude data together
        f_raw_x.write(line.split()[1]+' '+line.split()[2]+' '+str(amp_data[i])+' 0 '+' ' +str(per_error)+' '+str(per_error) +' 0.05 stat(0,0) test1 \n')
        f_raw_y.write(line.split()[1]+' '+line.split()[2]+' '+' 0 '+str(amp_data[i])+' ' +str(per_error)+' '+str(per_error) +' 0.05 stat(0,0) test1 \n')
        i += 1  #update index for amplitude data in the list amp_data
    f_raw_x.close()
    f_raw_y.close()
    #produce Ux_y data 
    f_amp = open('GPS_raw_x.dat','r')
    for line in f_amp.readlines():
        if re.search(master_lat,line):
            Ux_y.append(float(line.split()[2])/1000000000)
    #produce Uzxx data
    system('mv GPS_raw_x.dat GPS_raw.dat')
    system('process_wg2 '+str(damping))
    f_strain_x = open('strain.out','r')
    for line in f_strain_x.readlines():
        if re.search('^[\d\s]*'+master_lat,line):
            Uzxx.append(float(line.split()[4])/1000000000000)
    #produce Uzyy data
    system('mv GPS_raw_y.dat GPS_raw.dat')
    system('process_wg2 '+str(damping))
    f_strain_y = open('strain.out','r')
    for line in f_strain_y.readlines():
        if re.search('^[\d\s]*'+master_lat,line):
            Uzyy.append(float(line.split()[4])/1000000000000)   
    #produce Vx_y data, which include ground velocity data for master station within all time steps
    vel_data = []
    for tr in st2:
        vel_data.append(tr.data[int(t/tr.stats.delta)] / (-1000))
    with open('loc_sta') as myfile:
        for i, line in enumerate(myfile,1):
            if master_lat in line:
                Vx_y.append(vel_data[i-1])
#cal Ax Bx
U_V = []
d_x = np.array(Uzxx)
for i in range(len(Ux_y)):
    U_V.append([Ux_y[i],Vx_y[i]])
G = np.array(U_V)
Ax, Bx = np.linalg.lstsq(G,d_x)[0]
#cal Ay,By
d_y = np.array(Uzyy)
Ay,By = np.linalg.lstsq(G,d_y)[0]
#get velocity for shifting
f_old_velo = open('velo_start','r') #original velo
old_vel = float(f_old_velo.read())
px = sin(master_azi*pi/180) / old_vel
py = cos(master_azi*pi/180) / old_vel
f_old_velo.close()
new_px = px + Bx 
new_py = py + By
new_vel = 1. / sqrt(new_px ** 2+new_py ** 2)
f_vel_new = open('velo_start','w')
f_vel_new.write(str(new_vel))
f_vel_new.close()
#get azimuth varation
f_azi_var = open('azi_var.dat','w')
new_azi = atan2(new_px,new_py)*180/pi
azi_var = new_azi - master_azi
f_azi_var.write(str(azi_var))
#get new azimuth
f_new_azi = open('master_azi','w')
f_new_azi.write(str(new_azi))
#get radiation pattern
f_rad_patt = open('rad_patt.dat','w')
rad_patt = master_dist * (Ax * cos(new_azi * pi / 180) - Ay * sin(new_azi * pi / 180))
f_rad_patt.write(str(rad_patt))
#get geometrical spreading
f_geo_spread = open ('geo_spread.dat','w')
geo_spread = Ax * sin(new_azi * pi / 180) - Ay * cos(new_azi * pi / 180)
f_geo_spread.write(str(geo_spread))
