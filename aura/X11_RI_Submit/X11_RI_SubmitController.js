({
    doInit: function (component, event, helper) {
        window.scrollTo(0, 0);
        helper.doInit_Helper(component, event);
    },
    verifyDetails: function (component, event, helper) {
        var allValid = component.find('idPassword').reduce(function (validSoFar, inputCmp) {
            inputCmp.showHelpMessageIfInvalid();
            return validSoFar && !inputCmp.get('v.validity').valueMissing;
        }, true);
        if (allValid ) {
            helper.verifyDetails_Helper(component, event);       
        } 
        else {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Error!",
                "message": "Please fill mandatory fields on this page",
                "type" : "error",
                "mode":"sticky"
                
            });
            toastEvent.fire(); 
        }    
        
    },
    createAccount: function (component, event, helper) {
        helper.createAccount_Helper(component, event);
    },
    signInPage: function (component, event, helper) {
         let sltCmp = component.find("idPassword");
        if(sltCmp.get("v.validity").valid){ 
            helper.signInPage_Helper(component, event); 
        }else{
            sltCmp.showHelpMessageIfInvalid();
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Error!",
                "message": "Please fill mandatory fields on this page",
                "type" : "error",
                "mode":"sticky"
                
            });
            toastEvent.fire(); 
            //return;
        }
       /* var allValid = component.find('idPassword').reduce(function (validSoFar, inputCmp) {
            inputCmp.showHelpMessageIfInvalid();
            return validSoFar && !inputCmp.get('v.validity').valueMissing;
        }, true);
        if (allValid ) {
            helper.signInPage_Helper(component, event);  
        } 
        else {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Error!",
                "message": "Please fill mandatory fields on this page",
                "type" : "error",
                "mode":"sticky"
                
            });
            toastEvent.fire(); 
        }    */
        
    },
    redirectToAccount: function (component, event, helper) {
        helper.redirectToAccount_Helper(component, event);
    },
    redirectToHome: function (component, event, helper) {
        helper.redirectToHome_Helper(component, event);
    },
     reset_Password: function(component,event,helper){
        helper.resetPassword_Helper(component);
    }
})