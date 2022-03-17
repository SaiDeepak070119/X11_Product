({
    init: function(component, event, helper) {
        component.set('v.objForm', {});
    },

    isNumberKey: function(component, event, helper) {
        var value = component.get("v.objForm.sPhoneNumber");
    	if (value.match(/[a-z A-Z]/)) {    
        	value = value.replace(/[a-z A-Z]/g, '');
            component.set("v.objForm.sPhoneNumber", value);
        }
	},

    formatPhone: function(component, event, helper) {
        var value = component.get("v.objForm.sPhoneNumber");
    	var numbers = value.replace(/\D/g, ''),
            char = { 0: '(', 3: ') ', 6: '-' };
            value = '';
        
        for(var i = 0; i < numbers.length; i++) {
            value += (char[i] || '') + numbers[i];
        }

        component.set("v.objForm.sPhoneNumber", value);
	},

    searchAddresses: function(component, event, helper) {
        var addressSearchKey = component.get("v.addressSearchKey");
        var valid = helper.openListbox(component, component.get("v.addressSearchKey"));
        if(!valid) {
            helper.displayOptionsLocation(component, addressSearchKey); 
        }
	},

    showAddressDetails: function(component, event, helper) {
        var selectedAddress = event.currentTarget.dataset.record;        
        var selectedPlaceId= event.currentTarget.dataset.value;
        component.set("v.addressSearchKey", selectedAddress); 
        var addressLookup = component.find("addressLookup");
        $A.util.removeClass(addressLookup, 'slds-is-open');
        helper.setAddressDetails(component, selectedPlaceId, selectedAddress);
    },

    handleCancel: function(component, event, helper){
        window.open('../../', '_self');
    },

	register : function(component, event, helper) {
        component.set("v.errorMessage", '');
        component.set("v.errorMessages", []);
        console.log('*******');
        var valid = helper.validate(component);
        console.log('*******'+valid);
        if(!valid) {
            return;
        }

        var password = component.get("v.objForm.sPassword");
        var confirmPassword = component.get("v.confirmPassword");

        if (password !== confirmPassword) {
            component.set("v.errorMessage", $A.get("$Label.c.X11_Registration_Form_Password_Confirm_Password_Mismatch_Error_Message"));
            component.set("v.errorMessagesType", 'error');
        } 
        else {
            helper.registerUser(component);
        }
	}
    
})