<map version="0.9.0">
<!-- To view this file, download free mind mapping software FreeMind from http://freemind.sourceforge.net -->
<node CREATED="1336037971857" ID="ID_150542004" MODIFIED="1374673860520" TEXT="TORFTUISSO-807">
<node CREATED="1336037984024" ID="ID_679454563" MODIFIED="1343766368521" POSITION="right" TEXT="Functional Tests">
<node CREATED="1336038105179" ID="ID_1952501790" MODIFIED="1374679679899" TEXT="sSO_httpd_SG_check">
<node CREATED="1336039735424" ID="ID_476293350" MODIFIED="1372072486814" TEXT="COMPONENT: SSO"/>
<node CREATED="1336038744773" ID="ID_980368206" MODIFIED="1374679639057" TEXT="DESCRIPTION: Verify the httpd SG can be checked"/>
<node CREATED="1336038752013" ID="ID_1594248477" MODIFIED="1372072735875" TEXT="PRIORITY:  MEDIUM"/>
<node CREATED="1336038780830" ID="ID_1038721631" MODIFIED="1343116349936" TEXT="GROUP: &lt;enter group type here&gt;"/>
<node CREATED="1336038860069" ID="ID_1229104487" MODIFIED="1374679943836" TEXT="PRE: "/>
<node CREATED="1336038805518" ID="ID_179853746" MODIFIED="1374757776659" TEXT="EXECUTE: Run httpd_sg_admin_hc.bsh">
<node CREATED="1336038832124" ID="ID_1404539601" MODIFIED="1374679971873" TEXT="VERIFY: Script will report whether SG is UNLOCKED or LOCKED"/>
</node>
<node CREATED="1336039548353" ID="ID_759623165" MODIFIED="1372073062639" TEXT="VUSERS: {1}"/>
<node CREATED="1343750957036" ID="ID_27752480" MODIFIED="1372073083028" TEXT="CONTEXT: API"/>
</node>
<node CREATED="1336038105179" ID="ID_65393909" MODIFIED="1374673966829" TEXT="sSO_httpd_SI_check">
<node CREATED="1336039735424" ID="ID_1344725589" MODIFIED="1372072486814" TEXT="COMPONENT: SSO"/>
<node CREATED="1336038744773" ID="ID_1743200677" MODIFIED="1374757752869" TEXT="DESCRIPTION: Verify the httpd SI can be checked"/>
<node CREATED="1336038752013" ID="ID_1171062126" MODIFIED="1372072735875" TEXT="PRIORITY:  MEDIUM"/>
<node CREATED="1336038780830" ID="ID_1353276662" MODIFIED="1343116349936" TEXT="GROUP: &lt;enter group type here&gt;"/>
<node CREATED="1336038860069" ID="ID_744089715" MODIFIED="1374757762135" TEXT="PRE: "/>
<node CREATED="1336038805518" ID="ID_1329167138" MODIFIED="1374757963141" TEXT="EXECUTE: 1. Run httpd_si_admin_hc.bsh   2. Run httpd_si_assign_hc.bsh">
<node CREATED="1336038832124" ID="ID_1980625276" MODIFIED="1374757922488" TEXT="VERIFY: 1. Script will report whether SI is UNLOCKED or LOCKED.   2. Script will report whether SI is FULLY_ASSIGNED or not."/>
</node>
<node CREATED="1336039548353" ID="ID_1573689342" MODIFIED="1372073062639" TEXT="VUSERS: {1}"/>
<node CREATED="1343750957036" ID="ID_1172509828" MODIFIED="1372073083028" TEXT="CONTEXT: API"/>
</node>
<node CREATED="1336038105179" ID="ID_1204210115" MODIFIED="1374673980822" TEXT="sSO_httpd_SU_check">
<node CREATED="1336039735424" ID="ID_816149286" MODIFIED="1372072486814" TEXT="COMPONENT: SSO"/>
<node CREATED="1336038744773" ID="ID_495576881" MODIFIED="1374757940178" TEXT="DESCRIPTION: Verify the httpd SU can be checked"/>
<node CREATED="1336038752013" ID="ID_382591432" MODIFIED="1372072735875" TEXT="PRIORITY:  MEDIUM"/>
<node CREATED="1336038780830" ID="ID_1717091083" MODIFIED="1343116349936" TEXT="GROUP: &lt;enter group type here&gt;"/>
<node CREATED="1336038860069" ID="ID_312219685" MODIFIED="1374757958617" TEXT="PRE: "/>
<node CREATED="1336038805518" ID="ID_830286793" MODIFIED="1374758217594" TEXT="EXECUTE: 1. Run httpd_su_admin_hc.bsh   2. Run httpd_su_oper_hc.bsh    3. Run httpd_su_pres_hc.bsh   4. Run httpd_su_ready_hc.bsh">
<node CREATED="1336038832124" ID="ID_159421774" MODIFIED="1374758131622" TEXT="VERIFY: 1. Script will report whether SU is UNLOCKED or LOCKED.   2. Script will report whether SU is ENABLED or not.   3. Script will report whether SU is INSTANTIATED or not.   4. Script will report whether SU is IN-SERVICE or not."/>
</node>
<node CREATED="1336039548353" ID="ID_1655542412" MODIFIED="1372073062639" TEXT="VUSERS: {1}"/>
<node CREATED="1343750957036" ID="ID_1200584839" MODIFIED="1372073083028" TEXT="CONTEXT: API"/>
</node>
<node CREATED="1336038105179" ID="ID_697568901" MODIFIED="1374674018169" TEXT="sSO_httpd_service_check">
<node CREATED="1336039735424" ID="ID_1130400530" MODIFIED="1372072486814" TEXT="COMPONENT: SSO"/>
<node CREATED="1336038744773" ID="ID_1041071453" MODIFIED="1374758855225" TEXT="DESCRIPTION: Verify that httpd SU is INSTANTIATED and the httpd  linux service is running"/>
<node CREATED="1336038752013" ID="ID_475605123" MODIFIED="1372072735875" TEXT="PRIORITY:  MEDIUM"/>
<node CREATED="1336038780830" ID="ID_1998853218" MODIFIED="1343116349936" TEXT="GROUP: &lt;enter group type here&gt;"/>
<node CREATED="1336038860069" ID="ID_1999354726" MODIFIED="1374758201042" TEXT="PRE: "/>
<node CREATED="1336038805518" ID="ID_1735000036" MODIFIED="1374758238732" TEXT="EXECUTE: 1. Run httpd_service_hc.bsh">
<node CREATED="1336038832124" ID="ID_1983244472" MODIFIED="1374758839719" TEXT="VERIFY: Script will report the state of the httpd Linux service and the SU."/>
</node>
<node CREATED="1336039548353" ID="ID_497690775" MODIFIED="1372073062639" TEXT="VUSERS: {1}"/>
<node CREATED="1343750957036" ID="ID_775869323" MODIFIED="1372073083028" TEXT="CONTEXT: API"/>
</node>
<node CREATED="1336038105179" ID="ID_673332576" MODIFIED="1374674042130" TEXT="sSO_httpd_return_200_check">
<node CREATED="1336039735424" ID="ID_974540063" MODIFIED="1372072486814" TEXT="COMPONENT: SSO"/>
<node CREATED="1336038744773" ID="ID_1226601657" MODIFIED="1374758314267" TEXT="DESCRIPTION: Verify that a curl using https is succesful towards httpd"/>
<node CREATED="1336038752013" ID="ID_459699617" MODIFIED="1372072735875" TEXT="PRIORITY:  MEDIUM"/>
<node CREATED="1336038780830" ID="ID_581443903" MODIFIED="1343116349936" TEXT="GROUP: &lt;enter group type here&gt;"/>
<node CREATED="1336038860069" ID="ID_785388109" MODIFIED="1374758324407" TEXT="PRE: "/>
<node CREATED="1336038805518" ID="ID_1708394010" MODIFIED="1374758398367" TEXT="EXECUTE: 1. Run httpd_return_200_hc.bsh">
<node CREATED="1336038832124" ID="ID_1506534234" MODIFIED="1374758416322" TEXT="VERIFY: Script reports whether curl is successful or not"/>
</node>
<node CREATED="1336039548353" ID="ID_852851400" MODIFIED="1372073062639" TEXT="VUSERS: {1}"/>
<node CREATED="1343750957036" ID="ID_324121224" MODIFIED="1372073083028" TEXT="CONTEXT: API"/>
</node>
<node CREATED="1336038105179" ID="ID_1834348717" MODIFIED="1374674141695" TEXT="sSO_httpd_policy_agent_check">
<node CREATED="1336039735424" ID="ID_1105346213" MODIFIED="1372072486814" TEXT="COMPONENT: SSO"/>
<node CREATED="1336038744773" ID="ID_1111731315" MODIFIED="1374758533421" TEXT="DESCRIPTION: Verify that redirect URL from policy agent is well formed"/>
<node CREATED="1336038752013" ID="ID_1635582316" MODIFIED="1372072735875" TEXT="PRIORITY:  MEDIUM"/>
<node CREATED="1336038780830" ID="ID_1467797352" MODIFIED="1343116349936" TEXT="GROUP: &lt;enter group type here&gt;"/>
<node CREATED="1336038860069" ID="ID_1148200377" MODIFIED="1374758544232" TEXT="PRE: "/>
<node CREATED="1336038805518" ID="ID_1520711315" MODIFIED="1374758563701" TEXT="EXECUTE: Run httpd_policy_agent_hc.bsh">
<node CREATED="1336038832124" ID="ID_1386609067" MODIFIED="1374758592358" TEXT="VERIFY: Script reports a well formed URL if policy agent is configured correctly."/>
</node>
<node CREATED="1336039548353" ID="ID_1929447351" MODIFIED="1372073062639" TEXT="VUSERS: {1}"/>
<node CREATED="1343750957036" ID="ID_1680633760" MODIFIED="1372073083028" TEXT="CONTEXT: API"/>
</node>
<node CREATED="1336038105179" ID="ID_1618956223" MODIFIED="1374674155758" TEXT="sSO_httpd_modcluster_check">
<node CREATED="1336039735424" ID="ID_623284084" MODIFIED="1372072486814" TEXT="COMPONENT: SSO"/>
<node CREATED="1336038744773" ID="ID_1548434915" MODIFIED="1374758624492" TEXT="DESCRIPTION: Verify that the modcluster extension is loaded in UI JBoss"/>
<node CREATED="1336038752013" ID="ID_1333232232" MODIFIED="1372072735875" TEXT="PRIORITY:  MEDIUM"/>
<node CREATED="1336038780830" ID="ID_914481702" MODIFIED="1343116349936" TEXT="GROUP: &lt;enter group type here&gt;"/>
<node CREATED="1336038860069" ID="ID_1949164414" MODIFIED="1374758665154" TEXT="PRE: "/>
<node CREATED="1336038805518" ID="ID_1358915731" MODIFIED="1374758689678" TEXT="EXECUTE: Run httpd_modcluster_hc.bsh">
<node CREATED="1336038832124" ID="ID_114534625" MODIFIED="1374758716728" TEXT="VERIFY: Scripts reports whether or not the org.jboss.as.modcluster is loaded"/>
</node>
<node CREATED="1336039548353" ID="ID_1540652117" MODIFIED="1372073062639" TEXT="VUSERS: {1}"/>
<node CREATED="1343750957036" ID="ID_888207491" MODIFIED="1372073083028" TEXT="CONTEXT: API"/>
</node>
<node CREATED="1336038105179" ID="ID_797337100" MODIFIED="1374674313782" TEXT="sSO_logger_service_check">
<node CREATED="1336039735424" ID="ID_1295444782" MODIFIED="1372072486814" TEXT="COMPONENT: SSO"/>
<node CREATED="1336038744773" ID="ID_1688101047" MODIFIED="1374758790610" TEXT="DESCRIPTION: Verify that httpd SU is INSTANTIATED and ssologger linux service is running"/>
<node CREATED="1336038752013" ID="ID_1388483454" MODIFIED="1372072735875" TEXT="PRIORITY:  MEDIUM"/>
<node CREATED="1336038780830" ID="ID_716565685" MODIFIED="1343116349936" TEXT="GROUP: &lt;enter group type here&gt;"/>
<node CREATED="1336038860069" ID="ID_739259652" MODIFIED="1374758746165" TEXT="PRE:"/>
<node CREATED="1336038805518" ID="ID_1192388031" MODIFIED="1374758807879" TEXT="EXECUTE: Run ssologger_service_hc.bsh">
<node CREATED="1336038832124" ID="ID_267755846" MODIFIED="1374758832090" TEXT="VERIFY: Script will report the state of the ssologger Linux service and the httpd SU."/>
</node>
<node CREATED="1336039548353" ID="ID_737953200" MODIFIED="1372073062639" TEXT="VUSERS: {1}"/>
<node CREATED="1343750957036" ID="ID_1578673393" MODIFIED="1372073083028" TEXT="CONTEXT: API"/>
</node>
</node>
<node CREATED="1336037980751" ID="ID_353380802" MODIFIED="1372073084724" POSITION="right" TEXT="Performance Tests"/>
<node CREATED="1336038065478" ID="ID_1299048467" MODIFIED="1343766431087" POSITION="right" TEXT="Workflow Tests"/>
<node CREATED="1336037987873" ID="ID_1820063504" MODIFIED="1343766451965" POSITION="right" TEXT="HighAvailability Tests"/>
<node CREATED="1343766476125" ID="ID_1303512424" MODIFIED="1343766481054" POSITION="right" TEXT="Scalability Tests"/>
<node CREATED="1343766458099" ID="ID_1903836703" MODIFIED="1343766468545" POSITION="right" TEXT="Robustness Tests"/>
<node CREATED="1336038009268" ID="ID_970254648" MODIFIED="1336038015456" POSITION="right" TEXT="Security Tests"/>
</node>
</map>
