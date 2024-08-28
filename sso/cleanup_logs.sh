#!/bin/bash
MOD_TIME=3600
REF_FILE=/tmp/.reference_time
TOUCH=/bin/touch
ECHO=/bin/echo
CAT=/bin/cat
FIND=/bin/find
LOG_DIR=/var/log
PERL=/usr/bin/perl
FILESIZE_EXCEEDED_TO_DELETE=300M

l_1hoursago=$($PERL -w -e '@mytime=localtime (time - $ARGV[0]); printf "%02d%02d%02d%02d", $mytime[4]+1,$mytime[3],$mytime[2],$mytime[1];' ${MOD_TIME})

                        $TOUCH -t $l_1hoursago /tmp/.reference_time
                        $ECHO "Deleting files in  ${LOG_DIR} and its subdirectories older than ${MOD_TIME} seconds and greater than ${FILESIZE_EXCEEDED_TO_DELETE}"
                        for val in `$FIND ${LOG_DIR} ! -newer ${REF_FILE} -type f -size +${FILESIZE_EXCEEDED_TO_DELETE}`;
                        do
                                $ECHO "emptying log file : ${val}"
                                $CAT /dev/null > $val
                        done

exit 0
