({
	doInit : function(component, event, helper) {
        if(component.get("v.objContact")['sState'] == null || component.get("v.objContact")['sState'] == "") {
            var formattedAddress = "N/A";  
        }
        else if(component.get("v.objContact")['sSuite'] != null && component.get("v.objContact")['sSuite'] != "") {
            var formattedAddress = component.get("v.objContact")['sStreet']+", "+component.get("v.objContact")['sSuite']+", "+component.get("v.objContact")['sCity']+", "+component.get("v.objContact")['sState']+" "+component.get("v.objContact")['sPostalCode']+", "+component.get("v.objContact")['sCountry'];
        }
        else if(component.get("v.objContact")['sSuite'] == null || component.get("v.objContact")['sSuite'] == "") {
            var formattedAddress = component.get("v.objContact")['sStreet']+", "+component.get("v.objContact")['sCity']+", "+component.get("v.objContact")['sState']+" "+component.get("v.objContact")['sPostalCode']+", "+component.get("v.objContact")['sCountry'];
        }
        component.set('v.formattedAddress', formattedAddress);
        //document.querySelector('.StatusBar').scrollIntoView();
        //window.addEventListener('scroll', helper.bindScrollEvent);
        var action = component.get("c.getS3Setting");
        
        action.setCallback(this, function(response){
            if(component.isValid() && response !== null && response.getState() === 'SUCCESS'){
                component.set("v.amazonsetting",response.getReturnValue());
                console.log("SUCCESS");
                //var bucketname = amazonsetting.get('Amazon');
                console.log('Bucket Name'+JSON.stringify(response.getReturnValue()));
            }
            else{
                console.log("FAILED");
            }
            
        });
        $A.enqueueAction(action);
    },
    
    submitButtonClickHandler: function(component, event, helper) {
        helper.submitCaseCreation(component, event, helper);
    },

    backButtonClickHandler: function(component, event, helper) {
        var moveToSectionEvent = component.getEvent("moveToSection");
        moveToSectionEvent.setParams({
            "iStageIndentifier": 3
        });
        moveToSectionEvent.fire();
    },

    navigateToStage: function(component,event,helper){
        //var stage= event.currentTarget.dataset.id;
        helper.navigateToStage_Helper(component,event);
        /*var moveToSectionEvent = component.getEvent("moveToSection");
        moveToSectionEvent.setParams({
            "iStageIndentifier": parseInt(stage, 10)
        });
        moveToSectionEvent.fire();*/
    },
    
    cancelButtonClickHandler: function (component, event, helper) {
        component.set('v.showCancelPopup', true);
    },

    closeCancelPopup:function(component, event, helper){
        component.set('v.showCancelPopup', false);
    }
})