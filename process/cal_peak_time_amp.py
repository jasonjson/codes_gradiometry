#!/usr/bin/env python
""" calculate peak amplitude and its arrival time"""
from obspy import read

st = read('TA.*.z')
f_time = open('travel_time','w')
f_amp = open('peak_amp','w')
for tr in st:
    f_time.write(str(tr.stats.sac.stlo)+' '+str(tr.stats.sac.stla)+' '+str(int(tr.data.argmax()*tr.stats.delta))+'\n')
    f_amp.write(str(tr.stats.sac.stlo)+' '+str(tr.stats.sac.stla)+' '+str(tr.data.max())+'\n')
f_time.close()
f_amp.close()
