({
	init: function(component, event, helper) {
        helper.doInit_Helper(component, event, helper);
    },
    populateFileData: function (component, event, helper) {
        helper.getUploadedFileLocation(component, event);
    }
})