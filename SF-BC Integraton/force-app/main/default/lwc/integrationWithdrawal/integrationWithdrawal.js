import { LightningElement, track } from 'lwc';
import EmptyState from '@salesforce/resourceUrl/EmptyState';
import getAllWithdrawalsApxc from '@salesforce/apex/EDAIntegrationController.getAllWithdrawalsApxc';
import getAccessToken from '@salesforce/apex/EDAIntegrationController.getToken';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const COLUMNS = [

    { label: 'Withdrawal Name', fieldName: 'Name', type: 'text', sortable: true },
    { label: 'Opportunity Name', fieldName: 'opportunityName', type: 'text', sortable: true },
    { label: 'Withdrawn?', fieldName: 'Withdrawan__c', type: 'checkbox', sortable: true },
    { label: 'Registration Fee', fieldName: 'Registration_Fee__c', type: 'currency', sortable: true },
    { label: 'Withdrawal Reason', fieldName: 'Withdrawal_Reason__c', type: 'text', sortable: true },
    { label: 'Withdrawal Effectiev Date', fieldName: 'Withdrawal_Effective_Date__c', type: 'text', sortable: true },
    { label: 'Refundable to NSL', fieldName: 'Refundable_to_NSL__c', type: 'currency', sortable: true },
    { label: 'Funds Payable to Student', fieldName: 'Funds_Payable_by_Student__c', type: 'currency', sortable: true },
    { label: 'Funds Received', fieldName: 'Funds_Received__c', type: 'currency', sortable: true },
    { label: 'Funds Retained', fieldName: 'Funds_Retained__c', type: 'currency', sortable: true }
];

export default class IntegrationWithdrawal extends LightningElement {
//#region Track Variables
@track spinner = false;
@track allWithdrawals = [];
@track selectedRecords;
@track disableSyncButton = true;
@track recordsCount = 0;
@track isOpenSingleRecord = false;
@track limitReached = false;
@track accessToken;
@track rowLimit = 50;
@track rowOffSet = 0;
@track fromDate;
@track toDate;

// Data table variables
@track withdrawalColumns;
@track sortBy;
@track sortDirection;
@track selectedRowsCount = 0;
@track emptyStateResourceURL = EmptyState;
@track error;
@track withdrawalExist = false;
//#endregion

columns = COLUMNS;

connectedCallback() {
//     this.withdrawalColumns = [{
//         label: 'Withdrawal Id',
//         fieldName: 'withdrawalHyperUrl',
//         type: 'url',
//         sortable: true,
//         typeAttributes: {
//             label: {
//                 fieldName: 'name'
//             },
//             target: '_self',
//             tooltip: 'Click to visit opportunity'
//         }
//     },
//     {
//         label: 'Withdrawn?',
//         fieldName: 'withdrawan',
//         type: 'checkbox',
//         sortable: true
//     },
//     {
//         label: 'Created By',
//         fieldName: 'createdByNameId',
//         sortable: true,
//         type: 'url',
//         typeAttributes: {
//             label: {
//                 fieldName: 'createdByName'
//             },
//             target: '_self',
//             tooltip: 'Click to visit owner'
//         }
//     },
//     {
//         label: 'Program Fee',
//         fieldName: 'registrationFee',
//         sortable: true,
//         type: 'currency'
//     },
//     {
//         label: 'Withdrawal Reason',
//         fieldName: 'withdrawalReason',
//         type: 'text',
//         sortable: true,
//     },
//     {
//         label: 'Withdrawal Effectiev Date',
//         fieldName: 'effectiveDate',
//         type: 'text',
//         sortable: true,
//     },
//     {
//         label: 'Refundable to NSL',
//         fieldName: 'refundToNSL',
//         type: 'currency',
//         sortable: true,
//     },
//     {
//         label: 'Funds Payable to Student',
//         fieldName: 'fundsPayToStudent',
//         type: 'currency',
//         sortable: true,
//     },
//     {
//         label: 'Funds Received',
//         fieldName: 'fundsReceived',
//         type: 'currency',
//         sortable: true,
//     },
//     {
//         label: 'Funds Retained',
//         fieldName: 'fundsRetained',
//         type: 'currency',
//         sortable: true,
//     }
    
// ];
   getAccessToken()
   .then(result => {
     this.accessToken = result;
   })
   .catch(error => {
    console.error('Error occurred:', error);
   });
    this.spinner = true;
    this.getAllWithDrawals();
}
getAllWithDrawals(target){
    var recordsCount = this.recordsCount;
    var allWithdrawals = this.allWithdrawals;
    getAllWithdrawalsApxc({limitSize: this.rowLimit , offset : this.rowOffSet})
    .then(records => {
            if (records != null && records != undefined && records.length > 0) {
                this.limitReached = false;
                this.withdrawalExist = true;
                var remainder = Math.floor(records.length / 10);
                var updatedCount = recordsCount + (remainder * 10);
                this.recordsCount = updatedCount;
                if (allWithdrawals.length != 0) {
                    allWithdrawals = Object.assign([], allWithdrawals);
                    for (var i = 0; i < records.length; i++) {
                        const withdrawalRecords = records[i];
                        withdrawalRecords.opportunityName = withdrawalRecords.Opportunity_Contact__r.Name;
                        allWithdrawals.push(records[i]);
                    }
                } else {
                    for (var i = 0; i < records.length; i++) {
                        const withdrawalRecords = records[i];
                        withdrawalRecords.opportunityName = withdrawalRecords.Opportunity_Contact__r.Name;
                        allWithdrawals.push(records[i]);
                    }
                }
                this.allWithdrawals = allWithdrawals;
                this.spinner = false;

            }
            else {
                this.spinner = false;
                this.limitReached = true;
                //this.withdrawalExist = false;
            }
            if (target != undefined){
                target.isLoading = false;
            }

        }).catch(error => {
            console.error('Error occurred:', error);
        });
}
syncWithdrawals(){
    try {
        this.spinner = true;
        this.syncSelectedWithdrawals();
    } catch (error) {
        console.error('Error occurred:', error);
    }
}
syncSelectedWithdrawals(){
 var withdrawalList = Object.assign([], this.selectedRecords);
 var requestBody = [];
 var j = -1;
  for (let i = 0; i < withdrawalList.length; i++) {
   var withdrawalData = withdrawalList[i];
    if(withdrawalData.Opportunity_Contact__r.External_Id__c != null || withdrawalData.Opportunity_Contact__r.External_Id__c != undefined){
      const updatedRequestBody = {
        "withdrawalEffectiveDate": withdrawalData.Withdrawal_Effective_Date__c,
        "withdrawalReason": withdrawalData.Withdrawal_Reason__c,
        "disbursementChecklist": withdrawalData.Disbursement_Schedule__c,
        "feeScheduleStatus": withdrawalData.Fee_Schedule_Status__c,
        "fundsReceived": withdrawalData.Funds_Received__c,
        "lastModifiedBy": withdrawalData.LastModifiedBy.Name,
        "createdBy": withdrawalData.CreatedBy.Name,
        "withdrawanYN": withdrawalData.Withdrawan__c,
        "registrationFee": withdrawalData.Registration_Fee__c,
        "fundsRetained": withdrawalData.Funds_Retained__c,
        "refundabletoNSL": withdrawalData.Refundable_to_NSL__c,
        "fundsPayablebyStudent": withdrawalData.Funds_Payable_by_Student__c 
      };
      requestBody.push(updatedRequestBody);
    const dynamicsAPIEndpoint = 'https://api.businesscentral.dynamics.com/v2.0/Sandbox/api/erpCollege/customerIntegration/v2.0/companies(293ffd01-a87a-eb11-bb54-000d3a2986d1)/customers('+withdrawalData.Opportunity_Contact__r.External_Id__c+')';
    fetch(dynamicsAPIEndpoint, {
       method: 'GET',
       headers: {
         'Content-Type': 'application/json',
         'Authorization': this.accessToken,
       },
     })
       .then(response => {
         if (!response.ok) {
           throw new Error('GET API request failed.');
         }
         return response.json();
       })
       .then(data => {
        j = j+1;
         console.log('Getting Response from GET API:>>> '+ JSON.stringify(data));
         var oDataTag = JSON.stringify(data["@odata.etag"]);
         var extractedData= oDataTag.substring(4, oDataTag.length -3);
         extractedData = extractedData+'"';  
        fetch(dynamicsAPIEndpoint, {
          method: 'PATCH',
          headers: {
            'Content-Type': 'application/json',
            'Authorization': this.accessToken,
            'If-Match': extractedData
          },
          //body: JSON.stringify(updatedRequestBody),
          body: JSON.stringify(requestBody[j]),
        })
          .then(response => {
            if (!response.ok) {
              throw new Error('PATCH API request failed.');
            }
            return response.json();
          })
          .then(data => {
            console.log('Updated data response>>>' + JSON.stringify(data));
            this.spinner = false;
            this.showToast('Success!','Withdrawal(s) is successfully update to BC', 'success');
          })
          .catch(error => {
            console.error('Error occurred:', error);
            this.spinner = false;
          });
       })
       .catch(error => {
         console.error('Error occurred:', error);
         this.spinner = false;
       });
   }else{
    this.spinner = false;
    this.showToast('Error',withdrawalData.Name+ ' related Opportunity is not synced yet', 'warning');
   } 
}     
}
loadMoreDataHandler(event) {
    if (!this.limitReached) {
    const { target } = event;
    target.isLoading = true;
    this.rowOffSet = this.rowOffSet + this.rowLimit;
    this.getAllWithDrawals(target);
    }   
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
handleSort(event) {
    
    this.sortBy = event.detail.fieldName;
    this.sortDirection = event.detail.sortDirection;
    this.sortData();
}
sortData() {
    let fieldName = this.sortBy;
    let sortDirection = this.sortDirection;
    let parseDate = (dateString) => new Date(dateString);

    let reverse = sortDirection !== 'asc';
    let cloneData = JSON.parse(JSON.stringify(this.allWithdrawals));

    cloneData.sort((a, b) => {
      let valueA = a[fieldName];
      let valueB = b[fieldName];

      if (fieldName === 'createdDate' || fieldName === 'lastModifiedDate') {
        valueA = parseDate(valueA);
        valueB = parseDate(valueB);
      }

      let comparison = 0;
      if (valueA > valueB) {
        comparison = 1;
      } else if (valueA < valueB) {
        comparison = -1;
      }

      return reverse ? comparison * -1 : comparison;
    });

    this.allWithdrawals = cloneData;
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