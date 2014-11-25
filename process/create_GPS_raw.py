#!/usr/bin/env python
#create GPS_raw.dat for sparse codes

from obspy import read
from numpy import arange,array
import numpy as np
from os import system
import re

f_master = open('master_sta','r')
master_info = f_master.read().split()
master_tr = read(master_info[0])[0]
peak_time = int(master_tr.data.argmax() * master_tr.stats.delta)
master_lat = master_info[3]

f_loc = open('loc_sta','r') #location of stations within this folder
lines = f_loc.readlines()
st1 = read('shift.*.z') #read amplitude data
st2 = read('vel.*.z') #read velocity data
f_vel = open('vel.txt','w+') #we use 'w+' to add new lines to the same file
f_ux_all = open('ux.txt','w+')
f_uy_all = open('uy.txt','w+')
Uzxx = []
Uzyy = []
Ux_y = []
Vx_y = []
#for t in arange(peak_time-100,peak_time+102,2):
for t in arange(peak_time-100,peak_time-98,2):
    #find amplitude information
    amp_data = []
    for tr in st1:
        amp_data.append(tr.data[int(t/tr.stats.delta)]*1000000)
    per_error = max(amp_data) * 0.005 
    damping = (max(amp_data) * 0.04 / 6.371) ** 2
    #produce GPS_raw.dat
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
    #produce amplitude data file GPS_raw.dat
    f_amp = open('GPS_raw_x.dat','r')
    for line in f_amp.readlines():
        if re.search(master_lat,line):
            Ux_y.append(float(line.split()[2])/1000000000)
    #produce Uzxx data
    system('mv GPS_raw_x.dat GPS_raw.dat')
    system('./process_wg2 '+str(damping))
    f_strain_x = open('strain.out','r')
    for line in f_strain_x.readlines():
        if re.search('^[\d\s]*'+master_lat,line):
            Uzxx.append(float(line.split()[4])/1000000000000)
    #produce Uzyy data
    system('mv GPS_raw_y.dat GPS_raw.dat')
    system('./process_wg2 '+str(damping))
    f_strain_y = open('strain.out','r')
    for line in f_strain_y.readlines():
        if re.search('^[\d\s]*'+master_lat,line):
            Uzyy.append(float(line.split()[4])/1000000000000)   
    #produce Vx_y data, which include ground velocity data for master station within all time steps
    vel_data = []
    for tr in st2:
        vel_data.append(tr.data[int(t/tr.stats.delta)])
    with open('loc_sta') as myfile:
        for i, line in enumerate(myfile,1):
            if master_lat in line:
                Vx_y.append(vel_data[i-1])
