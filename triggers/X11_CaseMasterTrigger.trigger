trigger X11_CaseMasterTrigger on Case (before update, after update) {

    if(Trigger.isBefore && Trigger.isUpdate){
        List<Id> closedCaseId = new List<Id>();
        for(Case csObj: Trigger.new){
            if(csObj.ParentId == null && (csObj.Status == 'Closed' || csObj.Status == 'Cancelled')){
                closedCaseId.add(csObj.Id);
            }
        }
        if(closedCaseId.size() > 0){
         	X11_CaseTrigger_Handler.checkChildCaseVerified(closedCaseId,Trigger.newMap);   
        }
    }
    
    if(Trigger.isAfter && Trigger.isUpdate){
        List<Id> closedCaseId = new List<Id>();
        for(Case csObj: Trigger.new){
            if(csObj.ParentId == null && (csObj.Status == 'Closed' || csObj.Status == 'Cancelled')){
                closedCaseId.add(csObj.Id);
            }
        }
        if(closedCaseId.size() > 0){
         	X11_CaseTrigger_Handler.updateChildCasesDetails(closedCaseId,Trigger.newMap);   
        }
    }
}