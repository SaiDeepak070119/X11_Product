({
    continueClick : function(component, event, helper) {
        console.log("---->",component.get("v.options"));
        helper.continueClick(component, event);
    }
})