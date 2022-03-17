public without sharing class X11_Case_DuplicateCheck {

    public static void duplicatecheck(Case csObj){
        String slatitude = String.ValueOf(csObj.Geolocation__latitude__s);
        String slongitude = String.ValueOf(csObj.Geolocation__longitude__s);
        if(slatitude != null && slongitude != null){
        	String sDistance = 'mi';
            Double radius = 100;
            Double radius_ft = radius;
            Double radius_mi = 0.00018939 * radius_ft;
            List<X11_Case_Metadata_Type__c> caseConfigList = [SELECT Id, Case_Record_Type__c, Case_Type__c, X11_Case_Status__c, Duplicate_Radious_Miles__c FROM X11_Case_Metadata_Type__c WHERE Case_UX_Type__c=: csObj.Type LIMIT 1];
            if(caseConfigList.size() > 0 && caseConfigList[0].Duplicate_Radious_Miles__c > 0){
            	radius_mi = Double.valueOf(caseConfigList[0].Duplicate_Radious_Miles__c);
            }
            
            List<String> statusList = new List<String>{'New','In Progress'};
                String queryString = 'Select Id,RecordTypeId,Status,Type,ParentId,Geolocation__c,Geolocation__Latitude__s,Geolocation__Longitude__s from Case';
            String whereCondition = '';
            whereCondition += ' WHERE Id <>\''+csObj.Id+'\'';//Department__c = \''+caseObj.Department__c+'\' AND
            whereCondition += ' AND Type = \''+csObj.Type+'\'';
            whereCondition += ' AND Status IN :statusList';
            whereCondition += ' AND DISTANCE(Geolocation__c, GEOLOCATION(' + csObj.Geolocation__Latitude__s + ', ' + csObj.Geolocation__Longitude__s + ' ), \'mi\') < '+radius_mi;
            whereCondition += ' ORDER BY DISTANCE(Geolocation__c, GEOLOCATION(' + csObj.Geolocation__Latitude__s + ', ' + csObj.Geolocation__Longitude__s + ' ), \'mi\') ASC LIMIT 1';   
            List<Case> parentCaseLst = Database.query(queryString + whereCondition);
            if(parentCaseLst.size() > 0){ 
                csObj.Status = 'Duplicate';
                csObj.ParentId = parentCaseLst[0].Id;
                if(csObj != Null){
                    update csObj;
                }
            }
        }
    }
}