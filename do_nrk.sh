#!/bin/bash

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

####################################### do_nrk
	if [ "$1" == "-h" ] ; then
		echo "Usage: `basename $0` [N mesh] [2nd bound] [magnetic fied] [bcType] [ADlimit] [eta] [ome2stepInNoAD] [ome2minInNoAD] [ome2stepInLoop] [ome2minInLoop]"
		echo "Example: `basename $0` 2001 50.0 0.001 4310 100 100.0 0.002 -0.12 0.0001 -0.12"
		exit 0
	fi

	if [ ! $# -eq 10 ]; then
		echo "Must have 10 input arguments!"
		echo "Help: `basename $0` -h"
		exit 1
	fi
# 	echo $@
	noADPath="/media/d3/FUM_PROJ/nrk_no_AD"
	ADPath="/media/d3/FUM_PROJ/nrk_AD"
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
	0.2 0.2 0.010             # wave_n_up, wave_n_low, Dummy[wave_n_step]
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
	0.6 0.6 0.010             # wave_n_up, wave_n_low, Dummy[wave_n_step]
	$magnet                   # magnetic field
	" > nrk.ini_0.6
	
	nrk_no_AD.sh
	sort -n -k2 om-k.dat > om-k.dat.sorted
	mv om-k.dat.sorted om-k.dat
	
# 	mkdir eta0; cd eta0; ln -s ../om-k.dat .; cd ..
# 	omplot.sh 2 3 p t 1
	
	else
	
	echo -e "$noADPathRunDir""/brf_results is exist. Ignoring No_AD calculation.\n"
	
# 	mkdir eta0; cd eta0; ln -s ../om-k.dat .; cd ..
# 	omplot.sh 2 3 p t 1
	
	fi
	
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
	
	nrk_with_brf_result.sh $eta 1
	else
	echo -e "eta$eta"" is exist. Ignoring AD no-loop calculation.\n"
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
	
	if [ ! $ome2Left = $ome2Right ]; then
# 	ls ./brf_results -x1 | tail -3
		leftLoop=$(ls ./brf_results -x1 | tail -3 | head -1)
		rightLoop=$(ls ./brf_results -x1 | tail -2 | head -1)
		ome2Left=`echo "-"$leftLoop | awk -F '[_]' '{print $1}'`
		wave_nLeft=`echo $leftLoop | awk -F '[_]' '{print $2}'`
		ome2Right=$(echo "-"$rightLoop | awk -F '[_]' '{print $1}')
		wave_nRight=$(echo $rightLoop | awk -F '[_]' '{print $2}')
	fi
# 	echo "$leftLoop"" #### ""$rightLoop"
# 	echo "$ome2Left $wave_nLeft $ome2Right $wave_nRight"
# 	exit
# 	[ -d "loop" ] && rm -r ./loop
	mkdir loop
	cd loop
	cp ../brf_results/$leftLoop result.dat.org
	##################### left loop
# 	ome2Left=`echo "-"$leftLoop | awk -F '[_]' '{print $1}'`
# 	wave_nLeft=`echo $leftLoop | awk -F '[_]' '{print $2}'`
# 	ome2Right=$(echo "-"$rightLoop | awk -F '[_]' '{print $1}')
# 	wave_nRight=$(echo $rightLoop | awk -F '[_]' '{print $2}')
	
	# echo $leftLoop
	# echo $ome2Left
	# echo $wave_n
	# exit
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
# 	NRK_AD_brf_loop.exe | grep "yes"
	# cp om-k.dat om-k.dat.l
	##################### right loop
	# rightLoop=`ls ../brf_results -x1 | tail -1`
	# echo $rightLoop
	# ls ..
	# pwd
	cp ../brf_results/$rightLoop result.dat.org
	######################
# 	ome2Right=$(echo "-"$rightLoop | awk -F '[_]' '{print $1}')
# 	wave_nRight=$(echo $rightLoop | awk -F '[_]' '{print $2}')
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
# 	NRK_AD_brf_loop.exe | grep "yes"
	######################
	
	cat om-k.dat >> ../om-k.dat
	sort -n -k2 ../om-k.dat > ../om-k.dat.sorted
	mv ../om-k.dat.sorted ../om-k.dat
	
#######################################
# do_nrk 2001 50.0 0.001 4310 100 0.001 0.002 -0.12 0.0001 -0.14
# do_nrk 2001 50.0 0.001 4310 100 0.01 0.002 -0.12 0.0001 -0.12
# do_nrk 2001 50.0 0.001 4310 100 0.1 0.002 -0.12 0.0001 -0.12
# do_nrk 2001 50.0 0.001 4310 100 1.0 0.002 -0.12 0.0001 -0.12
# do_nrk 2001 50.0 0.001 4310 100 10.0 0.002 -0.12 0.0001 -0.12
# do_nrk 2001 50.0 0.001 4310 100 100.0 0.002 -0.12 0.0001 -0.12

# do_nrk 2001 50.0 2.0 4310 100 1.0 0.002 -0.0905 0.0005 -0.1
	# meshNumber="2001"
	# secondBound="50.0"
	# magnet="2.0"
	# bcType="4310"
	# adLimit="100"
	# eta="1.0"
	# 
	# ome2stepInNoAD='0.002'
	# ome2minInNoAD='-0.0905'
	# ome2stepInLoop='0.0005'
	# ome2minInLoop='-0.1'