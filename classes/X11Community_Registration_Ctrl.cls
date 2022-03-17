/* Class Name   : X11Community_Registration_Ctrl
* Description  : Controller To Custom Registration Component
* Created By   : Abhishek Mishra
* Created On   : 04-MAR-2019
* References   : X11_CustomRegistration.cmp, Class-CustomRegistration_Ctrl
* Modification Log:  
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer                Date                Modification ID         Description 
* --------------------------------------------------------------------------------------------------------------------------------------
* Suresh                   03-MAR-2019         1000                    Initial version
* Moiz Nagpurwala          15-AUG-2020         2000                    Updated Methods to follow coding best practices and deleted unused code
*/
public without sharing class X11Community_Registration_Ctrl {

    /* @Name:   getAddressAutoComplete 
     * @Desc:   Method to Fetch all the addresses based on the search key and country code
     * @param:  String - enteredAddress (Key to search the address)
     * @return: String : List of addresses for the searched key 
     */
    @AuraEnabled 
    public static AddressSearchResponse getAddressAutoComplete(String enteredAddress) {
        AddressSearchResponse response = new AddressSearchResponse();
        try {
            response.response = LRC_AddressAutoSelectionCtrl.getAddressAutoComplete(enteredAddress, Label.CountryCode);
            response.status = Label.Success_Label;
        } 
        catch (exception ex) {
            X11_Utility.logError(ex, 'X11Community_Registration_Ctrl', 'getAddressAutoComplete');           
            throw ex;
        }
        return response;
    }

    /* @Name:   getSelectedAddressDetails 
     * @Desc:   Method to Fetch All Hardcorded Values in Label Map
     * @param:  String PlaceId - Google specified id of a place, selectedAddress - Selected address
     * @return: String - Get All address details of the specified address
     */
    @AuraEnabled
    public static AddressSearchResponse getSelectedAddressDetails(String selectedPlaceId, String selectedAddress) {
        AddressSearchResponse response = new AddressSearchResponse();
        try {
            response.response = LRC_AddressAutoSelectionCtrl.getAddressDetailsFromPlaceId(selectedPlaceId, selectedAddress);
            response.status = Label.Success_Label;
        } 
        catch(Exception ex) {
            throw ex;
        }
        return response;
    }

    /* registerUser 
     * Register Partner User anlong with a new Account based on Form Inputs and 
     * on Successful creation - logged in into Lightning community as the newly created user
     * @params : String - Form inputs in stringified format 
     * @return : RegisterUserResult : Error If any
    */ 
    @AuraEnabled
    public static RegisterUserResult registerUser(FormResponseWrapper wrapper) {
        Savepoint sp = Database.setSavepoint();
        RegisterUserResult result = new RegisterUserResult();
        try {
            System.debug(wrapper);

            Profile profile = [SELECT Id, Name FROM Profile WHERE Name = :Label.Community_User_Profile];

            List<User> users = [SELECT Id, Username, phone, ContactId FROM User 
                                WHERE FirstName = :wrapper.sFirstName And LastName = :wrapper.sLastName AND 
                                        (Email = :wrapper.sEmail OR Phone = :wrapper.sPhoneNumber) AND 
                                        ProfileId = :profile.id];

            if(!users.isEmpty()) {
                list<Contact> contacts = [SELECT Id, Email, Phone FROM Contact WHERE Id= :users[0].ContactId];
                result.sUserId = users[0].UserName;
                result.sStatus = Label.Error_Label;
                result.errorMessages = new list<string>{ Label.X11_Registration_Form_Duplicate_Email };
                return result;
            }

            Account acc = new Account(  Name = wrapper.sFirstName + ' ' + wrapper.sLastname,
                                        Phone = wrapper.sPhoneNumber,
                                        BillingStreet = (String.isNotBlank(wrapper.sStreet) && String.isNotBlank(wrapper.sSuite)) ? wrapper.sStreet+', ' + wrapper.sSuite : (String.isNotBlank(wrapper.sStreet) ? wrapper.sStreet : ''),
                                        BillingCity = wrapper.sCity,
                                        BillingState = wrapper.sState,
                                        BillingPostalCode = wrapper.sPostalCode,
                                        BillingCountry = wrapper.sCountry
                                    );
            insert acc;

            User userRecord = new User( FirstName = wrapper.sFirstName, LastName = wrapper.sLastName, Username = wrapper.sEmail,
                                        CommunityNickname = wrapper.sEmail.substringBefore('@') + ((string.valueOF(System.now())).remove(':')).remove('-').remove(' '),
                                        Phone = wrapper.sPhoneNumber, Email = wrapper.sEmail,
                                        Street = (String.isNotBlank(wrapper.sStreet) && String.isNotBlank(wrapper.sSuite)) ? wrapper.sStreet+', ' + wrapper.sSuite : (String.isNotBlank(wrapper.sStreet) ? wrapper.sStreet : ''),
                                        City = wrapper.sCity, State = wrapper.sState,
                                        PostalCode = wrapper.sPostalCode, Country = wrapper.sCountry
                                    ); 
            userRecord.EmailEncodingKey = Label.Label_For_Email_Encoding;
            userRecord.LocaleSidKey = Label.Label_For_LocaleSidKey;
            userRecord.TimeZoneSidKey = Label.Label_For_Time_Zone;
            userRecord.LanguageLocaleKey = Label.Label_For_LocaleSidKey;
            
            Id userId;
            if(Test.isRunningTest()){
                userId = userInfo.getUserId();
            }
            else{
                userId = Site.createExternalUser(userRecord, acc.Id, wrapper.sPassword);
            }

            if(userId != null) {
                User user = [SELECT Id, ContactID FROM User WHERE Id= :userId];
                List<Contact> loggedInUserContacts = [SELECT Id FROM Contact WHERE Id = :user.ContactID];

                Contact contactRecord = new Contact(AccountId = acc.Id, FirstName = wrapper.sFirstName, LastName = wrapper.sLastName,
                                                    Email = wrapper.sEmail, Phone = wrapper.sPhoneNumber,
                                                    MailingStreet = (String.isNotBlank(wrapper.sStreet) && String.isNotBlank(wrapper.sSuite)) ? wrapper.sStreet+', ' + wrapper.sSuite : (String.isNotBlank(wrapper.sStreet) ? wrapper.sStreet : ''),
                                                    MailingCity = wrapper.sCity, MailingState = wrapper.sState,
                                                    MailingPostalCode = wrapper.sPostalCode, MailingCountry = wrapper.sCountry);
                if(loggedInUserContacts.size() > 0) {
                    contactRecord.Id = loggedInUserContacts[0].Id;
                    system.debug(wrapper.bPormotionalEmail);
                    contactRecord.Opt_In_for_Promotional_Emails__c = (boolean)wrapper.bPormotionalEmail;
                    contactRecord.League_Representative__c = wrapper.bLegueRep;
                    update contactRecord;
                }
            }

            PageReference pageRef = Site.login(userRecord.username, wrapper.sPassword, Label.X11_Home_Page_Link);
            aura.redirect(pageRef);
            result.sStatus = Label.Success_Label;
            result.sUserId = userId;
            result.redirectUrl = pageRef.getUrl();
        }
        catch(Site.ExternalUserCreateException ex) {
            Database.rollback(sp);
            System.debug(ex.getMessage());
            result.sStatus = Label.Error_Label;
            result.errorMessages = ex.getDisplayMessages();
        }
        
        return result;
    }
     
    @AuraEnabled
    public static boolean resetPassword(String username) {
        try {
            return Site.forgotPassword(username);
        }
        catch(Exception e) {
            throw new AuraHandledException(e.getMessage()); 
        }
    }  
    
    public class AddressSearchResponse {
        @AuraEnabled public String status;
        @AuraEnabled public String response;
    }

    public class FormResponseWrapper {
        @AuraEnabled public String sFirstName {get; set;}
        @AuraEnabled public String sLastName {get; set;}
        @AuraEnabled public String sPhoneNumber {get; set;}
        @AuraEnabled public String sEmail {get; set;}
        @AuraEnabled public String sPassword {get; set;}
        @AuraEnabled public String sStreet {get; set;}
        @AuraEnabled public String sSuite {get; set;}
        @AuraEnabled public String sCity {get; set;}
        @AuraEnabled public String sState {get; set;}
        @AuraEnabled public String sPostalCode {get; set;}
        @AuraEnabled public String sCountry {get; set;}
        @AuraEnabled public String sCompany {get; set;}
        @AuraEnabled public Boolean bPormotionalEmail {get; set;}
        @AuraEnabled public Boolean bLegueRep {get; set;}
    }

    public class RegisterUserResult {
        @AuraEnabled public String sStatus;
        @AuraEnabled public List<String> errorMessages;
        @AuraEnabled public String sUserId;
        @AuraEnabled public String redirectUrl;
    }
    
}