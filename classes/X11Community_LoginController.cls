public with sharing class X11Community_LoginController {
	
    @AuraEnabled
    public static LoginWrapper login(String username, String password) {
        LoginWrapper wrapper = new LoginWrapper();
        try {
            PageReference page = Site.login(username, password, null);
            if(page == null) {
                wrapper.loginSuccessful = false;
                wrapper.errorMessage = Label.X11_Login_Failed_Error;
            }
            else {
                wrapper.loginSuccessful = true;
                wrapper.loginURL = page.getUrl();
            }
        }
        catch(Exception e) {
            wrapper.loginSuccessful = false;
            wrapper.errorMessage = Label.X11_Login_Failed_Error;
        }
        
        return wrapper;
    } 
    
    @AuraEnabled
    public static Boolean resetPassword(String username) {
        try {
            return Site.forgotPassword(username);
        }
        catch(Exception e) {
            throw new AuraHandledException(e.getMessage()); 
        }
    }   
    
    public class LoginWrapper {
        @AuraEnabled public Boolean loginSuccessful {get; set;}
        @AuraEnabled public String loginURL {get; set;}
        @AuraEnabled public String errorMessage {get; set;}
    }
}