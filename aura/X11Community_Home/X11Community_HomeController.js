({
	init: function(component, event, helper) {
		helper.getAllCaseConfigurationRecords(component);
	},

	navigateToReportIssue: function(component, event, helper) {
        helper.navigateToReportIssue(component, event, helper);
		/*if(component.get('v.isPortalUser')) {
			helper.redirectToPageURL($A.get("$Label.c.X11_Report_Issue_Link") + "?issueTypeId=" + event.getParam("caseConfigId") + 
									"&c__IsPortalUser=true");
		}
		else {
            var pageReference = {
                type: 'standard__component',
                attributes: {
                    componentName: 'c__X11_RI_ParentComponent'
                },
                state: {
                    "c__issueTypeId": event.getParam("caseConfigId")
                }
            };
            var navService = component.find("navService");
            navService.navigate(pageReference);
        }*/
	}
})