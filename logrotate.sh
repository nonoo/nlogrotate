#!/bin/sh

scriptname=`basename $0`
scriptdir=${0/$scriptname/}

source $scriptdir/config

lf=$1
logcopytruncate=$2

if [ ! -f "$lf" ]; then
	exit 1
fi

echo "rotating $lf..."
if [ -f $lf.$keepcount ]; then
	echo "  removing $lf.$keepcount"
	rm $lf.$keepcount
fi

i=$((keepcount - 1))
while [ $i -ge 0 ]; do
	if [ -f $lf.$i ]; then
		echo "  moving $lf.$i to $lf.$((i + 1))"
		mv $lf.$i $lf.$((i + 1))
	fi
	i=$((i - 1))
done

if [ -z "$logcopytruncate" ]; then
	echo "  moving $lf to $lf.0"
	mv $lf $lf.0
else
	echo "  copying $lf to $lf.0"
	cp $lf $lf.0
	echo "  truncating $lf"
	truncate -s 0 $lf
fi
echo "  done."
