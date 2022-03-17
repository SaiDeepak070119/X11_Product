({
	doInit_Helper : function(cmp, event) {
		cmp.set("v.bShowMessage", false);
        if($A.util.isEmpty(cmp.get("v.sTitle"))){
            if(cmp.get("v.sSeverity").toUpperCase() === "confirm"){
                cmp.set("v.sTitle", "Confirmation");
                cmp.set("v.sIconName", "action:approval");
                cmp.set("v.sIconSize", "xx-small");
            }else if(cmp.get("v.sSeverity").toUpperCase() === "info"){
                cmp.set("v.sTitle", "Information");
                cmp.set("v.sIconName", "utility:connected_apps");
            }else if(cmp.get("v.sSeverity").toUpperCase() === "warning"){
                cmp.set("v.sTitle", "Warning");
                cmp.set("v.sIconName", "utility:warning");
            }else if(cmp.get("v.sSeverity").toUpperCase() === "error"){
                cmp.set("v.sTitle", "Error");
                cmp.set("v.sIconName", "utility:error");
            }
            cmp.set("v.bShowMessage", true);
        }        
	}
})