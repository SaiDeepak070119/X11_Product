({
	yesNoAnswer : function(component, event, helper) {
        try{
            helper.helperMethod(component,event);
        }catch(e){
            console.error(e.stack);
        } 
	}
})