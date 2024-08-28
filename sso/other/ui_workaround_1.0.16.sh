#!/bin/bash

if [  ! -f /ericsson/tor/no_rollback/presentation_server/config/applications.xml ]; then
    cp /ericsson/tor/no_rollback/presentation_server/config/applications.xml.sample /ericsson/tor/no_rollback/presentation_server/config/applications.xml
fi
