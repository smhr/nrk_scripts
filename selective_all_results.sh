#!/bin/bash

## must be run in all_result's parent directory

ls all_results/*0.3724* | sed 's/$/\"/' | sed 's/^/\"/' | sed "s/$/ u 1:"$1", /" | tr '\n' ' ' | sed 's/...$//' | sed 's/^/plot /' > temp.plot
echo "" >> temp.plot
echo "pause -1" >> temp.plot
gnuplot temp.plot
rm temp.plot
