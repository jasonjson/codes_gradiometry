#!/usr/bin/env python
from obspy import read

st = read('TA.*.z')
f_peak = open('vertical_name_time','w')
for tr in st:
    peak_time = int(tr.data.argmax() * tr.stats.delta)
    sta_id = tr.id.split('.')[1]
    print >> f_peak, 'TA.'+sta_id+'.z '+str(peak_time-100)+' '+str(peak_time+100)
