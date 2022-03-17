({
    isUserLoggedIn : function() {
        return !$A.util.isEmpty($A.get('$SObjectType.CurrentUser.Id'));
    },
    
    callServer: function(component, method, callback, params, cacheable,background, showSpinner) {
        try {
            showSpinner = (showSpinner === undefined || showSpinner === null) ? true : showSpinner;

            var action = component.get(method);
            var baseComponent = component.getSuper();
            if(showSpinner) {
                this.showSpinner(baseComponent);
            }
            if (params) {
                action.setParams(params);
            }
            if(background) {
                action.setBackground();
            }
            if (cacheable) {
                action.setStorable();
            }
            action.setCallback(this, function(response) {
                var state = response.getState();
                var returnValue = response.getReturnValue();
                this.hideSpinner(baseComponent);
                if (state === "SUCCESS") {
                    callback.call(this, returnValue);
                }
                else{
                    this.showToast('Error!', 'Unexpected Error Occured!', 'error', 'dismissible', '5000ms');
                } 
            });
            $A.enqueueAction(action);
        } 
        catch(e) {
            this.consoleLog(e.stack, true);
        }
    },
    
    showSpinner: function(component) {
        var spinner = component.find("spinner");
        $A.util.removeClass(spinner, "slds-hide");
    },
    
    hideSpinner: function(component) {
        var spinner = component.find("spinner");
        $A.util.addClass(spinner, "slds-hide");
    },
    
    showToast : function(title, message, type, mode, duration) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : title,
            message : message,
            type: type,
            mode: mode,
            duration : duration
        });
        toastEvent.fire();
    },
    
    redirectToPageURL : function(url, noBase){
        window.open(url, '_self');    
    },  

    getUrlParameterValue: function(paramName, pageUrl) {
        if($A.util.isEmpty(pageUrl)) {
            pageUrl = window.location.href;
        }

        paramName = paramName.replace(/[\[\]]/g, "\\$&");
        var regex = new RegExp("[?&]" + paramName + "(=([^&#]*)|&|#|$)");
        var results = regex.exec(pageUrl);
        if(!results) { 
            return null;
        }
        if(!results[2]) {
            return ''; 
        }
        return decodeURIComponent(results[2].replace(/\+/g, " "));
    },
    
    fireAppEvent: function (sEventName, objParameter) {
        var appEvent = $A.get(sEventName);
        appEvent.setParams(objParameter);
        appEvent.fire();
    }
})