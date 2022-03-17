({
    handleChange : function(component, event) {
        try{
            var getValue = component.get("v.value");
            var getId = component.find("multipleChoice");
            var getElement = document.querySelector(".slds-checkbox");
            component.set("v.detailsMultipleOptionsAnswer",getValue.join());
        }catch(e){
            
        }
    },
    continueClick : function(cmp, event){
        var answer = cmp.get("v.detailsMultipleOptionsAnswer");
        if(answer !== undefined && answer !== ""){
            var childOption = cmp.getEvent("X11_RI_Details_QAEvent");
            childOption.setParams({"sQuestion":cmp.get("v.detailsMultipleOptionsQuestion"),"sAnswer":cmp.get("v.detailsMultipleOptionsAnswer")});
            childOption.fire(); 
        }
    }
})