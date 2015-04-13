#!/bin/bash

#usage: the script calculate structural phase velocity, A, B, grad A, grad B, apparent amplitude decay, focusing/defocusing and corrceted amplitude decay in a denser grid

#remove larger or smaller magnitudes of A
paste AB_all dyna_pxpy | awk '{print $1,$2,$3,$4,$7,$8}' > A_P_all
awk '{print $1,$2,sqrt($3^2+$4^2),$3,$4,$5,$6}' A_P_all > A_mag
eliminate_A A_mag A_P_selected

#process A
awk 'function abs(x){return ((x < 0.0) ? -x : x)} {printf "%f\n%f\n",abs($3)*1000,abs($4)*1000}' A_P_selected > A_all
percentage=`minmax -C A_all | awk '{print $2*0.005}'`
damping=`minmax -C A_all | awk '{print ($2*0.04/6.371)^2}'`
dense_lon_lat=`minmax -C st.txt | awk '{printf "%.f %.f %.f %.f\n",$1-1,$2+1,$3-1,$4+1}'`
dense_points=`echo $dense_lon_lat | awk '{print ($2-$1)/0.2,($4-$3)/0.2}'`
awk -v a=$percentage 'BEGIN {print "lon lat Ve Vn Se Sn Cen Site Ref"} {print $1,$2,$3*1000,$4*1000,a,a,"0.05 stat(0,0) test1"}' A_P_selected > GPS_raw.dat
process_AB $damping $dense_lon_lat $dense_points
num_stations=`awk '{if(NR==1) print $1}' output.dat`
awk -v a=$num_stations '{if(NR>=4&&NR<=a+3)print $2,$3,$4/1000000,$5/1000000}' strain.out > grad_A
awk '{print $1,$2,$3/1000,$4/1000}' vel.gmt > A.dat
#awk '{print $2,$1,($3+$4)*1e6}' grad_A > sigma_c.dat
#image_A

#process B
awk 'function abs(x){return ((x < 0.0) ? -x : x)} {printf "%f\n%f\n",abs($5),abs($6)}' A_P_selected > B_all
percentage=`minmax -C B_all | awk  '{print $2*0.005}'`
damping=`minmax -C B_all | awk  '{print ($2*0.04/6.371)^2}'`
awk -v a=$percentage 'BEGIN {print "lon lat Ve Vn Se Sn Cen Site Ref"} {print $1,$2,-$5,-$6,a,a,"0.05 stat(0,0) test1"}' A_P_selected > GPS_raw.dat
process_AB $damping $dense_lon_lat $dense_points
awk -v a=$num_stations '{if(NR>=4&&NR<=a+3)print $2,$3,$4/1000,$5/1000}' strain.out > grad_B
mv vel.gmt B.dat
#awk '{print $2,$1,($3+$4)*1e3}' grad_B > sigma_c.dat
#image_B

#mv AxAy*ps BxBy*ps ../plots
#cal structural phase velocity
#$13-lon $12-lat $3-Ax $4-Ay $7-Bx $8-By $14-gradAx $15-gradAy
omega=`awk -F_ '{printf "%f",2*3.14159/$1}' period`
paste A.dat B.dat grad_A | awk -v w=$omega '{print $13,$12,w/sqrt((w*$7)^2-$3^2-$14+(w*$8)^2-$4^2-$15)}' > stru_velo

#cal apparent local amplification factor
paste A.dat B.dat | awk '{print $1-360,$2,2e3*($3*$7+$4*$8)}' > appa_amp

#cal fosucing/defocusing
awk '{print $2,$1,1e3*($3+$4)}' grad_B > focusing_amp

#cal corrected local amplifcation factor
paste appa_amp focusing_amp stru_velo B.dat | awk '{print $1,$2,atan2($12,$13)*180/3.1415926+180,$3+$6,$9}' > azi_amp_stru_velo
