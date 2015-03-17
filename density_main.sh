#!/bin/bash

#locate points inside the polygon along the ray path, output profile_*
find_profile.py

percentage=`minmax -C A_all | awk '{print $2*0.005}'`
damping=`minmax -C A_all | awk '{print ($2*0.04/6.371)^2}'`
awk -v a=$percentage 'BEGIN {print "lon lat Ve Vn Se Sn Cen Site Ref"} {print $1,$2,$3*1000,$4*1000,a,a,"0.05 stat(0,0) test1"}' AB_all > GPS_raw.dat
process_AB $damping
mv spline_fit.out spline_fit_A.out

omega=`awk -F_ '{printf "%f",2*3.14159/$1}' period`
paste st.txt dyna_pxpy | awk -v a=$omega '{print $1,$2,$3*a,$4*a}' > loc_B
awk 'function abs(x){return ((x < 0.0) ? -x : x)} {printf "%f\n%f\n",abs($3),abs($4)}' loc_B > B_all
percentage=`minmax -C B_all | awk  '{print $2*0.005}'`
damping=`minmax -C B_all | awk  '{print ($2*0.04/6.371)^2}'`
awk -v a=$percentage 'BEGIN {print "lon lat Ve Vn Se Sn Cen Site Ref"} {print $1,$2,-$3,-$4,a,a,"0.05 stat(0,0) test1"}' loc_B > GPS_raw.dat
process_AB $damping
mv spline_fit.out spline_fit_B.out

for i in profile_[0-9]*
do
	number_stations=`sed -n '$=' $i`
	#only profiles with more than 10 points are processed
	if [ -s $i ] && [ $number_stations -gt 10 ]
	then
		awk -v a=$number_stations 'BEGIN{print a}{print NR,$2,$1}' $i > profile_lat_long.out
		#process Ax Ay
		cp spline_fit_A.out spline_fit.out
		process_profile
		awk '{print $1,$2,$3/1000,$4/1000}' vel.gmt > AxAy_$i
		#process Bx By
		cp spline_fit_B.out spline_fit.out
		process_profile
		awk '{print $3,$4}' vel.gmt > BxBy_$i
		awk -v a=$number_stations '{if(NR>=4&&NR<=a+3)print $4/1000000,$5/1000000}' strain.out > grad_BxBy_$i
		#$1 lon $2 lat $3 Ax $4 Ay $5 omega*Bx $6 omega*By $7 grad(omega*Bx) $8 grad(omega*By)
		paste AxAy_$i BxBy_$i grad_BxBy_$i | awk '{print $1-360,$2,-(2*$3*$5+$7+2*$4*$6+$8)/sqrt($5^2+$6^2)}' > rhs_profile
		rm AxAy_$i BxBy_$i grad_BxBy_$i $i
		#integrate along the ray path
		int_profile.py
		#$1 lon $2 lat $3 rhs $4 int
		paste rhs_profile int_profile > rhs_int_$i
	fi
done
