public without sharing class X11_HomePageController {

    @AuraEnabled
    public static Wrapper getAllCaseConfigurationRecords() {
        Wrapper response = new Wrapper();
        String loggedInUserLincence = [Select Profile.UserLicense.Name from User WHERE Id =: UserInfo.getUserId() LIMIT 1].Profile.UserLicense.Name;
        response.isPortalUser = (System.Label.X11Community_Licenses.contains(loggedInUserLincence));
		response.allCaseConfigurations = new List<CaseConfiguration>();
        response.popularCaseConfigurations = new List<CaseConfiguration>();
        
        Map<String, CaseCategoryConfiguration> caseConfigurationsByCategory = new Map<String, CaseCategoryConfiguration>();
        
        String query =  'SELECT Id, Case_UX_Category__c, Case_UX_Type__c, Case_UX_Description__c, Case_UX_Estimation__c, ' +
            					'Case_UX_Popular_Types__c, Sequence_on_portal__c ' + 
            			'FROM X11_Case_Metadata_Type__c ' + 
            			'WHERE Display_on_Web__c = true ';
        if(response.isPortalUser) {
            query += 'AND Available_for_Portal_User__c = true ';
        }
        
        query += 'ORDER BY Sequence_on_portal__c LIMIT 100';
        
        for(X11_Case_Metadata_Type__c caseMetadataType : Database.query(query)) {
            CaseConfiguration caseConfig = new CaseConfiguration();
            caseConfig.caseId = response.isPortalUser ? X11_Utility.encryptAndEncodeURL(caseMetadataType.Id) : caseMetadataType.Id;
            caseConfig.caseCategory = caseMetadataType.Case_UX_Category__c;
            caseConfig.caseType = caseMetadataType.Case_UX_Type__c;
            caseConfig.caseDescription = caseMetadataType.Case_UX_Description__c;
            caseConfig.caseEstimation = String.valueOf(caseMetadataType.Case_UX_Estimation__c);
            caseConfig.casePopularType = caseMetadataType.Case_UX_Popular_Types__c;
            
            //Add Case Configuration to All Case Configuration List
            response.allCaseConfigurations.add(caseConfig);
            
            //Add Case Configuration in List Grouped by Category
            if(String.isNotBlank(caseConfig.caseCategory)) {
                if(!caseConfigurationsByCategory.containsKey(caseConfig.caseCategory)) {
                    CaseCategoryConfiguration temp = new CaseCategoryConfiguration();
                    temp.caseCategory = caseConfig.caseCategory;
                    temp.caseConfigurations = new List<CaseConfiguration>();
                    caseConfigurationsByCategory.put(caseConfig.caseCategory, temp);
                }
                caseConfigurationsByCategory.get(caseConfig.caseCategory).caseConfigurations.add(caseConfig);
            }
            
            //Add Case Configuration to Popuplar Case Configuration List
            if(caseConfig.casePopularType) {
                response.popularCaseConfigurations.add(caseConfig);
            }
        }
        
        response.caseConfigurationsByCategory = caseConfigurationsByCategory.values();
        
		return response;        
    }
    
    public class Wrapper {
        @AuraEnabled public Boolean isPortalUser;
        @AuraEnabled public List<CaseConfiguration> allCaseConfigurations;
        @AuraEnabled public List<CaseCategoryConfiguration> caseConfigurationsByCategory;
        @AuraEnabled public List<CaseConfiguration> popularCaseConfigurations;
    }
    
    public class CaseCategoryConfiguration {
        @AuraEnabled public String caseCategory;
        @AuraEnabled public List<CaseConfiguration> caseConfigurations;
    }
    
    public class CaseConfiguration {
        @AuraEnabled public String caseId;
        @AuraEnabled public String caseCategory;
        @AuraEnabled public String caseType;
        @AuraEnabled public String caseDescription;
        @AuraEnabled public String caseEstimation;
        @AuraEnabled public Boolean casePopularType;
    }
}