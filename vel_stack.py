#!/usr/bin/env python

import math

def vel_stack(infile,period):
    f = open(infile,'r')
    lines = f.readlines()
    slowness = {}
    for line in lines:
        line = line.split()
        sta = tuple(line[0:3])
        dyna_slowness = float(line[3])
        stru_slowness = float(line[4])
        x = dyna_slowness
        y = stru_slowness
        #remove velocity larger than 4.5 or smaller than 3.5 or nan
        if x < 0.2222 or x > 0.2857 or math.isnan(x) or y < 0.2222 or y > 0.2857 or math.isnan(y):
            continue
        elif sta not in slowness:
            #store station name, lat and lon as a tuple for key, dyna and stru as a tuple for value
            slowness[sta] = [(x,y),]
        else:
            slowness[sta].append((x,y))
    slowness_ave = {}
    for key, values in slowness.items():
        count = 0
        sum_dyna = 0
        sum_stru = 0
        for value in values:
            dyna,stru = value
            sum_dyna += float(dyna)
            sum_stru += float(stru)
            count += 1
        slowness_ave[key] = (sum_dyna/count, sum_stru/count)
    outf = open('dyna_stru_ave_'+period,'w')
    for key, value in slowness_ave.items():
        outf.write(key[0]+' '+key[1]+' '+key[2]+' '+str(value[0])+' '+str(value[1])+'\n')
    outf.close()

if __name__=='__main__':
    period = [20,25,30,35,40,45,50,55,60,65,70,75,80,90,100,110,120,130,140,150]
    for i in period:
        vel_stack('velo_period_'+str(i),str(i))
