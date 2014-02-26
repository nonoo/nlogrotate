#!/bin/sh

scriptname=`basename $0`
scriptdir=${0/$scriptname/}

source $scriptdir/config

lf=$1
logcopytruncate=$2

if [ ! -f "$lf" ]; then
	exit 2
fi

if [ `$du --apparent-size $lf | awk '{print $1}'` -gt $maxlogsizeinkb ]; then
	echo "logfile \"$lf\" is over size, needs rotating."
	$scriptdir/logrotate.sh $lf $logcopytruncate

	exit 0
fi

exit 1
