#!/usr/bin/env python

from obspy import read
import geographiclib
from obspy.core.util.geodetics import gps2DistAzimuth
from math import sin, cos, pi
from os import system


system('cp ../velo_start .') #the starting velocity for the first iteration
system('saclst stlo stla f TA.*.z > loc_sta') #produce station location data file
f_velo = open('velo_start','r')
f_master = open('master_sta','r')
f_shift = open('shift_time','w')
master_info = f_master.read().split()
master_azi = float(master_info[4])
master_lon = float(master_info[2])
master_lat = float(master_info[3])
velo = float(f_velo.read())
px = sin(master_azi * pi / 180) / velo
py = cos(master_azi * pi / 180) / velo
f_pxpy = open('pxpy_main','w')
f_pxpy.write(str(px) + ' '+str(py))
f_pxpy.close()
#calculate shifting time based on the x and y distance between master and supporting stations
st = read('TA.*.z')
for tr in st:
    dist = ((tr.stats.sac.stlo - master_lon) * 111.2 * cos(master_lat * pi / 180), (tr.stats.sac.stla - master_lat) * 111.2)
    shift_time = tr.stats.sac.b - (dist[0] * px + dist[1] * py)
    f_shift.write(tr.id.split('.')[1]+' '+str(shift_time)+'\n')
