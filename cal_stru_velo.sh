#!/bin/bash
#calculate structural phase velocity
omega=`awk -F_ '{printf "%f",2*3.14159/$2}' period`
awk 'function abs(x){return ((x < 0.0) ? -x : x)} {print abs($3)*1000}' AB_all > A_all
percentage=`minmax -C A_all | awk '{print $2*0.005}'`
damping=`minmax -C A_all | awk '{print ($2*0.04/6.371)^2}'`
awk -v a=$percentage 'BEGIN {print "lon lat Ve Vn Se Sn Cen Site Ref"} {print $1,$2,$3*1000,$4*1000,a,a,"0.05 stat(0,0) test1"}' AB_all > GPS_raw.dat
process_AB $damping
awk '{if(NR>=4&&NR<=365)print $2,$3,$4/1000000,$5/1000000}' strain.out > lap_A
# $1-dyna_velo $2-TA*.z $3-dist $4-lon $5-lat $6-azi $7-lon $8-lat $9-Ax $10-Ay $11-Bx $12-By $13-lat $14-lon $15 Exx(lap_Ax) $16-Eyy(lap_Ay)  make sure the lon and lat are the same for each line
paste dyna_velo ../header_all AB_all lap_A | awk -v w=$omega '{print $4,$5,$7,$8,$14,$13, w/sqrt((w*(sin($6*3.14159/180))^2)-$9^2-$15+(w*(cos($6*3.14159/180))^2)-$10^2-$16)}' > stru_velo
