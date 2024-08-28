#!/bin/bash

UI_JBOSS_IP=`ps -ef | grep UI | grep Xmx | egrep -o  "\-Djboss\.bind\.address=[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+"|awk -F\= '{print $NF}' | head -1`
SI_INSTANCE=`ls /home/jboss | grep UIServ_si_`
JBOSS_CLI="/home/jboss/${SI_INSTANCE}/bin/jboss-cli.sh --controller=${UI_JBOSS_IP}:9999 -c"

cat /home/jboss/${SI_INSTANCE}/standalone/configuration/standalone-full-ha.xml | grep -i modcluster

service iptables stop

        $JBOSS_CLI << EOF
connect
        /extension=org.jboss.as.modcluster:add
        /:composite(steps=[ \
        {"operation" => "add", "address" => [("subsystem" => "modcluster")]}, \
        {"operation" => "add", "address" => [("subsystem" => "modcluster"), \
        ("mod-cluster-config" => "configuration")], \
        "advertise-socket" => "modcluster", "connector" => "http"}, \
        {"operation" => "add", "address" => [("socket-binding-group" => "standard-sockets"), \
        ("socket-binding" => "modcluster")], \
        "multicast-address" => "\${jboss.modcluster.multicast.address:224.0.1.105}", \
        "port" => "0", "multicast-port" => "23364" }])
EOF

 cat /home/jboss/${SI_INSTANCE}/standalone/configuration/standalone-full-ha.xml | grep -i modcluster
