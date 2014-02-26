# This script redirects stdout to a file and timestamps every line.
# The script should be sourced, not executed directly.

if [ -z "$logfile" ]; then
	echo "redirectlog error: no logfile name given."
	exit 1
fi

if [ -z "$logrotateifneeded" ] || [ ! -f "$logrotateifneeded" ]; then
	echo "redirectlog error: no logrotateifneeded script found."
	exit 1
fi

if [ ! -d "$logdir" ]; then
	echo "redirectlog error: no logdir given."
	exit 1
fi

if [ -z "$logpipe" ]; then
	echo "redirectlog error: no logpipe name given."
	exit 1
fi

checklogsize() {
	if [ "$quietmode" != "1" ]; then
		return
	fi

	$logrotateifneeded $logfile
	# If logrotate happened, the exit code of the script is 0.
	if [ $? -eq 0 ]; then
		redirectlog
	fi
}

redirectlog() {
	if [ "$quietmode" != "1" ]; then
		return
	fi

	# Creating the directory for the logfile if it doesn't exist
	logdir=`dirname $logfile`
	if [ ! -d $logdir ]; then
		mkdir -p $logdir
		chmod -f o+w $logdir
	fi

	logpipe=`echo $logfile | cut -f1 -d'.'`.pipe
	if [ -e $logpipe.pid ]; then
		kill -9 `cat $logpipe.pid` &>/dev/null
	fi
	rm -f $logpipe*

	# Creating pipe
	mknod $logpipe p

	# Reading from the log pipe and processing it.
	awk '{ print strftime("[%Y/%m/%d %H:%M:%S]"), $0; }' $logpipe >> $logfile &
	awkpid=$!
	echo $awkpid > $logpipe.pid

	# Setting up a trap to delete the pipe on exit
	trap "kill -9 $awkpid" INT TERM EXIT
	trap "rm -f $logpipe*" INT TERM EXIT

	# Closing stdout
	exec 1>&-

	# Redirecting stdout to the pipe
	exec 1>$logpipe
	exec 2>&1
}
