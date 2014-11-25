#!/usr/bin/env python
#create GPS_raw.dat for sparse codes

from obspy import read
from numpy import arange

f_time = open('peak_time','r') #peak amplitude time window file
time_window = f_time.read().split()
f_loc = open('loc_sta','r') #location of stations within this folder
lines = f_loc.readlines()
st1 = read('shift.*.z') #read amplitude data
st2 = read('vel.*.z') #read velocity data
f_vel = open('vel.txt','w+') #we use 'w+' to add new lines to the same file
f_ux_all = open('ux.txt','w+')
f_uy_all = open('uy.txt','w+')
for t in arange(int(time_window[0]),int(time_window[1])+2,2):
    # create ux_.txt and uy_txt, amplitude information
    amp_data = []
    for tr in st1:
        amp_data.append(tr.data[int(t/tr.stats.delta)]*1000000)
    per_error = max(amp_data) * 0.005 
    damping = (max(amp_data) * 0.04 / 6.371) ** 2
    f_ux = open('ux_'+str(t)+'.txt','w')
    f_uy = open('uy_'+str(t)+'.txt','w')
    f_ux.write('lon lat Ve Vn Se Sn Cen Site Ref \n')
    f_uy.write('lon lat Ve Vn Se Sn Cen Site Ref \n')
    i = 0 
    for line in lines:  #put location information and amplitude data together
        f_ux.write(line.split()[1]+' '+line.split()[2]+' '+str(amp_data[i])+' 0 '+' ' +str(per_error)+' '+str(per_error) +' 0.05 stat(0,0) test1 \n')
        f_ux_all.write(line.split()[1]+' '+line.split()[2]+' '+str(amp_data[i])+' 0 '+' ' +str(per_error)+' '+str(per_error) +' 0.05 stat(0,0) test1 \n')
        f_uy.write(line.split()[1]+' '+line.split()[2]+' '+' 0 '+str(amp_data[i])+' ' +str(per_error)+' '+str(per_error) +' 0.05 stat(0,0) test1 \n')
        f_uy_all.write(line.split()[1]+' '+line.split()[2]+' '+' 0 '+str(amp_data[i])+' ' +str(per_error)+' '+str(per_error) +' 0.05 stat(0,0) test1 \n')
        i += 1  #update index for amplitude data in the list amp_data
#create vel.txt, which include ground velocity data for all stations within all time steps
    vel_data = []
    for tr in st2:
        vel_data.append(tr.data[int(t/tr.stats.delta)])
    j = 0
    for line in lines:
        f_vel.write(line.split()[1]+' '+line.split()[2]+' '+str(vel_data[j])+'\n')
        j += 1
