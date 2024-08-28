#!/bin/bash

## Post install step to rename ssl conf file and restart apache
echo "waiting for /etc/httpd/conf.d/ssl.conf"

while true; do
     #for file in /etc/httpd/conf.d/10_ssl.conf /etc/httpd/conf.d/ssl.conf; do
     for file in /etc/httpd/conf.d/ssl.conf; do
             if [ -f $file ]; then
                echo "Renaming ${file} ${file}.OFF" > /tmp/sslconf.output
                mv ${file} ${file}.OFF
                exit
             fi
     done
sleep 10
done
