#!/usr/bin/env python

import subprocess

#subroutine to find the points inside the polygon (edge points are not included)
def point_in_poly(x,y,poly):
    n = len(poly)
    inside = False
    p1x,p1y = poly[0]
    for i in range(n+1):
        p2x,p2y = poly[i % n]
        if y > min(p1y,p2y):
            if y <= max(p1y,p2y):
                if x <= max(p1x,p2x):
                    if p1y != p2y:
                        xints = (y-p1y)*(p2x-p1x)/(p2y-p1y)+p1x
                    if p1x == p2x or x <= xints:
                        inside = not inside
        p1x,p1y = p2x,p2y
    return inside
source_lon=raw_input('please enter the source lon: ')
source_lat=raw_input('please enter the source lat: ')
#source_lon="-44.6219"
#source_lat="26.5904"
#put the edge station locations in polygon.txt, first column = lon, second column = lat
f_edge = open('polygon.txt','r')
polygon = []
for line in f_edge:
    line = line.split()
    polygon.append([float(i) for i in line])

i = 1
for point in polygon:
    # use gmt command to find the lat and lon for points along great circle path
    p = subprocess.Popen('project -C'+source_lon+'/'+source_lat+' -E'+str(point[0])+'/'+str(point[1])+' -G5 -Q',shell=True,stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    f_points_inside = open('profile_'+str(i),'w')
    for line in p.stdout.readlines():
        line = line.split()
        #if stations are inside the polygon, ouput the lon and lat to profile file
        if point_in_poly(float(line[0]),float(line[1]),polygon):
            f_points_inside.write(line[0]+' '+line[1]+'\n')
    f_points_inside.close()
    i += 1
