#!/bin/bash
eta_previous="0.01"
eta="0.10"; b="1.0"
for i in {1..500}; do
#	if [ "$eta" = "0.1" ]; then
	path="../eta$eta_previous""/all_results/"
#	else
#		path="../eta$eta_previous""/all_results/"
#	fi
	echo "path = $path"
	mkdir "eta$eta" && cd "eta$eta"
	echo "**************"
	for input in `ls $path`; do
	#	if [ -f STOP ]; then echo "**** STOP ****"; exit 1;fi
		rm ./nrk.ini ./result.dat.org >> ../out.log 2>&1
		cp ../nrk.ini.org .
		cp -v $path"$input" ./result.dat.org >> ../out.log 2>&1
#	echo "cp $path""$input"" ./result.dat.org"
		wave_n=`echo $input | awk -F '[_]' '{print $1}'`
		ome2=`echo $input | awk -F '[_]' '{print $3}'`
		echo "eta, wave_n, ome2 =  ""$eta"'        '"$wave_n"'       '"$ome2"
		sed -e "s/ome2_up/$ome2/" nrk.ini.org > nrk.ini.tmp1
		sed -e "s/ome2_low/$ome2/" nrk.ini.tmp1 > nrk.ini.tmp2
		sed -e "s/wave_n_up/$wave_n/" nrk.ini.tmp2 > nrk.ini.tmp3
		sed -e "s/wave_n_low/$wave_n/" nrk.ini.tmp3 > nrk.ini.tmp4
		sed -e "s/eta/$eta/" nrk.ini.tmp4 > nrk.ini
		rm nrk.ini.tmp* >> ../out.log 2>&1
		rm ./result.dat >> ../out.log 2>&1
		mkdir ./logs >> ../out.log 2>&1 
		NRK_noloop.exe &> ./logs/"$input".log
	done
	cd ..
	echo $PWD
	eta_previous=$eta
	eta=`awk "BEGIN {printf \"%.4f\n\", $eta+0.001}"`
done
