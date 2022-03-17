({
    init: function(component, event, helper) {
        helper.getAwsSettings(component,event,helper);
        if (window.location.href.indexOf("q=true") > 1) {
            component.set("v.viewAllRequests", false);
        }
        helper.getSearchCriteria(component);
        helper.searchCaseRequest(component, '', '', '');
        var todaysDate = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD");
        component.set('v.todaysDate', todaysDate);
    },
    
    handleDateSearchCriteria: function(component, event, helper) {
        component.set("v.selectedDateFilterValue", '');
        component.set("v.showCustomDatePicker", false);
        
        var selectedValue = event.getParam("value");
        
        component.find("dateSearchCriterias").forEach(function (menuItem) {
            if (menuItem.get("v.value") === selectedValue) {
                menuItem.set("v.checked", !menuItem.get("v.checked"));
            }
            else {
                menuItem.set("v.checked", false);
            }
            
            if (menuItem.get("v.checked") && selectedValue !== 'Custom') {
                component.set("v.selectedDateFilterValue", selectedValue);
            }
            if (selectedValue === 'Custom') {
                if (!menuItem.get("v.checked")) {
                    component.set("v.selectedDateFilterValue", '');
                } 
                else {
                    component.set("v.showCustomDatePicker", true);
                }
            }
        });
        event.getSource().set("v.visible", true);
    },
    
    setCustomDateSearchCriteriaValue: function(component, event, helper) {
        const customStartDate = component.get("v.customStartDate");
        const customEndDate = component.get("v.customEndDate");
        if (customStartDate && customEndDate) {
            component.set("v.selectedDateFilterValue", customStartDate + '/--/' + customEndDate);
        }
    },
    
    handleStatusSearchCriteria: function(component, event, helper) {
        var selectedStatusFilterValue = component.get("v.selectedStatusFilterValue");
        var selectedValue = event.getParam("value");
        
        var selectedMenuItem = component.find("statusSearchCriterias").find(function (menuItem) {
            return menuItem.get("v.value") === selectedValue;
        });
        selectedMenuItem.set("v.checked", !selectedMenuItem.get("v.checked"));
        
        if (selectedMenuItem.get("v.checked")) {
            if(!$A.util.isEmpty(selectedStatusFilterValue)) {
                selectedStatusFilterValue += ',';
            }
            selectedStatusFilterValue += selectedValue;
        } 
        else {
            if (selectedStatusFilterValue.indexOf(',' + selectedValue) !== -1) {
                selectedStatusFilterValue = selectedStatusFilterValue.replace(',' + selectedValue, '');
            } 
            else if (selectedStatusFilterValue.indexOf(selectedValue + ',') !== -1) {
                selectedStatusFilterValue = selectedStatusFilterValue.replace(selectedValue + ',', '');
            } 
                else {
                selectedStatusFilterValue = selectedStatusFilterValue.replace(selectedValue, '');
            }
        }
        component.set("v.selectedStatusFilterValue", selectedStatusFilterValue);
        
        event.getSource().set("v.visible", true);
    },

    setSelectedRequestTypeCategory: function (component, event, helper) {
        var selectedValue = event.getSource().get("v.value");
        component.set("v.selectedRequestTypeCategory", selectedValue);
        component.set("v.selectedRequestTypeFilterValue", '');
        component.find("requestTypeSearchCriteriaButtonMenu").set("v.visible", true);
    },

    handleRequestTypeSearchCriteria: function (component, event, helper) {
        var selectedValue = event.getParam("value");
        var selectedRequestTypeFilterValue = component.get("v.selectedRequestTypeFilterValue");
        
        var menuItems = component.find("requestTypeSearchCriterias");
        var menuItem;
        // Get the selected menu item
        if (menuItems.get === undefined) {
            menuItem = menuItems.find(function(menuItem) {
                return menuItem.get("v.value") === selectedValue;
            });
        } 
        else {
            menuItem = menuItems;
        }
        menuItem.set("v.checked", !menuItem.get("v.checked"));

        if (menuItem.get("v.checked")) {
            if(!$A.util.isEmpty(selectedRequestTypeFilterValue)) {
                selectedRequestTypeFilterValue += ',';
            }
            selectedRequestTypeFilterValue += selectedValue;
        } 
        else {
            if (selectedRequestTypeFilterValue.indexOf(',' + selectedValue) !== -1) {
                selectedRequestTypeFilterValue = selectedRequestTypeFilterValue.replace(',' + selectedValue, '');
            } 
            else if (selectedRequestTypeFilterValue.indexOf(selectedValue + ',') !== -1) {
                selectedRequestTypeFilterValue = selectedRequestTypeFilterValue.replace(selectedValue + ',', '');
            } 
            else {
                selectedRequestTypeFilterValue = selectedRequestTypeFilterValue.replace(selectedValue, '');
            }
        }
        component.set("v.selectedRequestTypeFilterValue", selectedRequestTypeFilterValue);
        event.getSource().set("v.visible", true);
    },
    
    searchCases: function(component, event, helper) {
        helper.searchCaseRequest(component, component.get('v.selectedDateFilterValue'), component.get('v.selectedStatusFilterValue'), 
                                            component.get('v.selectedRequestTypeFilterValue'));
    },

    clearSearchFilter: function(component, event, helper) {
        window.location.reload();
    },

    cardSelectHandler: function(component, event, helper) {
        component.set('v.selectedServiceRequest', event.getParam("serviceRequest"));
        component.set('v.amazonsetting', event.getParam("amazonsetting"));
    },

    showServiceRequestListHandler: function(component, event, helper) {
        component.set('v.selectedServiceRequest', null);
    },
})