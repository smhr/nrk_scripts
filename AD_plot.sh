#!/bin/bash

############################# plotMe function
plotMe () {
	Path="$ADPath""/consMesh/2000_50.0""/b$magnet""/bc$bcType""/ADlimit$adLimit"

	echo "
	set fontpath '/usr/local/texlive/2013/texmf-dist/fonts/type1/public/amsfonts/cm/'
	set terminal post eps enhanced color fontfile 'cmsy10.pfb'
	
	set style fill  transparent solid 0.35 noborder
	set style circle radius 0.005

	set style line 1 lt 1 lw 5 pt 1 lc rgb \"black\"
	set style line 2 lt 2 lw 5 pt 1 lc rgb \"red\"
	set style line 3 lt 3 lw 5 pt 1 lc rgb \"orange\"
	set style line 4 lt 4 lw 5 pt 1 lc rgb \"green\"
	set style line 5 lt 5 lw 5 pt 1 lc rgb \"blue\"
	set style line 6 lt 6 lw 5 pt 1 lc rgb \"violet\"
	set style line 7 lt 7 lw 5 pt 1 lc rgb \"brown\"

	set style line 8 lt 8 lw 2 pt 1 lc rgb \"black\" # b0
	
	
	set key font \"$font,$fontSize\"
	set key spacing 2.5
	set ylabel font \"$font,$fontSize\"
	set xlabel font \"$font,$fontSize\"
	set xtics font \"$font,$fontSize\"
	set ytics font \"$font,$fontSize\"
	set size ratio 1
	#set grid
	
	set xl 'k'
	set yl '{/Symbol w}^2' offset -2
	set yr [-.2:0]
	set key right bottom title \"B = $magnet \"

	" > temp.plot
	echo "set output \"b$magnet""bc$bcType""ADl$adLimit"".eps\"" >> temp.plot

	echo "p \""$Path""/eta0/om-k.dat"\" "u 2:3 w l ls 1 t \"0\" ," \""$Path""/eta00000.01000/om-k.dat"\" "u 2:3 w l ls 2 t \"0.01\" ," \""$Path""/eta00000.10000/om-k.dat"\" "u 2:3 w l ls 3 t \"0.1\" ," \""$Path""/eta00001.00000/om-k.dat"\" "u 2:3 w l ls 4 t \"1\" ," \""$Path""/eta00010.00000/om-k.dat"\" "u 2:3 w l ls 5 t \"10\" ," \""$Path""/eta00100.00000/om-k.dat"\" "u 2:3 w l ls 6 t \"100\" ," "\"/media/d3/FUM_PROJ/nrk_no_AD/consMesh/2001_50.0/b0/om-k.dat\"" "u 2:3 w l ls 8 t \"B = 0\""


	" >> temp.plot

	gnuplot temp.plot
	pstool.sh > /dev/null
	rm temp.plot
}
#####################################
plotMe2 () {
        
	Path0_1="$ADPath""/consMesh/2000_50.0""/b0.1""/bc$bcType""/ADlimit$adLimit/eta00100.00000/om-k.dat"
	Path1="$ADPath""/consMesh/2000_50.0""/b1.0""/bc$bcType""/ADlimit$adLimit/eta00100.00000/om-k.dat"
	Path2="$ADPath""/consMesh/2000_50.0""/b2.0""/bc$bcType""/ADlimit$adLimit/eta00100.00000/om-k.dat"
	Path5="$ADPath""/consMesh/2000_50.0""/b5.0""/bc$bcType""/ADlimit$adLimit/eta00100.00000/om-k.dat"
	echo "
	set fontpath '/usr/local/texlive/2013/texmf-dist/fonts/type1/public/amsfonts/cm/'
	set terminal post eps enhanced color fontfile 'cmsy10.pfb'
	
	set style fill  transparent solid 0.35 noborder
	set style circle radius 0.005

	set style line 1 lt 1 lw 5 pt 1 lc rgb \"black\"
	set style line 2 lt 2 lw 5 pt 1 lc rgb \"red\"
	set style line 3 lt 3 lw 5 pt 1 lc rgb \"orange\"
	set style line 4 lt 4 lw 5 pt 1 lc rgb \"green\"
	set style line 5 lt 5 lw 5 pt 1 lc rgb \"blue\"
	set style line 6 lt 6 lw 5 pt 1 lc rgb \"violet\"
	set style line 7 lt 7 lw 5 pt 1 lc rgb \"brown\"

	set style line 8 lt 8 lw 2 pt 1 lc rgb \"black\" # b0
	
	
	set key font \"$font,$fontSize\"
	set key spacing 2.5
	set ylabel font \"$font,$fontSize\"
	set xlabel font \"$font,$fontSize\"
	set xtics font \"$font,$fontSize\"
	set ytics font \"$font,$fontSize\"
	set size ratio 1
	#set grid
	
	set xl 'k'
	set yl '{/Symbol w}^2' offset -2
	set yr [-.2:0]
	set key right bottom title \"{/Symbol h}=100 \"

	" > temp.plot
	echo "set output \"eta100""bc$bcType""ADl$adLimit"".eps\"" >> temp.plot

	echo "p \""$Path1"\" "u 2:3 w l ls 2 t \"B=1\" ," \""$Path2"\" "u 2:3 w l ls 3 t \"B=2\" ," \""$Path5"\" "u 2:3 w l ls 4 t \"B=5\" ," "\"/media/d3/FUM_PROJ/nrk_no_AD/consMesh/2001_50.0/b0/om-k.dat\"" "u 2:3 w l ls 8 t \"B=0\""


	" >> temp.plot

	gnuplot temp.plot
	pstool.sh > /dev/null
	rm temp.plot
}

	
#####################################
# source "$HOME/bin/FUM_PROJ_VARS.sh"
set -u ## exit when the script tries to use undeclared variables
numberExistingEps=$(find  -maxdepth 1 -name "*.eps" | wc -l)

if [ $numberExistingEps -gt 0 ]; then
	echo "WARNING! There exist $numberExistingEps eps file in current directory as"
	ls | grep eps
	exit
	
fi

bcType="4310"
adLimit="100"
eta="0"
fontSize="25", font="Courier"
# cd consMesh/2000_50.0"b$magnet""bc$bcType""ADl$adLimit"

magnet="0.1"
plotMe

magnet="0.5"
plotMe

magnet="1.0"
plotMe

magnet="2.0"
plotMe

magnet="5.0"
plotMe

plotMe2

mv ./*.eps $reportImagesPath


#####################################
	

	