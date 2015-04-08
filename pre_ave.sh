#!/bin/bash

N=`wc -l header_all | awk '{print $1}'`
M=`expr $N / 30 `
P=`expr $N / 30 + 1`
for i in `seq 1 $M`
do
    start=`expr $i \* 30 - 30`
    end=`expr $i \* 30 - 1`
    cp cal_average_stru_amp.py cal_average_stru_amp_$i.py
    sed -i  "s/startline/$start/g" cal_average_stru_amp_$i.py  #in linux
    sed -i  "s/endline/$end/g" cal_average_stru_amp_$i.py
done

for i in `seq $P $P`
do
    start=`expr $i \* 30 - 30`
    end=`expr $N - 1`
    cp cal_average_stru_amp.py cal_average_stru_amp_$i.py
    sed -i  "s/startline/$start/g" cal_average_stru_amp_$i.py 
    sed -i  "s/endline/$end/g" cal_average_stru_amp_$i.py
done
