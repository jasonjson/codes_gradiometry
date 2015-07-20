#!/usr/bin/env python

import matplotlib as mpl
mpl.use('Agg')
import matplotlib.pyplot as plt
import numpy
from os import system

#assume sigma_c.dat contains gradients of B
system("paste ../for_stru_wn/A_P_all.dat sigma_c.dat | awk '{print $2,$3,2000*($4*$6+$5*$7),$10}' > appa_focusing.dat")
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

t = numpy.arange(-5., 5., 0.2)
plt.plot(focus,appa,'r.')
plt.plot(t,t,'b-',linewidth=5)
#plt.plot(focus,ys,linewidth=3)
plt.gca().set_aspect('equal', adjustable='box')
plt.xlim(-1.5, 1.5)
plt.ylim(-1.5, 1.5)
plt.xlabel('Focusing/defocusing correction(10^-3 s/km^2)')
plt.ylabel('Apparent amplitude decay(10^-3 s/km^2)')
plt.savefig('amp_appa_focusing_correlation.ps')
