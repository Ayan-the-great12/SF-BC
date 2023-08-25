import { LightningElement, track } from 'lwc';
import EmptyState from '@salesforce/resourceUrl/EmptyState'; //Get a static resource namely EmptyState
import getAllOpportunitiesApxc from '@salesforce/apex/EDAIntegrationController.getAllOpportunitiesApxc';
import getAccessToken from '@salesforce/apex/EDAIntegrationController.getToken';
import updateExternalIdInSalesforce from '@salesforce/apex/EDAIntegrationController.updateCustomerInSalesforce';

import { ShowToastEvent } from 'lightning/platformShowToastEvent';


const COLUMNS = [

    { label: 'Opportunity Name', fieldName: 'Name', type: 'text', sortable: true },
    { label: 'Customer External Id', fieldName: 'External_Id__c', type: 'text', sortable: true },
    { label: 'Vender External Id', fieldName: 'Account_External_Id__c', type: 'text', sortable: true },
    { label: 'Stage', fieldName: 'StageName', type: 'text', sortable: true },
    { label: 'Lead Source', fieldName: 'LeadSource', type: 'text', sortable: true },
    { label: 'Created Date', fieldName: 'CreatedDate', type: 'text', sortable: true },
    { label: 'Close Date', fieldName: 'CloseDate', type: 'text', sortable: true }
];

export default class IntegrationOpportunity extends LightningElement {
//#region Track Variables
@track spinner = false;
@track allOpportunities = [];

@track selectedRecords;
@track accountsMap;
@track oppMap;
@track disableSyncButton = true;
@track recordsCount = 0;
@track isOpenSingleRecord = false;
@track accountDetail;
@track limitReached = false;
@track accessToken;
@track rowLimit = 50;
@track rowOffSet=0;
@track fromDate;
@track toDate;
@track businessCentralCustomers;
@track isChecked = false;
@track venderExternalId;
@track fromDate;
@track toDate;

// Data table variables
@track opportunityColumns;
@track sortBy;
@track sortDirection;
@track selectedRowsCount = 0;
@track emptyStateResourceURL = EmptyState;
@track error;
@track OpportunityExist;
//#endregion

columns = COLUMNS;

connectedCallback() {
//     this.opportunityColumns = [{
//         label: 'Oppoutunity Name',
//         fieldName: 'oppHyperUrl',
//         type: 'url',
//         sortable: true,
//         typeAttributes: {
//             label: {
//                 fieldName: 'oppName'
//             },
//             target: '_self',
//             tooltip: 'Click to visit opportunity'
//         }
//     },
//     {
//         label: 'Account Name',
//         fieldName: 'accountOwnerHyperUrl',
//         type: 'url',
//         sortable: true,
//         typeAttributes: {
//             label: {
//                 fieldName: 'accountName'
//             },
//             target: '_self',
//             tooltip: 'Click to visit account'
//         }
//     },
//     {
//         label: 'Stage',
//         fieldName: 'stageName',
//         sortable: true,
//         type: 'text'
//     },
//     {
//         label: 'Created Date',
//         fieldName: 'createdDate',
//         sortable: true,
//         type: 'text'
//     },
//     {
//         label: 'Owner Full Name',
//         fieldName: 'oppOwnerHyperUrl',
//         type: 'url',
//         sortable: true,
//         typeAttributes: {
//             label: {
//                 fieldName: 'createdOwnerName'
//             },
//             target: '_self',
//             tooltip: 'Click to visit owner'
//         }
//     },
//     {
//         label: 'Last Modified Date',
//         fieldName: 'lastModifiedDate',
//         type: 'text',
//         sortable: true,
//     },
// ];
   getAccessToken()
   .then(result => {
     this.accessToken = result;
   })
   .catch(error => {
    console.error('Error occurred:', error);
   });
    this.spinner = true;
    this.getAllOpportunities();
}

getAllOpportunities(target){
    var recordsCount = this.recordsCount;
    var allOpportunities = this.allOpportunities;
    var checked = this.isChecked;
    getAllOpportunitiesApxc({limitSize: this.rowLimit , offset : this.rowOffSet,checked : checked})
            .then(records => {   
            if (records != null && records != undefined && records.length > 0) {
                this.limitReached = false;
                this.OpportunityExist = true;
                var remainder = Math.floor(records.length / 10);
                var updatedCount = recordsCount + (remainder * 10);
                this.recordsCount = updatedCount;
                if (allOpportunities.length != 0) {
                    allOpportunities = Object.assign([], allOpportunities);
                    for (var i = 0; i < records.length; i++) {
                        allOpportunities.push(records[i]);
                    }
                } else {
                    for (var i = 0; i < records.length; i++) {
                        allOpportunities.push(records[i]);
                    }
                }
                
                this.allOpportunities = allOpportunities;
                this.spinner = false;
            }
            else {
                this.spinner = false;
                this.limitReached = true;
            }

            if (target != undefined){
                target.isLoading = false;
            }

        }).catch(error => {
            console.error('Error occurred:', error);
        });
}

loadMoreDataHandler(event) {
    if (!this.limitReached) {
    const { target } = event;
    target.isLoading = true;
    this.rowOffSet = this.rowOffSet + this.rowLimit;
    this.getAllOpportunities(target);
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

syncOpportunities() {
    try {
        this.spinner = true;
        this.syncSelectedOpportunities();
    } catch (error) {
        console.error('Error occurred:', error);
    }
}

syncSelectedOpportunities() {
   var opportunityList = Object.assign([], this.selectedRecords);
   var opportunityId;
   var requestBody;
    if (opportunityList.length > 0) {
         if(this.accessToken !=null){
            const dynamicsAPIEndpoint = 'https://api.businesscentral.dynamics.com/v2.0/c5acb22f-8e62-4ace-9283-eb2485c9bc5b/Sandbox/ODataV4/Company(\'CRONUS%20Canada%2C%20Inc.\')/CustomerAPI';
            if (opportunityList && opportunityList.length > 0) {
                for (let i = 0; i < opportunityList.length; i++) {
                    const account = opportunityList[i];     
                    if(account.External_Id__c == '' || account.External_Id__c == undefined){
                        this.venderSyncingData(account);
                        if(account.Contact__r != null || account.Contact__r != undefined){
                          if(account.Program_Enrollments__r != null || account.Program_Enrollments__r != undefined){
                            requestBody = {
                              "name": account.Contact__r.Name,
                              "accountName": account.Contact__r.Account.Name,  
                              "birthDate": account.Contact__r.Birthdate,
                              "sfContactOwner": account.Contact__r.Owner.Name,
                              "address": account.Contact__r.MailingStreet,
                              //"address2": "Mainland Newyork",
                              "city": account.Contact__r.MailingCity,
                              "postCode": account.Contact__r.MailingPostalCode,
                              //"countryRegionCode": account.Contact__r.MailingCountry,
                              //"country":account.contactMailingCountry,
                              "eMail": account.Contact__r.hed__AlternateEmail__c,
                              "phoneNo": account.Contact__r.Phone,
                              "mobilePhoneNo":account.Contact__r.MobilePhone,
                              "alternateEmail": account.Contact__r.hed__AlternateEmail__c,
                              "universityEmail": account.Contact__r.hed__UniversityEmail__c,
                              "oppCloseDate": account.CloseDate,
                              "govtStudentID": account.Student_ID__c,
                              "ssn": account.Social_Security_Number__c,
                              "stage": account.StageName,
                              "orientationAttended": account.Orientation_Attended__c,
                              "leadSource":account.LeadSource,
                              "promotion": account.Promotion__c,
                              "studentlocation":account.Location__c,
                              //"peID": account.programEnrollmentName,
                              "admissionDate": account.Program_Enrollments__r[0].hed__Admission_Date__c,
                              "startDate": account.Program_Enrollments__r[0].hed__Start_Date__c,
                              "programName": account.Program_Enrollments__r[0].hed__Account__r.Name,
                              "applicationDate": account.Program_Enrollments__r[0].hed__Application_Submitted_Date__c,
                              "endDate": account.Program_Enrollments__r[0].hed__End_Date__c
                          };
                          }else{
                            requestBody = {
                              "name": account.Contact__r.Name,
                              "accountName": account.Contact__r.Account.Name,  
                              "birthDate": account.Contact__r.Birthdate,
                              "sfContactOwner": account.Contact__r.Owner.Name,
                              "address": account.Contact__r.MailingStreet,
                              //"address2": "Mainland Newyork",
                              "city": account.Contact__r.MailingCity,
                              "postCode": account.Contact__r.MailingPostalCode,
                              //"countryRegionCode": account.Contact__r.MailingCountry,
                              //"country":account.contactMailingCountry,
                              "eMail": account.Contact__r.hed__AlternateEmail__c,
                              "phoneNo": account.Contact__r.Phone,
                              "mobilePhoneNo":account.Contact__r.MobilePhone,
                              "alternateEmail": account.Contact__r.hed__AlternateEmail__c,
                              "universityEmail": account.Contact__r.hed__UniversityEmail__c,
                              "oppCloseDate": account.CloseDate,
                              "govtStudentID": account.Student_ID__c,
                              "ssn": account.Social_Security_Number__c,
                              "stage": account.StageName,
                              "orientationAttended": account.Orientation_Attended__c,
                              "leadSource":account.LeadSource,
                              "promotion": account.Promotion__c,
                              "studentlocation":account.Location__c
                          };
                          }
                        }else{//request body for those Opportunity which have no related contact
                          if(account.Program_Enrollments__r != null || account.Program_Enrollments__r != undefined){
                            requestBody = {
                              "oppCloseDate": account.CloseDate,
                              "govtStudentID": account.Student_ID__c,
                              "ssn": account.Social_Security_Number__c,
                              "stage": account.StageName,
                              "orientationAttended": account.Orientation_Attended__c,
                              "leadSource":account.LeadSource,
                              "promotion": account.Promotion__c,
                              "studentlocation":account.Location__c,
                              //"peID": account.programEnrollmentName,
                              "admissionDate": account.Program_Enrollments__r[0].hed__Admission_Date__c,
                              "startDate": account.Program_Enrollments__r[0].hed__Start_Date__c,
                              "programName": account.Program_Enrollments__r[0].hed__Account__r.Name,
                              "applicationDate": account.Program_Enrollments__r[0].hed__Application_Submitted_Date__c,
                              "endDate": account.Program_Enrollments__r[0].hed__End_Date__c
                            };
                          }else{
                            requestBody = {
                              "oppCloseDate": account.CloseDate,
                              "govtStudentID": account.Student_ID__c,
                              "ssn": account.Social_Security_Number__c,
                              "stage": account.StageName,
                              "orientationAttended": account.Orientation_Attended__c,
                              "leadSource":account.LeadSource,
                              "promotion": account.Promotion__c,
                              "studentlocation":account.Location__c
                            };
                          }
                        }
                        fetch(dynamicsAPIEndpoint, {
                            method: 'POST',
                            headers: {
                              'Content-Type': 'application/json',
                              'Authorization': this.accessToken
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
                              console.log('Response Data:'+ JSON.stringify(data));
                              opportunityId =  account.Id;
                              this.updateCustomerInSalesforce(opportunityId,data.systemId,this.venderExternalId);
                            })
                            .catch(error => {
                              console.error('Error occurred:', error);
                            });
                            this.spinner = false;
                    }else{
                        this.spinner = false;
                        this.showToast('','The Opportunity '+ account.Name + ' is already Synced', 'warning');
                    }
                }
            }
        }
    } else {
       this.spinner = false;
       this.showToast('Error!','Please select an Account!', 'error');
    }
}

venderSyncingData(account){
    const dynamicsAPIEndpointForVender = 'https://api.businesscentral.dynamics.com/v2.0/c5acb22f-8e62-4ace-9283-eb2485c9bc5b/Sandbox/ODataV4/Company(\'CRONUS%20Canada%2C%20Inc.\')/VendorAPI';
    const requestBody = {
        "name": account.Account.Name,
        //"contact": "Agnes Milagros Caymo",
        "address": account.Account.BillingStreet,
        "city": account.Account.BillingCity,
        "postCode": account.Account.BillingPostalCode,
        "phoneNo": account.Account.Phone,
        "sFAccountOwner": account.Account.Owner.Name,
        "bNNo": account.Account.SSN__c
    }
    fetch(dynamicsAPIEndpointForVender, {
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
          console.log('Response Data:'+ JSON.stringify(data));
          this.venderExternalId = data.systemId;
          
        })
        .catch(error => {
          console.error('Error occurred:', error);
        });
}

updateCustomerInSalesforce(syncedCustomersId,syncedCustomerExternalId,venderExternalId){
    updateExternalIdInSalesforce({ opportunityId: syncedCustomersId, externalId : syncedCustomerExternalId,venderExternalId: venderExternalId})
    .then(result => {
        this.showToast('Success!','Opportunity(s) successfully synced to BC', 'success');
        setTimeout(() => {
          window.location.reload();
        }, 3000);
    }).catch(error => {
        console.error('Error occurred:', error);
    });
}

updatedOpportunities(){
  var opportunityList = Object.assign([], this.selectedRecords);
  var updatedRequestBody;
  var objectArray = [];
  var j = -1;
  for (let i = 0; i < opportunityList.length; i++) {
    var oppData = opportunityList[i];
    this.venderUpdatingData(oppData);
    if(oppData.Contact__r != null || oppData.Contact__r != undefined){
      updatedRequestBody = {
        "name": oppData.Contact__r.Name,
        "accountName": oppData.Contact__r.Account.Name,
        "birthDate": oppData.Contact__r.Birthdate,
        "sfContactOwner": oppData.Contact__r.Owner.Name,
        "address": oppData.Contact__r.MailingStreet,
        //"address2": "Mainland Newyork",
        "city": oppData.Contact__r.MailingCity,
        "postCode": oppData.Contact__r.MailingPostalCode,
        //"countryRegionCode": oppData.Contact__r.MailingCountry,
        //"country":oppData.contactMailingCountry,
        "eMail": oppData.Contact__r.hed__AlternateEmail__c,
        "phoneNo": oppData.Contact__r.Phone,
        "mobilePhoneNo":oppData.Contact__r.MobilePhone,
        "alternateEmail": oppData.Contact__r.hed__AlternateEmail__c,
        "universityEmail": oppData.Contact__r.hed__UniversityEmail__c,
        "oppCloseDate": oppData.CloseDate,
        "govtStudentID": oppData.Student_ID__c,
        "ssn": oppData.Social_Security_Number__c,
        "stage": oppData.StageName,
        "orientationAttended": oppData.Orientation_Attended__c,
        "leadSource":oppData.LeadSource,
        "promotion": oppData.Promotion__c,
        "studentlocation":oppData.Location__c,
        //"peID": oppData.programEnrollmentName,
        "admissionDate": oppData.Program_Enrollments__r[0].hed__Admission_Date__c,
        "startDate": oppData.Program_Enrollments__r[0].hed__Start_Date__c,
        "programName": oppData.Program_Enrollments__r[0].hed__Account__r.Name,
        "applicationDate": oppData.Program_Enrollments__r[0].hed__Application_Submitted_Date__c,
        "endDate": oppData.Program_Enrollments__r[0].hed__End_Date__c

        //"cost":oppData.amount
        // "withdrawalEffectiveDate": "0001-01-01",
        // "withdrawalReason": "",
        // "disbursementChecklist": "",
        // "feeScheduleStatus": "",
        // "fundsReceived": 0,
        // "lastModifiedBy": "",
        // "createdBy": "",
        // "withdrawanYN": true,
        // "registrationFee": 110,
        // "fundsRetained": 100,
        // "refundabletoNSL": 50,
        // "fundsPayablebyStudent": 200 
      };
    }else{
      updatedRequestBody = {
        "oppCloseDate": oppData.CloseDate,
        "govtStudentID": oppData.Student_ID__c,
        "ssn": oppData.Social_Security_Number__c,
        "stage": oppData.StageName,
        "orientationAttended": oppData.Orientation_Attended__c,
        "leadSource":oppData.LeadSource,
        "promotion": oppData.Promotion__c,
        "studentlocation":oppData.Location__c,
        //"peID": oppData.programEnrollmentName,
        "admissionDate": oppData.Program_Enrollments__r[0].hed__Admission_Date__c,
        "startDate": oppData.Program_Enrollments__r[0].hed__Start_Date__c,
        "programName": oppData.Program_Enrollments__r[0].hed__Account__r.Name,
        "applicationDate": oppData.Program_Enrollments__r[0].hed__Application_Submitted_Date__c,
        "endDate": oppData.Program_Enrollments__r[0].hed__End_Date__c

        //"cost":oppData.amount
        // "withdrawalEffectiveDate": "0001-01-01",
        // "withdrawalReason": "",
        // "disbursementChecklist": "",
        // "feeScheduleStatus": "",
        // "fundsReceived": 0,
        // "lastModifiedBy": "",
        // "createdBy": "",
        // "withdrawanYN": true,
        // "registrationFee": 110,
        // "fundsRetained": 100,
        // "refundabletoNSL": 50,
        // "fundsPayablebyStudent": 200 
      };
    }
    objectArray.push(updatedRequestBody);
    const dynamicsAPIEndpoint = 'https://api.businesscentral.dynamics.com/v2.0/Sandbox/api/erpCollege/customerIntegration/v2.0/companies(293ffd01-a87a-eb11-bb54-000d3a2986d1)/customers('+oppData.External_Id__c+')';
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
          body: JSON.stringify(objectArray[j])
        })
          .then(response => {
            if (!response.ok) {
              throw new Error('PATCH API request failed.');
            }
            return response.json();
          })
          .then(data => {
            console.log('Updated data response>>>' + JSON.stringify(data));
            this.showToast('Success!','Opportunity(s) along with related data successfully update to BC', 'success');
          })
          .catch(error => {
            console.error('Error occurred:', error);
          });
       })
       .catch(error => {
         console.error('Error occurred:', error);
       });
  }     
}

venderUpdatingData(account){
  const requestBody = {
    "name": account.Account.Name,
    //"contact": "Agnes Milagros Caymo",
    "address": account.Account.BillingStreet,
    "city": account.Account.BillingCity,
    "postCode": account.Account.BillingPostalCode,
    "phoneNo": account.Account.Phone,
    "sFAccountOwner": account.Account.Owner.Name,
    "bNNo": account.Account.SSN__c
}
const dynamicsAPIEndpoint = 'https://api.businesscentral.dynamics.com/v2.0/Sandbox/api/erpCollege/vendorIntegration/v2.0/companies(293ffd01-a87a-eb11-bb54-000d3a2986d1)/vendors('+account.Account_External_Id__c+')';
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
        //j = j+1;
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
          body: JSON.stringify(requestBody)
        })
          .then(response => {
            if (!response.ok) {
              throw new Error('PATCH API request failed.');
            }
            return response.json();
          })
          .then(data => {
            console.log('Updated data response>>>' + JSON.stringify(data));
            //this.showToast('Success!','Opportunity(s) along with related data successfully update to BC', 'success');
          })
          .catch(error => {
            console.error('Error occurred:', error);
          });
       })
       .catch(error => {
        console.error('Error occurred:', error);
       });
}

filterData(event){
  if(event.target.name == 'fromDate'){
    this.fromDate = event.target.value;
  }else{
    this.toDate = event.target.value;
  }
  if(this.fromDate != null && this.toDate){

  }
}

filterDataOnExternalId(event){
    this.isChecked = event.target.checked;
    this.allOpportunities = [];
    this.recordsCount = 0;
    this.rowLimit = 50;
    this.rowOffSet = 0;
    this.OpportunityExist = false;
    this.disableSyncButton = true;
    this.selectedRecords = [];
    this.spinner = true;
    this.getAllOpportunities();
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
    let cloneData = JSON.parse(JSON.stringify(this.allOpportunities));

    cloneData.sort((a, b) => {
      let valueA = a[fieldName];
      let valueB = b[fieldName];

      if (fieldName === 'CreatedDate' || fieldName === 'CloseDate') {
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
    this.allOpportunities = cloneData;
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