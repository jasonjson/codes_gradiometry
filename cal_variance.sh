#!/bin/bash
mkdir variance
#for ((i=1;i<=30;i++))
for ((i=1;i<=331;i++))
do
cd waveforms_$i
paste supp_no_master select_time | awk '{if(NR==1) a=$3; if(NR==1) b=$4;print "cut",a,b;x=$1; print "r",x; print"lh depmax"}END{print "q"}'| sac | grep -i depmax |awk '{printf "%s\n",$3*1000000}'> biggest_z_amp
zmintime=`awk -v a=$i '{if(NR==a) print $2}' vertical_name_time`
zmaxtime=`awk -v a=$i '{if(NR==a) print $3}' vertical_name_time`
percentage1=`minmax biggest_z_amp | awk -F/ '{print $2}' | awk -F\> '{print $1*0.005}'`
damping_value_z=`minmax biggest_z_amp | awk -F/ '{print $2}' | awk -F\> '{print ($1*0.04/6.371)^2}'`
numlines=`sed -n '$=' loc_all3`

for((j=$zmintime+100;j<=$zmintime+102;j=j+2))
do
awk -v a=$j '{print "cut",a,a+0.01; print "r",$1;print "lh depmen"}END{print "q"}' fileinfo2 | sac | grep -i depmen |awk '{print $3*1000000}' > dis_$j.txt
awk -v a=$j '{print "cut",a,a+0.01; print "r",$2;print "lh depmen"}END{print "q"}' fileinfo2 | sac | grep -i depmen |awk '{print $3}' > vel.txt
paste location.txt vel.txt > vel_$j.txt 
awk '{print $1,"0"}' dis_$j.txt | paste location.txt - | awk -v a=$percentage1 'BEGIN {print "lon lat Ve Vn Se Sn Cen Site Ref"} {print $1,$2,$3,$4,a,a,"0.05 stat(0,0) test1"}' > ux_$j.txt
awk '{print "0",$1}' dis_$j.txt | paste location.txt - | awk -v a=$percentage1 'BEGIN {print "lon lat Ve Vn Se Sn Cen Site Ref"} {print $1,$2,$3,$4,a,a,"0.05 stat(0,0) test1"}' > uy_$j.txt
done

rm strain_ordered*.out
make_geometry_new2
for((k=$zmintime+100;k<=$zmintime+100;k=k+2))
do
mv ux_$k.txt GPS_raw.dat
../process_error $damping_value_z
cp strain.out strain_ordered_ux_$k.out 
done

for((f=$zmintime+100;f<=$zmintime+100;f=f+2))
do
mv uy_$f.txt GPS_raw.dat
../process_error $damping_value_z
cp strain.out strain_ordered_uy_$f.out
done

cat strain_ordered_ux_*.out > strain_ordered_ux.out
cat strain_ordered_uy_*.out > strain_ordered_uy.out
lat=`awk '{print $3}' loc_master`
grep "^.\{3\}$lat" strain_ordered_ux.out | awk '{print $3/1e24}' > v_zx.dat
grep "^.\{3\}$lat" strain_ordered_uy.out | awk '{print $4/1e24}' > v_zy.dat
stationname=`awk '{x=$1; split(x,aa,".");print aa[2]}' loc_master`
paste v_zx.dat v_zy.dat > ../$stationname/sigma_square
cd ../$stationname
svd_px_variance
svd_py_variance
#ABx.dat contains calculated Ax and Bx, Vzx.dat containes variance of Ax and Bx, sigma_square contains sigma square
paste ABx.dat Vzx.dat sigma_square  | awk '{print $2,sqrt($4*$5)}' > Bx_variance
paste ABy.dat Vzy.dat sigma_square  | awk '{print $2,sqrt($4*$6)}' > By_variance
paste Bx_variance By_variance > ../variance/B_variance_$stationname
cd ..
done

