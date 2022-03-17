({
	showModal : function(component, event, helper) {
		component.set('v.showModalFlag', true);
	},
    
    closeModal : function(component, event, helper) {
		component.set('v.showModalFlag', false);
	}
})