#!/usr/bin/env bash

# -----------------------------------------------------------------------------
#
# Copyright (C) 2019 AT&T Intellectual Property and Nokia
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# -----------------------------------------------------------------------------

#	Mnemonic:	publish
#	Abstract:	Simple script which copies files that the build script left
#				for export (packages, but could be anything). This expects
#				that all files in /tmp/exportd are to be copied to the 
#				export directory /export The export directory is assumed to be
#				mounted from the outside world as /export, though we will use $1
#				as an override so this can be changed if needed.
#
#	Date:		30 July 2019
#
# -----------------------------------------------------------------------------

# This file is copied from  ric-plt/lib/rmr ci/publish.sh.
#

echo "$0 starting" >&2
argv0=${0##*/}

target=${1:-/export}
exportd=/tmp/exported		# build script dumps here

if ! cd $target
then
	echo "$argv0: abort: cannot find or switch to: $target" >&2
	exit 1
fi

if [[ ! -w ./ ]]
then
	echo "$argv0: abort: cannot write to target directory: $target"
	exit 1
fi

if [[ ! -d $exportd ]]
then
	echo "$argv0: abort: unable to find the exported directory: $exportd" >&2
	exit 1
fi

errors=0
echo "$argv0: copy: $exportd/* --> $target" >&2
if ! cp -v $exportd/* $target/
then
	errors=1
fi

echo "$argv0: finshed, $errors errors"
exit $errors
