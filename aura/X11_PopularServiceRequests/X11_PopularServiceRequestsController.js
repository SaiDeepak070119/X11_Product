({
	previousSlideClickHandler : function(component, event, helper) {
		var index = component.get('v.currentSlideIndex');
        if(index > 0) {
            component.set('v.currentSlideIndex', index - 1);
            helper.updateSlideToDisplay(component);
        }
	},
    
    nextSlideClickHandler : function(component, event, helper) {
		var index = component.get('v.currentSlideIndex');
        var popularCaseConfigurationsLength = component.get('v.popularCaseConfigurations').length;
        if(index < popularCaseConfigurationsLength - 1) {
            component.set('v.currentSlideIndex', index + 1);
            helper.updateSlideToDisplay(component);
        }
    },
    
    navigateToReportIssuePage : function(component, event, helper) {
		var navigateToReportIssue = component.getEvent("navigateToReportIssue");
        navigateToReportIssue.setParams({
            "caseConfigId" : event.currentTarget.dataset.id 
        });
        navigateToReportIssue.fire();
    }
})