#!/bin/bash

## must be run in brf_results directory
## $1 is the value of converged k
## $2 is the column number in the file
## $3 is the type of plot: p, l or lp
## $4 is the legend option

if [ $4 = "nt" ]; then
## without legend
ls "$1"* | sed 's/$/\"/' | sed 's/^/\"/' | sed "s/$/ u 1:"$2" t \"\" w "$3", /" | tr '\n' ' ' | sed 's/...$//' | sed 's/^/plot /' > temp.plot

elif [ $4 = "t" ]; then
## with legend
ls "$1"* | sed 's/$/\"/' | sed 's/^/\"/' | sed "s/$/ u 1:"$2" w "$3", /" | tr '\n' ' ' | sed 's/...$//' | sed 's/^/plot /' > temp.plot
fi

echo "" >> temp.plot
echo "pause -1" >> temp.plot
gnuplot temp.plot
rm temp.plot
