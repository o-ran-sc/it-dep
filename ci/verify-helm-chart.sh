#!/bin/bash
##############################################################################
#
#   Copyright (c) 2019 AT&T Intellectual Property.
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.
#
##############################################################################

# Installs well-known RIC charts then verifies specified helm chart
# Requires chart tgz archives in /tmp

commonfile="ric-common*.tgz"
common=(/tmp/$commonfile)
if [ ! -f "$common" ]; then
  echo "$0: Failed to find $common"
  exit 1
fi
dir=$1
echo "Processing chart directory $dir"
chartsdir=$dir/charts
if [ ! -d "$chartsdir" ]; then
  echo "$0: Creating $chartsdir"
  mkdir "$chartsdir"
fi
if [ ! -f "$chartsdir/$commonfile" ]; then
  echo "$0: Adding link to common archive in $chartsdir"
  ln -s "$common" "$chartsdir"
fi
# Lint clearly marks errors; e.g., [ERROR]
cmd="helm lint $1"
echo "$0: $cmd"
$cmd
# Template emits garbage, no error messages
cmd="helm template $1"
echo "$0: $cmd"
$cmd
