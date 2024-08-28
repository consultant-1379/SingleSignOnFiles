#!/bin/bash


for su in $( amf-find su all | grep httpd ); do
                amf-adm lock $su
                amf-adm unlock $su
done
amf-find su all | grep httpd
