#!/bin/bash

for i in 20 25 30 35 40 45 50 
do
	mkdir Period_$i
	cp *.z geometry.dat header_all Period_$i
	cd Period_$i
	echo 3.8 > velo_start
	lower_freq=`awk -v a=$i 'BEGIN{print (1/a)*0.9}'`
	higher_freq=`awk -v a=$i 'BEGIN{print (1/a)*1.1}'`
	awk -v x=$lower_freq -v y=$higher_freq '{print "r",$1; print "bp c "x,y" n 4 p 2"; print "w over"}END{print "q"}' header_all | sac
	cd ..
done

for i in 55 60 65 70 75 80 90 100 110 120 130 140 150
do
	mkdir Period_$i
	cp *.z geometry.dat header_all Period_$i
	cd Period_$i
	echo 4.0 > velo_start
	lower_freq=`awk -v a=$i 'BEGIN{print (1/a)*0.9}'`
	higher_freq=`awk -v a=$i 'BEGIN{print (1/a)*1.1}'`
	awk -v x=$lower_freq -v y=$higher_freq '{print "r",$1; print "bp c "x,y" n 4 p 2"; print "w over"}END{print "q"}' header_all | sac
	cd ..
done
#delete original data
rm *
