#!/bin/bash

## must be run in all_result's parent directory
## $1 is the column number in the file.
## $2 is the type of plot: p, l or lp

ls all_results/*0.3724* | sed 's/$/\"/' | sed 's/^/\"/' | sed "s/$/ u 1:"$1" w "$2", /" | tr '\n' ' ' | sed 's/...$//' | sed 's/^/plot /' > temp.plot
echo "" >> temp.plot
echo "pause -1" >> temp.plot
gnuplot temp.plot
rm temp.plot
