<map version="0.9.0">
<!-- To view this file, download free mind mapping software FreeMind from http://freemind.sourceforge.net -->
<node CREATED="1336037971857" ID="ID_150542004" MODIFIED="1355500597636" TEXT="TORFTUISSO-340">
<node CREATED="1336037984024" HGAP="32" ID="ID_679454563" MODIFIED="1359629402155" POSITION="right" TEXT="Functional Tests" VSHIFT="1">
<arrowlink DESTINATION="ID_679454563" ENDARROW="Default" ENDINCLINATION="0;0;" ID="Arrow_ID_538647491" STARTARROW="None" STARTINCLINATION="0;0;"/>
<arrowlink DESTINATION="ID_679454563" ENDARROW="Default" ENDINCLINATION="0;0;" ID="Arrow_ID_1033489340" STARTARROW="None" STARTINCLINATION="0;0;"/>
<node CREATED="1336038105179" ID="ID_404950472" MODIFIED="1355500710849" TEXT="Verify that the Security Service generates a token">
<node CREATED="1336039735424" ID="ID_416732176" MODIFIED="1355500767007" TEXT="COMPONENT: Security Service"/>
<node CREATED="1336038744773" ID="ID_690087273" MODIFIED="1355500783281" TEXT="DESCRIPTION: Token generation"/>
<node CREATED="1336038752013" ID="ID_503780013" MODIFIED="1351873656204" TEXT="PRIORITY: &lt;HIGH&gt;"/>
<node CREATED="1336038780830" ID="ID_1585817280" MODIFIED="1351873698262" TEXT="GROUP: SSO"/>
<node CREATED="1336038860069" ID="ID_248228929" MODIFIED="1355500866594" TEXT="PRE: predefined masterkey and a valid userId"/>
<node CREATED="1336038805518" HGAP="19" ID="ID_1348894701" MODIFIED="1355500930287" TEXT="EXECUTE: String requestToken(String userId) method is invoked " VSHIFT="3">
<node CREATED="1336038832124" ID="ID_1459976699" MODIFIED="1355500958725" TEXT="VERIFY:The method gives back a token as a string"/>
</node>
<node CREATED="1336039548353" ID="ID_1682642370" MODIFIED="1351873803150" TEXT="VUSERS: 1"/>
<node CREATED="1355501029269" ID="ID_1666115219" MODIFIED="1355501373916" TEXT="CONTEXT: API"/>
</node>
<node CREATED="1336038105179" HGAP="51" ID="ID_1135511817" MODIFIED="1355501409785" TEXT="Verify that the Security Service can be deployed as a service on JBoss" VSHIFT="45">
<node CREATED="1336039735424" ID="ID_1528880910" MODIFIED="1355501448206" TEXT="COMPONENT: JBoss"/>
<node CREATED="1336038744773" ID="ID_1477509825" MODIFIED="1355501651894" TEXT="DESCRIPTION: Successful deployment"/>
<node CREATED="1336038752013" ID="ID_1802300897" MODIFIED="1355501661078" TEXT="PRIORITY: &lt;HIGH&gt;"/>
<node CREATED="1336038780830" ID="ID_1221226774" MODIFIED="1355501667661" TEXT="GROUP: SSO"/>
<node CREATED="1336038860069" ID="ID_1857956787" MODIFIED="1355502389226" TEXT="PRE: Properly packaged Security Service and configured standalone-full-ha.xml"/>
<node CREATED="1336038805518" ID="ID_899677004" MODIFIED="1355502483242" TEXT="EXECUTE: deploy SecurityService.ear ">
<node CREATED="1336038832124" ID="ID_549009630" MODIFIED="1355502501314" TEXT="VERIFY: The Service gets deployed and accessible from the browser"/>
</node>
<node CREATED="1336039548353" ID="ID_141421886" MODIFIED="1355502723463" TEXT="VUSERS: 1"/>
<node CREATED="1343750957036" ID="ID_1771301287" MODIFIED="1355502729261" TEXT="CONTEXT: API"/>
</node>
<node CREATED="1336038105179" HGAP="51" ID="ID_1332785724" MODIFIED="1355504158869" TEXT="Verify that the SS interface is configured as @Remote @EService" VSHIFT="45">
<node CREATED="1336039735424" ID="ID_895415118" MODIFIED="1355503456192" TEXT="COMPONENT: Security Service"/>
<node CREATED="1336038744773" ID="ID_1549487770" MODIFIED="1355503466225" TEXT="DESCRIPTION: Interface configuration"/>
<node CREATED="1336038752013" ID="ID_40169349" MODIFIED="1355501661078" TEXT="PRIORITY: &lt;HIGH&gt;"/>
<node CREATED="1336038780830" ID="ID_317203851" MODIFIED="1355501667661" TEXT="GROUP: SSO"/>
<node CREATED="1336038860069" ID="ID_922625112" MODIFIED="1355503598804" TEXT="PRE: SS Interface and ejb implemented"/>
<node CREATED="1336038805518" ID="ID_629591570" MODIFIED="1355503635050" TEXT="EXECUTE: Check the Interface for the right annotations">
<node CREATED="1336038832124" ID="ID_541185185" MODIFIED="1355503653931" TEXT="VERIFY: The interface is properly configured and contains the necessary annotations"/>
</node>
<node CREATED="1336039548353" ID="ID_1139556376" MODIFIED="1355502723463" TEXT="VUSERS: 1"/>
<node CREATED="1343750957036" ID="ID_1300458138" MODIFIED="1355502729261" TEXT="CONTEXT: API"/>
</node>
<node CREATED="1336038105179" HGAP="51" ID="ID_362165154" MODIFIED="1355504188353" TEXT="A Client can inject the Security Service" VSHIFT="45">
<node CREATED="1336039735424" ID="ID_1050104493" MODIFIED="1355504197498" TEXT="COMPONENT: Security Service and Client"/>
<node CREATED="1336038744773" ID="ID_1997297697" MODIFIED="1355504209644" TEXT="DESCRIPTION: Injection"/>
<node CREATED="1336038752013" ID="ID_1399132300" MODIFIED="1355501661078" TEXT="PRIORITY: &lt;HIGH&gt;"/>
<node CREATED="1336038780830" ID="ID_782536350" MODIFIED="1355501667661" TEXT="GROUP: SSO"/>
<node CREATED="1336038860069" ID="ID_1903684906" MODIFIED="1355504237511" TEXT="PRE: The Service exposes itself through its interface"/>
<node CREATED="1336038805518" ID="ID_869663521" MODIFIED="1355504272588" TEXT="EXECUTE: A client is trying to inject the Security Service and access it through its interface">
<node CREATED="1336038832124" ID="ID_732411658" MODIFIED="1355504299617" TEXT="VERIFY: The client successfully injected the service and can invoke its requestToken method"/>
</node>
<node CREATED="1336039548353" ID="ID_266553321" MODIFIED="1355502723463" TEXT="VUSERS: 1"/>
<node CREATED="1343750957036" ID="ID_370403305" MODIFIED="1355502729261" TEXT="CONTEXT: API"/>
</node>
</node>
<node CREATED="1336037980751" ID="ID_353380802" MODIFIED="1336977418661" POSITION="right" TEXT="Performance Tests"/>
<node CREATED="1336038065478" ID="ID_1299048467" MODIFIED="1343766431087" POSITION="right" TEXT="Workflow Tests"/>
<node CREATED="1336037987873" ID="ID_1820063504" MODIFIED="1343766451965" POSITION="right" TEXT="HighAvailability Tests"/>
<node CREATED="1343766476125" ID="ID_1303512424" MODIFIED="1343766481054" POSITION="right" TEXT="Scalability Tests">
<node CREATED="1336038105179" HGAP="51" ID="ID_437914639" MODIFIED="1355745051841" TEXT="Verify that the Security Service can be deployed as a clustered service" VSHIFT="45">
<node CREATED="1336039735424" ID="ID_1015153114" MODIFIED="1355504762083" TEXT="COMPONENT: Security Service and JBoss"/>
<node CREATED="1336038744773" ID="ID_468399069" MODIFIED="1355504812141" TEXT="DESCRIPTION: Clustered Service Deployment"/>
<node CREATED="1336038752013" ID="ID_55744700" MODIFIED="1355501661078" TEXT="PRIORITY: &lt;HIGH&gt;"/>
<node CREATED="1336038780830" ID="ID_1814982971" MODIFIED="1355501667661" TEXT="GROUP: SSO"/>
<node CREATED="1336038860069" ID="ID_960943483" MODIFIED="1355504824409" TEXT="PRE: Service can be deployed"/>
<node CREATED="1336038805518" ID="ID_663057086" MODIFIED="1355504929988" TEXT="EXECUTE: Deploy the Service as clustered">
<node CREATED="1336038832124" ID="ID_1046898146" MODIFIED="1355741301125" TEXT="VERIFY: The service is successfully deployed in a clustered environment"/>
</node>
<node CREATED="1336039548353" ID="ID_375685425" MODIFIED="1355502723463" TEXT="VUSERS: 1"/>
<node CREATED="1343750957036" ID="ID_978595474" MODIFIED="1355502729261" TEXT="CONTEXT: API"/>
</node>
</node>
<node CREATED="1343766458099" ID="ID_1903836703" MODIFIED="1343766468545" POSITION="right" TEXT="Robustness Tests">
<node CREATED="1336038105179" FOLDED="true" HGAP="76" ID="ID_809374366" MODIFIED="1359629440616" TEXT="Verify that the service is continously accessible under heavy load and during many simultaneous requests " VSHIFT="35">
<node CREATED="1336039735424" ID="ID_519650171" MODIFIED="1355504762083" TEXT="COMPONENT: Security Service and JBoss"/>
<node CREATED="1336038744773" ID="ID_1493686165" MODIFIED="1355749478494" TEXT="DESCRIPTION: Service is working properly under heavy load"/>
<node CREATED="1336038752013" ID="ID_1945075963" MODIFIED="1355501661078" TEXT="PRIORITY: &lt;HIGH&gt;"/>
<node CREATED="1336038780830" ID="ID_1056576490" MODIFIED="1355501667661" TEXT="GROUP: SSO"/>
<node CREATED="1336038860069" ID="ID_59045528" MODIFIED="1355750139989" TEXT="PRE: The service is deployed and ICA builder makes simultaneous requests for tokens"/>
<node CREATED="1336038805518" ID="ID_995524972" MODIFIED="1355750210001" TEXT="EXECUTE: make simultaneous requests for tokens">
<arrowlink DESTINATION="ID_995524972" ENDARROW="Default" ENDINCLINATION="0;0;" ID="Arrow_ID_1954237780" STARTARROW="None" STARTINCLINATION="0;0;"/>
<node CREATED="1336038832124" ID="ID_720229814" MODIFIED="1355758684837" TEXT="VERIFY: The service is up and running and properly generating tokens for each ICA files"/>
</node>
<node CREATED="1336039548353" ID="ID_93490003" MODIFIED="1355750240783" TEXT="VUSERS: 1000"/>
<node CREATED="1343750957036" ID="ID_1273153539" MODIFIED="1355502729261" TEXT="CONTEXT: API"/>
</node>
</node>
<node CREATED="1336038009268" HGAP="-39" ID="ID_970254648" MODIFIED="1359629413571" POSITION="right" TEXT="Acceptance" VSHIFT="55">
<node CREATED="1336038105179" HGAP="76" ID="ID_280751923" MODIFIED="1359629499557" TEXT="Verify that with the generated tokens the user can establish a putty session" VSHIFT="35">
<node CREATED="1336039735424" ID="ID_436405627" MODIFIED="1359629564867" TEXT="COMPONENT: Security Service and Putty"/>
<node CREATED="1336038744773" ID="ID_1862869921" MODIFIED="1359629674012" TEXT="DESCRIPTION: Using the generated token the user can login"/>
<node CREATED="1336038752013" ID="ID_261451770" MODIFIED="1355501661078" TEXT="PRIORITY: &lt;HIGH&gt;"/>
<node CREATED="1336038780830" ID="ID_1274116036" MODIFIED="1359629680916" TEXT="GROUP: SSO/Security Service"/>
<node CREATED="1336038860069" ID="ID_1638918939" MODIFIED="1359629694461" TEXT="PRE: The service is generating tokens"/>
<node CREATED="1336038805518" ID="ID_304877849" MODIFIED="1359629736311" TEXT="EXECUTE: Generate a token for a specified username. Currently(eeijgay)">
<arrowlink DESTINATION="ID_304877849" ENDARROW="Default" ENDINCLINATION="0;0;" ID="Arrow_ID_222286099" STARTARROW="None" STARTINCLINATION="0;0;"/>
<node CREATED="1336038832124" ID="ID_1809500638" MODIFIED="1371550516421" TEXT="VERIFY: By opening a putty session and using the token when prompted for password the user can successfully login"/>
</node>
<node CREATED="1336039548353" ID="ID_133753750" MODIFIED="1359629794890" TEXT="VUSERS: 1"/>
<node CREATED="1343750957036" ID="ID_60982069" MODIFIED="1355502729261" TEXT="CONTEXT: API"/>
</node>
</node>
</node>
</map>
