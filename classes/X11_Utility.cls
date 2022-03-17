public with sharing class X11_Utility {

    public static String encryptAndEncodeURL(String str) {
        String sEncodedCipherText = EncodingUtil.base64Encode(Crypto.encryptWithManagedIV('AES128', Blob.valueOf(Label.X11_Encryption_Key), Blob.valueOf(str)));
        return encodingUtil.URLEncode(sEncodedCipherText, 'UTF-8');
    }
    
    public static string decrypt(string str) {
        System.debug(str);
        Blob decryptedBlob = Crypto.decryptWithManagedIV('AES128', Blob.valueOf(Label.X11_Encryption_Key), EncodingUtil.base64Decode(str));    
        return decryptedBlob.toString();
    }
     
    /**
* logError --- Log Error in Error Object
* @param Id : Exception ex, Classname, Method Name
* @return : null
*/
    public static void logError(Exception ex, String sClassName, String sMethodName){
       /* System.debug('Exception on Class : ' + sClassName + ' - ' + sMethodName 
                     + ', Error : ' 
                     + ex.getMessage() 
                     + ' Line Number : ' 
                     + ex.getLineNumber()
                     + ' Cause : '
                     + ex.getCause()
                     + ' Type : '
                     + ex.getTypeName());*/
        //Error Log in Error Object     
        X11_Error_Log__c objErrorerror = new X11_Error_Log__c();
        objErrorerror.X11_ClassName__c = sClassName;
        objErrorerror.X11_MethodName__c = sMethodName;
        string exceptionStr = 'Exception on Class : ' + sClassName + ' - ' + sMethodName + ', Error : ' + ex.getMessage()  + ' Line Number : ' + ex.getLineNumber()
            + ' Cause : ' + ex.getCause()+ ' Type : '+ ex.getTypeName();
        // objErrorerror.X11_ErrorMessage__c = 'Exception on Class : ' + sClassName + ' - ' + sMethodName + ', Error : ' + ex.getMessage()  + ' Line Number : ' + ex.getLineNumber()
        //   + ' Cause : ' + ex.getCause()+ ' Type : '+ ex.getTypeName();
        
        objErrorerror.X11_ErrorMessage__c =  exceptionStr;
        
        objErrorerror.X11_ErrorType__c = X11_Constants.sERROR;
        objErrorerror.X11_SourceSystem__c = X11_Constants.sSourceSystem;
        objErrorerror.X11_Type__c = X11_Constants.sType;
        if(objErrorerror!=null){
            insert objErrorerror;
        }
    }
    
}