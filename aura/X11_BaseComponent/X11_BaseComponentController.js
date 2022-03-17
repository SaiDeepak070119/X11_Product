({
	init : function(component, event, helper) {
		component.set('v.isUserLoggedIn', helper.isUserLoggedIn());
	}
})