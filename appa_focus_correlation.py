#!/usr/bin/env python

import matplotlib as mpl
mpl.use('Agg')
import matplotlib.pyplot as plt
import numpy

f_data = open('appa_focusing.dat','r')
appa = []
focus = []
for line in f_data:
    line = line.split()
    appa.append(float(line[2]))
    focus.append(float(line[3]))
    
coefficients = numpy.polyfit(focus, appa, 1)
polynomial = numpy.poly1d(coefficients)
ys = polynomial(focus)
print coefficients
print polynomial

x=[-1,1]
y=[1,-1]
plt.plot(focus,appa,'r.')
plt.plot(x,y,'b-',linewidth=3)
#plt.plot(focus,ys,linewidth=3)
plt.gca().set_aspect('equal', adjustable='box')
plt.xlim(-1, 1)
plt.ylim(-1, 1)
plt.xlabel('Focusing/defocusing correction(10^-3 s/km^2)')
plt.ylabel('Apparent amplitude decay(10^-3 s/km^2)')
plt.savefig('amp_appa_focusing_correlation.ps')
