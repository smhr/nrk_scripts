#!/bin/bash

## must be run in eta`s parent directory
## $1 is the eta value
## $2 is the value of converged k
## $3 is the column number in the file
## $4 is the type of plot: p, l or lp
## $5 is the legend option
## $6 is every option

## example: etaplot.sh 000000.1 0.22 8 p t 10
echo "
set style fill  transparent solid 0.35 noborder
set style circle radius 0.05
" > temp.plot

if [ $5 = "nt" ]; then
## without legend
ls eta"$1"*/brf*/"$2"* | sed 's/$/\"/' | sed 's/^/\"/' | sed "s/$/ every "$6" u 1:"$3" t \"\" w "$4", /" | tr '\n' ' ' | sed 's/...$//' | sed 's/^/plot /' >> temp.plot

elif [ $5 = "t" ]; then
## with legend
ls eta"$1"*/brf*/"$2"* | sed 's/$/\"/' | sed 's/^/\"/' | sed "s/$/ every "$6"u 1:"$3" w "$4", /" | tr '\n' ' ' | sed 's/...$//' | sed 's/^/plot /' >> temp.plot
fi

echo "" >> temp.plot
echo "pause -1" >> temp.plot
gnuplot temp.plot
rm temp.plot
