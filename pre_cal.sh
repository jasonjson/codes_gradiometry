#!/bin/bash

rm -rf final_para plots
mkdir final_para plots #folder for final results and figures
cal_peak_time_amp.py #get peak amp and its arrival time for plotting
saclst dist stlo stla baz f *.z | awk '{print $1,$2,$3,$4,$5-180}' > header_all
find_subarry.py #create folder for each master station and put supporting stations inside

N=`wc -l header_all | awk '{print $1}'`
M=`expr $N / 30 `
P=`expr $N / 30 + 1`
for i in `seq 1 $M`
do
    start=`expr $i \* 30 - 29`
    end=`expr $i \* 30`
    cp main.sh  main_$i.sh
    #sed -i  "s/startline/$start/g" main_$i.sh  #in linux
    sed -i '' "s/startline/$start/g" main_$i.sh  #in osx
    #sed -i  "s/endline/$end/g" main_$i.sh
    sed -i '' "s/endline/$end/g" main_$i.sh
done

for i in `seq $P $P`
do
    start=`expr $i \* 30 - 29`
    cp main.sh main_$i.sh
    #sed -i  "s/startline/$start/g" main_$i.sh
    sed -i '' "s/startline/$start/g" main_$i.sh
    #sed -i  "s/endline/$N/g" main_$i.sh
    sed -i '' "s/endline/$N/g" main_$i.sh
done
