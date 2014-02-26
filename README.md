logrotate
=========

A simple logrotate shell script I use in embedded enviroments.

logrotateifneeded.sh
--------------------
Rotates the file given in the first parameter if it's size is greater than
$maxlogsizeinkb, which can be set in logrotate's config. If a second parameter
is given, then copytruncate is used: it truncates the original log file to
zero size in place after creating a copy, instead of moving the old log file
and optionally creating a new one. It can be used  when some program cannot
be told to close its logfile and thus might continue writing (appending) to
the previous log file forever. Note that there is a very small time slice
between copying the file and truncating it, so some logging data might be
lost. When this option is used, the create option will have no effect, as
the old log file stays in place.

logrotate.sh
------------
Rotates the file given in the first parameter. If a second parameter is given,
then copytruncate is used (see logrotateifneeded.sh for explanation).

redirectlog.src.sh
------------------
This script should be sourced from other scripts which print log messages to
the standard output. If $quietmode is set, and redirectlog() is called, it
will redirect stdout to the file specified in $logfile and timestamps every
line. checklogsize() should be called periodically, which runs
logrotateifneeded.sh.

You have to set the following variables before sourcing the script:

$logfile: name of the logfile to redirect stdout to.
$logrotateifneeded: path to the logrotateifneeded.sh script.

Optional variables:

$logcopytruncate: if set to 1, log rotation will be done in the copytruncate
way (see the description of logrotateifneeded.sh).
$quietmode: if set other than 1, redirectlog.src.sh functions do nothing.
