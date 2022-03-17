({
	getAllCaseConfigurationRecords : function(component) {
		this.callServer(component, "c.getAllCaseConfigurationRecords", function(result) {
         	component.set('v.isPortalUser', result.isPortalUser);
            component.set('v.allCaseConfigurations', result.allCaseConfigurations);
            component.set('v.caseConfigurationsByCategory', result.caseConfigurationsByCategory);
            component.set('v.popularCaseConfigurations', result.popularCaseConfigurations);
        }); 
	},
    navigateToReportIssue: function(component, event, helper) {
        var bIsPortalUser = component.get("v.isPortalUser");
		if(component.get('v.isPortalUser')) {
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
                    "c__issueTypeId": event.getParam("caseConfigId"),
                    "c__IsPortalUser": "false"
                }
            };
            var navService = component.find("navService");
            event.preventDefault();
            navService.navigate(pageReference);
        }
	}
})