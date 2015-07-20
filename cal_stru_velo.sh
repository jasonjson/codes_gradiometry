#!/bin/bash

#calculate structural phase velocity in a normal grid
omega=`awk -F_ '{printf "%f",2*3.14159/$1}' ../period`
awk '{print $1,$2}' AB_all > st.txt
awk '{print $1,$2,sqrt($3^2+$4^2),$3,$4,$5,$6}' AB_all > AB_all_A_mag
#remove larger or smaller AxAy values
eliminate_A AB_all_A_mag AB_all_selected
awk 'function abs(x){return ((x < 0.0) ? -x : x)} {printf "%f\n%f\n",abs($3)*1000,abs($4)*1000}' AB_all_selected > A_all
percentage=`minmax -C A_all | awk '{print $2*0.005}'`
damping=`minmax -C A_all | awk '{print ($2*0.04/6.371)^2}'`
awk -v a=$percentage 'BEGIN {print "lon lat Ve Vn Se Sn Cen Site Ref"} {print $1,$2,$3*1000,$4*1000,a,a,"0.05 stat(0,0) test1"}' AB_all > GPS_raw.dat
process_AB $damping
num_stations=`wc -l AB_all | awk '{print $1}'`
awk -v a=$num_stations '{if(NR>=4&&NR<=a+3)print $2,$3,$4/1000000,$5/1000000}' strain.out > lap_A
# $1-dyna_px $2-dyna_py $3-lon $4-lat $5-Ax $6-Ay $7-Bx $8-By $9-lat $10-lon $11 Exx(lap_Ax) $12-Eyy(lap_Ay)  make sure the lon and lat are the same for each line
awk '{print 1/sqrt($1^2+$2^2)}' dyna_pxpy > dyna_velo
paste dyna_pxpy AB_all lap_A | awk -v w=$omega '{print $3,$4,w/sqrt((w*$1)^2-$5^2-$11+(w*$2)^2-$6^2-$12)}' > stru_velo
