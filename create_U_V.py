#!/usr/bin/env python
#create GPS_raw.dat for inspection 

from obspy import read
from numpy import arange

f_master = open('master_sta','r')
master_info = f_master.read().split()
master_tr = read(master_info[0])[0]
master_azi = float(master_info[4])
master_lat = master_info[3] #use the latitude of master station to find corresponding strain, amp and vel
master_dist = float(master_info[1])
f_master.close()
peak_time = int(master_tr.data.argmax() * master_tr.stats.delta)
f_loc = open('loc_sta','r') #location of stations within this folder
lines = f_loc.readlines()
st1 = read('shift.*.z') #read amplitude data
st2 = read('vel.*.z') #read velocity data
#f_vel = open('vel.txt','w+') #we use 'w+' to add new lines to the same file
for t in arange(peak_time-100,peak_time+102,2):
    amp_data = []
    time_correction = []
    max_amp = []
    f_shift = open('shift_time','r')
    for line in f_shift.readlines():
        time_correction.append(line.split()[1])
    k = 0
    for tr in st1:
        max_amp.append(tr.data.max()*1000000)
        amp_data.append(tr.data[int((t-float(time_correction[k]))/tr.stats.delta)]*1000000)
        k += 1
    max_amp = [ i if i > 0 else -i for i in max_amp]
    per_error = max(max_amp) * 0.005 
    damping = (max(max_amp) * 0.04 / 6.371) ** 2
    f_ux = open('ux_'+str(t)+'.txt','w')
    f_uy = open('uy_'+str(t)+'.txt','w')
    f_ux.write('lon lat Ve Vn Se Sn Cen Site Ref \n')
    f_uy.write('lon lat Ve Vn Se Sn Cen Site Ref \n')
    i = 0
    for line in lines:  #put location information and amplitude data together
        f_ux.write(line.split()[1]+' '+line.split()[2]+' '+str(amp_data[i])+' 0 '+' ' +str(per_error)+' '+str(per_error) +' 0.05 stat(0,0) test1 \n')
        f_uy.write(line.split()[1]+' '+line.split()[2]+' '+' 0 '+str(amp_data[i])+' ' +str(per_error)+' '+str(per_error) +' 0.05 stat(0,0) test1 \n')
        i += 1
    vel_data = []
    f_vel = open('vel'+str(t)+'.txt','w')
    l = 0
    for tr in st2:
        vel_data.append(tr.data[int((t-float(time_correction[l]))/tr.stats.delta)])
	l += 1
    j = 0
    for line in lines:
        f_vel.write(line.split()[1]+' '+line.split()[2]+' '+str(vel_data[j])+'\n')
        j += 1
