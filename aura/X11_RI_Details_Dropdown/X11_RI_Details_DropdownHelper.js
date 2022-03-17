({
    continueClick : function(cmp, event){
        
        var answer = cmp.get("v.detailsAnswer");
        if(answer !== undefined && answer !== ""){
            var childOption = cmp.getEvent("X11_RI_Details_QAEvent");
            childOption.setParams({"sQuestion":cmp.get("v.detailsQuestion"),"sAnswer":cmp.get("v.detailsAnswer")});
            childOption.fire(); 
        }
    }
})