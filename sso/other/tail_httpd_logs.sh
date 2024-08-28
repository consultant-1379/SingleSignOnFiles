#!/bin/bash

# Script to keep copy of httpd logs

HTTPD_LOG_FILE_DIR=/var/log/httpd
HTTPD_LOG_FILES="access_log error_log ssl_access_log ssl_error_log ssl_request_log"

while true; do
        if [ -d ${HTTPD_LOG_FILE_DIR} ]; then
                echo "httpd log dir now exists"
                cd ${HTTPD_LOG_FILE_DIR}
                for file in ${HTTPD_LOG_FILES}; do
                        if [ -f $file ]; then
                                echo "$file now exists, tailing"
                                tail -f ${file} > /tmp/${file} &
                        fi
                done
        fi
        sleep 10
done
