({
    getSearchCriteria: function(component) {
        this.callServer(component, "c.getSearchCriteria", function(response) {
            component.set("v.statusSearchCriterias", response.statusSearchCriterias);
            component.set("v.dateSearchCriterias", response.dateSearchCriterias);
            component.set("v.requestTypeSearchCriterias", response.requestTypeSearchCriterias);
        });
    },
    
    searchCaseRequest: function(component, dateFilter, statusFilter, requestTypeFilter) {
        this.callServer(component, "c.searchCaseRequest", function(response) {
            component.set("v.results", response);
            component.set("v.numberOfRecords", response.length);
        }, {
            viewAllRequests: component.get('v.viewAllRequests'), 
            dateFilter : dateFilter,
            statusFilter : statusFilter,
            requestTypeFilter: requestTypeFilter
        });
    },
    getAwsSettings : function(component,event){
        this.callServer(component, "c.getS3Setting", function(response) {
            component.set("v.amazonsetting",response);
            console.log('resp'+JSON.stringify(response));
        });
	},
    
})