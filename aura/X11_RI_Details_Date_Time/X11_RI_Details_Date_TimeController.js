({
	verifyDate : function(component, event, helper) {
		var inputCmp = component.find('dtfieldId');
        var validity = inputCmp.checkValidity();
        return validity;
	},
    setMaxDate: function(component, event, helper) {
        var today = new Date();
        component.set('v.todayDate', today);
	}
})