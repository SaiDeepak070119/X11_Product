({
    signIn : function(component) {
        this.callServer(component, "c.login", function(result) {
            if(result.loginSuccessful) {
                this.redirectToPageURL(result.loginURL, true);
            }
            else {
                this.showToast('Error!', result.errorMessage, 'error', 'dismissible', '5000ms');
            }
        }, {
            "username": component.get('v.username'),
            "password": component.get('v.password')
        }); 
    },
    
    resetPassword : function(component) {
        this.callServer(component, "c.resetPassword", function(result) {
            if(result) {
                component.set('v.showForgotPasswordSuccess', true);
            }
            else {
                this.showToast('Error!', 'We were not able to send reset password email. Please try again!', 'error', 'dismissible', '5000ms');
            }
        }, {
            "username" : component.get('v.forgotPasswordUsername')
        });
    },
    
    ShowAccountInfoDropDown_Helper : function(component, event) {
        component.set("v.bshowAccountInfoComp", !component.get("v.bshowAccountInfoComp"));
    }
})