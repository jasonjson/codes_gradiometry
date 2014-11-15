#!/usr/bin/env python

import commands
from numpy import arange

def create_geometry():
    cmd = 'saclst stlo stla f *.z | awk \'{print $2,$3}\' | minmax -I3 '
    (status,output) = commands.getstatusoutput(cmd)
    lon_lat_minmax = output[2:].split('/')
    lon = arange(float(lon_lat_minmax[0]),float(lon_lat_minmax[1])+1,0.5)
    lat = arange(float(lon_lat_minmax[2]),float(lon_lat_minmax[3])+1,0.5)
    outf = open('geometry.dat','w')
    outf.write(str(len(lon)-1)+' '+str(len(lat)-1)+' '+str(2)+'\n')
    for i in range(0,len(lat)):
        for j in range(0,len(lon)):
            outf.write(str(j)+' '+str(i)+' 1 3 3'+'\n') 
            outf.write(str(lat[i])+' '+str(lon[j])+'\n')
    outf.close()

def main():
    create_geometry()

if __name__ == '__main__':
    main()
