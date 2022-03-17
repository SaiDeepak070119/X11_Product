public without sharing class X11_ViewServiceRequestsController {
    
    @AuraEnabled
    public static Amazon_S3_Credential__c getS3Setting()
    {
        return Amazon_S3_Credential__c.getValues('Amazon');
    }
    
    @AuraEnabled
    public static FilterWrapper getSearchCriteria() {
        FilterWrapper result = new FilterWrapper();
        
        //Status Filter
        result.statusSearchCriterias = new List<SearchCriteria>();
        result.statusSearchCriterias.add(new SearchCriteria('New', 'New'));
        result.statusSearchCriterias.add(new SearchCriteria('In Progress', 'In Progress'));
        result.statusSearchCriterias.add(new SearchCriteria('Closed', 'Closed'));
        
        //Date Filter
        Integer days = Date.daysInMonth(Date.today().year(), Date.today().month());
        result.dateSearchCriterias = new List<SearchCriteria>();
        result.dateSearchCriterias.add(new SearchCriteria('Today', '' + System.today() + '/--/' + System.today().addDays(1)));
        result.dateSearchCriterias.add(new SearchCriteria('This Week', '' + System.today().toStartOfWeek() + '/--/' + System.today().toStartOfWeek().addDays(7)));
        result.dateSearchCriterias.add(new SearchCriteria('This Month', '' + System.today().toStartOfMonth() + '/--/' + System.today().toStartOfMonth().addDays(days)));
        
        //Request Type Filter
        result.requestTypeSearchCriterias = new List<SearchCriteria>();
        Map<String, List<String>> categoryToTypesMap = new Map<String, List<String>>();
        for (X11_Case_Metadata_Type__c caseConfiguration : [SELECT Id, Case_UX_Category__c, Case_UX_Type__c 
                                                            FROM X11_Case_Metadata_Type__c 
                                                            WHERE Display_on_Web__c = true 
                                                            LIMIT 100]) {
            if (String.isNotBlank(caseConfiguration.Case_UX_Category__c)) {
                if(!categoryToTypesMap.containskey(caseConfiguration.Case_UX_Category__c)) {
                    categoryToTypesMap.put(caseConfiguration.Case_UX_Category__c, new List<String>());
                }
                categoryToTypesMap.get(caseConfiguration.Case_UX_Category__c).add(caseConfiguration.Case_UX_Type__c);
            }
        }
        for (String category : categoryToTypesMap.keySet()) {
            List<SearchCriteria> childFilters = new List<SearchCriteria>();
            for (String caseType : categoryToTypesMap.get(category)) {
                childFilters.add(new SearchCriteria(caseType, caseType));
            }
            result.requestTypeSearchCriterias.add(new SearchCriteria(category, category, childFilters));
        }
        
        return result;
    }
    
    @AuraEnabled
    public static List<CaseSearchResultWrapper> searchCaseRequest(Boolean viewAllRequests, String dateFilter, String statusFilter, String requestTypeFilter) {
        String contactId = null;
        Date startDate = null, endDate = null;
        List<String> statusToSearch = new List<String>();
        List<String> requestTypeToSearch = new List<String>();
        
        List<CaseSearchResultWrapper> results = new List <CaseSearchResultWrapper>();
        Map<String, List<String>> caseIdToImageMap = new Map<String,List<String>>();
        
        String query = 'SELECT Id, ContactId, type, Hide_from_Web__c, CaseNumber, RecordType.Name, Status, Description, ' + 
            'Geolocation__Longitude__s, Geolocation__Latitude__s, ' + 
            'Street_Address__c, CreatedDate, ClosedDate, Action_Taken__c ' + 
            'FROM Case ';
        if(viewAllRequests) {
            query += 'WHERE Hide_from_Web__c = false ';//and Offensive_Content__c != \'Yes\'
        }
        else {
            contactId = [SELECT ContactId FROM User WHERE id = :UserInfo.getUserId()].ContactId;    
            query += 'WHERE ContactId = :contactId ';
        }
        
        //Date Filter
        if(String.isNotBlank(dateFilter)) {
            List<String> dateFilterList = new List<String>(dateFilter.split('/--/'));
            startDate = Date.valueOf(dateFilterList[0]);
            endDate = Date.valueOf(dateFilterList[1]).addDays(1);
            query += 'AND CreatedDate >= :startDate AND CreatedDate < :endDate ';
        }
        
        //Status Filter
        if (String.isNotBlank(statusFilter)) {
            statusToSearch = statusFilter.contains(',') ? statusFilter.split(',') : new List<String>{statusFilter};
            query += 'AND Status IN :statusToSearch ';
        }
        
        //Request Type Filter
        if (String.isNotBlank(requestTypeFilter)) {
            requestTypeToSearch = requestTypeFilter.contains(',') ? requestTypeFilter.split(',') : new List<String>{requestTypeFilter};
            query += 'AND Type IN :requestTypeToSearch ';
        }
        
        query +=  ' Order By CreatedDate DESC';
        
        for (Case objCase: Database.Query(query)) {
            CaseSearchResultWrapper caseWrapper = new CaseSearchResultWrapper(objCase);
            results.add(caseWrapper);
            caseIdToImageMap.put(objCase.Id, new List<String>());
        }
        
        Set<Id> contentDocumentIds = new Set<Id>();
        Map<Id, Set<Id>> caseIdToContentDocumentIdsMap = new Map<Id, Set<Id>>();
        Map<Id, List<ContentVersion>> caseIdToContentVersionsMap = new Map<Id, List<ContentVersion>>();
        Map<Id, List<Attachment>> caseIdToAttachmentsMap = new Map<Id, List<Attachment>>();
        
        if(caseIdToImageMap.isEmpty()) {
            return results;
        }
        
        for(ContentDocumentLink cd : [SELECT ContentDocumentId, LinkedEntityId 
                                      FROM ContentDocumentLink 
                                      WHERE LinkedEntityId IN :caseIdToImageMap.keySet()
                                     		AND LinkedEntity.Type = 'Case']) {
            contentDocumentIds.add(cd.ContentDocumentId);
            if(!caseIdToContentDocumentIdsMap.containsKey(cd.LinkedEntityId)) {
                caseIdToContentDocumentIdsMap.put(cd.LinkedEntityId, new Set<Id>());   
            }	
			caseIdToContentDocumentIdsMap.get(cd.LinkedEntityId).add(cd.ContentDocumentId);
        }
        
        List<ContentVersion> contentVersions = [SELECT Id, Title, ContentDocumentId
                                                FROM ContentVersion 
                                                WHERE ContentDocumentId IN :contentDocumentIds];
        for(Id caseId : caseIdToContentDocumentIdsMap.keySet()) {
            for(Id contentDocumentId : caseIdToContentDocumentIdsMap.get(caseId)) {
                for(ContentVersion cv : contentVersions) {
                    if(cv.ContentDocumentId == contentDocumentId) {
                        if(!caseIdToContentVersionsMap.containsKey(caseId)) {
                            caseIdToContentVersionsMap.put(caseId, new List<ContentVersion>());
                        }
                        caseIdToContentVersionsMap.get(caseId).add(cv);
                    }
                }
            }
        }
        
        for(Attachment att : [SELECT Id, ParentId 
                              FROM Attachment 
                              WHERE ParentId IN :caseIdToImageMap.keySet()]){
			if(!caseIdToAttachmentsMap.containsKey(att.ParentId)) {
                caseIdToAttachmentsMap.put(att.ParentId, new List<Attachment>());
            }
			caseIdToAttachmentsMap.get(att.ParentId).add(att);
        }
        
        for(Document__c objDoc : [SELECT Id,Name, Document_URL__c, Claim__c 
                                  FROM Document__c 
                                  WHERE Claim__c IN: caseIdToImageMap.keySet() 
                                  ORDER BY CreatedDate]) {
            caseIdToImageMap.get(objDoc.Claim__c).add(objDoc.Name);
        }
        
        for(CaseSearchResultWrapper caseWrapper : results) {
            if(caseIdToContentVersionsMap.containsKey(caseWrapper.caseObj.Id)) {
                caseWrapper.urlsList = caseIdToContentVersionsMap.get(caseWrapper.caseObj.Id);
                caseWrapper.imageUrl = !caseIdToContentVersionsMap.get(caseWrapper.caseObj.Id).isEmpty() ? Label.ImageURL1 + caseIdToContentVersionsMap.get(caseWrapper.caseObj.Id)[0].Id : caseWrapper.imageUrl;
                
            }
            else if(caseIdToAttachmentsMap.containsKey(caseWrapper.caseObj.Id)){
                caseWrapper.attachurlsList = caseIdToAttachmentsMap.get(caseWrapper.caseObj.Id);
                caseWrapper.imageUrl = !caseIdToAttachmentsMap.get(caseWrapper.caseObj.Id).isEmpty() ?  Label.ImageURL2 + caseIdToAttachmentsMap.get(caseWrapper.caseObj.Id)[0].Id : caseWrapper.imageUrl;
                
            }
            else if(caseIdToImageMap.containsKey(caseWrapper.caseObj.Id)){
                caseWrapper.awsImageList = !caseIdToImageMap.get(caseWrapper.caseObj.Id).isEmpty() ? caseIdToImageMap.get(caseWrapper.caseObj.Id) : caseWrapper.awsImageList;
            }
        }        
        
        return results;
    }
    
    public class FilterWrapper {
        @AuraEnabled public List<SearchCriteria> statusSearchCriterias;
        @AuraEnabled public List<SearchCriteria> dateSearchCriterias;
        @AuraEnabled public List<SearchCriteria> requestTypeSearchCriterias;
    }

    public class SearchCriteria {
        @AuraEnabled public String label;
        @AuraEnabled public String value;
        @AuraEnabled public List<SearchCriteria> childFilters;
        
        public SearchCriteria(String label, String value) {
            this.label = label;
            this.value = value;
            this.childFilters = new List<SearchCriteria>();
        }
        
        public SearchCriteria(String label, String value, List <SearchCriteria> childFilters) {
            this.label = label;
            this.value = value;
            this.childFilters = childFilters;
        }
    }
    
    public class CaseSearchResultWrapper {
        @AuraEnabled public Case caseObj;
        @AuraEnabled public Integer caseStatusLevel;
        @AuraEnabled public String imageUrl;
        @AuraEnabled public List<String> awsImageList;
        @AuraEnabled public List<ContentVersion> urlsList;
        @AuraEnabled public List<Attachment> attachurlsList;
        
        public CaseSearchResultWrapper(case caseObj) {
            this.caseObj = caseObj;
            this.caseStatusLevel = getCaseStatusLevel(caseObj.Status);
            this.caseObj.Status = getCaseStatus(this.caseObj.Status);
            this.imageUrl = Label.X11_Case_DefaultImage;
            this.urlsList = new List<ContentVersion>();
            this.attachurlsList = new list<Attachment>();
            this.awsImageList = new List<String>();
        }
        
        public Integer getCaseStatusLevel(String caseStatus) {
            switch on caseStatus {
                when 'Closed' {
                    return 3;
                }
                when 'In Progress' {
                    return 2;
                }
                when else {
                    return 1;
                }
            }
        }
        
        public String getCaseStatus(String caseStatus) {
            if(caseStatus == Label.Duplicate){
                return Label.Label_For_In_Progress;
            }
            if(caseStatus == label.On_Hold || caseStatus == Label.Escalated || caseStatus == label.Rolling_Production || caseStatus == label.Extended || caseStatus == label.X14_Day_Extension ){
                return Label.Label_For_In_Progress;
            }
            if(caseStatus == Label.Cancelled || caseStatus == label.Closed_Referred_Status  ){
                return Label.Closed_Status;
            }
            return caseStatus;
        }
        
    }
    
}