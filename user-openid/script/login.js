/**
 * Enhancements to the OpenID login process
 */
(function($){
	var elements;
	var identity;
	var isSubmitted = false;
	var providers = {};
	
	$(function(){
		elements = {
			providers: $('.providers'),
			submit: $('.submit')
		};
		
		identity = {
			container: $('.element.identity'),
			input: $('#identity')
		};
		
		providers.aol = {
			identity: 'https://openid.aol.com',
			icon: $('.provider.aol', elements.providers)
		};
		
		providers.google = {
			identity: 'https://www.google.com/accounts/o8/id?source=profiles',
			icon: $('.provider.google', elements.providers)
		};
		
		providers.yahoo = {
			identity: 'https://me.yahoo.com',
			icon: $('.provider.yahoo', elements.providers)
		};
		
		// Add the click trigger
		$('.provider', elements.providers).click(handleProviderChange);
		
		// Detect when submitted
		elements.submit.parents('form').submit(function(){
			isSubmitted = true;
		});
		
		// Check if the last time used was an OpenID url
		if($.cookie('user-openid.lastUsed') === 'openID') {
			$('.provider.openid', elements.providers).click();
		}
	});
	
	function handleProviderChange() {
		var provider;
		var providerContainer = $(this);
		
		// No longer able to change after submit
		if(isSubmitted) {
			return false;
		}
		
		provider = providerContainer.data('provider');
		
		// Fade in current provider
		providerContainer.fadeTo('fast', 1);
		
		// Fade out the other providers
		$('.provider:not([data-provider=' + provider + '])', elements.providers).fadeTo('slow', 0.35);
		
		// Check for known provider url
		if(providers[provider] && providers[provider].identity) {
			identity.container.slideUp('fast', function(){
				identity.input.val(providers[provider].identity);
				
				identity.input.parents('form').submit();
			});
			
			elements.submit.fadeOut('fast');
		} else {
			identity.input.val('');
			
			identity.container.slideDown('fast', function() {
				identity.input.focus();
			});
			
			elements.submit.fadeIn('fast');
		}
		
		// Add a cookie of what openID was used last
		$.cookie('user-openid.lastUsed', provider, { expire: 'never', path: '/' })
	}
}(jQuery));
