({
    setAccountColumns: function(component) {
        component.set("v.accountColumns", [{
                label: 'Account Name',
                fieldName: 'accountHyperUrl',
                type: 'url',
                sortable: true,
                typeAttributes: {
                    label: {
                        fieldName: 'accountName'
                    },
                    target: '_self',
                    tooltip: 'Click to visit account'
                }
            },
            {
                label: 'Primary Contact',
                fieldName: 'contactHyperUrl',
                type: 'url',
                sortable: true,
                typeAttributes: {
                    label: {
                        fieldName: 'primaryContactName'
                    },
                    target: '_self',
                    tooltip: 'Click to visit contact'
                }
            },
            {
                label: 'Record Type',
                fieldName: 'recordTypeName',
                sortable: true,
                type: 'text'
            },
            {
                label: 'Account Owner',
                fieldName: 'accountOwnerHyperUrl',
                type: 'url',
                sortable: true,
                typeAttributes: {
                    label: {
                        fieldName: 'createdOwnerName'
                    },
                    target: '_self',
                    tooltip: 'Click to visit owner'
                }
            },
            {
                label: 'SSN',
                fieldName: 'SSN',
                type: 'text',
                sortable: true,
            },
            {
                label: 'Phone#',
                fieldName: 'accountPhone',
                type: 'text',
                sortable: true,
                cellAttributes: {
                    iconName: {
                        fieldName: 'provenanceIconNamePhone'
                    },
                    iconLabel: {
                        fieldName: 'provenanceIconLabelPhone'
                    },
                    iconPosition: 'left'
                }
            },
           
        ]);
    },
    getAccountList: function(component) {
        var recordsCount = component.get("v.recordsCount");
        var accountsMap = component.get("v.accountsMap");
        var allAccounts = component.get("v.allAccounts");
        var action = component.get("c.getAllAccountsApxc");
        action.setParams({
            accountsMap: accountsMap
        });
        action.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS") {
                var responseValue = response.getReturnValue();
                var records = responseValue.accountsDataList;
                if (records != null && records != undefined && records.length > 0) {
                    var remainder = Math.floor(records.length / 10);
                    
                    var updatedCount = recordsCount + (remainder * 10);
                    component.set("v.recordsCount", updatedCount);
                    component.set("v.accountsMap", responseValue.accountsMap);

                    records.map(function(rowData) {
                        if (rowData.accountEmail) {
                            rowData.provenanceIconNameEmail = 'utility:email';
                        }
                        if (rowData.accountPhone) {
                            rowData.provenanceIconNamePhone = 'utility:call';
                        }
                        if (!rowData.accountFirstName) {
                            rowData.accountFirstName = '-';
                        }
                        if (!rowData.accountLastName) {
                            rowData.accountLastName = '-';
                        }
                        if (!rowData.accountEmail) {
                            rowData.accountEmail = '-';
                        }
                        if (!rowData.accountPhone) {
                            rowData.accountPhone = '-';
                        }
                        if (rowData.accountStatus == 'Synced') {
                            rowData.provenanceIconNameSync = 'utility:success';
                        } else {
                            rowData.provenanceIconNameSync = 'utility:clear';
                        }
                        return rowData;
                    });

                    //Looping through all the records
                    for (var i = 0; i < records.length; i++) {
                        allAccounts.push(records[i]);
                    }

                    component.set('v.allAccounts', allAccounts);
                    component.set("v.maxPage", Math.floor((records.length + 49) / 50));
                    component.set("v.spinner", false);
                } else {
                    component.set("v.spinner", false);
                }
                
            } else {
                component.set("v.spinner", false);
                var errors = response.getError();
                this.showToastMessage('Something went wrong: ' + errors[0].message + '!', 'Error');
            }
        });
        $A.enqueueAction(action);
    },
    syncSelectedAccounts: function(component, event) {
         var accountList = component.get("v.selectedRecords");
                var action = component.get("c.syncAccountsApxc");
                action.setParams({
                    selectedAccountCol: JSON.stringify(accountList)
                });
                action.setCallback(this, function(response) {
                    if (response.getState() === "SUCCESS") {
                        component.set("v.spinner", false);
                        // if (accountList.length == 1) {
                        //     this.searchAccount(component, event);
                        // } else {
                        //     window.location.reload();
                        // }
                        this.showToastMessage('Account(s) successfully synced! to BC', 'Success');
                    } else {
                        component.set("v.spinner", false);
                        var errors = response.getError();
                        this.showToastMessage('Something went wrong: ' + errors[0].message + '!', 'Error');
                    }
                });
                $A.enqueueAction(action);
    },
    sortData: function(component, fieldName, sortDirection) {
        var accounts = component.get("v.allAccounts");
        
        var key = function(columnName) {
            return columnName[fieldName];
        }
        var reverse = sortDirection == 'asc' ? 1 : -1;
        if (fieldName == 'accountHyperUrl') {
            var key = function(columnName) {
                return columnName['accountName'];
            }
            accounts.sort(function(direction1, direction2) {
                var direction1 = key(direction1) ? key(direction1).toLowerCase() : '';
                var direction2 = key(direction2) ? key(direction2).toLowerCase() : '';
                return reverse * ((direction1 > direction2) - (direction2 > direction1));
            });
        } else {
            accounts.sort(function(direction1, direction2) {
                var direction1 = key(direction1) ? key(direction1).toLowerCase() : '';
                var direction2 = key(direction2) ? key(direction2).toLowerCase() : '';
                return reverse * ((direction1 > direction2) - (direction2 > direction1));
            });
        }
        component.set("v.allAccounts", accounts);
    }
})
