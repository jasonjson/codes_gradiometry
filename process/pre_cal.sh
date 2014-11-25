#!/bin/bash

mkdir final_para  #folder for final results

N=`wc -l header_all | awk '{print $1}'`
M=`expr $N / 30 `
P=`expr $N / 30 + 1`
for i in `seq 1 $M`
do
    start=`expr $i \* 30 - 29`
    end=`expr $i \* 30`
    cp cal_dynamical_1st.sh  cal_dynamical_$i.sh
    sed -i  "s/startline/$start/g" cal_dynamical_$i.sh
    sed -i  "s/endline/$end/g" cal_dynamical_$i.sh

    cp cal_dynamical_2nd.sh  cal_dynamical-$i.sh
    sed -i   "s/startline/$start/g" cal_dynamical-$i.sh
    sed -i   "s/endline/$end/g" cal_dynamical-$i.sh

done

for i in `seq $P $P`
do
    start=`expr $i \* 30 - 29`
    cp cal_dynamical_1st.sh  cal_dynamical_$i.sh
    sed -i  "s/startline/$start/g" cal_dynamical_$i.sh
    sed -i  "s/endline/$N/g" cal_dynamical_$i.sh

    cp cal_dynamical_2nd.sh  cal_dynamical-$i.sh
    sed -i  "s/startline/$start/g" cal_dynamical-$i.sh
    sed -i  "s/endline/$N/g" cal_dynamical-$i.sh

done
