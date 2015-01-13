#!/bin/bash

#modify this for various events
for i in 0[0-5][0-9]* 06[0-7]*
do
	cd $i
	for j in Period_*
	do
		cd $j/final_para
		mkdir ../../../velo_stacking/$j  #do this once
		awk '{if(sqrt($1^2+$2^2)>1e-5) print 1/sqrt($1^2+$2^2)}' dyna_pxpy > dyna_velo
		paste ../header_all dyna_velo stru_velo  | awk '{if($6>1e-5 && $13>1e-5) print $1,$3,$4,1/$6,1/$13}' > ../../../velo_stacking/$j/velo_$i
		cd ../..
	done
	cd ..
done

#stack all velocities
cd velo_stacking
for i in Period_*
do
	cd $i
	cat velo_* > all_$i
	cd ..
done
cd ..
