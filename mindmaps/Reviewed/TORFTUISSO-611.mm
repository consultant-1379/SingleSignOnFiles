<map version="0.9.0">
<!-- To view this file, download free mind mapping software FreeMind from http://freemind.sourceforge.net -->
<node CREATED="1336037971857" ID="ID_150542004" MODIFIED="1365585914078" TEXT="TORFTUISSO-611">
<node CREATED="1336037984024" ID="ID_679454563" MODIFIED="1365514839109" POSITION="right" TEXT="Functional Tests">
<node CREATED="1362576605707" HGAP="36" ID="ID_1263812517" MODIFIED="1365586358768" TEXT="sSO_Install_Order_1" VSHIFT="-61">
<node CREATED="1336039735424" ID="ID_1399826176" MODIFIED="1359130827194" TEXT="COMPONENT: SSO"/>
<node CREATED="1336038744773" ID="ID_293380175" MODIFIED="1365586410295" TEXT="DESCRIPTION: Installation of Apache and Policy Agent occurs after OpenAM is installed"/>
<node CREATED="1336038752013" ID="ID_1551130900" MODIFIED="1359130901564" TEXT="PRIORITY: HIGH"/>
<node CREATED="1336038780830" ID="ID_1240236855" MODIFIED="1359130916607" TEXT="GROUP: "/>
<node CREATED="1336038860069" ID="ID_1207612622" MODIFIED="1365586445925" TEXT="PRE: Campaign finished and OpenAM, Apache and Policy Agent are installed"/>
<node CREATED="1336038805518" ID="ID_1618316508" MODIFIED="1365586641206" TEXT="EXECUTE: 1. Check that the new OpenAM RPM is installed before the Apache RPM and the Policy Agent RPM on both Peer servers.">
<node CREATED="1365586462742" ID="ID_714322233" MODIFIED="1365586616964" TEXT="VERIFY:Run the following commands on both servers and check the timestamps of each. The OpenAM timestamp should be earlier than the Apache one and the policy agent one:  rpm -qi &lt;openam&gt; ;  rpm -qi &lt;policy_agent&gt; ;     rpm -qi &lt;apache"/>
</node>
<node CREATED="1336039548353" ID="ID_388460282" MODIFIED="1359539756428" TEXT="VUSERS: {1}"/>
<node CREATED="1343750957036" ID="ID_211606451" MODIFIED="1363012017634" TEXT="CONTEXT: API"/>
</node>
</node>
<node CREATED="1336037980751" ID="ID_353380802" MODIFIED="1363013857293" POSITION="right" TEXT="Performance Tests"/>
<node CREATED="1336038065478" ID="ID_1299048467" MODIFIED="1343766431087" POSITION="right" TEXT="Workflow Tests"/>
<node CREATED="1336037987873" ID="ID_1820063504" MODIFIED="1343766451965" POSITION="right" TEXT="HighAvailability Tests"/>
<node CREATED="1343766476125" ID="ID_1303512424" MODIFIED="1343766481054" POSITION="right" TEXT="Scalability Tests"/>
<node CREATED="1343766458099" ID="ID_1903836703" MODIFIED="1343766468545" POSITION="right" TEXT="Robustness Tests"/>
<node CREATED="1336038009268" ID="ID_970254648" MODIFIED="1336038015456" POSITION="right" TEXT="Security Tests"/>
</node>
</map>
