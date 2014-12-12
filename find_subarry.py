#!/usr/bin/env python

from obspy.core.util.geodetics import gps2DistAzimuth
from os import system


f_header = open('header_all','r')
sta_lon_lat = {}
for line in f_header:
    words = line.split()
    if words[0] not in sta_lon_lat:
        sta_lon_lat[words[0]] = (words[1],words[2],words[3],words[4])
for master_sta,master_loc in sta_lon_lat.items():
    folder = master_sta.split('.')[1]
    system('mkdir '+folder) #create folder
    system('echo '+master_sta+' '+master_loc[0]+' '+master_loc[1]+' '+master_loc[2]+' '+master_loc[3]+' > '+folder+'/master_sta') 
    #output the master station name and location file
    master_lon = float(master_loc[1])
    master_lat = float(master_loc[2])
    for supp_sta, supp_loc in sta_lon_lat.items():
        supp_lon = float(supp_loc[1])
        supp_lat = float(supp_loc[2])
        if gps2DistAzimuth(master_lat,master_lon,supp_lat,supp_lon)[0] < 200000:
            system('cp '+supp_sta+' '+folder)

