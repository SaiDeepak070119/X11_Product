({
	doInit_Helper : function(cmp, event) {
       	var labels = cmp.get("v.mapLabels");
        var objContact;
        if(cmp.get("v.objContact") != undefined && cmp.get("v.objContact")['sAddress'] != undefined){
             objContact = cmp.get("v.objContact")['sAddress'];
        }
        //addedd PRA check for required fields
        if(cmp.get("v.objCaseConfig.sCaseCategory") != undefined && cmp.get("v.objCaseConfig.sCaseCategory") != $A.get("$Label.c.PRA_Case_Type")){
             cmp.set("v.isPRA", false);
        }else if(cmp.get("v.objCaseConfig.sCaseCategory") != undefined && cmp.get("v.objCaseConfig.sCaseCategory") == $A.get("$Label.c.PRA_Case_Type")){
             cmp.set("v.isPRA", true);
        }
       
        if(objContact != null){
            cmp.set("v.sSearchKey", objContact);
        }
         this.callServer(cmp, "c.initialLoading", function(result) {
            var objResponse = JSON.parse(result);
            cmp.set("v.sCountryCode", objResponse.sCountryCode);
            document.querySelector('.POSD_StatusBar').scrollIntoView();
             console.log(objResponse.mapLabels);
             cmp.set("v.mapLabels", objResponse.mapLabels);

        });
    },
    backCreation_Helper: function(cmp, event) {
        if(cmp.get("v.objCaseConfig.sCaseCategory") != undefined &&  (cmp.get("v.objCaseConfig.sCaseCategory") == $A.get("$Label.c.PRA_Case_Type") ||  cmp.get("v.objCaseConfig.sCaseType") == $A.get("$Label.c.General_Parking_Question_Case_Type"))){
            this.fireAppEvent("e.c:X11_RI_StatusBarEvent", {"iStageIndentifier" : 1});
        }else{
            this.fireAppEvent("e.c:X11_RI_StatusBarEvent", {"iStageIndentifier" : 2});
        }
        
    },
	verifyDetails_Helper : function(cmp, event){    
       	var objContact = cmp.get("v.objContact");
    	objContact['sAddress'] = cmp.get("v.sSearchKey");
        cmp.set("v.objContact",objContact);
        //All Required Field Check
        var bAnyError;
            if(cmp.get("v.objCaseConfig.sCaseCategory") != $A.get("$Label.c.PRA_Case_Type")){
                bAnyError = this.validateInput_Helper(cmp, event);
            }
        
        var caseType = cmp.get("v.objCaseConfig.sCaseType");
        var valuenumber=cmp.get("v.numbervalidity");
        
        if(!bAnyError && cmp.get("v.objCaseConfig.sCaseCategory") != $A.get("$Label.c.PRA_Case_Type")  && cmp.get("v.objCaseConfig.sCaseType") != $A.get("$Label.c.General_Parking_Question_Case_Type") && valuenumber){
            this.fireAppEvent("e.c:X11_RI_StatusBarEvent", {"iStageIndentifier" : 3});
        } else if(!bAnyError && (cmp.get("v.objCaseConfig.sCaseCategory") == $A.get("$Label.c.PRA_Case_Type") ||  cmp.get("v.objCaseConfig.sCaseType") == $A.get("$Label.c.General_Parking_Question_Case_Type") && valuenumber))  {
            this.fireAppEvent("e.c:X11_RI_StatusBarEvent", {"iStageIndentifier" : 1});
        }     
    },
    validateInput_Helper : function(cmp, event){
        var bNoFirstName = false, bNoLastName = false, bNoEmail = false, bNoPhone = false, bNoAddress=false;
        var bAnyError = false;
        bNoFirstName = this.validDataCheck_Helper(cmp, 'idFirstName');
        bNoLastName = this.validDataCheck_Helper(cmp, 'idLastName');
        bNoEmail = this.validDataCheck_Helper(cmp, 'idEmail');
        bNoPhone = this.validDataCheck_Helper(cmp, 'idPhoneNumber');
        //bNoAddress = this.validDataCheck_Helper(cmp, 'idSearchKey');    
        if(bNoFirstName || bNoLastName || bNoEmail || bNoPhone){
            bAnyError = true;
        }        
        return bAnyError;     
    },
   	validDataCheck_Helper : function(cmp, sFieldAuraId){
        var bAnyError = false;
        var sErrorMsg = cmp.get("v.mapLabels")['sBlankValue']; 
        var sInField = cmp.find(sFieldAuraId);
        var sFieldVal = sInField.get("v.value");
        //Blank Value Check
        if ($A.util.isEmpty(sFieldVal)){
            sInField.setCustomValidity(sErrorMsg, null);
			sInField.showHelpMessageIfInvalid();
            bAnyError = true;
        }else{
            sInField.setCustomValidity('');
            sInField.showHelpMessageIfInvalid();
        }
        //Standard Error Check
        if(!sInField.reportValidity()){
        	bAnyError = true;            
        }else{
            sInField.setCustomValidity('');
            sInField.showHelpMessageIfInvalid();
        } 
        return bAnyError;
    },    
	openListbox: function (cmp, sSearchKey) {
        debugger;
        try{
            var cmpSearchLookup = cmp.find("idSearchLookup");
            if (typeof sSearchKey === 'undefined' || sSearchKey.length < 3) {
                $A.util.addClass(cmpSearchLookup, 'slds-combobox-lookup');
                $A.util.removeClass(cmpSearchLookup, 'slds-is-open');
                return true;
            }
            $A.util.addClass(cmpSearchLookup, 'slds-is-open');
            $A.util.removeClass(cmpSearchLookup, 'slds-combobox-lookup');
            return false;
        }catch(e){console.log(e); return true;}
    },
    displayOptionsLocation: function (cmp, sSearchKey) {
        debugger;
        try{
            this.callServer(cmp, "c.getAddressAutoComplete", function(result) {
                var options = JSON.parse(result); 
                if(!$A.util.isEmpty(options)){
                    var predictions = JSON.parse(options.sResponse).predictions;
                    var addresses = [];
                    if(!$A.util.isEmpty(predictions) && predictions.length > 0){
                        for (var i = 0; i < predictions.length; i++) {
                            addresses.push({
                                value: predictions[i].place_id,
                                label: predictions[i].description
                            });     
                        }
                        
                        cmp.set("v.lstAddresses", addresses);
                    }
                    else{
                        cmp.set("v.lstAddresses", addresses);
                    }
                }
            }, {
                "sSearchKey": sSearchKey,
                "sCountryCode": cmp.get("v.sCountryCode")
            });
        }catch(e){console.log(e);}
    },
    showAddressDetails_Helper : function(cmp, event, helper){
        debugger;
        try{
            
            var sSelectedAddress = event.currentTarget.dataset.record;        
            var sSelectedPlaceId= event.currentTarget.dataset.value;
            cmp.set("v.sSearchKey", sSelectedAddress); 
            var cmpSearchLookup = cmp.find("idSearchLookup");
            $A.util.removeClass(cmpSearchLookup, 'slds-is-open');
            this.setAddressDetails(cmp, sSelectedPlaceId, sSelectedAddress);
        }catch(e){console.log(e);}
    },
    setAddressDetails: function (cmp, sSelectedPlaceId, sSelectedAddress) {
        debugger;
        try{
            this.callServer(cmp, "c.getselectedAddressDetails", function(result) {    
                var objResponse = JSON.parse(JSON.parse(result).sResponse); 
                var objAddress;
                if(!$A.util.isEmpty(objResponse.result) && !$A.util.isEmpty(objResponse.result.address_components)){
                    objAddress = objResponse.result;
                }else{
                    objAddress = objResponse.results[0];
                }
                var objAddressDetails = objAddress.address_components;
                var sStreet = ''; var sStreetNumber = ''; var sCity = ''; var sState = ''; var sCounty = ''
                var sState = ''; var sCountry = ''; var sPostalCode = ''; var sCountyCode = '';
                console.log(objAddressDetails);
                if (!$A.util.isEmpty(objAddressDetails)) {
                    for (var i = 0; i < objAddressDetails.length; i++) {
                        for(var j = 0; j <  objAddressDetails[i].types.length; j++){
                            if(objAddressDetails[i].types[j] === "route") {
                                sStreet = objAddressDetails[i].long_name;}
                            else if(objAddressDetails[i].types[j] === "street_number"){
                                sStreetNumber = objAddressDetails[i].long_name}
                                else if(objAddressDetails[i].types[j] === "locality"){
                                    sCity = objAddressDetails[i].long_name;}
                                    else if(objAddressDetails[i].types[j] === "administrative_area_level_1"){
                                        sState = objAddressDetails[i].long_name;}
                                        else if(objAddressDetails[i].types[j] === "administrative_area_level_2"){
                                            sState = objAddressDetails[i].long_name;}
                                            else if(objAddressDetails[i].types[j] === "country"){
                                                sCountry = objAddressDetails[i].long_name;}
                                                else if(objAddressDetails[i].types[j] === "postal_code"){
                                                    sPostalCode = objAddressDetails[i].long_name; }
                        }
                    }
                }
                var objForm = cmp.get("v.objContact");
                objForm.sStreet = $A.util.isEmpty(sStreetNumber) ? sStreet : sStreetNumber+' '+sStreet;
                objForm.sSuite = '';
                objForm.sCity = sCity;
                objForm.sState = sState;
                objForm.sPostalCode = sPostalCode;
                objForm.sCountry = sCountry;
                cmp.set("v.objContact", objForm);
                cmp.set("v.bAddrDisabled", false);

                var sLatitude = objAddress.geometry.location.lat;
                var sLongitude = objAddress.geometry.location.lng;
                cmp.set('v.mapMarkers', [
                    {
                        location: {
                            Latitude: objAddress.geometry.location.lat,
                            Longitude: objAddress.geometry.location.lng           
                        },
                        title: objAddress.formatted_address
                    }
        		]);
                console.log(v.mapMarkers);  
            }, {
                "sSelectedPlaceId": sSelectedPlaceId,
                "selectedAddress": sSelectedAddress,
            });
        }catch(e){console.log(e);}
    },
    bindScrollEvent: function () {
        const breadcrumWrapperElement = document.querySelector('.breadcrumb-wrap'),
            footer = document.querySelector('.footer'),
            footerRect = footer.getBoundingClientRect();
        if (footerRect.top <= (window.innerHeight || document.documentElement.clientHeight)) {
            breadcrumWrapperElement.classList.remove('sticky-breadcrumb');
        } else {
            breadcrumWrapperElement.classList.add('sticky-breadcrumb');
        }
    }
})