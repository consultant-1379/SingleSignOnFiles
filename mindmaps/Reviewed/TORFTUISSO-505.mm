<map version="0.9.0">
<!-- To view this file, download free mind mapping software FreeMind from http://freemind.sourceforge.net -->
<node CREATED="1363009220863" ID="ID_432116723" MODIFIED="1363009220863" TEXT="1: TORFTUISSO-505">
<node CREATED="1363009220863" ID="ID_641507434" MODIFIED="1363009220863" POSITION="right" TEXT="Performance Tests"/>
<node CREATED="1363009220865" MODIFIED="1363009220865" POSITION="right" TEXT="Functional Tests">
<node CREATED="1363009220865" MODIFIED="1363009220865" TEXT="TORFTUISSO-505_Func_1: sSO_UpGrdHealthcheck_positive_all_up">
<node CREATED="1363009220865" ID="ID_30106947" MODIFIED="1363009268811" TEXT="COMPONENT: ssoUpGrdHealthCheck"/>
<node CREATED="1363009220865" ID="ID_5985075" MODIFIED="1363009220865" TEXT="DESCRIPTION: Verify health check when SSO fully configured"/>
<node CREATED="1363009220865" ID="ID_1413936388" MODIFIED="1363009220865" TEXT="PRIORITY: HIGH"/>
<node CREATED="1363009220865" ID="ID_1809944402" MODIFIED="1363009308008" TEXT="GROUP:regression"/>
<node CREATED="1363009220865" ID="ID_664668311" MODIFIED="1363009220865" TEXT="PRE: SSO installed and running on both SCs. Apache live on one SC only."/>
<node CREATED="1363009220865" MODIFIED="1363009220865" TEXT="EXECUTE: 1. call the upgrade-healthcheck.sh on Sc-1. 2. 1. call the upgrade-healthcheck.sh on Sc-2">
<node CREATED="1363009220865" MODIFIED="1363009220865" TEXT="VERIFY: both health checks return positive result"/>
</node>
<node CREATED="1363009220865" ID="ID_1618073570" MODIFIED="1363009220865" TEXT="VUSERS: 1"/>
<node CREATED="1363009220866" ID="ID_691075494" MODIFIED="1363009806404" TEXT="CONTEXT: API"/>
</node>
<node CREATED="1363009220866" MODIFIED="1363009220866" TEXT="TORFTUISSO-505_Func_2: sSO_UpGrdHealthcheck_one_jboss down">
<node CREATED="1363009220866" ID="ID_418922264" MODIFIED="1363009288623" TEXT="COMPONENT: ssoUpGrdHealthCheck"/>
<node CREATED="1363009220866" ID="ID_4497739" MODIFIED="1363009220866" TEXT="DESCRIPTION: Verify health check returns negative if one of the two JBoss is uncontactable"/>
<node CREATED="1363009220866" MODIFIED="1363009220866" TEXT="PRIORITY: HIGH"/>
<node CREATED="1363009220866" ID="ID_188122772" MODIFIED="1363009303071" TEXT="GROUP:regression"/>
<node CREATED="1363009220866" ID="ID_1439514152" MODIFIED="1363009220866" TEXT="PRE: SSO installed and running on a SC, SSO Jboss on other SSO offline, repeat test  alternating which Jboss is online/offline"/>
<node CREATED="1363009220866" ID="ID_249862205" MODIFIED="1363009220866" TEXT="EXECUTE: call the upgrade-healthcheck.sh on both scs">
<node CREATED="1363009220866" MODIFIED="1363009220866" TEXT="VERIFY: Script  health-checks SC-1 and SC-2 and returns  negative result"/>
</node>
<node CREATED="1363009220866" MODIFIED="1363009220866" TEXT="VUSERS: 1"/>
<node CREATED="1363009220866" ID="ID_1396325268" MODIFIED="1363009806405" TEXT="CONTEXT: API"/>
</node>
<node CREATED="1363009220866" MODIFIED="1363009220866" TEXT="TORFTUISSO-505_Func_3: sSO_UpGrdHealthcheck_LDAP down">
<node CREATED="1363009220867" ID="ID_1160431676" MODIFIED="1363009314540" TEXT="COMPONENT: ssoUpGrdHealthCheck"/>
<node CREATED="1363009220867" MODIFIED="1363009220867" TEXT="DESCRIPTION: Verify health check returns negative if LDAP uncontactable"/>
<node CREATED="1363009220867" MODIFIED="1363009220867" TEXT="PRIORITY: HIGH"/>
<node CREATED="1363009220867" ID="ID_452100989" MODIFIED="1363009321497" TEXT="GROUP: regression"/>
<node CREATED="1363009220867" ID="ID_1504796821" MODIFIED="1363009220867" TEXT="PRE: SSO installed and running on both SCs, LDAP connection down on one SC, repeat test alternating which LDAP connection is down (i.e connection from sc-1 or connection from sc-2)"/>
<node CREATED="1363009220867" ID="ID_153707512" MODIFIED="1363009220867" TEXT="EXECUTE: call the upgrade-healthcheck.sh">
<node CREATED="1363009220867" MODIFIED="1363009220867" TEXT="VERIFY: Script  health-checks SC-1 and SC-2 and returns  negative result"/>
</node>
<node CREATED="1363009220867" MODIFIED="1363009220867" TEXT="VUSERS: 1"/>
<node CREATED="1363009220867" ID="ID_1122855492" MODIFIED="1363009806405" TEXT="CONTEXT: API"/>
</node>
<node CREATED="1363009220867" MODIFIED="1363009220867" TEXT="TORFTUISSO-505_Func_4: sSO_UpGrdHealthcheck_apache_down">
<node CREATED="1363009220867" ID="ID_1883585188" MODIFIED="1363009342176" TEXT="COMPONENT: ssoUpGrdHealthCheck"/>
<node CREATED="1363009220867" ID="ID_1294951064" MODIFIED="1363009220867" TEXT="DESCRIPTION: Verify health check when both apaches inactive"/>
<node CREATED="1363009220868" MODIFIED="1363009220868" TEXT="PRIORITY: HIGH"/>
<node CREATED="1363009220868" ID="ID_1249484742" MODIFIED="1363009349548" TEXT="GROUP: regression"/>
<node CREATED="1363009220868" ID="ID_125102022" MODIFIED="1363009220868" TEXT="PRE: SSO installed and running on both SCs. Apache inactive on both SCs"/>
<node CREATED="1363009220868" MODIFIED="1363009220868" TEXT="EXECUTE: 1. call the upgrade-healthcheck.sh on Sc-1. 2. 1. call the upgrade-healthcheck.sh on Sc-2">
<node CREATED="1363009220868" MODIFIED="1363009220868" TEXT="VERIFY: both health checks return negative result result"/>
</node>
<node CREATED="1363009220868" MODIFIED="1363009220868" TEXT="VUSERS: 1"/>
<node CREATED="1363009220868" ID="ID_1731328027" MODIFIED="1363009806406" TEXT="CONTEXT: API"/>
</node>
<node CREATED="1363009220868" MODIFIED="1363009220868" TEXT="TORFTUISSO-505_Func_5: sSO_UpGrdHealthcheck_both_jboss down">
<node CREATED="1363009220868" ID="ID_1775649583" MODIFIED="1363009357411" TEXT="COMPONENT: ssoUpGrdHealthCheck"/>
<node CREATED="1363009220868" ID="ID_1376760030" MODIFIED="1363009220868" TEXT="DESCRIPTION: Verify health check returns negative if both SSO JBoss instances are uncontactable"/>
<node CREATED="1363009220868" MODIFIED="1363009220868" TEXT="PRIORITY: HIGH"/>
<node CREATED="1363009220868" ID="ID_1930964700" MODIFIED="1363009365782" TEXT="GROUP: regression"/>
<node CREATED="1363009220868" MODIFIED="1363009220868" TEXT="PRE: Jboss instances that are configured to runn SSO are not running"/>
<node CREATED="1363009220868" MODIFIED="1363009220868" TEXT="EXECUTE: call the upgrade-healthcheck.sh on both scs">
<node CREATED="1363009220868" MODIFIED="1363009220868" TEXT="VERIFY: Script  health-checks SC-1 and SC-2 and returns  negative result"/>
</node>
<node CREATED="1363009220869" MODIFIED="1363009220869" TEXT="VUSERS: 1"/>
<node CREATED="1363009220869" ID="ID_276301988" MODIFIED="1363009806406" TEXT="CONTEXT: API"/>
</node>
</node>
</node>
</map>
