#!/bin/bash

## must be run in eta`s parent directory
## $1 must be 2 for converged k
## $2 must be 3 for omega
## $3 is the type of plot: p, l or lp
## $4 is the legend option
## $5 is every option

## example: omplot.sh 2 3 p t 1
echo "
set style fill  transparent solid 0.35 noborder
set style circle radius 0.05
" > temp.plot

if [ $4 = "nt" ]; then
## without legend
ls eta*/om-k.dat | sed 's/$/\"/' | sed 's/^/\"/' | sed "s/$/ every "$5" u "$1":"$2" t \"\" w "$3", /" | tr '\n' ' ' | sed 's/...$//' | sed 's/^/plot /' >> temp.plot

elif [ $4 = "t" ]; then
## with legend
ls eta*/om-k.dat | sed 's/$/\"/' | sed 's/^/\"/' | sed "s/$/ every "$5"u "$1":"$2" w "$3", /" | tr '\n' ' ' | sed 's/...$//' | sed 's/^/plot /' >> temp.plot
fi

echo "" >> temp.plot
echo "pause -1" >> temp.plot
gnuplot temp.plot
#rm temp.plot
