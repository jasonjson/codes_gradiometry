#!/bin/bash

for i in 20 25 30 35 40 45 50 
do
	mkdir Period_$i
	#cp *.z geometry.dat edge_location.txt header_all Period_$i
	cp *.z geometry.dat header_all Period_$i
	cp /home/yuanliu/codes/codes_gradiometry/main.sh Period_$i
	cp /home/yuanliu/codes/codes_gradiometry/get_final.sh Period_$i
	cd Period_$i
	echo 3.8 > velo_start
	echo $i > period
	lower_freq=`awk -v a=$i 'BEGIN{print (1/a)*0.9}'`
	higher_freq=`awk -v a=$i 'BEGIN{print (1/a)*1.1}'`
	awk -v x=$lower_freq -v y=$higher_freq '{print "r",$1; print "bp c "x,y" n 4 p 2"; print "w over"}END{print "q"}' header_all | sac
	cal_peak_time_amp.py #get peak amp and its arrival time for plotting, remove stations with large or smaller amplitudes
	saclst dist stlo stla baz f *.z | awk '{print $1,$2,$3,$4,$5-180}' > header_all
	qsub ./get_final.sh
	cd ..
done

for i in 55 60 65 70 75 80 90 100 110 120 130 140 150
do
	mkdir Period_$i
	#cp *.z edge_location.txt geometry.dat header_all Period_$i
	cp *.z geometry.dat header_all Period_$i
	cp /home/yuanliu/codes/codes_gradiometry/main.sh Period_$i
	cp /home/yuanliu/codes/codes_gradiometry/get_final.sh Period_$i
	cd Period_$i
	echo 4.0 > velo_start
	echo $i > period
	lower_freq=`awk -v a=$i 'BEGIN{print (1/a)*0.9}'`
	higher_freq=`awk -v a=$i 'BEGIN{print (1/a)*1.1}'`
	awk -v x=$lower_freq -v y=$higher_freq '{print "r",$1; print "bp c "x,y" n 4 p 2"; print "w over"}END{print "q"}' header_all | sac
	cal_peak_time_amp.py #get peak amp and its arrival time for plotting, remove stations with large or smaller amplitudes
	saclst dist stlo stla baz f *.z | awk '{print $1,$2,$3,$4,$5-180}' > header_all
	qsub ./get_final.sh
	cd ..
done
#delete original data
rm *
