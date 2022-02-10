#!/bin/bash

if [ ! -d "data" ] ; then
  echo "no 'data' directory"
fi

percentile_script=$(which percentile.py)
if [ "$percentile_script" == "" ] ; then
  if [ ! -x percentile.py ] ; then
    curl -opercentile.py https://raw.githubusercontent.com/ccicconetti/serverlessonedge/master/scripts/percentile.py >& /dev/null
    if [ $? -ne 0 ] ; then
      echo "error downloading the percentile.py script"
    fi
    chmod 755 percentile.py
  fi
  percentile_script=./percentile.py
fi

if [ ! -d "post" ] ; then
  mkdir post 2> /dev/null
fi

flows="10 20 50 100 200 500 1000 2000 5000 10000"
mus="50 100"
eprs="constant uniform"
columns=(20 21 22 25 26)
names=("num-edges" "min-degree" "max-degree" "diameter" "tot-capacity")

mus="50 100"
linkthresholds="15000 20000"
linkprobabilities="0.5 0.75 1"

for m in $mus ; do
  for t in $linkthresholds ; do
    for i in ${!columns[@]}; do
      outmangle=${names[$i]}-$m-$t
      echo "$outmangle"
      outfile=post/$outmangle.dat
      rm -f $outfile 2> /dev/null
      for p in $linkprobabilities ; do
        inmangle=out-$m-$t-$p
        datafile=data/$inmangle.csv
        value=$($percentile_script --delimiter , --column ${columns[$i]} --mean < $datafile | cut -f 1,3 -d ' ')
        echo $p $value >> $outfile
      done
    done
  done
done
