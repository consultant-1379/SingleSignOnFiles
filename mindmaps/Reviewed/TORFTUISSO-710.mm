<map version="0.9.0">
<!-- To view this file, download free mind mapping software FreeMind from http://freemind.sourceforge.net -->
<node CREATED="1336037971857" ID="ID_150542004" MODIFIED="1372845694822" TEXT="TORFTUISSO-710">
<node CREATED="1336037984024" ID="ID_679454563" MODIFIED="1343766368521" POSITION="right" TEXT="Functional Tests">
<node CREATED="1336038105179" ID="ID_92267896" MODIFIED="1372845732122" TEXT="sSO_ldap_pw_1">
<node CREATED="1336039735424" ID="ID_1881978803" MODIFIED="1372845738486" TEXT="COMPONENT: SSO"/>
<node CREATED="1336038744773" ID="ID_709154124" MODIFIED="1372845778517" TEXT="DESCRIPTION: Verify SSO works as normal after LDAP admin password is changed"/>
<node CREATED="1336038752013" ID="ID_1339319240" MODIFIED="1368719555317" TEXT="PRIORITY:MEDIUM"/>
<node CREATED="1336038780830" ID="ID_1153529106" MODIFIED="1372845813779" TEXT="GROUP: "/>
<node CREATED="1336038860069" ID="ID_48247714" MODIFIED="1372846130959" TEXT="PRE: LDAP has same password as when SSO was installed"/>
<node CREATED="1336038805518" ID="ID_1943378781" MODIFIED="1372845975427" TEXT="EXECUTE: 1. Login to LDAP server and run the /ericsson/sdee/bin/chg_ds_admin_password.sh and change the password">
<node CREATED="1336038832124" ID="ID_213489239" MODIFIED="1372846158836" TEXT="VERIFY: TOR Launcher works as normal."/>
</node>
<node CREATED="1336039548353" ID="ID_1882389980" MODIFIED="1368719631277" TEXT="VUSERS: {1}"/>
<node CREATED="1343750957036" ID="ID_677679291" MODIFIED="1368719637320" TEXT="CONTEXT: UI"/>
</node>
<node CREATED="1336038105179" ID="ID_1271190299" MODIFIED="1372846849216" TEXT="sSO_new _ldap_server_1">
<node CREATED="1336039735424" ID="ID_1130018993" MODIFIED="1372846203047" TEXT="COMPONENT: SSO"/>
<node CREATED="1336038744773" ID="ID_552429888" MODIFIED="1372846350841" TEXT="DESCRIPTION: Verify SSO works as normal after new LDAP server is configured"/>
<node CREATED="1336038752013" ID="ID_255246604" MODIFIED="1368719555317" TEXT="PRIORITY:MEDIUM"/>
<node CREATED="1336038780830" ID="ID_62558637" MODIFIED="1372845817898" TEXT="GROUP: "/>
<node CREATED="1336038860069" ID="ID_1199985365" MODIFIED="1372846439668" TEXT="PRE: SSO is working normally using server that SSO was installed with"/>
<node CREATED="1336038805518" ID="ID_1861078371" MODIFIED="1372846826799" TEXT="EXECUTE: 1. Update OpenAM so that it points to newly configured LDAP server:  /opt/ericsson/sso/bin/sso.sh config update-datastore -e / -m OpenDJ -a &quot;sun-idrepo-ldapv3-config-ldap-server=&lt;ldap_master_hostname&gt;:636&quot; &quot;sun-idrepo-ldapv3-config-ldap-server=&lt;ldap_slave_hostname&gt;:636&quot;     2. Edit &quot;/ericsson/tor/data/sso/sso.properties&quot; file so that sanity_check.sh will work with new LDAP server hostname. (This is optional to run as SSO will work without this but is recommended for consistency.)">
<node CREATED="1336038832124" ID="ID_571654716" MODIFIED="1372846451259" TEXT="VERIFY: TOR Launcher works as normal."/>
</node>
<node CREATED="1336039548353" ID="ID_925156651" MODIFIED="1368719631277" TEXT="VUSERS: {1}"/>
<node CREATED="1343750957036" ID="ID_1774359762" MODIFIED="1368719637320" TEXT="CONTEXT: UI"/>
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
