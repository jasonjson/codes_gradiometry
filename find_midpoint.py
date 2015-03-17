#!bin/usr/env python

#find the edge stations from station.ps, try to include all edge stations
f_polygon = open('edge_stations.txt','r')
lon = []
lat = []
for line in f_polygon:
    line = line.split()
    lon.append(float(line[0]))
    lat.append(float(line[1]))
new_lon = []
new_lat = []
#intesect the midpoint
for i in range(len(lon)-1):
    new_lon.append(lon[i])
    new_lat.append(lat[i])
    new_lon.append((lon[i]+lon[i+1])/2)
    new_lat.append((lat[i]+lat[i+1])/2)
#include the last point
new_lon.append(lon[-1])
new_lat.append(lat[-1])
#output the denser edge stations into polygon.txt
f_new = open('polygon.txt','w')
for i in range(len(new_lon)):
    f_new.write(str(new_lon[i])+' '+str(new_lat[i])+'\n')
f_new.close()

