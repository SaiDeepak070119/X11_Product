({
	doInit : function(component, event, helper) {
        //window.scrollTo(0, 0);
        helper.doInit_Helper(component, event);
        window.addEventListener('scroll', helper.bindScrollEvent);     
    },
    backCreation: function(component, event, helper) {
        helper.backCreation_Helper(component, event);
    },
    verifyDetails : function(component, event, helper) {
        helper.verifyDetails_Helper(component, event);
	},
    getAddressesForKey : function(component, event, helper) {
        var sSearchKey = component.get("v.sSearchKey");
        var bSearchKeyValid = helper.openListbox(component, component.get("v.sSearchKey"));
        if(!bSearchKeyValid) {
            helper.displayOptionsLocation(component, sSearchKey);}
	},
    showAddressDetails: function(component, event, helper){
        helper.showAddressDetails_Helper(component,event);
    },
    isNumberKey: function(component, event, helper){
        var value = component.get("v.objContact.sPhone");
    	if (value.match(/[a-z A-Z]/)) {    
        	value = value.replace(/[a-z A-Z]/g, '');
            component.set("v.objContact.sPhone",value)
        }
	},
    formatPhone : function(component, event, helper){
        var value = component.get("v.objContact.sPhone");
        if(value==null || value.length==0){
            var cmpTarget = component.find('phoneError');
            $A.util.addClass(cmpTarget, 'slds-hide');
            component.set("v.numbervalidity", false);
            return;
        }
        if(value!=null && value.length<10){
            var cmpTarget = component.find('phoneError');
            $A.util.removeClass(cmpTarget, 'slds-hide');
            component.set("v.numbervalidity", false);
            return;
        }
        if(value!=null && value.length==10){
            component.set("v.numbervalidity", true);
        }
    	var numbers = value.replace(/\D/g, ''),
        char = { 0: '(',3:') ',6:'-' };
        var value1 = '';
        for (var i = 0; i < numbers.length; i++) {
            value1 += (char[i] || '') + numbers[i];
        }
        if(value1 != null && value1.length == 14){
         component.set("v.objContact.sPhone",value1); 
            component.set("v.numbervalidity", true);
        }
        else{
           var cmpTarget = component.find('phoneError');
            $A.util.removeClass(cmpTarget, 'slds-hide');
            component.set("v.numbervalidity", false);
            return; 
        }
	},
    hideErrorOnPhone : function(component, event, helper){
    	var cmpTarget = component.find('phoneError');
        $A.util.addClass(cmpTarget, 'slds-hide');
    },
    loadOptions: function (component, event, helper) {
        var opts = [
            { value: "CA", label: "CA" },
            { value: "USA", label: "USA" },
            { value: "Texas", label: "Texas" },
            { value: "Sandiego", label: "Sandiego" }
        ];
        component.set("v.options", opts);
    },
    onCancelClick: function (component, event, helper) {
        var appEvent = $A.get("e.c:testEvent");
        appEvent.setParams({ "pageFrom" : "homepage" });
        appEvent.fire();
        component.set('v.isEventCancelPopupOpen', true);
    },
    onEventCancelPopupClose:function(component, event, helper){
        component.set('v.isEventCancelPopupOpen', false);
    },
    unrender: function (component, event, helper) {
        this.superUnrender();
        window.removeEventListener('scroll', helper.bindScrollEvent);
    }
})