({
    handelError: true,
    /*
    * @author Abhishek Mishra
    * @date   04-MAR-2019
    * @description  Method handles server calls
    * @param component --> reference for the component from which this method is called
    * @param method (String) --> method name which needs to be called
    * @param callback(function) --> function to be called when server call completes
    * @param params(JSON) --> parameters to be passed to the server call
    * @param cacheable(boolean) --> boolean to set cacheable call
    * @param background(boolean) --> boolean to set background call
    */
    callServer: function (component, method, callback, params, cacheable, background, showSpinner) {
        try {
            showSpinner = (showSpinner === undefined || showSpinner === null) ? true : showSpinner;

            var action = component.get(method);
            var baseComp = component.getSuper();
            if(showSpinner) {
                this.toggleSpinner(baseComp);
            }
            
            if(params) {
                action.setParams(params);
            }
            if (background) {
                action.setBackground();
            }
            if (cacheable) {
                action.setStorable();
            }
            action.setCallback(this, function (response) {
                var state = response.getState();
                var lightningServerResponse = response.getReturnValue();
                this.toggleSpinner(baseComp);
                if (state === "SUCCESS") {
                    callback.call(this, lightningServerResponse, lightningServerResponse);
                }
                else {
                    this.showErrorToast('Unexpected error occured!');
                }
            });
            $A.enqueueAction(action);
        } catch (e) {
            this.consoleLog(e.stack, true);
        }
    },
    createErrorCMP: function (component, event, auraId, auraComponentId, lstMessages, sSeverity) {
        //-----
        $A.createComponent(
            "c:SWT_Error_Component",
            {
                "aura:id": auraComponentId,
                "v.lstMsgs": lstMessages,
                "v.sSeverity": sSeverity
            },
            function (cmpError, status, errorMessage) {
                //Add the new button to the body array
                if (status === "SUCCESS") {
                    var body = cmp.get("v." + auraId);// won't work
                    body.push(cmpError);
                    cmp.set("v.body", body);
                }
                else if (status === "INCOMPLETE") {
                    console.log("No response from server or client is offline.")
                    // Show offline error
                }
                else if (status === "ERROR") {
                    console.log("Error: " + errorMessage);
                    // Show error message
                }
            }
        );
        //------
    },
    /*
    *  @AUTHOR:  Abhishek Mishra
    *  @DESCRIPTION:This reusable method Initializes Record Template for any sObject using data service
    *  @PARAM :
       1. strObjAPIName(String) --> API name of the sObject
       2. strDataServiceAuraId(String) --> Aura Id of the recordData service used.
       3. objAttribute(Object) --> sObject instance specified in targetRecord
       4. strError(String) --> Error in initialization
       5. strRecTypeId(String) --> Initial record type Id for sObject Record
       6. boolSkipCache(Boolean) --> for skipping cache set true else false
       7. component
       8. callback(function) --> pass null if no callback method to be executed on success
    *  @RETURN:  JSON string with all relevant data
    *  Created as a part of DCP-3003
    */
    initializeRecordTemplate: function (strObjAPIName, strDataServiceAuraId, objAttribute, strError, strRecTypeId, boolSkipCache, component, callback) {

        component.find(strDataServiceAuraId).getNewRecord(
            strObjAPIName, // objectApiName
            strRecTypeId, // recordTypeId
            boolSkipCache, // skip cache?
            $A.getCallback(function () {
                var record = component.get(objAttribute);
                var error = component.get(strError);
                if (error || (record === null)) {
                    this.consoleLog("Error initializing record template: " + error, true);
                }
                else {
                    if (!$A.util.isUndefinedOrNull(callback)) {
                        callback.call(this);
                    }
                }
            })
        );
    },


    /*
    * @author Abhishek Mishra
    * @date   04-MAR-2019
    * @description  Method shows an error toast of the message passed
    * @param message (string) --> message to be displayed
    * @param error (boolean) --> parameter to be set only for error messages primarily from catch blocks
    * @param objGeneric(Object) --> Parameter to be set only if an object needs to be printed in the console
    */
    consoleLog: function (message, error, objGeneric) {
        try {
            var sCallStack = "";//storing call stack
            try { throw new Error(); } catch (e) { sCallStack = String(e.stack); }
            var originalLine = sCallStack.split("\n")[2].trim();
            var sConsoleLog = $A.get("$Label.c.X11_UI_Console_Logger");
            var sShowError = sConsoleLog.split("|")[0];
            var sShowMessage = sConsoleLog.split("|")[1];
            if (objGeneric) {
                objGeneric = JSON.stringify(objGeneric); }
            if (error && sShowError === "Yes") {
                if (objGeneric) {
                    console.error(message, objGeneric); }
                else {
                    console.error(message); }

            }
            else if (sShowMessage === "Yes") {
                if ((Array.isArray(message) && typeof (message[0]) === "object") && (console.table !== undefined)) {
                    console.table(message);
                } else if (objGeneric) {
                    console.debug(message, objGeneric);
                } else {
                    console.debug(message);
                }

                console.debug(originalLine);
            }

        } catch (e) {
            console.error(e.stack);
        }
    },

    /*
    * @author Abhishek Mishra
    * @date   04-MAR-2018
    * @description  Method shows an error toast of the message passed
    * @param strMessage (string) --> message to be shown
    * @param strMode (string) --> mode for toast
    * @param intDuration (number) --> duration
    */
    showErrorToast: function (strMessage, strMode, intDuration) {
        if ($A.util.isEmpty(strMode)) {
            strMode = 'sticky'; }//by default sticky 
        if ($A.util.isEmpty(intDuration)) {
            intDuration = 200;
            this.showToast('Error', strMessage, 'error', strMode, intDuration); }
    },

    /*
    * @author Abhishek Mishra
    * @date   04-MAR-2018
    * @description  Method shows a success toast of the message passed, by default sticky
    * @param strMessage (string) --> message to be shown
    * @param strMode (string) --> mode for toast
    * @param intDuration (number) --> duration
    */
    showSuccessToast: function (strMessage, strMode, intDuration) {
        if ($A.util.isEmpty(strMode)) {
            strMode = 'sticky'; }
        if ($A.util.isEmpty(intDuration)) {
            intDuration = 200;
            this.showToast('Success', strMessage, 'success', strMode, intDuration); }
    },

    /*
    * @author Abhishek Mishra
    * @date   04-MAR-2018
    * @description  shows the lightning toast
    * Documentation for toast below
    * https://developer.salesforce.com/docs/component-library/bundle/force:showToast/documentation
    * @param strTitle (string) --> Title to be shown
    * @param strMessage (string) --> message to be shown
    * @param strType (string) --> type of toast to be shown
    * @param strMode (string) --> mode for toast
    * @param intDuration (number) --> duration
    */
    showToast: function (strTitle, strMessage, strType, strMode, intDuration) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title: strTitle,
            message: strMessage,
            duration: intDuration,
            mode: strMode,
            type: strType
        });
        toastEvent.fire();
    },

    /*
    * @author Abhishek Mishra
    * @date   04-MAR-2019
    * @description  toggle the spinner
    *
    */
    toggleSpinner: function (component) {
        component.set("v.isSpinnerActive", !component.get("v.isSpinnerActive"));
    },

    /*
    * @author Abhishek Mishra
    * @date   04-MAR-2019
    * @description  redirect to a url
    * @param strRedirectURL (string) --> redirection url
    */
    redirectToPageURL: function (strRedirectURL, noBase) {
        if ($A.util.isEmpty(noBase)) {


            window.location.href = '/s' + strRedirectURL;
        } else {
            //alert(strRedirectURL)
            window.open(strRedirectURL, '_self');
        }
    },
    /*
    * @author Abhishek Mishra
    * @date   04-MAR-2019
    * @description  redirect to a record detail
    * @param sRecordId (string) --> record Id
    */
    redirectToSObject: function (sRecordId) {
        //redirects to the record
        this.consoleLog("sRecordId: " + sRecordId);
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": sRecordId
        });
        navEvt.fire();
    },

    /*
    * @author Abhishek Mishra
    * @date   04-MAR-2019
    * @description  sort the JSON list based on field, sort direction and a parser
    * @param strField (string) --> Field to be sorted
    * @param booReverse (boolean) --> boolean to indicate direction
    * @param primer (function) --> parsing function
    */
    sortBy: function (strField, booReverse, primer) {
        var key = primer ?
            function (x) { return primer(x[strField]) } :
            function (x) { return x[strField] };
        booReverse = !booReverse ? 1 : -1;
        return function (a, b) {
            return a = key(a), b = key(b), booReverse * ((a > b) - (b > a));
        }
    },
    /*
     * @author Abhishek Mishra
     * @date   04-MAR-2019
     * @description  Method Closes the quick Action
     * @param No Parameters
     */
    closeAction: function (component, event) {
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire();
    },

    /*
     * @author Abhishek Mishra
     * @date   04-MAR-2019
     * @description  Refreshes the back ground page
     * @param No Parameters
     */
    refreshPage: function (component, event) {
        $A.get('e.force:refreshView').fire();
    },

    /*
   * @author Abhishek Mishra
   * @date   04-MAR-2019
   * @description  Fetch the Parameter value from a Page Url
   * @param pageUrl (string) --> Page Url that contains attributes
   * @param paramName (String) --> Attribute to be extracted
   * @param No Parameters
   */
    getUrlParameterValue: function (paramName, pageUrl) {
        if ($A.util.isEmpty(pageUrl)) {
            pageUrl = window.location.href;
        }
        paramName = paramName.replace(/[\[\]]/g, "\\$&");
        var regex = new RegExp("[?&]" + paramName + "(=([^&#]*)|&|#|$)");
        var results = regex.exec(pageUrl);
        if (!results) {return null;}
        if (!results[2]) {return ''; }
        return decodeURIComponent(results[2].replace(/\+/g, " "));
    },
    /*
     * @author Abhishek Mishra
     * @date   17-APL-2019
     * @description  Fires an application event
     * @param eventname (string) --> Page Url that contains attributes
     * @param paramNames (JSON) --> Attribute to be extracted
     * @returnType N/A
     */
    fireAppEvent: function (sEventName, objParameter) {
        var appEvent = $A.get(sEventName);
        appEvent.setParams(objParameter);
        appEvent.fire();
    }
})