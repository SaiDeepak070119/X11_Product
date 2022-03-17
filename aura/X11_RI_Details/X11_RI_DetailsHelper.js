({
    nextButtonClickHandler: function (component, event) {
        var objCaseConfig = component.get("v.objCaseConfig");
        var objCase = component.get("v.objCase");
        objCase.Origin = objCaseConfig.sCaseOrigin;
        objCase.Hide_from_Web__c = objCaseConfig.sHideFromWeb;
        let mapDataToPopulate = component.get('v.selectedMapValues');
        if(mapDataToPopulate){
            objCase['Street_Address__c'] = mapDataToPopulate.streetNum + ' ' + mapDataToPopulate.streetaddress;
            objCase['City__c'] = mapDataToPopulate.city;
            objCase['State__c'] = 'CA';
            objCase['Country__c'] = 'US';
            objCase['Zipcode__c'] = mapDataToPopulate.postal;
            objCase['Geolocation__Longitude__s'] = mapDataToPopulate.latLong.lng;
            objCase['Geolocation__Latitude__s'] = mapDataToPopulate.latLong.lat;  
        }
        component.set('v.objCase', objCase);

        objCaseConfig.lstCaseQuestion.forEach(function (objQuestion) {
            if (objQuestion.sQuestion == 'REQUEST ANONYMOUSLY' && objQuestion.sAnswer == 'Yes') {
                component.set("v.isAnonymous", true);
            }
        });

        this.fireAppEvent("e.c:X11_RI_StatusBarEvent", {"iStageIndentifier" : 2});
    },
    backToPrevious: function(component, event, helper){
        this.fireAppEvent("e.c:X11_RI_StatusBarEvent", {"iStageIndentifier" : 1});
    },
    /*getAddressDetails: function (component, event, helper) {
        console.log(event);
        component.set('v.selectedMapValues', event.getParam("mapDataToPass"));
        console.log(component.get('v.selectedMapValues'));
    },*/
    
})