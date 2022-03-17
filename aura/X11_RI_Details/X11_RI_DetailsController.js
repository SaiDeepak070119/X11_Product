({
    init: function (component, event, helper) {
        window.addEventListener('scroll', helper.bindScrollEvent);
        let userLocation = null;
        let mapDatatoPopulate = component.get('v.mapDateToPopulate');
        if (mapDatatoPopulate) {
            userLocation = mapDatatoPopulate.latLong;
        } else {
            userLocation = { "lat": parseFloat(32.715736), "lng": parseFloat(-117.161087) };
        }
        
        const mapOptionsCenter = userLocation;
        const mapData = [userLocation];
        component.set('v.mapOptionsCenter', mapOptionsCenter);
        component.set('v.mapData', mapData);
    },

    setAnswerOptions: function (component, event, helper) {
        var sQuestion = event.getParam("sQuestion");
        var sAnswer = event.getParam("sAnswer").split(",");
        var objCaseConfig = component.get("v.objCaseConfig");
        var objQuestionMap = objCaseConfig.mapQuestionAnswer;
        objCaseConfig.lstCaseQuestion.forEach(function (objQuestion) {
            if (objQuestion.bParentDependent && objQuestion.sParentQuestion === sQuestion) {
                objQuestion.lstOptions = [];
                var childMap = objQuestionMap[objQuestion.sQuestion];
                if (childMap !== undefined) {
                    sAnswer.forEach(function (answer) {
                        var optionsVal = childMap[sQuestion + '/--/' + answer];
                        if (optionsVal !== undefined) {
                            optionsVal.forEach(function (objValue) {
                                var objOption = { 'label': objValue, 'value': objValue };
                                objQuestion.lstOptions.push(objOption);
                                objQuestion.sAnswer = "";
                            });
                        }
                    });
                }
            }
        });
    },

    nextButtonClickHandler: function (component, event, helper) {
        var ispageDirty = false;
        var dateTimefailed = false;
        var listQuestionsMan = component.find("genericIdforAll");
		console.log(ispageDirty);
        console.log(listQuestionsMan);
        if(listQuestionsMan!==undefined){
        if (listQuestionsMan.length == undefined && listQuestionsMan.getType().indexOf('X11_RI_Details') >= 0) {
            var req = listQuestionsMan.get('v.isRequired');
            var ans = listQuestionsMan.get("v.detailsAnswer");
            if ((ans == undefined || ans == "") && req == true) {
                $A.util.addClass(listQuestionsMan, 'slds-has-error');
                listQuestionsMan.set("v.isInvalid", true);
                ispageDirty = true;
            }
            else {
                $A.util.removeClass(listQuestionsMan, 'slds-has-error');
                listQuestionsMan.set("v.isInvalid", false);
            }
        }
        else if (listQuestionsMan.length > 0) {
            listQuestionsMan.forEach(function (question) {
                var req = question.get('v.isRequired');
                var ans = question.get("v.detailsAnswer");
                if ((ans == undefined || ans == "") && req == true) {
                    $A.util.addClass(question, 'slds-has-error');
                    question.set("v.isInvalid", true);
                    ispageDirty = true;
                } 
                else {
                    $A.util.removeClass(question, 'slds-has-error');
                    question.set("v.isInvalid", false);
                }
            });
        }
        }
        if (component.find('dateTimeFieldId') !== undefined) {
            var verifyDate = component.find('dateTimeFieldId').verifyDate();
            if (!verifyDate) {
                ispageDirty = true;
                dateTimefailed = true;
            }
        }

        component.set('v.mapError',false);
        var selectedMapValues = component.get('v.selectedMapValues');
        var boundsCheck = selectedMapValues != null ? selectedMapValues.boundCheck : false;
        if (selectedMapValues == null || selectedMapValues == 'null') {
            component.set('v.mapError',true);
            ispageDirty = true;
        }else if (boundsCheck == false) {
            component.set('v.mapError',false);
            ispageDirty = true;
        }
        
        if (ispageDirty && !dateTimefailed) {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Error!",
                "message": "Please fill mandatory fields on this page",
                "type": "error"
            });
            toastEvent.fire();
        }

        if (dateTimefailed) {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Error!",
                "message": "Future time cannot be entered.",
                "type": "error"
            });
            toastEvent.fire();
        }
		console.log(ispageDirty);
        
        if (!ispageDirty) {
            helper.nextButtonClickHandler(component, event);
        }

    },
    setFileData: function (component, event, helper) {
        var appeventStatus = $A.get("e.c:SendUploadedFileDataToParent");
        appeventStatus.setParams({ "fileContentToInsert": event.getParam("uploadedFileData") });
        appeventStatus.fire();
    },
    backButtonClickHandler: function (component, event, helper) {
        helper.backToPrevious(component, event, helper);
    },
    cancelButtonClickHandler: function (component, event, helper) {
        component.set('v.showCancelPopup', true);
    },
    closeCancelPopup:function(component, event, helper){
        component.set('v.showCancelPopup', false);
    },
    handleChangeCaseType: function(component, event, helper){
        var csObj = component.get('v.objCase');
        component.set('v.predictedCaseType', csObj.Type);
    },
    getMapDataFromChildCmp : function(component, event, helper){
        var mapData = event.getParam("mapDataToPass");
        component.set('v.selectedMapValues', event.getParam("mapDataToPass"))
        component.set("v.boundsCheck",mapData.boundCheck);
        if(mapData == null){
            component.set('v.mapError',true);
        }else{
            component.set('v.mapError',false);
        }
        var appeventStatus =   $A.get("e.c:PopulatAddresOnParent");
        appeventStatus.setParams({ "mapDataToPass" : mapData });
        appeventStatus.fire();
    }
})