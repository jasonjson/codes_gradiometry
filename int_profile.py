#!/usr/bin/env python

f_rhs = open('rhs_profile','r')
rhs = []
for line in f_rhs:
    line = line.split()
    rhs.append(float(line[2]))
f_int = open('int_profile','w+')
f_int.write('0 \n')
area = 0
for i in range(len(rhs)-1):
    area += ( rhs[i] + rhs[i+1] ) * 5 / 2
    f_int.write(str(area)+'\n')
f_int.close()
