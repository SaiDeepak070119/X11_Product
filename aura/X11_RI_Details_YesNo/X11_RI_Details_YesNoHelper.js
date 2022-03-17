({
    helperMethod : function(cmp, event, helper) {
       var getBtnName = event.getSource().get("v.name");
        var whichOne = event.getSource().getLocalId();
        console.log(whichOne);
        //cmp.set("v.whichButton", whichOne);
        
        var cmpTargetYes = cmp.find("yesBtn");
        console.log(cmpTargetYes);
        var cmpTargetNo = cmp.find("noBtn");
        if(getBtnName === 'yesBtn'){//console.log("sdfsd");
            
            
            $A.util.addClass(cmpTargetYes, 'selected-btn');
            
            $A.util.removeClass(cmpTargetNo, 'selected-btn');
            
            cmp.set("v.selectedValue","Yes");
        }else{
            ///var cmpTargetNo = cmp.find("noBtn");
            $A.util.addClass(cmpTargetNo, 'selected-btn');
            //var cmpTargetYes = cmp.find("yesBtn");
            $A.util.removeClass(cmpTargetYes, 'selected-btn');
            
            cmp.set("v.selectedValue","No");
        }
        
        var childOption = cmp.getEvent("X11_RI_Details_QAEvent");
        childOption.setParams({"sQuestion":cmp.get("v.detailsYesNoQuestion"),"sAnswer":cmp.get("v.selectedValue")});
        childOption.fire();
    }
})