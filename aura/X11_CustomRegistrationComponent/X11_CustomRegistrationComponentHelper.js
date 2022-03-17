({

    openListbox: function (component, addressSearchKey) {
        try {
            var addressLookup = component.find("addressLookup");
            if (typeof addressSearchKey === 'undefined' || addressSearchKey.length < 3) {
                $A.util.addClass(addressLookup, 'slds-combobox-lookup');
                $A.util.removeClass(addressLookup, 'slds-is-open');
                return true;
            }

            $A.util.addClass(addressLookup, 'slds-is-open');
            $A.util.removeClass(addressLookup, 'slds-combobox-lookup');
            return false;
        }
        catch (e) {
            console.log(e);
            return true;
        }
    },

    displayOptionsLocation: function (component, addressSearchKey) {
        this.callServer(component, "c.getAddressAutoComplete", function (result) {
            if (!$A.util.isEmpty(result)) {
                var predictions = JSON.parse(result.response).predictions;
                var addresses = [];
                if (!$A.util.isEmpty(predictions)) {
                    for (var i = 0; i < predictions.length; i++) {
                        addresses.push({
                            value: predictions[i].place_id,
                            label: predictions[i].description
                        });
                    }
                }
                component.set("v.addressSearchResult", addresses);
            }
        },
        {
            "enteredAddress": addressSearchKey
        }, false, false, false);
    },

    setAddressDetails: function (component, selectedPlaceId, selectedAddress) {
        try {
            this.callServer(component, "c.getSelectedAddressDetails", function (result) {
                var objResponse = JSON.parse(result.response);

                var objAddress;
                if (!$A.util.isEmpty(objResponse.result) && !$A.util.isEmpty(objResponse.result.address_components)) {
                    objAddress = objResponse.result;
                } 
                else {
                    objAddress = objResponse.results[0];
                }
                var objAddressDetails = objAddress.address_components;
                var sStreet = ''; var sStreetNumber = ''; var sCity = ''; var sState = ''; var sCounty = ''
                var sState = ''; var sCountry = ''; var sPostalCode = ''; var sCountyCode = '';
                console.log(objAddressDetails);
                if (!$A.util.isEmpty(objAddressDetails)) {
                    for (var i = 0; i < objAddressDetails.length; i++) {
                        for (var j = 0; j < objAddressDetails[i].types.length; j++) {
                            if (objAddressDetails[i].types[j] === "route") {
                                sStreet = objAddressDetails[i].long_name;
                            }
                            else if (objAddressDetails[i].types[j] === "street_number") {
                                sStreetNumber = objAddressDetails[i].long_name
                            }
                            else if (objAddressDetails[i].types[j] === "locality") {
                                sCity = objAddressDetails[i].long_name;
                            }
                            else if (objAddressDetails[i].types[j] === "administrative_area_level_1") {
                                sState = objAddressDetails[i].long_name;
                            }
                            else if (objAddressDetails[i].types[j] === "administrative_area_level_2") {
                                sState = objAddressDetails[i].long_name;
                            }
                            else if (objAddressDetails[i].types[j] === "country") {
                                sCountry = objAddressDetails[i].long_name;
                            }
                            else if (objAddressDetails[i].types[j] === "postal_code") {
                                sPostalCode = objAddressDetails[i].long_name;
                            }
                        }
                    }
                }
                var objForm = component.get("v.objForm");
                /*if(!objForm) {
                    objForm = {};
                }*/
                objForm.sStreet = $A.util.isEmpty(sStreetNumber) ? sStreet : sStreetNumber + ', ' + sStreet;
                objForm.sSuite = '';
                objForm.sCity = sCity;
                objForm.sState = sState;
                objForm.sPostalCode = sPostalCode;
                objForm.sCountry = sCountry;
                component.set("v.objForm", objForm);
                component.set("v.bAddrDisabled", false);
            },
            {
                "selectedPlaceId": selectedPlaceId,
                "selectedAddress": selectedAddress,
            });
        }
        catch (e) {
            console.log(e);
        }
    },

    registerUser: function (component) {
        console.log(component.get("v.objForm.bLegueRep"));
        if(component.get("v.objForm.bLegueRep")==undefined){
            component.set("v.objForm.bLegueRep",false);
        }
        if(component.get("v.objForm.bPormotionalEmail")==undefined){
            component.set("v.objForm.bPormotionalEmail",false);
        }
        this.callServer(component, "c.registerUser", function (result) {
            if (!$A.util.isEmpty(result.sStatus) && result.sStatus == 'Success') {
                window.open(result.redirectUrl);
            } 
            else {
                component.set("v.errorMessages", result.errorMessages);
                component.set("v.sMessageType", 'error');
            }
        }, {
            "wrapper": component.get("v.objForm")
        });
    },

    validate: function (component) {
        var firstNameValid = false, lastNameValid = false, phoneNumberValid = false, 
            emailValid = false, passwordValid = false, confirmPasswordValid = false;
        
        firstNameValid = this.validateInput(component, 'firstName');
        lastNameValid = this.validateInput(component, 'lastName');
        phoneNumberValid = this.validateInput(component, 'phoneNumber');
        emailValid = this.validateInput(component, 'email');
        passwordValid = this.validateInput(component, 'password');
        confirmPasswordValid = this.validateInput(component, 'confirmPassword');

        if(firstNameValid && lastNameValid && !phoneNumberValid && emailValid && passwordValid && confirmPasswordValid) {
            return false;
        }
        return true;
    },

    validateInput: function (component, sFieldAuraId) {
        var inputComponent = component.find(sFieldAuraId);
        inputComponent.showHelpMessageIfInvalid();
        return inputComponent.get('v.validity').valid;
    }
})