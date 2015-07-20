#!/usr/bin/env python
""" calculate peak amplitude and its arrival time"""
from obspy import read
from math import sqrt
from numpy import ones
from os import system

st_before = read('TA.*.z')
max_amp = []
#find the maximum amplitude for checking
for tr in st_before:
    max_amp.append(tr.data.max())
ave = sum(max_amp) / len(max_amp)
sigma = sqrt(sum((max_amp - ones(len(max_amp))*ave)**2) / (len(max_amp) - 1))
#find the larger or smaller amplitude values and remove the bad station
for tr in st_before:
    if abs(tr.data.max() - ave) >= 2 * sigma:
        system('rm *'+tr.id.split('.')[1]+'*')
st_after = read('TA.*.z')
f_time = open('travel_time','w')
f_amp = open('peak_amp','w')
for tr in st_after:
    f_time.write(str(tr.stats.sac.stlo)+' '+str(tr.stats.sac.stla)+' '+str(int(tr.data.argmax()*tr.stats.delta))+'\n')
    f_amp.write(str(tr.stats.sac.stlo)+' '+str(tr.stats.sac.stla)+' '+str(tr.data.max())+'\n')
f_time.close()
f_amp.close()
