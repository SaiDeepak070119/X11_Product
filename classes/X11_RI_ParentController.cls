public without sharing class X11_RI_ParentController{ 
    
    public static caseConfigWrapper objCaseConfigWrapper; 
    public static contactWrapper contactWrapperData;
    public static CaseResponseWrapper objCaseResponseWrapper;
    public static responseWrapper responseWrapper = new responseWrapper();
    public static Id AccountId;
    public static Boolean bIsPortalUser=false;    

    @AuraEnabled
    public static ResponseWrapper fetchCaseTypeDetails(String caseTypeId) {
        try {
            ResponseWrapper wrapper = new ResponseWrapper();
            wrapper.mapLabels = getLabels();
            wrapper.scaseTypeLst = getPickListValuesIntoList(new X11_Case_Metadata_Type__c(), 'Case_UX_Type__c');
            wrapper.allStages = Label.X11_Report_Issue_Chevron.split(';');
            wrapper.objCaseConfigWrapper = new CaseConfigWrapper();
            wrapper.contactWrapperResponse = new ContactWrapper();

            if(String.isBlank(caseTypeId)) {
                wrapper.objCaseConfigWrapper.sMsgType = Label.Error_Label;
                wrapper.objCaseConfigWrapper.sMsg = Label.No_Case_Config;
                return wrapper;
            }

            String loggedInUserLincence = [Select Profile.UserLicense.Name from User WHERE Id =: UserInfo.getUserId() LIMIT 1].Profile.UserLicense.Name;
            Boolean isPortalUser = (System.Label.X11Community_Licenses.contains(loggedInUserLincence));
            //Boolean isPortalUser = (Label.X11Community_Licenses.contains(UserInfo.getUserType()));
            caseTypeId = (isPortalUser) ? X11_Utility.decrypt(caseTypeId) : caseTypeId;

            String query = 'SELECT Id, Case_UX_Category__c, Case_UX_Type__c, Case_UX_Description__c, Case_UX_Estimation__c, ' + 
                                    'Case_UX_Popular_Types__c ' + 
                                    'FROM X11_Case_Metadata_Type__c ' +
                                    'WHERE Id = :caseTypeId';
            List<X11_Case_Metadata_Type__c> caseConfigurations = Database.query(query);
            if(caseConfigurations.isEmpty()) {
                wrapper.objCaseConfigWrapper.sMsgType = Label.Error_Label;
                wrapper.objCaseConfigWrapper.sMsg = Label.No_Case_Config;
                return wrapper;
            }

            wrapper.objCaseConfigWrapper.sCaseCategory = caseConfigurations[0].Case_UX_Category__c;
            wrapper.objCaseConfigWrapper.sCaseType = caseConfigurations[0].Case_UX_Type__c;
            wrapper.objCaseConfigWrapper.bIsPortalUser = isPortalUser;
            wrapper.objCaseConfigWrapper.sCaseType = caseConfigurations[0].Case_UX_Type__c;
            wrapper.objCaseConfigWrapper.sCaseDescription = caseConfigurations[0].Case_UX_Description__c;
            wrapper.objCaseConfigWrapper.sId= caseConfigurations[0].Id;
            wrapper.objCaseConfigWrapper.sRedirectToHomeURL = null;
            questionAnswerFunction(wrapper.objCaseConfigWrapper, wrapper.objCaseConfigWrapper.sCaseType);

            List<User> users = [SELECT Id, Username, ContactId, FirstName, LastName, Email, Phone, Address, Profile.Name 
                                FROM User 
                                WHERE Id = :UserInfo.getUserId()];
            if(users.isEmpty()) {
                return wrapper;
            }

            List<Contact> contacts = [SELECT FirstName, LastName, Email, Phone 
                                      FROM Contact 
                                      WHERE Id = :users[0].ContactId];

            wrapper.objCaseConfigWrapper.sContactId = users[0].ContactId;
            if(users[0].Profile.Name == Label.Community_User_Profile) {
                wrapper.objCaseConfigWrapper.bIsLogin = true; 
                wrapper.contactWrapperResponse.bIsLogin = true; 
            }
            
            wrapper.contactWrapperResponse.sUserName = users[0].UserName;
            if(contacts != null && contacts.Size()>0) {
                wrapper.contactWrapperResponse.sFirstName = contacts[0].FirstName;
                wrapper.contactWrapperResponse.sLastName = contacts[0].LastName;
                wrapper.contactWrapperResponse.sEmail = contacts[0].Email;
                wrapper.contactWrapperResponse.sPhone = contacts[0].Phone;
            }
            if(users[0].Address != null) {
                wrapper.contactWrapperResponse.sAddress = String.Valueof(users[0].Address.getStreet() + ' ' + users[0].Address.getCity()+' ' + users[0].Address.getState() + ' ' + users[0].Address.getPostalCode()); 
                wrapper.contactWrapperResponse.sAddress = wrapper.contactWrapperResponse.sAddress.replace(', null','');
                wrapper.contactWrapperResponse.sAddress = wrapper.contactWrapperResponse.sAddress.replace('null','');
                wrapper.contactWrapperResponse.sStreet = users[0].Address.getStreet();
                wrapper.contactWrapperResponse.sCity = users[0].Address.getCity();
                wrapper.contactWrapperResponse.sState = users[0].Address.getState();
                wrapper.contactWrapperResponse.sPostalCode = users[0].Address.getPostalCode();
                wrapper.contactWrapperResponse.sCountry = users[0].Address.getCountry();
            }
            else {
                wrapper.contactWrapperResponse.sAddress = '';
            }

            return wrapper;
        }
        catch(Exception e){
            X11_Utility.logError(e, 'X11_RI_ParentController', 'fetchCaseTypeDetails');    
            throw new AuraHandledException(e.getMessage()); 
        }
    }
    @AuraEnabled
    public static Boolean UploadDoc(String claimId, String docURL){
        System.debug('inside this method from portal');
        Boolean result = false;
        try{
            List<Document__c> lstDocument = new List<Document__c>();
            //for(String url: docURL)
            //{
            	String fileName = EncodingUtil.urlDecode(docURL.substring(docURL.lastindexOf('/')+1,docURL.length()),'UTF-8');
                Document__c doc = new Document__c();
            	doc.Name = fileName;
            	doc.FileName__c = fileName;
                doc.Claim__c = claimId;
                doc.Document_URL__c = docURL;  
                lstDocument.add(doc);
            //}
            if(!lstDocument.isEmpty())
            {
                insert lstDocument;
            }
            
            result = true;
        }
        catch(Exception e){
            result = false;
            system.debug('Error Occured '+e.getMessage());
        }
        return result;
    }
    
    
	@AuraEnabled
    public static Amazon_S3_Credential__c getS3Setting()
    {
        return Amazon_S3_Credential__c.getValues('Amazon');
    }
    
    @AuraEnabled
    public static String getSelectedCaseTypeId(String sCaseType){
        String selectedCaseTypeId = '';
        try{
            String loggedInUserLincence = [Select Profile.UserLicense.Name from User WHERE Id =: UserInfo.getUserId() LIMIT 1].Profile.UserLicense.Name;
            boolean isPortalUser = (System.Label.X11Community_Licenses.contains(loggedInUserLincence));
            
            String query =  'SELECT Id FROM X11_Case_Metadata_Type__c WHERE Display_on_Web__c = true '; 
            if(isPortalUser) {
                query += 'AND Available_for_Portal_User__c = true ';
            }
            query += 'AND Case_UX_Type__c = '+'\''+sCaseType+'\'';
            
            List<X11_Case_Metadata_Type__c> caseMetadataTypeLst = Database.query(query);
            if(caseMetadataTypeLst.size() > 0){
                selectedCaseTypeId = isPortalUser ? X11_Utility.encryptAndEncodeURL(caseMetadataTypeLst[0].Id) : caseMetadataTypeLst[0].Id;
            }
        }catch(Exception e){
            X11_Utility.logError(e, 'X11_RI_ParentController', 'getSelectedCaseTypeId');
        }
        return selectedCaseTypeId;
    } 
    
    public static List<CaseQuestionOptions> getPickListValuesIntoList(sObject objName, String fieldApi){
        List<CaseQuestionOptions> pickListValuesList= new List<CaseQuestionOptions>();
        Schema.sObjectType objType = objName.getSObjectType();
        Schema.DescribeSObjectResult objDescribe = objType.getDescribe();
        map<String, Schema.SObjectField> fieldMap = objDescribe.fields.getMap();
        list<Schema.PicklistEntry> values = fieldMap.get(fieldApi).getDescribe().getPickListValues();
        for (Schema.PicklistEntry a : values)
        { 
            pickListValuesList.add(new CaseQuestionOptions(a.getLabel(), a.getValue()));
        }
        return pickListValuesList;
    }
    
    public static void questionAnswerFunction(CaseConfigWrapper objCaseConfigWrapper, String caseType) {
        List<CaseQuestionWrapper> lstCaseQuestion = new List<CaseQuestionWrapper>();
        Map<String,Map<String,List<String>>> mapQuestion = new Map<String,Map<String,List<String>>>();
        Map<String,List<String>> mapQuestionAnswer= new Map<String,List<String>>();
        Integer iQuestionOrder = 0;

        String query = 'SELECT ID, Case_Question__r.Question_Label__c, Required__c, Case_Question__r.Type__c, ' +
                                'Parent_Question__c, Parent_Question__r.Question_Label__c,  Answer_Choices__c, ' +
                                'Display_Order__c, Display_on_Load__c, Answer_Field_API_Name__c, Parent_Answer__c ' +
                        'FROM X11_Case_Config_Question__c ' + 
                        'WHERE Case_Configuration__r.Case_UX_Type__c =: caseType AND ' + 
                                'Display_on_Load__c = true ' + 
                        'ORDER BY Display_Order__c ASC ';
        
        
        for(X11_Case_Config_Question__c objQuestion : Database.Query(query)) {
            String sParentQuestion = String.isNotBlank(objQuestion.Parent_Question__c) ?  objQuestion.Parent_Question__r.Question_Label__c : objQuestion.Case_Question__r.Question_Label__c;
            String sQuestion = String.isNotBlank(objQuestion.Case_Question__c) ?  objQuestion.Case_Question__r.Question_Label__c : ''; 
            String sParentAnswer =  String.isNotBlank(objQuestion.Parent_Answer__c) ? objQuestion.Parent_Answer__c : 'N/A';
            String sQuestionKey = sParentQuestion + '/--/'+sParentAnswer; 
            Boolean brequired = objQuestion.Required__c;

            if(mapQuestion.containsKey(sQuestion)){
                mapQuestionAnswer = mapQuestion.get(sQuestion);
                if(!mapQuestionAnswer.containsKey(sQuestionKey)){
                    mapQuestionAnswer.put(sQuestionKey,new List<String>(objQuestion.Answer_Choices__c.split(',')));
                    mapQuestion.put(sQuestion, mapQuestionAnswer); 
                }
            }
            else {
                mapQuestionAnswer = new Map<String,List<String>>();
                CaseQuestionWrapper objCaseQuestion = new CaseQuestionWrapper();
                objCaseQuestion.lstOptions = new List<CaseQuestionOptions>();
                
                if(String.isNotBlank(objQuestion.Answer_Choices__c)){
                    mapQuestionAnswer.put(sQuestionKey, new List<String>(objQuestion.Answer_Choices__c.split(',')));
                    mapQuestion.put(sQuestion, mapQuestionAnswer);
                    if(String.isBlank(objQuestion.Parent_Question__c)){
                        for(String sAnswer : objQuestion.Answer_Choices__c.split(',')){
                            objCaseQuestion.lstOptions.add(new CaseQuestionOptions(sAnswer,sAnswer));
                        }
                    }   
                }  
                objCaseQuestion.sQuestion = sQuestion.touppercase();
                objCaseQuestion.sParentQuestion = sParentQuestion;
                objCaseQuestion.sAnswer = '';
                iQuestionOrder += 1;
                objCaseQuestion.iOrder = iQuestionOrder; 
                objCaseQuestion.brequired = brequired;
                objCaseQuestion.sFieldtoUpdate = objQuestion.Answer_Field_API_Name__c;
                objCaseQuestion.sQuestionType = objQuestion.Case_Question__r.Type__c;
                objCaseQuestion.bParentDependent = String.isNotBlank(objQuestion.Parent_Question__c) ? true : false;
                lstCaseQuestion.add(objCaseQuestion);
            }
        }
        objCaseConfigWrapper.mapQuestionAnswer = mapQuestion;
        objCaseConfigWrapper.lstCaseQuestion = lstCaseQuestion;
    }

    @AuraEnabled
    public static string submitCase(Case sObjCase, String sObjContact, String sFileLinks, String sCaseQuestionJSON, String address) {
        Map<string, String> contactCaseNumber = new Map<string, String>();

        try {
            String sCaseNumber;
            String contactId;
            CaseResponseWrapper objCaseResponseWrapper = new CaseResponseWrapper();
            //sObjCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Graffiti').getRecordTypeId();
            
            Set<String> setFields = Schema.getGlobalDescribe().get('Case').getDescribe().fields.getMap().keySet();
            
            sCaseQuestionJSON = '['+sCaseQuestionJSON+']';
            
            List<caseConfigWrapper> lstCaseQuestion = (List<CaseConfigWrapper>)JSON.deserialize(sCaseQuestionJSON, List<CaseConfigWrapper>.class);
                
            for(CaseConfigWrapper configObj : lstCaseQuestion){
                for(CaseQuestionWrapper cqWrapper : configObj.lstCaseQuestion){
                    /*if(String.isBlank(cqWrapper.sFieldtoUpdate) || String.isBlank(cqWrapper.sAnswer) || setFields.contains(cqWrapper.sFieldtoUpdate.toLowerCase())) {
                        continue;
                    }*/

                    /*Schema.DisplayType fieldDataType = Schema.getGlobalDescribe().get(Label.Case).getDescribe().fields.getMap().get(cqWrapper.sFieldtoUpdate).getDescribe().getType();
                    if(fieldDataType == Schema.DisplayType.DateTime) {
                        String delimiter = '-';
                        Integer year = Integer.valueof(cqWrapper.sAnswer.substringBefore(delimiter).trim());
                        
                        String remaining = cqWrapper.sAnswer.substringAfter(delimiter);
                        Integer month = Integer.valueof(remaining.substringBefore(delimiter).trim());
                        
                        remaining = remaining.substringAfter(delimiter);
                        Integer day = Integer.valueof(remaining.substringBefore('T').trim());
                       
                        delimiter = ':';
                        remaining = remaining.substringAfter('T');
                        Integer hour = Integer.valueof(remaining.substringBefore(delimiter).trim());
                        
                        remaining = remaining.substringAfter(delimiter);
                        Integer minute = Integer.valueof(remaining.substringBefore(delimiter).trim());

                        remaining = remaining.substringAfter(delimiter);
                        Integer second = Integer.valueof(remaining.substringBefore('.').trim());

                        Datetime myDate = Datetime.newInstanceGMT(year, month, day, hour, minute, second);
                        sObjCase.put(cqWrapper.sFieldtoUpdate, DateTime.valueOf(myDate));
                    }
                    else {*/
                        sObjCase.put(cqWrapper.sFieldtoUpdate,cqWrapper.sAnswer);
                    //}
                }

                sObjCase.Type  = configObj.sCaseType;
                List<X11_Case_Metadata_Type__c> caseConfigLst = [Select Case_Record_Type__c from X11_Case_Metadata_Type__c WHERE Case_UX_Type__c =:configObj.sCaseType];
                if(caseConfigLst.size() > 0){
                    sObjCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(caseConfigLst[0].Case_Record_Type__c).getRecordTypeId();
                }
                
                contactWrapper contactWrapper = (contactWrapper)JSON.deserialize(sObjContact, contactWrapper.class);
                sObjCase.Organization_Text__c = contactWrapper.sOrganization;

                /*if(sObjCase.Type == System.Label.Non_Stormwater_Discharges_Case_Type){
                    sObjCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Non-Stormwater Discharges').getRecordTypeId();
                }
                else if(sObjCase.Type == 'Street Lights'){
                    sObjCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Street Lights').getRecordTypeId();
                }
                else if(sObjCase.Type == 'Vegetation'){
                    sObjCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Vegetation').getRecordTypeId();
                }
                else if(sObjCase.Type == 'Broken Parking Meter'){
                    sObjCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Broken Parking Meter').getRecordTypeId();
                }
                else if(sObjCase.Type == 'Irrigation'){
                    sObjCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Irrigation').getRecordTypeId();
                }
                else if(sObjCase.Type == System.Label.Buoys_and_Nav_Aids_Case_Type){
                    sObjCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Buoys and Nav Aids').getRecordTypeId();
                }
                else if(sObjCase.Type == System.Label.Dead_Animal_Case_Type){
                    sObjCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Dead Animal').getRecordTypeId();
                }
                else if(sObjCase.Type == System.Label.Paths_and_Walkways_Case_Type){
                    sObjCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Paths and Walkways').getRecordTypeId();
                }
                else if(sObjCase.Type == System.Label.Sidewalks_Case_Type){
                    sObjCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Sidewalks').getRecordTypeId();
                }
                else if(sObjCase.Type == System.Label.Pier_Case_Layout){
                    sObjCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Pier').getRecordTypeId();
                }
                else if(sObjCase.Type == System.Label.General_Parking_Question_Case_Type){
                    sObjCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Parking').getRecordTypeId();
                }
                else if(sObjCase.Type == System.Label.Floating_Debris_Case_Type) {
                    sObjCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Floating Debris').getRecordTypeId();
                }
                else if(sObjCase.Type == System.Label.Graffiti_Case_Type){
                    sObjCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Graffiti').getRecordTypeId();
                }
                else if(sObjCase.Type == System.Label.Facilities_and_Equipment_Case_Type){
                    sObjCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Facilities and Equipment').getRecordTypeId();
                }
                else if(sObjCase.Type == System.Label.Storm_case_type){
                    sObjCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Storm Damage').getRecordTypeId();
                }
                else if(sObjCase.Type == System.Label.Illegal_Dumping_and_Litter){
                    sObjCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Illegal Dumping').getRecordTypeId();
                }*/
            }
            
            if(sObjCase.Reported_Anonymously__c != 'Yes' || (contactId != null && contactId != '')) {
                contactId = verifyEmail2(sObjContact);
                if(AccountId != null) {
                    sObjCase.AccountId = AccountId;
                }
                if(contactId != 'noUserExist') {
                    sObjCase.contactId = ContactId;
                    contactCaseNumber.put('ContactID',sObjCase.contactId);
                }
            }
                
            
            String sUserId = userInfo.getUserId();
            String sProfileName = [Select Profile.UserLicense.name from user where id=: sUserId].Profile.UserLicense.name;
            if(sProfileName == System.Label.Guest_License || sProfileName == System.Label.Community_Licnese  || sProfileName == label.Guest_User_License){
                bIsPortalUser = true;
            }
            else{
                bIsPortalUser = false;
            }
            if(bIsPortalUser){
                sObjCase.Intake_Method__c = Label.Portal;
                sObjCase.Origin= Label.Web;
            }
            
            if(sObjCase!=null){
                insert sObjCase;
            }
            X11_Case_DuplicateCheck.duplicatecheck(sObjCase);
            List<Case> lstCases = [SELECT id,CaseNumber 
                                   from case 
                                   where id =: sObjCase.Id];
            if(!lstCases.isEmpty()){
                sCaseNumber = lstCases[0].CaseNumber;
                contactCaseNumber.put('CaseID',sCaseNumber);
                contactCaseNumber.put('CaseSFID',sObjCase.Id);
                if(String.isNotBlank(sCaseNumber) && String.isNotBlank(sFileLinks)){
                    
                    List<FileUploadWrapper> lstFileLinks = (List<FileUploadWrapper>)JSON.deserialize(sFileLinks, List<FileUploadWrapper>.class); 
                    list<ContentDocumentLink>attachList = new list<ContentDocumentLink>();
                    /*if(System.Label.EnableAWSFileUpload == 'Yes'){
                        AmazonS3FileUploadHandler.saveToS3(sFileLinks,sObjCase.Id);
                    }*/
                    if(System.Label.EnableAWSFileUpload == 'No')
                    {
                    if(sObjCase.Type != System.Label.PRA_Case_Type){
                        FileUplaodAndSaveAsContentVersion.saveFileData(sFileLinks,sObjCase.Id);
                    }
                    else{
                        if(!lstFileLinks.isEmpty()){
                            for(FileUploadWrapper sLink : lstFileLinks){
                                
                                ContentDocumentLink contentlink=new ContentDocumentLink();
                                contentlink.LinkedEntityId=sObjCase.Id;
                                contentlink.ShareType= Label.V;
                                
                                contentlink.Visibility = Label.AllUsers;
                                contentlink.ContentDocumentId=sLink.documentId;
                                
                                attachList.add(contentlink);
                            }
                            if(!attachList.isEmpty()) {
                                database.insert(attachList);
                            }
                        }
                    }
                }
                }
            }
        }
        catch(exception ex){
            X11_Utility.logError(ex, Label.X11_RI_ParentController, Label.submitCase);
        }
        return JSON.serialize(contactCaseNumber);
    }


    @AuraEnabled
    public static string verifyEmail(String sEmail){
        try{
           if(sEmail != null){
            List<user> lstUser = [Select id from user where Email =: sEmail];
            if(lstUser!= null && lstUser.Size()>0){
                return 'userExist';
            }else{
                return 'noUserExist';
            }
        }
        return 'noUserExist';  
        }
        catch(Exception e){
            X11_Utility.logError(e, Label.X11_RI_ParentController, Label.verifyEmail);   
                 
            throw new AuraHandledException(e.getMessage()); 
        }
       
    }
    
     @AuraEnabled
    public Static string registerUser(string objContact,String sPassword,String sCaseNumber, String sEmailOptIn,String ContactID){
        
       // Savepoint sp = Database.setSavepoint();
        try{
        String sContactID = ContactID;
        //system.debug('sContactID>'+sContactID);
        if(string.isNotEmpty(objContact)){
            contactWrapper objFormRes = (contactWrapper)JSON.deserialize(objContact, contactWrapper.class);
            contact contactCreatedOnSubmission = [Select id,AccountID from contact where id=:ContactID];
            //system.debug('objFormRes>'+objFormRes);
            //system.assert(false);
            //Checking Duplicate Email                          
            if(string.isNotEmpty(objFormRes.sEmail)||string.isNotEmpty(objFormRes.sPhone)){    
                //Duplicate User Check
                Profile profile=[Select id ,name from Profile where name=:X11_Constants.sCustomerProfileName];
                list<User> lstUsers = [select id,Username,phone,ContactId,contact.AccountID from user where email = :objFormRes.sEmail AND ProfileId=:profile.id ];                    
                if(lstUsers.isEmpty()){
                    
                    //User Creation
                    User objUser =  X11_sObjectInstanceCreater.getUserInstance(null, objFormRes.sFirstName, objFormRes.sLastName, 
                                                                               objFormRes.sEmail, objFormRes.sPhone, 
                                                                               objFormRes.sStreet, objFormRes.sSuite, 
                                                                               objFormRes.sCity, objFormRes.sState, 
                                                                               objFormRes.sPostalCode, objFormRes.sCountry);
                    
                    //system.debug(sEmailOptIn);
                    
                    objUser.Opt_in_Email__c = Boolean.valueOf(sEmailOptIn);
                    
                  //  string timzone = [Select id,TimeZoneSidKey from organization limit 1].TimeZoneSidKey;
                    objUser.TimeZoneSidKey = label.America_Los_Angeles;
                    //system.debug('objUser>'+objUser);
                    //Partner User creation from standard method
                    //String sUserId = Site.createPortalUser(objUser, objAccount.id,  objFormRes.sPassword, false);
                    String sUserId = Site.createExternalUser(objUser, contactCreatedOnSubmission.AccountID, sPassword);
                    User userObj = [SELECT ContactId from user where id =: sUserId];
                    sContactID = userObj.ContactId;
                    //system.debug('sUserId'+sUserId);
                    if(string.isNotEmpty(sUserId) && string.isNotEmpty(sPassword)){
                        //system.debug('--> in if ');
                        //Redirecting to lightning community as newly created user
                        aura.redirect(Site.login(objUser.userName, sPassword, X11_Constants.sCommunitySURL));
                        // objResult.sStatus = X11_Constants.sSUCCESS;
                        // objResult.sUserId = sUserId;
                        // objResult.sRedirectToHomeURL = X11_Constants.sCommunitySURL;
                    }
                }else{
                    list<Contact> lstContact=[select id,email,phone from contact where id=:lstUsers[0].ContactId];
                    // objResult.sUserId=lstUsers[0].UserName;
                    if(!lstContact.isEmpty()){
                        sContactID = lstContact[0].Id;
                        if(lstContact[0].Phone!=objFormRes.sPhone && String.isNotEmpty(objFormRes.sPhone) ){
                            lstContact[0].Phone=objFormRes.sPhone;
                            update lstContact[0];
                        } 
                    }
                    // objResult.sStatus = X11_Constants.sError;
                    // objResult.lstMessages = new list<string>{Label.X11_Registration_Form_Duplicate_Email};
                }
                
                List<Case>  lstCase = [Select contactId,Id from case where CaseNumber=:sCaseNumber];
                if(lstCase != null && lstCase.Size()>0){
                   // String sContactDelete = lstCase[0].contactId;
                    lstCase[0].contactId = sContactID;
                    //system.debug(lstCase[0]);
                    update lstCase;
                    //delete [Select id from contact where id =: sContactDelete ];
                }
            }
        }
        
        return 'Yes';
        }
        catch(Exception e){
            X11_Utility.logError(e, Label.X11_RI_ParentController, Label.registerUser);
                  
            throw new AuraHandledException(e.getMessage()); 
        }
    }
    
    @AuraEnabled
    Public static string logIntoCommunity(String sUserName,String sPassword){
        try {
            pagereference page = Site.login(sUserName, sPassword, null);
            // objCaseConfigWrapper.sRedirectToHomeURL = page.getURL();
            //system.debug('page.getURL()'+page.getURL());
            return page.getURL();
        } catch (exception ex) {
            X11_Utility.logError(ex, 'X11_CustomLogin_Ctrl', 'logIntoCommunity');           
            return System.Label.X11_Login_Failed;
        }   
    }  
        
    public static string verifyEmail2(string objContact){
        try{
            //system.debug('objContact>'+objContact);
        Contact listContactInstance = new contact();
        if(string.isNotEmpty(objContact)){
            contactWrapper contactWrapper = (contactWrapper)JSON.deserialize(objContact, contactWrapper.class);
            //system.debug('contactWrapper>'+contactWrapper);
            Account objAccount;
            Account orgAccount;
           // Boolean orgFound = false;
                if(!String.isBlank(contactWrapper.sOrganization)){
                    List<Account> accList = new List<Account>();
                    string org = contactWrapper.sOrganization;
                    accList = [Select id from account where name =:org and iscustomerportal=false limit 1];
                    if(accList.size()>0){
                        orgAccount = accList[0];
                    }
                    else{
                        orgAccount =  X11_sObjectInstanceCreater.getAccountInstance(contactWrapper.sOrganization, '',contactWrapper.sEmail, contactWrapper.sPhone, contactWrapper.sStreet, contactWrapper.sSuite, contactWrapper.sCity, contactWrapper.sState, contactWrapper.sPostalCode, contactWrapper.sCountry); 
                    }
                }
                
                objAccount =  X11_sObjectInstanceCreater.getAccountInstance(contactWrapper.sFirstName, contactWrapper.sLastName, contactWrapper.sEmail, contactWrapper.sPhone,contactWrapper.sStreet, contactWrapper.sSuite, contactWrapper.sCity, contactWrapper.sState,  contactWrapper.sPostalCode, contactWrapper.sCountry);
                //system.debug('orgAccount>'+orgAccount);
                //system.debug('objAccount.id>'+objAccount.id);
                //system.debug('objAccount>'+objAccount);
            if(!contactWrapper.bIsLogin){
                if(orgAccount!=null && orgAccount.id == null && orgAccount.Name != null && orgAccount.Name != '' && orgAccount.Name != ' '){ // insert the account if not already existing
                if(orgAccount != null){
                    insert orgAccount;
                }
                    
                    //system.debug('orgAccount.id>'+orgAccount.id);
                    
                }
                if(objAccount != null){
                    insert objAccount;
                }
                
                AccountId = objAccount.id;
                List<Contact> lstContact = [Select id,FirstName,LastName,Email,Phone,MailingStreet,MailingCity,MailingState,MailingPostalCode,MailingCountry,AccountID,Account.name from Contact where (FirstName =: contactWrapper.sFirstName And LastName =: contactWrapper.sLastName) 
                                            and (Email =: contactWrapper.sEmail OR Phone =: contactWrapper.sPhone)];
                //system.debug('lstContact>>First check not logged in '+lstContact);
                //system.debug('lstContact.Size()>>First check not logged in '+lstContact.Size());
                //system.debug('orgAccount.ID>>First check not logged in '+orgAccount);
                if(lstContact!= null && lstContact.Size()>0 ){ //&& orgAccount!=null 
                    if(orgAccount!=null && orgAccount.id !=null){
                        //insertAccContactRel(lstContact[0].id,orgAccount.ID,contactWrapper.sOrganization);
                    }
                    
                    listContactInstance =  X11_sObjectInstanceCreater.getContactInstance(lstContact[0].AccountID,contactWrapper.sFirstName, contactWrapper.sLastName, contactWrapper.sEmail, contactWrapper.sPhone,contactWrapper.sStreet, contactWrapper.sSuite, contactWrapper.sCity, contactWrapper.sState,  contactWrapper.sPostalCode, contactWrapper.sCountry);
                    listContactInstance.id = lstContact[0].id;
                    //system.debug('>>>> listContactInstance.id: ' +listContactInstance.id);
                    update listContactInstance;
                    /*
                    account relatedAccount =  X11_sObjectInstanceCreater.getAccountInstance(contactWrapper.sFirstName, contactWrapper.sLastName, contactWrapper.sEmail, contactWrapper.sPhone,contactWrapper.sStreet, contactWrapper.sSuite, contactWrapper.sCity, contactWrapper.sState,  contactWrapper.sPostalCode, contactWrapper.sCountry);
                    relatedAccount.id = lstContact[0].AccountID;
                    update relatedAccount;*/
                    
                    //system.debug('went inside >>'+listContactInstance.id);
                    return lstContact[0].Id;
                }else if((lstContact.Size()==0) && !String.isBlank(contactWrapper.sLastName) ){ //lstContact== null && 
                    contact contactObj = new Contact();
                    contactObj  = X11_sObjectInstanceCreater.getContactInstance(objAccount.id,contactWrapper.sFirstName, contactWrapper.sLastName, contactWrapper.sEmail, contactWrapper.sPhone,contactWrapper.sStreet, contactWrapper.sSuite, contactWrapper.sCity, contactWrapper.sState,  contactWrapper.sPostalCode, contactWrapper.sCountry);
                    if(contactObj.FirstName !=null && contactObj.LastName !=null && (contactObj.Email != null || contactObj.Phone != null )){
                        if(contactObj != null){
                            insert contactObj;
                        }
                        
                        //insertAccContactRel(contactObj.ID,objAccount.id,null);
                    }
                    return contactObj.ID;
                }
            }else{
                
                id currentUserID = userinfo.getUserid();
                User LoggedinUser  = [select contactid,Profile.UserLicense.name from user where id= : currentUserID limit 1];
                string localContactID = LoggedinUser.contactID;
                string license = LoggedinUser.Profile.UserLicense.name;
                //system.debug('localContactID>>'+localContactID);
                //system.debug('license>>'+license);
                if(license == System.Label.Guest_License || license == System.Label.Community_Licnese  || license == label.Guest_User_License){
                    List<Contact> lstContact = [Select id,AccountID,FirstName,LastName,Email,Phone,MailingStreet,MailingCity,MailingState,MailingPostalCode,MailingCountry from Contact where id= :localContactID];//contactWrapper.sContactId
                    if(lstContact!= null && lstContact.Size()>0){
                        
                        listContactInstance =  X11_sObjectInstanceCreater.getContactInstance(lstContact[0].AccountID,contactWrapper.sFirstName, contactWrapper.sLastName, contactWrapper.sEmail, contactWrapper.sPhone,contactWrapper.sStreet, contactWrapper.sSuite, contactWrapper.sCity, contactWrapper.sState,  contactWrapper.sPostalCode, contactWrapper.sCountry);
                        listContactInstance.id = lstContact[0].id;
                        if(String.isBlank(contactWrapper.sLastName)) {
                            listContactInstance.LastName = lstContact[0].LastName;
                        }
                        //system.debug('listContactInstance>'+listContactInstance);
                        
                        update listContactInstance;
                        /*
                        account relatedAccount =  X11_sObjectInstanceCreater.getAccountInstance(contactWrapper.sFirstName, contactWrapper.sLastName, contactWrapper.sEmail, contactWrapper.sPhone,contactWrapper.sStreet, contactWrapper.sSuite, contactWrapper.sCity, contactWrapper.sState,  contactWrapper.sPostalCode, contactWrapper.sCountry);
                        relatedAccount.id = lstContact[0].AccountID;
                        update relatedAccount;*/
                        
                        return contactWrapper.sContactId;
                    
                    }
                }
                else{
                    List<Contact> lstContact = [Select id,AccountID,FirstName,LastName,Email,Phone,MailingStreet,MailingCity,MailingState,MailingPostalCode,MailingCountry from Contact where (FirstName =: contactWrapper.sFirstName And LastName =: contactWrapper.sLastName) 
                                                and (Email =: contactWrapper.sEmail OR Phone =: contactWrapper.sPhone)];
                    //system.debug('lstContact>>First check not logged in '+lstContact);
                    if(lstContact!= null && lstContact.Size()>0){
                        
                        if(lstContact[0].AccountID == null ){
                            if(objAccount.id == null ){ // insert the account if not already existing
                                insert objAccount;
                            }
                            listContactInstance =  X11_sObjectInstanceCreater.getContactInstance(objAccount.ID,contactWrapper.sFirstName, contactWrapper.sLastName, contactWrapper.sEmail, contactWrapper.sPhone,contactWrapper.sStreet, contactWrapper.sSuite, contactWrapper.sCity, contactWrapper.sState,  contactWrapper.sPostalCode, contactWrapper.sCountry);
                        }else{
                            listContactInstance =  X11_sObjectInstanceCreater.getContactInstance(lstContact[0].AccountID,contactWrapper.sFirstName, contactWrapper.sLastName, contactWrapper.sEmail, contactWrapper.sPhone,contactWrapper.sStreet, contactWrapper.sSuite, contactWrapper.sCity, contactWrapper.sState,  contactWrapper.sPostalCode, contactWrapper.sCountry);
                        }
                        listContactInstance.id = lstContact[0].id;
                        update listContactInstance;
                        /*
                        account relatedAccount =  X11_sObjectInstanceCreater.getAccountInstance(contactWrapper.sFirstName, contactWrapper.sLastName, contactWrapper.sEmail, contactWrapper.sPhone,contactWrapper.sStreet, contactWrapper.sSuite, contactWrapper.sCity, contactWrapper.sState,  contactWrapper.sPostalCode, contactWrapper.sCountry);
                        relatedAccount.id = lstContact[0].AccountID;
                        update relatedAccount;*/
                        
                        //insertAccContactRel(lstContact[0].id,orgAccount.ID,contactWrapper.sOrganization);
                        //system.debug('went inside >>'+lstContact[0].id);
                        return lstContact[0].Id;
                    }else if((lstContact.Size()==0) && contactWrapper.sLastName!=null){ //lstContact== null && 
                        if(objAccount.id == null ){ // insert the account if not already existing
                            insert objAccount;
                        }
                        contact contactObj = new Contact();
                        contactObj = X11_sObjectInstanceCreater.getContactInstance(objAccount.id,contactWrapper.sFirstName, contactWrapper.sLastName, contactWrapper.sEmail, contactWrapper.sPhone,contactWrapper.sStreet, contactWrapper.sSuite, contactWrapper.sCity, contactWrapper.sState,  contactWrapper.sPostalCode, contactWrapper.sCountry);
                        insert contactObj;
                        //insertAccContactRel(contactObj.ID,objAccount.id,null);
                        return contactObj.ID;
                    }
                    
                }
                
                // }
            }
        }
        
        }
        catch(Exception e){
             X11_Utility.logError(e, Label.X11_RI_ParentController, Label.verifyEmail2); 
                 
            //throw new AuraHandledException(e.getMessage()); 
        }
        return 'noUserExist';
    }
    
    @AuraEnabled
    public static Boolean resetPassword(String sUserName){
        //system.debug('reset in RI_Parent'+sUserName);
        Boolean success =  X11_CustomRegistration_Ctrl.resetPassword(sUserName);
        //system.debug('reset in RI_Parent BOOL >'+success);
        return success;
    }
     
    @AuraEnabled
    public static void insertAccContactRel(id contactID,id AccountID,string orgName){
        try{
           Boolean orgFound =false;
        for(AccountContactRelation accConRel : [Select id,accountid, contactid,Account.name from AccountContactRelation where contactID=: contactID]){
            if(!String.isBlank(orgName) && accConRel.Account.name == orgName){
                orgFound = true;
                break;
            }
        } 
        if(!orgFound || String.isBlank(orgName)){
           // AccountContactRelation accConRel = new AccountContactRelation(accountId = AccountID ,contactId = contactID);
            //insert accConRel;
        } 
        }
        catch(Exception e){
             X11_Utility.logError(e, Label.X11_RI_ParentController, Label.insertAccContactRel);  
             throw new AuraHandledException(e.getMessage()); 
        }
        
    }
    
    
    public class CaseResponseWrapper{
        public String sMsgType;
        public String sMsg;
    }
    
    public class FileUploadWrapper{
        public Boolean showImage;
        public String label;
        public String filetype;
        public String filebody;
        public String documentId;
        public String fileSize;
        public String actualFileType;    
    }
    
    public class ResponseWrapper {
        @AuraEnabled public CaseConfigWrapper objCaseConfigWrapper = new caseConfigWrapper();
        @AuraEnabled public ContactWrapper contactWrapperResponse = new contactWrapper();
        @AuraEnabled public List<String> allStages = new List<String>();
        @AuraEnabled public Map <String,String> mapLabels = new Map<String,String>();
        @AuraEnabled public List<CaseQuestionOptions> scaseTypeLst = new List<CaseQuestionOptions>();
    }
    
    public class CaseConfigWrapper {
        @AuraEnabled public String sId;
        @AuraEnabled public String sCaseCategory;
        @AuraEnabled public String sCaseType;
        @AuraEnabled public String sCaseDescription;
        @AuraEnabled public String sMsgType;
        @AuraEnabled public String sMsg;
        @AuraEnabled public Boolean bIsLogin;
        @AuraEnabled public Boolean sReportAnonymously;
        @AuraEnabled public String sContactId;
        @AuraEnabled public String sProfileName;
        @AuraEnabled public Boolean bIsPortalUser;
        @AuraEnabled public String sRedirectToHomeURL;
        @AuraEnabled public Map<String,Map<String,List<String>>> mapQuestionAnswer = new Map<String,Map<String,List<String>>>();
        @AuraEnabled public List<CaseQuestionWrapper>  lstCaseQuestion = new List<CaseQuestionWrapper>();
        @AuraEnabled public string sCaseOrigin;
        @AuraEnabled public Boolean sHideFromWeb;
    }

    public class CaseQuestionWrapper {
        @AuraEnabled public String sQuestion;
        @AuraEnabled public String sParentQuestion;
        @AuraEnabled public String sAnswer;
        @AuraEnabled public Integer iOrder;
        @AuraEnabled public String sFieldtoUpdate;
        @AuraEnabled public String sQuestionType;
        @AuraEnabled public Boolean bParentDependent;
        @AuraEnabled public Boolean brequired;
        @AuraEnabled public List<CaseQuestionOptions> lstOptions = new List<CaseQuestionOptions>();
    }

    public class CaseQuestionOptions {
        @AuraEnabled public String label;
        @AuraEnabled public String value;
        
        public CaseQuestionOptions(String sLabel, String sValue){
            this.label = sLabel;
            this.value = sValue;
        }
    }

    public class ContactWrapper {
        @AuraEnabled public String sFirstName;
        @AuraEnabled public String sLastName;
        @AuraEnabled public String sEmail;
        @AuraEnabled public String sPhone;
        @AuraEnabled public String sAddress;
        @AuraEnabled public String sUserName;
        @AuraEnabled public Boolean bIsLogin = false;
        @AuraEnabled public String sContactId;
        @AuraEnabled public String sStreet;
        @AuraEnabled public String sSuite;
        @AuraEnabled public String sCity;
        @AuraEnabled public String sState;
        @AuraEnabled public String sPostalCode;
        @AuraEnabled public String sCountry;
        @AuraEnabled public String sOrganization;
    }
    
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
        mapLabels.put('sRegisterButton', System.Label.X11_Registration_Form_Field_BTN_Register); 
        mapLabels.put('sPasswordMismatch', System.Label.X11_Registration_Form_Password_Mismatch_Msg); 
        mapLabels.put('sBlankValue', System.Label.X11_Registration_Form_Mandatory_Msg); 
        mapLabels.put('sLoginIssue', System.Label.X11_Login_Failed);
        mapLabels.put('sLoginIssue', System.Label.X11_Login_Failed);
        /*mapLabels.put('sErrorFileUploadTitle', System.Label.X11_RI_File_Upload_Error_Title);
        mapLabels.put('sErrorFileUploadMaxFileError', System.Label.X11_RI_File_Upload_Max_No_Error);
        mapLabels.put('sUploadAnImage', System.Label.X11_RI_Upload_An_Image);
        mapLabels.put('sUploadImageHelp', System.Label.X11_RI_Upload_Image_Help);
        mapLabels.put('sFileUploadDropDrag', System.Label.X11_RI_Upload_Drop_Drag);
        mapLabels.put('sUploadBrowse', System.Label.X11_RI_Upload_Browse);
        mapLabels.put('sImageUploaded', System.Label.X11_RI_Image_Uploaded);
        mapLabels.put('sFileUploadDetails', System.Label.X11_RI_File_Upload_Details);
        mapLabels.put('sEroorFileSize', System.Label.X11_RI_File_Size_Limit_Error); 
        mapLabels.put('sErrorFileType', System.Label.X11_RI_Upload_File_Type_Error); 
        mapLabels.put('sHomePageTitle', System.Label.Home_Page_Title); 
        mapLabels.put('sNewReportTitle', System.Label.New_Report_Page_Titile);
        mapLabels.put('sNewSubmitTitle', System.Label.Submit_Page_Title);
        mapLabels.put('sNewSubmitTitle', System.Label.Submit_Page_Title);
        mapLabels.put('saccedptedFiletypes', System.Label.Accepted_File_Types);*/
        mapLabels.put('sORGANIZATION', System.Label.X11_ORGANIZATION);
        mapLabels.put('acceptedFileTypesPRA', System.Label.Accepted_File_Types_PRA);
        //mapLabels.put('acceptedFileUploadDetails', System.Label.X11_RI_File_Upload_Details_PRA);
        mapLabels.put('mandatoryCheck', System.Label.MandatoryCheck);
        
        return mapLabels;
    }
}