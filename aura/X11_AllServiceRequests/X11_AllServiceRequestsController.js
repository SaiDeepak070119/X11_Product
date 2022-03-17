({
    openOrCloseAccordion : function(component, event, helper) {
        event.target.classList.toggle("active")
    },

    navigateToReportIssuePage : function(component, event, helper) {
		var navigateToReportIssue = component.getEvent("navigateToReportIssue");
        navigateToReportIssue.setParams({
            "caseConfigId" : event.currentTarget.dataset.caseId 
        });
        navigateToReportIssue.fire();
    }
})