({
	doInit: function (component, event, helper) {
        helper.fetchIntialData(component, event,helper);
    },
    onEnterSearch: function(component, event, helper){
        component.set('v.searchKey', event.currentTarget.value);
        helper.getArticlesbySearch(component, event,helper);
    },
    handleAccordion: function (component, event, helper) {
        helper.handleAccordion(component, event);
    }
})