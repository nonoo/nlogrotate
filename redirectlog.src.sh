# The script should be sourced, not executed directly.

if [ -z "$nlogrotatepath" ] || [ ! -d "$nlogrotatepath" ]; then
	echo "redirectlog error: nlogrotate path not found."
	exit 1
fi

if [ -z "$logfile" ]; then
	echo "redirectlog error: no logfile name given."
	exit 1
fi

logrotateifneededscript=$nlogrotatepath/logrotateifneeded.sh

if [ -z "$logrotateifneededscript" ] || [ ! -f "$logrotateifneededscript" ]; then
	echo "redirectlog error: no logrotateifneeded script found."
	exit 1
fi

checklogsize() {
	if [ "$quietmode" != "1" ]; then
		return
	fi

	$logrotateifneededscript $logfile $logcopytruncate
	local logrotateifneededresult=$?
	if [ -z "$logcopytruncate" ]; then
		# If logrotate happened, the exit code of the script is 0.
		# When not using logcopytruncate, we have to reinit stdout redirection.
		if [ $logrotateifneededresult -eq 0 ]; then
			redirectlog
		fi
	fi
}

# This function redirects stdout to a file and timestamps every line.
redirectlog() {
	if [ "$quietmode" != "1" ]; then
		return
	fi

	# Creating the directory for the logfile if it doesn't exist
	local logdir=`dirname $logfile`
	if [ ! -d $logdir ]; then
		mkdir -p $logdir
	fi

	# The pipe's filename is the log file name without extension.
	local logpipe=`echo $logfile | sed -r 's/\.[^\.]+$//'`.pipe
	if [ -e $logpipe.pid ]; then
		kill -9 `cat $logpipe.pid`
	fi
	rm -f $logpipe*

	# Creating pipe
	mknod $logpipe p

	# Reading from the log pipe and processing it.
	stdbuf -i0 -o0 -e0 awk '{ print strftime("[%Y/%m/%d %H:%M:%S]"), $0; }' $logpipe >> $logfile &
	local awkpid=$!
	echo $awkpid > $logpipe.pid

	# Closing stdout
	exec 1>&-

	# Setting up a trap to delete the pipe on exit
	trap "rm -f $logpipe*" INT TERM EXIT

	# Redirecting stdout to the pipe
	exec 1>$logpipe
	exec 2>&1
}
