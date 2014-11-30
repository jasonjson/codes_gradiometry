#!/usr/bin/env python

from obspy import read
import geographiclib
from os import system
from obspy.core.util.geodetics import gps2DistAzimuth
from math import sin, cos, pi


f_pxpy = open('pxpy_main','r')
pxpy = f_pxpy.read().split()
f_pxpy.close()
f_master = open('master_sta','r')
f_shift = open('shift_time','w')
master_info = f_master.read().split()
master_azi = float(master_info[4])
master_lon = float(master_info[2])
master_lat = float(master_info[3])
px_master = float(pxpy[0])
py_master = float(pxpy[1])
#calculate shifting time based on the x and y distance between master and supporting stations
st = read('TA.*.z')
for tr in st:
    dist = ((tr.stats.sac.stlo - master_lon) * 111.2 * cos(master_lat * pi / 180), (tr.stats.sac.stla - master_lat) * 111.2)
    sta_id = tr.id.split('.')[1]
    f_support = open(r'../final_para/pxpy_'+sta_id,'r')
    pxpy = f_support.read().split()
    #cal average slowness between master and supporting stations
    ave_px = (px_master + float(pxpy[0])) / 2
    ave_py = (py_master + float(pxpy[1])) / 2
    shift_time = tr.stats.sac.b - (dist[0] * ave_px + dist[1] * ave_py)
    f_shift.write(tr.id.split('.')[1]+' '+str(shift_time)+'\n')
