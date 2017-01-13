#!/bin/bash
# This is part of the rsyslog testbench, licensed under GPLv3
echo [imfile-wildcards-dirs.sh]

export IMFILEINPUTFILES="10"

. $srcdir/diag.sh init
# generate input files first. Note that rsyslog processes it as
# soon as it start up (so the file should exist at that point).
imfiledirbefore="rsyslog.input.dir1"

# Create first dir and file
mkdir $imfiledirbefore
./inputfilegen -m 1 > $imfiledirbefore/file.log

# Start rsyslog now before adding more files
. $srcdir/diag.sh startup imfile-wildcards-dirs.conf
# sleep a little to give rsyslog a chance to begin processing
sleep 1

for i in `seq 2 $IMFILEINPUTFILES`;
do
	cp -r $imfiledirbefore rsyslog.input.dir$i
	imfiledirbefore="rsyslog.input.dir$i"
done
ls -d rsyslog.input.*

# sleep a little to give rsyslog a chance for processing
sleep 1

. $srcdir/diag.sh shutdown-when-empty # shut down rsyslogd when done processing messages
. $srcdir/diag.sh wait-shutdown	# we need to wait until rsyslogd is finished!
. $srcdir/diag.sh content-check-with-count "HEADER msgnum:00000000:" $IMFILEINPUTFILES
. $srcdir/diag.sh exit
