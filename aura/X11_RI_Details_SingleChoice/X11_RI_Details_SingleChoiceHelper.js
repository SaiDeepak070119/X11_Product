({
	radioValueChange : function(cmp, event){
        var answer = cmp.get("v.value");
        if(answer !== undefined && answer !== ""){
            var childOption = cmp.getEvent("X11_RI_Details_QAEvent");
            childOption.setParams({"sQuestion":cmp.get("v.detailsSingleChoiceQuestion"),"sAnswer":cmp.get("v.value")});
            childOption.fire(); 
        }
    }
})