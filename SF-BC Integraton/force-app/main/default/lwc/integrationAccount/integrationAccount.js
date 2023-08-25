//#region import
import { LightningElement, track } from 'lwc';
import EmptyState from '@salesforce/resourceUrl/EmptyState'; //Get a static resource namely EmptyState
import getAllAccountsApxc from '@salesforce/apex/EDAIntegrationController.getAllAccountsApxc';
import getAccessToken from '@salesforce/apex/EDAIntegrationController.getToken';
// import syncAccountsApxcRef from '@salesforce/apex/eBc_AccountController.syncAccountsApxc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
//#endregion

export default class IntegrationAccount extends LightningElement {
//#region Track Variables
@track spinner = false;
@track allAccounts = [];
@track selectedRecords;
@track accountList = [];
@track accountsMap;
@track disableSyncButton = true;
@track recordsCount = 0;
@track isOpenSingleRecord = false;
@track accountDetail;
@track limitReached = false;
@track accessToken;
@track rowLimit = 50;
@track rowOffSet=0;


// Data table variables
@track accountColumns;
@track sortBy;
@track sortDirection;
@track selectedRowsCount = 0;
@track emptyStateResourceURL = EmptyState;
@track error;
@track accountsExist;
//#endregion

connectedCallback() {
    this.accountColumns = [{
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
    }
];
   getAccessToken()
   .then(result => {
     this.accessToken = result;
   })
   .catch(error => {
    console.error('Error occurred:', error);
   });
    this.spinner = true;
    this.getAccountList();
}

loadMoreDataHandler(event) {
    if (!this.limitReached) {
    const { target } = event;
    target.isLoading = true;
    this.rowOffSet = this.rowOffSet + this.rowLimit;
    this.getAccountList(target);
    }   
}

getAccountList(target) {
    var recordsCount = this.recordsCount;
    var allAccounts = this.allAccounts;
    getAllAccountsApxc({ accountsMap: this.accountsMap,limitSize: this.rowLimit , offset : this.rowOffSet})
        .then(result => {
            var records = result.accountsDataList;
            if (records != null && records != undefined && records.length > 0) {
                this.limitReached = false;
                this.accountsExist = true;
                var remainder = Math.floor(records.length / 10);
                var updatedCount = recordsCount + (remainder * 10);
                this.recordsCount = updatedCount;
                this.accountsMap = result.accountsMap;
                if (allAccounts.length != 0) {
                    allAccounts = Object.assign([], allAccounts);
                    for (var i = 0; i < records.length; i++) {
                        allAccounts.push(records[i]);
                    }
                } else {
                    for (var i = 0; i < records.length; i++) {
                        allAccounts.push(records[i]);
                    }
                }
                this.allAccounts = allAccounts;
                this.spinner = false;

            }
            else {
                this.spinner = false;
                this.limitReached = true;
                this.accountsExist = false;
            }

            if (target != undefined){
                target.isLoading = false;
            }

        }).catch(error => {
            console.error('Error occurred:', error);
        });
}

updateSelectedText(event) {
    var selectedRows = event.detail.selectedRows;
    var data = [];
    selectedRows.map(function (rowData) {
        data.push(rowData);
    });
    if (selectedRows.length > 0) {
        this.disableSyncButton = false;
        this.selectedRecords = selectedRows;
    } else {
        this.disableSyncButton = true;
    }
    this.selectedRowsCount = selectedRows.length;
}

syncAccounts() {
    try {
        this.spinner = true;
        this.syncSelectedAccounts();
    } catch (error) {
        console.error('Error occurred:', error);
    }
}

syncSelectedAccounts() {
    var accountList = this.selectedRecords;
    if (accountList.length > 0) {
         if(this.accessToken !=null){
            const dynamicsAPIEndpoint = 'https://api.businesscentral.dynamics.com/v2.0/c5acb22f-8e62-4ace-9283-eb2485c9bc5b/Sandbox/ODataV4/Company(\'CRONUS%20Canada%2C%20Inc.\')/CustomerAPI';
            if (accountList && accountList.length > 0) {
                for (let i = 0; i < accountList.length; i++) {
                    const account = accountList[i];
                    const requestBody = {    
                       "name": account.accountName,
                       "owner": account.accountOwnerName,
                       "accountName":account.accountName,
                       "birthDate":account.birthDate,
                       "ssn":account.SSN,
                       "phoneNo":account.accountPhone,
                       "address":account.accountBillingStreet,
                       "city":account.accountBillingCity, 
                       "createdBy":account.createdOwnerName,
                       "lastModifiedBy": account.lastModifiedOwnerName,
                       "postCode":account.accountBillingPostalCode
                     //"countryRegionCode":account.accountBillingCountry,    
                     //"contact":account.primaryContactId
                   };
              fetch(dynamicsAPIEndpoint, {
                method: 'POST',
                headers: {
                  'Content-Type': 'application/json',
                  'Authorization': this.accessToken,
                },
                body: JSON.stringify(requestBody),
              })
                .then(response => {
                  if (!response.ok) {
                    throw new Error('API request failed.');
                  }
                  return response.json();
                })
                .then(data => {
                  console.log('Response Data:', data);
                  this.showToast('Success!','Account(s) successfully synced to BC', 'success');
                })
                .catch(error => {
                  console.error('Error occurred:', error);
                });
                this.spinner = false;
            }
        }
    }
    } else {
       this.spinner = false;
       this.showToast('Error!','Please select an Account!', 'error');
    }
}

handleSort(event) {
    var sortBy = event.detail.fieldName;
    var sortDirection = event.detail.sortDirection;
    this.sortBy = sortBy;
    this.sortDirection = sortDirection;
    this.sortData(sortBy, sortDirection);
}

sortData(fieldName, sortDirection) {
    var data = JSON.parse(JSON.stringify(this.allAccounts));
    var key = function (a) {
        return a[fieldName];
    }
    var reverse = sortDirection == 'asc' ? 1 : -1;
    if (fieldName == 'accAmount') {
        data.sort(function (a, b) {
            var a = key(a) ? key(a) : '';
            var b = key(b) ? key(b) : '';
            return reverse * ((a > b) - (b > a));
        });
    } else if (fieldName == 'accHyperUrl') {
        var key = function (a) {
            return a['accName'];
        }
        data.sort(function (a, b) {
            var a = key(a) ? key(a).toLowerCase() : '';
            var b = key(b) ? key(b).toLowerCase() : '';
            return reverse * ((a > b) - (b > a));
        });
    } else {
        data.sort(function (a, b) {
            var a = key(a) ? key(a).toLowerCase() : '';
            var b = key(b) ? key(b).toLowerCase() : '';
            return reverse * ((a > b) - (b > a));
        });
    }
    this.allAccounts = data;
}

showToast(message, title, variant) {
    const event = new ShowToastEvent({
        title: title,
        message: message,
        variant: variant
    });
    this.dispatchEvent(event);
}

}