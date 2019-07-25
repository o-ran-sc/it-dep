#!/bin/bash
# Verifies a RIC helm chart that depends on ric-common
# Requires ric-common archive in /tmp
commonfile=ric-common*.tgz
common=/tmp/$commonfile
if [ ! -f $common ]; then
  echo "Failed to find $common"
  exit 1
fi
dir=$1
echo "Processing chart directory $dir"
chartsdir=$dir/charts
if [ ! -d $chartsdir ]; then
  echo "Creating $chartsdir"
  mkdir $chartsdir
fi
if [ ! -f $chartsdir/$commonfile ]; then
  echo "Adding link to common archive in $chartsdir"
  ln -s $common $chartsdir
fi
helm lint $1
helm template $1
