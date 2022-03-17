({
	hamburgerMenuClickHandler: function(component, event, helper) {
		var x11HamburgerMenu = component.find('x11_community_hamburger_menu');
        var x11Menu = component.find('x11_community_menu');
        $A.util.toggleClass(x11HamburgerMenu, 'open');
        $A.util.toggleClass(x11Menu, 'open');
	},
    
    loginClickHandler: function(component, event, helper) {
		component.find('loginPopup').showModal();
        event.preventDefault();
        return false;
	},
    
    signInClickHandler: function(component, event, helper) {
        var username = component.get('v.username');
        var password = component.get('v.password');
        
        var validSoFar = component.find('validateLoginInput').reduce(function (validSoFar, inputComponent) {
            inputComponent.showHelpMessageIfInvalid();
            return validSoFar && inputComponent.get('v.validity').valid;
        }, true);
        
        if(!validSoFar) {
            return;
        }
        
        helper.signIn(component);
    },
    
    forgotPasswordClickHandler: function(component, event, helper) {
        component.find('loginPopup').closeModal();
        component.find('forgotPasswordPopup').showModal();
        component.set('v.showForgotPasswordSuccess', false);
    },
    
    resetPasswordClickHandler: function(component, event, helper) {
        var username = component.get('v.forgotPasswordUsername');
        
        if($A.util.isEmpty(username)) {
	   		component.find('validateForgotPasswordInput').showHelpMessageIfInvalid();
            return;
        }
        
        helper.resetPassword(component);
    },
    ShowAccountInfoDropDown : function(component, event,helper) {
        helper.ShowAccountInfoDropDown_Helper(component,event);
    }
})