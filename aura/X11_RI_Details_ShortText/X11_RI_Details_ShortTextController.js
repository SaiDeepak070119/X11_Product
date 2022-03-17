({
	verifyRequired : function(cmp){
        debugger;
        var bAnyError = false;
        var sErrorMsg = cmp.get("v.mapLabels")['sBlankValue']; 
        var sInField = cmp.find('ShortText');
        var sFieldVal = sInField.get("v.value");
        //Blank Value Check
        if ($A.util.isEmpty(sFieldVal)){
            sInField.setCustomValidity(sErrorMsg, null);
			sInField.showHelpMessageIfInvalid();
            bAnyError = true;
        }else{
            sInField.setCustomValidity('');
            sInField.showHelpMessageIfInvalid();
        }
        //Standard Error Check
        if(!sInField.reportValidity()){
        	bAnyError = true;            
        }else{
            sInField.setCustomValidity('');
            sInField.showHelpMessageIfInvalid();
        } 
        //return bAnyError;
    }
})