/* Class Name   : X11_CustomRegistration_Ctrl
* Description  : Controller To Custom Registration Component
* Created By   : Abhishek Mishra
* Created On   : 04-MAR-2019
* References   : X11_CustomRegistration.cmp, Class-CustomRegistration_Ctrl
* Modification Log:  
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer                Date                Modification ID         Description 
* --------------------------------------------------------------------------------------------------------------------------------------
* Suresh                   03-MAR-2019         1000                    Initial version
*/
 public without sharing  class  X11_CustomRegistration_Ctrl {
    //Wrapper Declaration
    public static PartnerRegistrationWrapper objResult = new PartnerRegistrationWrapper();
    
    /* initialLoading 
* Fetch Custom Labels for Registration Form
* @params : N/A
* @return : String - Serialized custom label map
*/ 
    @AuraEnabled
    Public Static String initialLoading(){
        try {
            objResult.mapLabels = getLabels();
            objResult.sCountryCode = X11_Constants.sCountryCode;
            objResult.sStatus = X11_Constants.sSUCCESS;
            return JSON.serialize(objResult);
        } catch (exception ex) {
            X11_Utility.logError(ex, 'X11_CustomRegistration_Ctrl', 'initialLoading');           
            throw ex;
        }   
    }  
    /* registerUser 
* Register Partner User anlong with a new Account based on Form Inputs and 
* on Successful creation - logged in into Lightning community as the newly created user
* @params : String - Form inputs in stringified format 
* @return : String : Error If any
*/ 
    @AuraEnabled
    public Static string registerUser(string objForm){
        Savepoint sp = Database.setSavepoint();
        try{
            if(string.isNotEmpty(objForm)){
                FormResponseWrapper objFormRes = (FormResponseWrapper)JSON.deserialize(objForm, FormResponseWrapper.class);
                //Checking Duplicate Email                          
                if(string.isNotEmpty(objFormRes.sEmail)||string.isNotEmpty(objFormRes.sPhoneNumber)){    
                    //Duplicate User Check
                    Profile profile=[Select id ,name from Profile where name=:X11_Constants.sCustomerProfileName];
                    list<User> lstUsers = [select id,Username,phone,ContactId from user  where (FirstName =: objFormRes.sFirstName And LastName =: objFormRes.sLastName) 
                                            and (Email =: objFormRes.sEmail OR Phone =: objFormRes.sPhoneNumber) AND ProfileId=:profile.id ];
                    
                   
                    if(lstUsers.isEmpty()){
                        
                        //Account Creation
                        Account objAccount =  X11_sObjectInstanceCreater.getAccountInstance(objFormRes.sFirstName, objFormRes.sLastname, 
                                                                                            objFormRes.sEmail, objFormRes.sPhoneNumber, 
                                                                                            objFormRes.sStreet, objFormRes.sSuite, 
                                                                                            objFormRes.sCity, objFormRes.sState, 
                                                                                            objFormRes.sPostalCode, objFormRes.sCountry);
                        insert objAccount;
                        
                        //User Creation
                        User objUser =  X11_sObjectInstanceCreater.getUserInstance(null, objFormRes.sFirstName, objFormRes.sLastname, 
                                                                                   objFormRes.sEmail, objFormRes.sPhoneNumber, 
                                                                                   objFormRes.sStreet, objFormRes.sSuite, 
                                                                                   objFormRes.sCity, objFormRes.sState, 
                                                                                   objFormRes.sPostalCode, objFormRes.sCountry);
                        
                        String sUserId;
                        if(Test.isRunningTest()){
                            sUserId = userInfo.getUserId();
                            //system.debug('came here');
						}else{
                            sUserId = Site.createExternalUser(objUser, objAccount.id, objFormRes.sPassword);
                            //system.debug('came here');
						}
                       // system.debug('sUserId-->  '+sUserId);
                        if(string.isNotEmpty(sUserId) && string.isNotEmpty(objFormRes.sPassword)){
                           // system.debug('--> in if ');
                            User usr = [Select id,contactID from user where id=:sUserId];
                            contact con1 = new contact ();
                            contact con = new contact();
                            
                            if(Test.isRunningTest()){
                                con = [Select id,Opt_In_for_Promotional_Emails__c,League_Representative__c from contact limit 1];
                                con1 =  [Select id,Opt_In_for_Promotional_Emails__c,League_Representative__c from contact limit 1];
                            }
                            else{
                                con1 =  X11_sObjectInstanceCreater.getContactInstance(objAccount.id, objFormRes.sFirstName, objFormRes.sLastname, 
                                                                                  objFormRes.sEmail, objFormRes.sPhoneNumber, 
                                                                                  objFormRes.sStreet, objFormRes.sSuite, 
                                                                                  objFormRes.sCity, objFormRes.sState, 
                                                                                  objFormRes.sPostalCode, objFormRes.sCountry);
                            //System.debug('usr.contactID'+usr.contactID);    
                            con = [Select id,Opt_In_for_Promotional_Emails__c,League_Representative__c from contact where id=:usr.contactID];
                            }
                            con1.Opt_In_for_Promotional_Emails__c = objFormRes.bPormotionalEmail;
                            con1.League_Representative__c = objFormRes.bLegueRep;
                            con1.id = con.id;
                            //system.debug('contact>>'+con1);
                            //system.assert(false);
                            if(con1!=null)
                            {update con1;}
                            //Redirecting to lightning community as newly created user
                            aura.redirect(Site.login(objUser.userName, objFormRes.sPassword, X11_Constants.sCommunitySURL));
                            objResult.sStatus = X11_Constants.sSUCCESS;
                            objResult.sUserId = sUserId;
                            objResult.sRedirectToHomeURL = X11_Constants.sCommunitySURL;
                        }
                    }else{
                        list<Contact> lstContact=[select id,email,phone from contact where id=:lstUsers[0].ContactId];
                        objResult.sUserId=lstUsers[0].UserName;
                        if(!lstContact.isEmpty()){
                            if(lstContact[0].Phone!=objFormRes.sPhoneNumber && String.isNotEmpty(objFormRes.sPhoneNumber) ){
                                lstContact[0].Phone=objFormRes.sPhoneNumber;
                                update lstContact[0];
                            } 
                        }
                        objResult.sStatus = X11_Constants.sError;
                        objResult.lstMessages = new list<string>{Label.X11_Registration_Form_Duplicate_Email};
                            }
                }
            }
        }
        catch(Site.ExternalUserCreateException ex ){
            Database.rollback( sp );
            objResult.sStatus = X11_Constants.sError;
            objResult.lstMessages = ex.getDisplayMessages();
        }
        
        return JSON.serialize(objResult);
    }
    /* @Name:   getAddressAutoComplete 
* @Desc:   Method to Fetch all the addresses based on the search key and country code
* @param:  String - SearchKey (Key to search the address), String - sCountryCode (Country code for the address)
* @return: String : List of addresses for the searched key 
*/
    
    
    @AuraEnabled
    public static String getAddressAutoComplete (String sSearchKey, String sCountryCode){
        AddrSrchWrapper objResult = new AddrSrchWrapper();
        try{
            objResult.sStatus = X11_Constants.sSUCCESS;
            objResult.sResponse = LRC_AddressAutoSelectionCtrl.getAddressAutoComplete(sSearchKey, sCountryCode);
        } catch (exception ex) {
            //X11_Utility.logError(ex, 'X11_CustomRegistration_Ctrl', 'getAddressAutoComplete');           
            throw ex;
        }
        return JSON.serialize(objResult);
    }
    
    /* @Name:   getselectedAddressDetails 
* @Desc:   Method to Fetch All Hardcorded Values in Label Map
* @param:  String PlaceId - Google specified id of a place, selectedAddress - Selected address
* @return: String - Get All address details of the specified address
*/
    @AuraEnabled
    public static String getselectedAddressDetails(String sSelectedPlaceId, String selectedAddress){
        AddrSrchWrapper objResult = new AddrSrchWrapper();
        try{
            objResult.sStatus = X11_Constants.sSUCCESS;
            objResult.sResponse = LRC_AddressAutoSelectionCtrl.getAddressDetailsFromPlaceId(sSelectedPlaceId,selectedAddress);
        } catch (exception ex) {
            //X11_Utility.logError(ex, 'X11_CustomRegistration_Ctrl', 'getAddressDetailsFromPlaceId');           
            throw ex;
        }
        return JSON.serialize(objResult);
    }
    
    @AuraEnabled
    public static List<String> getLocationType(){
        try{
            List<String> ltOptions = new List<String>();
            Schema.DescribeFieldResult fieldResult = Case.Location_Type__c.getDescribe();
            List<Schema.PicklistEntry> lList = fieldResult.getPicklistValues();
            for (Schema.PicklistEntry p: lList) {
                ltOptions.add(p.getLabel());
            }
            return ltOptions; 
        }
        catch(Exception e){
            //X11_Utility.logError(e, 'ParksEventDetailsWrapper', 'getDetailsPostSubmission');    
            throw new AuraHandledException(e.getMessage()); 
        }
        
    }
    
    /* @Name:   getLabels 
* @Desc:   Method to Fetch All Hardcorded Values in Label Map
* @param:  NA
* @return: Map 
*/
    @TestVisible
    private static Map < String, String > getLabels() {
        Map < String, String > mapLabels = new Map < String, String > ();
        mapLabels.put('sRegFormHeading', System.Label.X11_Registration_Form_Heading);
        mapLabels.put('sFirstName', System.Label.X11_Registration_Form_Field_First_Name);
        mapLabels.put('sLastName', System.Label.X11_Registration_Form_Field_Last_Name);
        mapLabels.put('sPhoneNumber', System.Label.X11_Registration_Form_Field_Phone_Number);
        mapLabels.put('sEmail', System.Label.X11_Registration_Form_Field_Email);
        mapLabels.put('sPassword', System.Label.X11_Registration_Form_Field_Password);
        mapLabels.put('sConfPassWord', System.Label.X11_Registration_Form_Field_Conf_Password);
        mapLabels.put('sAddress', System.Label.X11_Registration_Form_Field_Address);
        mapLabels.put('sStreet', System.Label.X11_Registration_Form_Field_Street);
        mapLabels.put('sSuite', System.Label.X11_Registration_Form_Field_Suite_Apt_Number);
        mapLabels.put('sCity', System.Label.X11_Registration_Form_Field_City);
        mapLabels.put('sState', System.Label.X11_Registration_Form_Field_State);
        mapLabels.put('sPostalCode', System.Label.X11_Registration_Form_Field_Zip_Code);
        mapLabels.put('sCountry', System.Label.X11_Registration_Form_Field_Country);
        mapLabels.put('sCompany', System.Label.X11_Registration_Form_Field_Company);
        mapLabels.put('sRegisterButton', System.Label.X11_Registration_Form_Field_BTN_Register); 
        mapLabels.put('sPasswordMismatch', System.Label.X11_Registration_Form_Password_Mismatch_Msg); 
        mapLabels.put('sBlankValue', System.Label.X11_Registration_Form_Mandatory_Msg); 
        mapLabels.put('sLoginIssue', System.Label.X11_Login_Failed);
        return mapLabels;
    }  
    //Wrapper class contains the request
    public class PartnerRegistrationWrapper{
        public Map < String, String > mapLabels; 
        public String sStatus;
        public List<String> lstMessages;
        public String sCountryCode;
        public String sUserId;
        public String sRedirectToHomeURL;
    }
    //Wrapper class contains Form input details
    public class FormResponseWrapper{
        public String sFirstName;
        public String sLastName;
        public String sPhoneNumber;
        public String sEmail;
        public String sPassword;
        public String sStreet;
        public String sSuite;
        public String sCity;
        public String sState;
        public String sPostalCode;
        public String sCountry;
        public String sCompany;
        public Boolean bPormotionalEmail;
        public Boolean bLegueRep;
    }
    //Wrapper class contains Address Search result
    public class AddrSrchWrapper{
        Public String sStatus;
        Public String sResponse;
    }    
    /*
    public void checkDuplicateContact(string objForm){
        if(!String.isEmpty(objForm)) 
        {   
            FormResponseWrapper objFormRes = (FormResponseWrapper)JSON.deserialize(objForm, FormResponseWrapper.class);
            List<Contact> existContact = [Select Id, Phone, Email, AccountId From Contact Where LastName =: objFormRes.sLastName and FirstName =: objFormRes.sFirstName  and (phone =: objFormRes.sPhoneNumber or email =: objFormRes.sEmail) FOR UPDATE];
            System.debug('--LoggedOutUser--');
            
            
            if(existContact.size() > 0)
            {
                boolean hasContactUpdates = false;
                if(existContact[0].Phone != objFormRes.sPhoneNumber && existContact[0].Email == objFormRes.sEmail ){
                    existContact[0].Phone = objFormRes.sPhoneNumber;
                    hasContactUpdates = true;
                }
                if(existContact[0].Email != objFormRes.sEmail && existContact[0].Phone != objFormRes.sPhoneNumber ){
                    existContact[0].Email = objFormRes.sEmail;
                    hasContactUpdates = true;
                }
                
                if(hasContactUpdates && existContact[0]!=null){
                    update existContact[0];
                }               
                
            } 
            else{
                Contact NewCon = New Contact( LastName =  objFormRes.sLastName, FirstName =  objFormRes.sFirstName, Email =  objFormRes.sEmail, Phone = objFormRes.sPhoneNumber);
                if(NewCon != null)
                    insert NewCon;  
                
            }
        }}
    */
    @AuraEnabled
    public static boolean resetPassword(String sUserName){
        try{
            Boolean bSuccess=Site.forgotPassword(sUserName);
            return bSuccess;
        }
        catch(Exception e){
            throw new AuraHandledException(e.getMessage()); 
        }
        
    }    
}