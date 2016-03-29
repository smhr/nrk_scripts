#!/bin/bash
if [ "$1" == "-h" ] ; then
    echo "Usage: `basename $0` [eta step] [number of repetition]"
    echo "Example: `basename $0` 0.01 5"
    exit 0
fi
eta_previous="0" ## we use this eta value for initial guess
eta_step="$1"
eta=`awk "BEGIN {printf \"%012.5f\n\", $eta_previous+$eta_step}"`
 b="1.0"
for i in `eval echo {1.."$2"}` ; do
#	if [ "$eta" = "0.1" ]; then
	path="../../eta$eta_previous""/brf_results/"
#	else
#		path="../eta$eta_previous""/all_results/"
#	fi
#	echo "path = $path"
	echo "**************"
	echo "**************" >> ../out.log 2>&1
	echo "eta = $eta"
	mkdir "eta$eta"
	cd "eta$eta"
	echo $PWD >> ../out.log 2>&1
	echo "**************"
#	ls $path
	for input in `ls $path`; do
#		if [ -f "STOP" ]; then echo "**** STOP ****"; exit 1;fi
		rm ./nrk.ini ./result.dat.org >> ../out.log 2>&1
		cp ../nrk.ini.org .
		cp -v $path"$input" ./result.dat.org >> ../out.log 2>&1
#	echo "cp $path""$input"" ./result.dat.org"
		wave_n=`echo $input | awk -F '[_]' '{print $1}'`
		ome2=`echo $input | awk -F '[_]' '{print $2}'`
		echo "eta, wave_n, ome2 =  ""$eta"'        '"$wave_n"'       '"$ome2"
		echo "eta, wave_n, ome2 =  ""$eta"'        '"$wave_n"'       '"$ome2" >> ../out.log 2>&1
		sed -e "s/ome2_up/$ome2/" nrk.ini.org > nrk.ini.tmp1
		sed -e "s/ome2_low/$ome2/" nrk.ini.tmp1 > nrk.ini.tmp2
		sed -e "s/wave_n_up/$wave_n/" nrk.ini.tmp2 > nrk.ini.tmp3
		sed -e "s/wave_n_low/$wave_n/" nrk.ini.tmp3 > nrk.ini.tmp4
		sed -e "s/eta/$eta/" nrk.ini.tmp4 > nrk.ini
		rm nrk.ini.tmp* >> ../out.log 2>&1
		rm ./result.dat >> ../out.log 2>&1
		mkdir ./logs >> ../out.log 2>&1 
		NRK_AD_brf_no_loop.exe &> ./logs/"$input".log
	done
	cd ..
#	echo $PWD
#	eta_previous=$eta  # comment this line to use the first eta as a guess persistently.
	eta=`awk "BEGIN {printf \"%012.5f\n\", $eta+$eta_step}"`
done
