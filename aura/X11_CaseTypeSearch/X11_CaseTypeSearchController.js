({
	search : function(component, event, helper) {
		var searchKey = component.get('v.searchKey');
        var searchResults= []; 
        
        if ($A.util.isEmpty(searchKey) || searchKey.length < 3) {
            component.set('v.searchResults', searchResults);
            return;
        }
        
        searchKey = searchKey.toUpperCase();
        var allCaseConfigurations = component.get('v.allCaseConfigurations');
        for(var i = 0; i < allCaseConfigurations.length; i++) {
            var caseConfig = allCaseConfigurations[i];
            if(!$A.util.isEmpty(caseConfig.caseType) && caseConfig.caseType.toUpperCase().search(searchKey) >= 0) {
                searchResults.push(caseConfig);
            }
        }
        component.set('v.searchResults', searchResults);
    },
    
    navigateToReportIssuePage : function(component, event, helper) {
		var navigateToReportIssue = component.getEvent("navigateToReportIssue");
        navigateToReportIssue.setParams({
            "caseConfigId" : event.currentTarget.dataset.caseId 
        });
        navigateToReportIssue.fire();
    }
})