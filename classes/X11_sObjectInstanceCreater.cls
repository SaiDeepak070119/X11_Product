/* Class Name   : X11_sObjectInstanceCreater
 * Description  : Creates Instance of Objects based on field passed
 * Created By   : Abhishek Mishra
 * Created On   : 04-MAR-2019
 * References   : Class-CustomRegistration_Ctrl
 * Modification Log:  
 * --------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date                Modification ID         Description 
 * --------------------------------------------------------------------------------------------------------------------------------------
 * Abhishek Mishra          04-MAR-2019         1000                    Initial version
 */
public class X11_sObjectInstanceCreater {
    Public static Account objAccount;
    Public static Contact objContact;
    Public static User objUSer;
    /* @Name:   getAccountInstance 
     * @Desc:   Method to create an account Instance
     * @param:  Fields on Partner form
     * @return: Account 
     */
    public static account getAccountInstance(String sFirstName, String sLastname, String sEmail, String sPhoneNumber, String sStreet, 
                                             String sSuite, String sCity, String sState, String sPostalCode, String sCountry){
        objAccount = new Account(name = sFirstName + ' ' + sLastname,
                                 Phone = sPhoneNumber,
                                 BillingStreet = (String.isNotBlank(sStreet) && String.isNotBlank(sSuite)) ? sStreet+', '+sSuite : (String.isNotBlank(sStreet) ? sStreet : ''),
                                 //BillingStreet = string.isEmpty(sStreet) ? sStreet : sStreet+', '+sSuite,
                                 BillingCity = sCity,
                                 BillingState = sState,
                                 BillingPostalCode = sPostalCode,
                                 BillingCountry = sCountry);
        //objAccount.IsPartner = true;
        //system.debug('objAccount>'+objAccount);
        return objAccount;
    }
    /* @Name:   getContactInstance 
     * @Desc:   Method to create an contact Instance
     * @param:  Fields on Partner form
     * @return: Contact 
     */
    public static contact getContactInstance(String sAccountId, String sFirstName, String sLastname, String sEmail, String sPhoneNumber, 
                                             String sStreet, String sSuite, String sCity, String sState, String sPostalCode, String sCountry){
        objContact = new Contact(AccountId = sAccountId,
                                 FirstName = sFirstName,
                                 LastName = sLastName,
                                 Email = sEmail,
                                 Phone = sPhoneNumber,
                                 MailingStreet = (String.isNotBlank(sStreet) && String.isNotBlank(sSuite)) ? sStreet+', '+sSuite : (String.isNotBlank(sStreet) ? sStreet : ''),
                                 //MailingStreet = sStreet + ', ' + sSuite,
                                 MailingCity = sCity,
                                 MailingState = sState,
                                 MailingPostalCode = sPostalCode,
                                 MailingCountry = sCountry);
       // system.debug('objContact>'+objContact);
        return objContact;
    }
    /* @Name:   getUserInstance 
     * @Desc:   Method to create an user Instance
     * @param:  Fields on Partner form
     * @return: user 
     */
    public static user getUserInstance(String sContactId, String sFirstname, String sLastname, String sEmail, String sPhoneNumber,
                                       String sStreet, String sSuite, String sCity, String sState, String sPostalCode, String sCountry){
        objUser = new User(FirstName = sFirstName,
                           LastName = sLastName,
                     Username = sEmail,
                           CommunityNickname = sEmail.substringBefore('@') + ((string.valueOF(System.now())).remove(':')).remove('-').remove(' '),
                           Phone = sPhoneNumber,
                           Email = sEmail,
                           Street = (String.isNotBlank(sStreet) && String.isNotBlank(sSuite)) ? sStreet+', '+sSuite : (String.isNotBlank(sStreet) ? sStreet : ''),
                           //Street = sStreet + ', ' + sSuite,
                           City = sCity,
                           State = sState,
                           PostalCode = sPostalCode,
                           Country = sCountry); 
        objUser.EmailEncodingKey = System.Label.Label_For_Email_Encoding;
        objUser.LocaleSidKey = System.Label.Label_For_LocaleSidKey;
        objUser.TimeZoneSidKey = System.Label.Label_For_Time_Zone;
        objUser.LanguageLocaleKey = System.Label.Label_For_LocaleSidKey;
        objUser.ContactId  = sContactId; 
        //system.debug('objUser>'+objUser);                                           
        return objUser;
    }
}