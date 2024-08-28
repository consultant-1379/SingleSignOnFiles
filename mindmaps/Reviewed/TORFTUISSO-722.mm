<map version="0.9.0">
<!-- To view this file, download free mind mapping software FreeMind from http://freemind.sourceforge.net -->
<node CREATED="1336037971857" ID="ID_150542004" MODIFIED="1369222118284" TEXT="TORFTUISSO-722">
<node CREATED="1336037984024" ID="ID_679454563" MODIFIED="1343766368521" POSITION="right" TEXT="Functional Tests">
<node CREATED="1336038105179" ID="ID_92267896" MODIFIED="1369222878943" TEXT="sSO_Upgrade_1">
<node CREATED="1336039735424" ID="ID_1881978803" MODIFIED="1369217732842" TEXT="COMPONENT: SSO"/>
<node CREATED="1336038744773" ID="ID_709154124" MODIFIED="1369222283489" TEXT="DESCRIPTION: Verify ssologger rpm is upgraded"/>
<node CREATED="1336038752013" ID="ID_1339319240" MODIFIED="1368719555317" TEXT="PRIORITY:MEDIUM"/>
<node CREATED="1336038780830" ID="ID_1153529106" MODIFIED="1369217856504" TEXT="GROUP:"/>
<node CREATED="1336038860069" ID="ID_48247714" MODIFIED="1369222790598" TEXT="PRE: Upgrade campaign ready with ssologger to be upgraded. 1. Update the definition:- litp /definition/ssologger/ssologger_pkg/ update version=&quot;&lt;version&gt;&quot;    2. Prepare the plan:-   litp /depmgr prepare upgrade_ssologger scope=/inventory;   litp /depmgr/upgrade_ssologger/ plan"/>
<node CREATED="1336038805518" ID="ID_1943378781" MODIFIED="1369222634113" TEXT="EXECUTE: 1. Execute the Upgrade plan:   &#x9;litp /depmgr/upgrade_ssologger/ start">
<node CREATED="1336038832124" ID="ID_213489239" MODIFIED="1369222602615" TEXT="VERIFY: Check the new version of the ssologger rpm has been upgraded on both nodes and ssologger is online on one node:     service ssologger status"/>
</node>
<node CREATED="1336039548353" ID="ID_1882389980" MODIFIED="1368719631277" TEXT="VUSERS: {1}"/>
<node CREATED="1343750957036" ID="ID_677679291" MODIFIED="1368719637320" TEXT="CONTEXT: UI"/>
</node>
<node CREATED="1336038105179" ID="ID_158915738" MODIFIED="1369228948142" TEXT="sSO_Upgrade_2">
<node CREATED="1336039735424" ID="ID_1162898989" MODIFIED="1369217732842" TEXT="COMPONENT: SSO"/>
<node CREATED="1336038744773" ID="ID_937593685" MODIFIED="1369228959686" TEXT="DESCRIPTION: Verify logs are being collected post-upgrade of ssologger"/>
<node CREATED="1336038752013" ID="ID_1587374361" MODIFIED="1368719555317" TEXT="PRIORITY:MEDIUM"/>
<node CREATED="1336038780830" ID="ID_1259264948" MODIFIED="1369217856504" TEXT="GROUP:"/>
<node CREATED="1336038860069" ID="ID_416758410" MODIFIED="1369222934605" TEXT="PRE: ssologger has been upgraded and is online"/>
<node CREATED="1336038805518" ID="ID_1808413087" MODIFIED="1369229986559" TEXT="EXECUTE: 1. Check that logs are being collected by checking that /var/log/messages is being updated:    tail -f /var/log/messages">
<node CREATED="1336038832124" ID="ID_480628606" MODIFIED="1369229989914" TEXT="VERIFY: Login using the TOR Launcher and you should see logs added to the messages log."/>
</node>
<node CREATED="1336039548353" ID="ID_155783156" MODIFIED="1368719631277" TEXT="VUSERS: {1}"/>
<node CREATED="1343750957036" ID="ID_1249060966" MODIFIED="1368719637320" TEXT="CONTEXT: UI"/>
</node>
</node>
<node CREATED="1336037980751" ID="ID_353380802" MODIFIED="1336977418661" POSITION="right" TEXT="Performance Tests"/>
<node CREATED="1336038065478" ID="ID_1299048467" MODIFIED="1343766431087" POSITION="right" TEXT="Workflow Tests"/>
<node CREATED="1336037987873" ID="ID_1820063504" MODIFIED="1343766451965" POSITION="right" TEXT="HighAvailability Tests"/>
<node CREATED="1343766476125" ID="ID_1303512424" MODIFIED="1343766481054" POSITION="right" TEXT="Scalability Tests"/>
<node CREATED="1343766458099" ID="ID_1903836703" MODIFIED="1343766468545" POSITION="right" TEXT="Robustness Tests"/>
<node CREATED="1336038009268" ID="ID_970254648" MODIFIED="1336038015456" POSITION="right" TEXT="Security Tests"/>
</node>
</map>
