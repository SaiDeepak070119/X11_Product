public without sharing class X11_CaseTrigger_Handler {
    
    public static void checkChildCaseVerified(List<Id> closeCaseId,Map<Id,Case> parentCaseInfo){
        try{
            List<Case> childCasesLst = [Select Id,ParentId,Parent.Status,Duplicate_Verified__c,Duplicate_Overridden__c from Case WHERE ParentId IN :closeCaseId AND Status = 'Duplicate'];
            if(childCasesLst.size() > 0){
                for(Case csObj : childCasesLst){
                    if(!csObj.Duplicate_Verified__c && !csObj.Duplicate_Overridden__c){
                        parentCaseInfo.get(csObj.ParentId).addError('Please Verify/Override child cases before you close current case.');
                    }
                }
            }
        }catch(Exception e){
            X11_Utility.logError(e, 'X11_CaseTrigger_Handler', 'checkChildCaseVerified');
        }
    }

    public static void updateChildCasesDetails(List<Id> closeCaseId,Map<Id,Case> parentCaseInfo){
        try{
            if(closeCaseId.size() > 0 && parentCaseInfo.size() > 0){
                List<Case> childCasesLst = [Select Id,Status,ParentId,Parent.Status,Duplicate_Verified__c,Duplicate_Overridden__c from Case WHERE ParentId IN :closeCaseId];//Closure_Reason__c,Duplicate_Verification_Status__c
                if(childCasesLst.size() > 0){
                    for(Case childObj: childCasesLst){
                        //childObj.Status = parentCaseInfo.get(childObj.ParentId).Status;
                        if(childObj.Duplicate_Verified__c){
                            childObj.Status = parentCaseInfo.get(childObj.ParentId).Status;
                            //childObj.Closure_Reason__c = parentCaseInfo.get(childObj.ParentId).Closure_Reason__c;
                        }else{
                            childObj.Status = 'New';
                            childObj.ParentId = null;
                        }
                    }
                    update childCasesLst;
                }   
            }
        }catch(Exception e){
            X11_Utility.logError(e, 'X11_CaseTrigger_Handler', 'updateChildCasesDetails');
        }
    }
}