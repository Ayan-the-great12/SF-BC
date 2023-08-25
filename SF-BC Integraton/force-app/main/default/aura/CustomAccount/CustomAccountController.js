({
    doInit : function(component, event, helper) {
        helper.setAccountColumns(component,event);
        component.set("v.spinner", true);
        helper.getAccountList(component);
    },
    updateSelectedText: function(component, event) {
        var selectedRows = event.getParam('selectedRows');
        if (selectedRows.length > 0) {
            component.set('v.disableSyncBtn', false);
            component.set('v.selectedRecords', selectedRows);
        } else {
            component.set('v.disableSyncBtn', true);
        }
        component.set('v.selectedRowsCount', selectedRows.length);
    },
    handleSort: function(component, event, helper) {
        var sortBy = event.getParam("fieldName");
        var sortDirection = event.getParam("sortDirection");
        component.set("v.sortBy", sortBy);
        component.set("v.sortDirection", sortDirection);
        helper.sortData(component, sortBy, sortDirection);
    },
    syncAccounts: function(component, event, helper) {
        component.set("v.spinner", true);
        try {
            helper.syncSelectedAccounts(component, event);
        } catch (ex) {
            component.set("v.spinner", false);
            helper.showToastMsg('Please refresh the page and try again!', 'Error');
        }
    }
})
