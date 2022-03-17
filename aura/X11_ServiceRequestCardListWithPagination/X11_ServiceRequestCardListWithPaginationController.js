({
    init: function(component, event, helper) {
        component.set('v.currentPageNumber', 1);
        var numberOfRecordsPerPage = component.get('v.numberOfRecordsPerPage');
        var serviceRequests = component.get('v.serviceRequests');
        component.set('v.totalPages', Math.ceil(serviceRequests.length/numberOfRecordsPerPage));
        helper.setPagesToShow(component);
        var caseToAwsImageNames = [];
        var imageList =[];
        serviceRequests.forEach(serviceRequest => {   
            if(serviceRequest && serviceRequest.awsImageList && serviceRequest.awsImageList!='')
            {
            	caseToAwsImageNames.push({key:serviceRequest.caseObj.CaseNumber,value:serviceRequest.awsImageList[0]});	
        	}
    		if(serviceRequest && serviceRequest.imageUrl && serviceRequest.awsImageList=='')
            {
            	imageList.push({key:serviceRequest.caseObj.CaseNumber,value:serviceRequest.imageUrl});
        	}
        });
        if(caseToAwsImageNames!=null || caseToAwsImageNames.length>0){
            helper.showImagePreview(component,event,caseToAwsImageNames,imageList);
        }
        if(caseToAwsImageNames.length==0){
            component.set("v.imageDataUrlList",imageList);
        }
    },
    
    cardClickHandler: function(component, event, helper) {
        var selectedServiceRequestId = event.currentTarget.dataset.requestId;
        var amazonSetting = component.get("v.amazonsetting");
        var serviceRequests = component.get('v.serviceRequests');
        serviceRequests.forEach(serviceRequest => {
            if(serviceRequest.caseObj.Id === selectedServiceRequestId) {
                var cardSelectEvent = component.get('e.cardSelect');
                cardSelectEvent.setParams({
                    "serviceRequest" : serviceRequest,
            		"amazonsetting" : amazonSetting
                });
                cardSelectEvent.fire();
            }
        });
    },

    moveToFirstPage: function(component, event, helper) {
        component.set('v.currentPageNumber', 1);
        helper.setPagesToShow(component);
    },

    moveToPreviousPage: function(component, event, helper) {
        component.set('v.currentPageNumber', component.get('v.currentPageNumber') - 1);
        helper.setPagesToShow(component);
    },

    moveToSelectedPage: function(component, event, helper) {
        component.set('v.currentPageNumber', parseInt(event.getSource().get("v.name"), 10));
        helper.setPagesToShow(component);
    },
    
    moveToNextPage: function(component, event, helper) {
        component.set('v.currentPageNumber', component.get('v.currentPageNumber') + 1);
        helper.setPagesToShow(component);
    },

    moveToLastPage: function(component, event, helper) {
        component.set('v.currentPageNumber', component.get('v.totalPages'));
        helper.setPagesToShow(component);
    }
})