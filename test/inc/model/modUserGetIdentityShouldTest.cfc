component extends="algid.inc.resource.base.modelTest" {
	public void function setup() {
		super.setup();
		
		variables.user = createObject('component', 'plugins.user-openid.inc.model.modUser').init(variables.i18n);
	}
	
	public void function testReturnLowercaseWithMixedCaseSet() {
		var identity = 'http://MyNameIsInigoMontoya.com';
		
		variables.user.setIdentity(identity);
		
		assertEquals(hash(lcase(identity)), hash(variables.user.getIdentity()));
	}
}
