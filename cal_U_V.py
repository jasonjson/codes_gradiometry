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
master_info = f_master.read().split()
master_tr = read(master_info[0])[0]
master_azi = float(master_info[4])
master_lat = master_info[3] #use the latitude of master station to find corresponding strain, amp and vel
master_lon = master_info[2]
master_dist = float(master_info[1])
f_master.close()
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
    time_correction = []  #put shifting time info into list
    max_amp = []
    f_shift = open('shift_time','r')
    for line in f_shift.readlines():
        time_correction.append(line.split()[1])
    k = 0
    for tr in st1:  #add a time correction to t to get the actual amplitude for shifted waveforms
        max_amp.append(tr.data.max()*1000000)
        amp_data.append(tr.data[int((t-float(time_correction[k]))/tr.stats.delta)]*1000000)
        k += 1
    max_amp = [ i if i > 0 else -i for i in max_amp]
    per_error = max(max_amp) * 0.005 
    damping = (max(max_amp) * 0.04 / 6.371) ** 2
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
    for line in f_amp:
        if re.search('\s+'+master_lat,line):
            Ux_y.append(float(line.split()[2])/1000000000)
    #produce Uzxx data
    system('mv GPS_raw_x.dat GPS_raw.dat')
    system('process_wg2 '+str(damping))
    f_strain_x = open('strain.out','r')
    for line in f_strain_x:
        if re.search('^[\d\s]*'+master_lat,line):
            Uzxx.append(float(line.split()[3])/1000000000000)
    #produce Uzyy data
    system('mv GPS_raw_y.dat GPS_raw.dat')
    system('process_wg2 '+str(damping))
    f_strain_y = open('strain.out','r')
    for line in f_strain_y:
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

f_Uzxx = open('Uzxx.dat','w')
for num in Uzxx:
	print >> f_Uzxx, str(num)
f_Uzxx.close()

f_Uzyy = open('Uzyy.dat','w')
for num in Uzyy:
        print >> f_Uzyy, str(num)
f_Uzyy.close()

f_Ux_y = open('Ux_y.dat','w')
for num in Ux_y:
	print >> f_Ux_y, str(num)
f_Ux_y.close()

f_Vx_y = open('Vx_y.dat','w')
for num in Vx_y:
	print >> f_Vx_y, str(num)
f_Vx_y.close()
