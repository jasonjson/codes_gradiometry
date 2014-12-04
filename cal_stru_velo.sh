#!/bin/bash
#calculate structural phase velocity
omega=`awk -F_ '{printf "%f",2*3.14159/$1}' ../period`
awk 'function abs(x){return ((x < 0.0) ? -x : x)} {print abs($3)*1000}' AB_all > A_all
percentage=`minmax -C A_all | awk '{print $2*0.005}'`
damping=`minmax -C A_all | awk '{print ($2*0.04/6.371)^2}'`
awk -v a=$percentage 'BEGIN {print "lon lat Ve Vn Se Sn Cen Site Ref"} {print $1,$2,$3*1000,$4*1000,a,a,"0.05 stat(0,0) test1"}' AB_all > GPS_raw.dat
process_AB $damping
awk '{if(NR>=4&&NR<=365)print $2,$3,$4/1000000,$5/1000000}' strain.out > lap_A
# $1-dyna_px $2-dyna_py $3-TA*.z $4-dist $5-lon $6-lat $7-azi $8-lon $9-lat $10-Ax $11-Ay $12-Bx $13-By $14-lat $15-lon $16 Exx(lap_Ax) $17-Eyy(lap_Ay)  make sure the lon and lat are the same for each line
paste dyna_pxpy ../header_all AB_all lap_A | awk -v w=$omega '{print $5,$6,$8,$9,$15,$14, w/sqrt((w*$1)^2-$10^2-$16+(w*$2)^2-$11^2-$17)}' > stru_velo
