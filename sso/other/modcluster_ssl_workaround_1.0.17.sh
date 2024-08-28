#!/bin/bash

## Post install step to rename ssl conf file and restart apache

for file in /etc/httpd/conf.d/10_ssl.conf /etc/httpd/conf.d/ssl.conf; do
             if [ -f $file ]; then
                echo "Renaming ${file} ${file}.OFF"
                mv ${file} ${file}.OFF
             else
                echo "$file not found"
             fi
             
done
