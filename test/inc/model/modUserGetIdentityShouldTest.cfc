<cfcomponent extends="mxunit.framework.TestCase" output="false">
	<cfscript>
		public void function setup() {
			variables.i18n = createObject('component', 'cf-compendium.inc.resource.i18n.i18n').init(expandPath('/'));
			variables.user = createObject('component', 'plugins.user-openid.inc.model.modUser').init(variables.i18n);
		}
		
		public void function testReturnLowercaseWithMixedCaseSet() {
			var identity = 'http://MyNameIsInigoMontoya.com';
			
			variables.user.setIdentity(identity);
			
			assertEquals(hash(lcase(identity)), hash(variables.user.getIdentity()));
		}
	</cfscript>
</cfcomponent>