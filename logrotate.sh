#!/bin/sh

self=`readlink "$0"`
if [ -z "$self" ]; then
	self=$0
fi
scriptname=`basename "$self"`
scriptdir=${self%$scriptname}

. $scriptdir/config

lf=$1
logcopytruncate=$2

if [ ! -f "$lf" ]; then
	exit 1
fi

if [ $keepcount -lt 1 ]; then
	echo "keepcount is $keepcount, no need to rotate."
	exit 0
fi

lastcount=$((keepcount - 1))

echo "rotating $lf..."
if [ -f $lf.$lastcount ]; then
	echo "  removing $lf.$lastcount"
	rm $lf.$lastcount
fi

i=$((lastcount - 1))
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
