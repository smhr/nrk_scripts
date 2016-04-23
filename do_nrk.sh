#!/usr/bin/env bash

####################################### printInputs
	function printInputs {
	echo "
	Input Variables:
	##############################################
        $meshNumber 		# Number of meshpoints
	$secondBound 		# 2nd boundary
	$magnet 		# magnetic field
	$bcType 		# bcType
	$adLimit 		# ADlimit
	$eta		# eta
	
	$ome2stepInNoAD		# ome^2 step in NoAD
	$ome2minInNoAD 		# ome^2 min in NoAD
	$ome2stepInLoop		# ome^2 step in ADloop
	$ome2minInLoop 		# ome^2 min in ADloop
	##############################################
	"
	}
####################################### omPlot	
	function omPlot {
	every="1"; with="l"; lw="3"
	fontSize="20", font="Courier"
	echo "
	set fontpath '/usr/local/texlive/2013/texmf-dist/fonts/type1/public/amsfonts/cm/'
	set terminal post eps enhanced color fontfile 'cmsy10.pfb'
	
	set style fill  transparent solid 0.35 noborder
	set style circle radius 0.005
	
	set key font \"$font,17\"
	set ylabel font \"$font,$fontSize\"
	set xlabel font \"$font,$fontSize\"
	set xtics font \"$font,$fontSize\"
	set ytics font \"$font,$fontSize\"
	set size ratio 1
	set grid
	
	set xl 'k'
	set yl '{/Symbol w}^2' offset -1
	set yr [-.2:0]
	set key center bottom title \"B = $magnet \"

	" > temp.plot
	echo "set output \"b$magnet""bc$bcType""ADl$adLimit"".eps\"" >> temp.plot

# 	ls eta*/om-k.dat | sed 's/$/\"/' | sed 's/^/\"/' | sed "s/$/ every "$every" u 2:3 t \"\" w "$with", /" | tr '\n' ' ' | sed 's/...$//' | sed 's/^/plot /' >> temp.plot
	ls eta*/om-k.dat | sed 's/$/\"/' | sed 's/^/\"/' | sed "s/$/ u 2:3 w "$with" lw "$lw", /" | tr '\n' ' ' | sed 's/...$//' | sed 's/^/plot /' >> temp.plot

	echo "" >> temp.plot
	gnuplot temp.plot
	rm temp.plot
	}

####################################### do_nrk
	set -u ## exit when the script tries to use undeclared variables
# 	set -x ## trace what gets executed. Useful for debugging
	source "$HOME/bin/FUM_PROJ_VARS.sh"
	if [ "$1" == "-h" ] ; then
		echo "Usage: `basename $0` [N mesh] [2nd bound] [magnetic fied] [bcType] [ADlimit] [eta] [ome2stepInNoAD] [ome2minInNoAD] [ome2stepInLoop] [ome2minInLoop] [waveLeft] [waveRight]"
		echo "Example: `basename $0` 2001 50.0 0.001 4310 100 100.0 0.002 -0.12 0.0001 -0.12 0.1 0.6"
		exit 0
	fi

	if [ ! $# -eq 12 ]; then
		echo "Must have 12 input arguments!"
		echo "Help: `basename $0` -h"
		exit 1
	fi

#	runTypeMode="test"
 	runTypeMode="production"
	meshType="consMesh"
	# if [ "$meshType" = "consMesh" ] then; MeshSelector="0" ; fi
	meshNumber="$1"
	secondBound="$2"
	meshNB="$meshNumber""_$secondBound"
	# echo $meshNB
	magnet="$3"
	bcType="$4"
	adLimit="$5"
	eta="$6"
	
	ome2stepInNoAD="$7"
	ome2minInNoAD="$8"
	ome2stepInLoop="$9"
	ome2minInLoop=${10}
	waveLeft=${11}
	waveRight=${12}
	printInputs 
	
	noADPathRunDir="$noADPath""/$meshType""/$meshNB""/b$magnet"
	
	####################################### Preparing No_AD calculation
	echo -e "\nGoing to $noADPathRunDir\n"
	if [ ! -d "$noADPathRunDir""/brf_results" ]; then
	
	echo -e "######### Starting nrk_no_AD.sh #########\n"
	
	mkdir -p $noADPathRunDir
	
	cd $noADPathRunDir
	# pwd
	
	echo "$meshNumber               # Number of meshpoints
	5                         # Number of equations
	3 2                       # Number of boundary conditions at first meshpoint and final meshpoint
	$secondBound              # 2nd boundary
	15                        # max num of iterations before giving up
	1.d0                      # convergence speed (do not change unless good reason)
	1.d-7                    # desired accuracy of solution
	0                         # mesh_selector
	-0.001 $ome2minInNoAD $ome2stepInNoAD     # ome2_up, ome2_low, ome2_step
	$waveLeft $waveLeft 0.010             # wave_n_up, wave_n_low, Dummy[wave_n_step]
	$magnet                   # magnetic field
	" > nrk.ini_0.1
	
	echo "$meshNumber               # Number of meshpoints
	5                         # Number of equations
	3 2                       # Number of boundary conditions at first meshpoint and final meshpoint
	$secondBound              # 2nd boundary
	15                        # max num of iterations before giving up
	1.d0                      # convergence speed (do not change unless good reason)
	1.d-7                    # desired accuracy of solution
	0                         # mesh_selector
	-0.001 $ome2minInNoAD $ome2stepInNoAD     # ome2_up, ome2_low, ome2_step
	$waveRight $waveRight 0.010             # wave_n_up, wave_n_low, Dummy[wave_n_step]
	$magnet                   # magnetic field
	" > nrk.ini_0.6
	
	[ $runTypeMode = "production" ] &&  nrk_no_AD.sh
	
	sort -n -k2 om-k.dat > om-k.dat.sorted
	mv om-k.dat.sorted om-k.dat
	
# 	mkdir eta0; cd eta0; ln -s ../om-k.dat .; cd ..
# 	omplot.sh 2 3 p t 1
	
	else
	
	echo -e "$noADPathRunDir""/brf_results exists. Ignoring No_AD calculation.\n"
	
# 	mkdir eta0; cd eta0; ln -s ../om-k.dat .; cd ..
# 	omplot.sh 2 3 p t 1
	
	fi
	
	[ "$magnet" -eq 0 ] && exit
	####################################### Preparing AD calculation
	eta=`awk "BEGIN {printf \"%011.5f\n\", $eta}"`
	let meshNumber=meshNumber-1
	meshNB="$meshNumber""_$secondBound"
	ADPathRunDir="$ADPath""/$meshType""/$meshNB""/b$magnet"
	mkdir -p $ADPathRunDir
	cd $ADPathRunDir
	mkdir -p "bc$bcType"
	cd "bc$bcType"
	mkdir -p eta0
	cd eta0
	ln -sf $noADPathRunDir"/brf_results" .
	ln -sf $noADPathRunDir"/om-k.dat" .
	cd ..
	mkdir -p "ADlimit$adLimit"
	cd "ADlimit$adLimit"
	echo -e "Going to $PWD""/eta$eta"" \n"
	# mkdir -p "eta$eta"
	# cd "eta$eta"
	
	if [ ! -d "eta$eta" ]; then
	
	echo -e "######### Starting nrk_with_brf_result.sh ""$eta 1 #########\n"
	
	echo "$meshNumber         # Number of meshpoints
	7                         # Number of equations
	4 3                       # Number of boundary conditions at first meshpoint and final meshpoint
	$secondBound              # 2nd boundary
	20                        # max num of iterations before giving up
	1.d0                      # convergence speed (do not change unless good reason)
	1.d-10                    # desired accuracy of solution
	$bcType                   # bcType
	ome2_up ome2_low 0.01     # ome2_up, ome2_low, Dummy[ome2_step]
	wave_n_up wave_n_low 0.05 # wave_n_up, wave_n_low, Dummy[wave_n_step]
	$magnet                   # magnetic field
	$eta                      # eta
	$adLimit".d0"             # ADlimit
	" > nrk.ini.org
	
	[ $runTypeMode = "production" ] && nrk_with_brf_result.sh $eta 1
	else
	echo -e "eta$eta"" exists. Ignoring AD no-loop calculation.\n"
	fi
	####################################### Preparing loop
	eta=`awk "BEGIN {printf \"%011.5f\n\", $eta}"`
	cd "eta$eta"
# 	ls ./brf_results -x1
	leftLoop=`ls ./brf_results -x1 | tail -2 | head -1`
	rightLoop=`ls ./brf_results -x1 | tail -1`
	ome2Left=`echo "-"$leftLoop | awk -F '[_]' '{print $1}'`
	wave_nLeft=`echo $leftLoop | awk -F '[_]' '{print $2}'`
	ome2Right=$(echo "-"$rightLoop | awk -F '[_]' '{print $1}')
	wave_nRight=$(echo $rightLoop | awk -F '[_]' '{print $2}')

	n3LinesFromEnd=3
	while [ ! $ome2Left = $ome2Right ]; do
		n2LinesFromEnd=$(( $n3LinesFromEnd - 1 ))
		leftLoop=$(ls ./brf_results -x1 | tail -$n3LinesFromEnd | head -1)
		rightLoop=$(ls ./brf_results -x1 | tail -$n2LinesFromEnd | head -1)
		ome2Left=`echo "-"$leftLoop | awk -F '[_]' '{print $1}'`
		wave_nLeft=`echo $leftLoop | awk -F '[_]' '{print $2}'`
		ome2Right=$(echo "-"$rightLoop | awk -F '[_]' '{print $1}')
		wave_nRight=$(echo $rightLoop | awk -F '[_]' '{print $2}')
		n3LinesFromEnd=$(( $n3LinesFromEnd + 1 ))
	done
# 	echo "$leftLoop"" #### ""$rightLoop"
# 	echo "$ome2Left $wave_nLeft $ome2Right $wave_nRight"
	if [ $runTypeMode = "production" ] && [ ! -d "loop" ]; then #&& rm -r ./loop
	mkdir loop
	cd loop
	cp ../brf_results/$leftLoop result.dat.org
	##################### left loop
	echo "$meshNumber         # Number of meshpoints
	7                         # Number of equations
	4 3                       # Number of boundary conditions at first meshpoint and final meshpoint
	$secondBound              # 2nd boundary
	15                        # max num of iterations before giving up
	1.d0                      # convergence speed (do not change unless good reason)
	1.d-10                    # desired accuracy of solution
	$bcType                   # bcType
	$ome2Left $ome2minInLoop $ome2stepInLoop     # ome2_up, ome2_low, ome2_step
	$wave_nLeft  $wave_nLeft 0.01 # wave_n_up, wave_n_low, wave_n_step
	$magnet                   # magnetic field
	$eta                      # eta
	$adLimit".d0"             # ADlimit
	" > nrk.ini
	echo -e "######### Starting AD left loop for ""$leftLoop"" as guess #########\n"
	[ $runTypeMode = "production" ] && NRK_AD_brf_loop.exe | grep "yes"
	# cp om-k.dat om-k.dat.l
	##################### right loop
	cp ../brf_results/$rightLoop result.dat.org

	echo "$meshNumber         # Number of meshpoints
	7                         # Number of equations
	4 3                       # Number of boundary conditions at first meshpoint and final meshpoint
	$secondBound              # 2nd boundary
	15                        # max num of iterations before giving up
	1.d0                      # convergence speed (do not change unless good reason)
	1.d-10                    # desired accuracy of solution
	$bcType                   # bcType
	$ome2Right $ome2minInLoop $ome2stepInLoop     # ome2_up, ome2_low, ome2_step
	$wave_nRight $wave_nRight 0.01 # wave_n_up, wave_n_low, wave_n_step
	$magnet                   # magnetic field
	$eta                      # eta
	$adLimit".d0"             # ADlimit
	" > nrk.ini
	echo -e "######### Starting AD right loop for ""$rightLoop"" as guess #########\n"
	[ $runTypeMode = "production" ] && NRK_AD_brf_loop.exe | grep "yes"
	######################
	
	cat om-k.dat >> ../om-k.dat
	sort -n -k2 ../om-k.dat > ../om-k.dat.sorted
	mv ../om-k.dat.sorted ../om-k.dat
	cd ../..
	else
	echo -e "loop directory"" exists. Ignoring AD loop calculation.\n"
	cd ..
	fi
	
	########### Preparing plot
# 	cd ../..
	rm ./*.eps
	[ ! -L "./eta0" ] && ln -s ../eta0 .
	echo " ########## Ploting ##########"
	omPlot
	pstool.sh > /dev/null
	cp ./*.eps $reportImagesPath
	
	
	
#######################################
# do_nrk 2001 50.0 0.001 4310 100 0.001 0.002 -0.12 0.0001 -0.14
# do_nrk 2001 50.0 0.001 4310 100 0.01 0.002 -0.12 0.0001 -0.12
# do_nrk 2001 50.0 0.001 4310 100 0.1 0.002 -0.12 0.0001 -0.12
# do_nrk 2001 50.0 0.001 4310 100 1.0 0.002 -0.12 0.0001 -0.12
# do_nrk 2001 50.0 0.001 4310 100 10.0 0.002 -0.12 0.0001 -0.12
# do_nrk 2001 50.0 0.001 4310 100 100.0 0.002 -0.12 0.0001 -0.12
