({
    init: function(component, event, helper) {
        var serviceRequest = component.get('v.serviceRequest');
        if(serviceRequest && serviceRequest.awsImageList)
        {
            helper.showImagePreview(component,event,serviceRequest.awsImageList);
        }
        var mapMarkers = [];
        if(serviceRequest && serviceRequest.caseObj && serviceRequest.caseObj.Street_Address__c && 
                serviceRequest.caseObj.Geolocation__Latitude__s && serviceRequest.caseObj.Geolocation__Longitude__s) {
            mapMarkers = [{
                    location: {
                        Latitude: serviceRequest.caseObj.Geolocation__Latitude__s,
                        Longitude: serviceRequest.caseObj.Geolocation__Longitude__s
                    },
                    title: serviceRequest.caseObj.Street_Address__c
            }];
        }
        component.set('v.mapMarkers', mapMarkers);
    },

    previousSlideClickHandler: function(component, event, helper) {
        var index = component.get('v.currentImageSlideIndex');
        if(index > 0) {
            component.set('v.currentImageSlideIndex', index - 1);
            helper.updateSlideToDisplay(component);
        }
    },
    
    nextSlideClickHandler: function(component, event, helper) {
        var index = component.get('v.currentImageSlideIndex');
        var numberOfImages = document.querySelectorAll('.service-request-image').length;
        if(index < numberOfImages - 1) {
            component.set('v.currentImageSlideIndex', index + 1);
            helper.updateSlideToDisplay(component);
        }
    }
})