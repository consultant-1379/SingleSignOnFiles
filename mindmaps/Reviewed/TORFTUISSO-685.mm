<map version="0.9.0">
<!-- To view this file, download free mind mapping software FreeMind from http://freemind.sourceforge.net -->
<node CREATED="1336037971857" ID="ID_150542004" MODIFIED="1370338407322" TEXT="TORFTUISSO-685">
<node CREATED="1336037984024" ID="ID_679454563" MODIFIED="1360756327740" POSITION="right" TEXT="Functional Tests">
<node CREATED="1336038105179" HGAP="154" ID="ID_404950472" MODIFIED="1370338241633" TEXT="SSO_Rsyslog_Func_1" VSHIFT="-20">
<node CREATED="1336039735424" ID="ID_416732176" MODIFIED="1366215037185" TEXT="COMPONENT: SSO-log-collector.sh"/>
<node CREATED="1336038744773" ID="ID_690087273" MODIFIED="1366213009176" TEXT="DESCRIPTION: Verify that OpenAM logs are redirected to syslog"/>
<node CREATED="1336038752013" ID="ID_503780013" MODIFIED="1355738443642" TEXT="PRIORITY: HIGH"/>
<node CREATED="1336038780830" ID="ID_1585817280" MODIFIED="1370336195854" TEXT="GROUP: ssologger"/>
<node CREATED="1336038860069" ID="ID_248228929" MODIFIED="1370342405587" TEXT="PRE: OpenAm is producing logs in /var/log/sso, UpdateSymlink.sh and SSO-log-collector.sh is installed and running, UpdateSymlink is creating and updating Links"/>
<node CREATED="1336038805518" HGAP="50" ID="ID_1348894701" MODIFIED="1370338161072" TEXT="EXECUTE: Start SSO-log-collector.sh ">
<node CREATED="1336038832124" HGAP="18" ID="ID_1459976699" MODIFIED="1370338228251" TEXT="VERIFY: OpenAM logs are getting redirected to syslog via SSO-log-collector.sh as it is reading the content of the Link files created by UpdateSymlink.sh" VSHIFT="3"/>
</node>
<node CREATED="1336039548353" HGAP="46" ID="ID_1682642370" MODIFIED="1360761143526" TEXT="VUSERS: 1" VSHIFT="-8"/>
<node CREATED="1343750957036" HGAP="41" ID="ID_1597637460" MODIFIED="1366213912731" TEXT="CONTEXT:API" VSHIFT="-1"/>
</node>
<node CREATED="1336038105179" HGAP="154" ID="ID_542723471" MODIFIED="1370338095713" TEXT="SSO_Rsyslog_Func_2" VSHIFT="-45">
<node CREATED="1336039735424" ID="ID_1476593305" MODIFIED="1370336012198" TEXT="COMPONENT: UpdateSymlink.sh"/>
<node CREATED="1336038744773" ID="ID_448269718" MODIFIED="1370336106604" TEXT="DESCRIPTION: Verify that Links are getting created and updated as OpenAm is producing logs in /var/log/sso"/>
<node CREATED="1336038752013" ID="ID_1201743211" MODIFIED="1355738443642" TEXT="PRIORITY: HIGH"/>
<node CREATED="1336038780830" ID="ID_1622040620" MODIFIED="1370336185583" TEXT="GROUP: ssologger"/>
<node CREATED="1336038860069" ID="ID_1834144637" MODIFIED="1370342430171" TEXT="PRE: UpdateSymlink.sh is installed and running, OpenAm is producing logs in /var/log/sso"/>
<node CREATED="1336038805518" ID="ID_1427977380" MODIFIED="1370336239139" TEXT="EXECUTE: OpenAm is producing logs ">
<arrowlink DESTINATION="ID_1427977380" ENDARROW="Default" ENDINCLINATION="0;0;" ID="Arrow_ID_1157462945" STARTARROW="None" STARTINCLINATION="0;0;"/>
<node CREATED="1336038832124" ID="ID_529625491" MODIFIED="1370336285283" TEXT="VERIFY: UpdateSymlink is creating then updating the Links so that they always point to the latest log files"/>
</node>
<node CREATED="1336039548353" ID="ID_637640928" MODIFIED="1355738558483" TEXT="VUSERS: 1"/>
<node CREATED="1343750957036" ID="ID_1590849561" MODIFIED="1359459006495" TEXT="CONTEXT: UI"/>
</node>
<node CREATED="1336038105179" HGAP="155" ID="ID_1141404047" MODIFIED="1370338101737" TEXT="SSO_Rsyslog_Func_3" VSHIFT="-17">
<node CREATED="1336039735424" ID="ID_1396983080" MODIFIED="1370337064197" TEXT="COMPONENT: ssologger"/>
<node CREATED="1336038744773" ID="ID_1243256216" MODIFIED="1370337095750" TEXT="DESCRIPTION: ssologger service is installed properly in /etc/init.d"/>
<node CREATED="1336038752013" ID="ID_1311264505" MODIFIED="1355738443642" TEXT="PRIORITY: HIGH"/>
<node CREATED="1336038780830" ID="ID_1393525837" MODIFIED="1370337104632" TEXT="GROUP: ssologger"/>
<node CREATED="1336038860069" ID="ID_1159384345" MODIFIED="1370337171049" TEXT="PRE: Campaign has run successfully"/>
<node CREATED="1336038805518" ID="ID_684649816" MODIFIED="1370337210812" TEXT="EXECUTE: Look for ssologger in /etc/init.d">
<node CREATED="1336038832124" ID="ID_1950696239" MODIFIED="1370337225112" TEXT="VERIFY: The file ssologger can be found in /etc/init.d"/>
</node>
<node CREATED="1355738630052" ID="ID_1281825344" MODIFIED="1370337260483" TEXT="EXECUTE: Run service ssologger start/restart/stop/status">
<node CREATED="1355738655074" ID="ID_526268345" MODIFIED="1370337313134" TEXT="VERIFY: The ssologger will start/restart/stop and show status when the corresponding command is issued"/>
</node>
<node CREATED="1336039548353" ID="ID_1758287324" MODIFIED="1355738558483" TEXT="VUSERS: 1"/>
<node CREATED="1343750957036" ID="ID_1058495698" MODIFIED="1359459006495" TEXT="CONTEXT: UI"/>
</node>
</node>
<node CREATED="1336037980751" ID="ID_353380802" MODIFIED="1336977418661" POSITION="right" TEXT="Performance Tests"/>
<node CREATED="1336038065478" ID="ID_1299048467" MODIFIED="1343766431087" POSITION="right" TEXT="Workflow Tests"/>
<node CREATED="1336037987873" ID="ID_1820063504" MODIFIED="1343766451965" POSITION="right" TEXT="HighAvailability Tests"/>
<node CREATED="1343766476125" ID="ID_1303512424" MODIFIED="1343766481054" POSITION="right" TEXT="Scalability Tests"/>
<node CREATED="1343766458099" ID="ID_1903836703" MODIFIED="1343766468545" POSITION="right" TEXT="Robustness Tests"/>
</node>
</map>
