public with sharing class EDAIntegrationController {
    
    // @AuraEnabled
    // public static AccountsDataWrapper getAllAccountsApxc(Map<String, String> accountsMap,Integer limitSize, Integer offset) {
    //     DML dml = new DML();
    //     AccountsDataWrapper reciprocate = getAllAccountsApxc(accountsMap,limitSize,offset,dml);
    //     return reciprocate;
    // }
    @AuraEnabled
    public static void updateCustomerInSalesforce(String opportunityId,String externalId,String venderExternalId){
        DML dml = new DML();
        try{
            if(opportunityId != null){
                String querySelect = Configuration.EMPTYSTRING; 
                String queryFrom = Configuration.EMPTYSTRING;
                String queryWhere = Configuration.EMPTYSTRING;
                querySelect = 'select id,External_Id__c,Account_External_Id__c';
                queryfrom = 'from Opportunity';
                queryWhere =  ' WHERE Id = \'' + opportunityId + '\'';
                Opportunity opportunityNeedToBeUpdated =  (Opportunity)dml.selectSingleRecord(querySelect,queryfrom,queryWhere,Configuration.EMPTYSTRING,Configuration.EMPTYSTRING);
                if(opportunityNeedToBeUpdated != null && externalId != null && venderExternalId != null){
                    opportunityNeedToBeUpdated.External_Id__c = externalId;
                    opportunityNeedToBeUpdated.Account_External_Id__c = venderExternalId;
                }
                dml.updateRecord(opportunityNeedToBeUpdated);
            }
        }catch(Exception e){
            throw new AuraHandledException('Error' + e.getMessage());
        }
    }
    @AuraEnabled
    public static String getToken(){
        String client = '74854b7d-f38b-41fc-b8de-5f708e672a11';
        String secret = '3ta8Q~GxkXesKv8sik7cyjezkyQCdzpQVtUrgbMB';
        String tenant = 'c5acb22f-8e62-4ace-9283-eb2485c9bc5b';
        String URL = 'https://login.microsoftonline.com/c5acb22f-8e62-4ace-9283-eb2485c9bc5b/oauth2/v2.0/token';
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(URL);
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        String body = 'grant_type=client_credentials' +
            '&scope=https://api.businesscentral.dynamics.com/.default' +
            '&client_id=' + EncodingUtil.urlEncode(client, 'UTF-8') +
            '&client_secret=' + EncodingUtil.urlEncode(secret, 'UTF-8');
        request.setBody(body); 
        HttpResponse response = http.send(request);
        String bearerToken;
        if (response.getStatusCode() == 200) {
            Map<String, Object> jsonResponse = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
             bearerToken = 'Bearer '+(String)jsonResponse.get('access_token');
        }else{
            bearerToken = '';
        }
        return bearerToken;
    }
   @AuraEnabled
   public static list<Opportunity> getAllOpportunitiesApxc(Integer limitSize, Integer offset, Boolean checked){
    if(checked){
        return [select id,LeadSource,AccountId,OwnerId,Owner.Name,CreatedBy.Name,Name,LastModifiedDate,External_Id__c,Account_External_Id__c,StageName,Location__c,Social_Security_Number__c,Student_ID__c,CloseDate,Amount, Orientation_Attended__c, Lead_Name__c, Promotion__c,CreatedDate,Contact__r.Account.Name, Contact__r.Name,Contact__r.Birthdate,Contact__r.Phone, Contact__r.MobilePhone,Contact__r.hed__AlternateEmail__c,Contact__r.Student_ID__c, Contact__r.hed__Social_Security_Number__c,Withdrawan__c,Contact__r.hed__UniversityEmail__c, Contact__r.Owner.Name,Contact__r.MailingStreet, Contact__r.MailingCity, Contact__r.MailingCountry, Contact__r.MailingPostalCode,Account.Name,Account.Phone,Account.hed__Primary_Contact__r.Name,Account.Owner.Name, Account.SSN__c, Account.BillingCity, Account.BillingCountry, Account.BillingPostalCode,Account.BillingStreet,(select id,hed__Admission_Date__c, hed__Start_Date__c, hed__End_Date__c, hed__Account__r.Name,hed__Application_Submitted_Date__c, hed__Graduation_Year__c from Program_Enrollments__r) from Opportunity WHERE StageName = 'Closed - Approved' AND External_Id__c != '' AND Withdrawan__c = false Order by Name  limit :limitSize offset :offset]; 
    }else{
        return [select id,LeadSource,AccountId,OwnerId,Owner.Name,CreatedBy.Name,Name,LastModifiedDate,External_Id__c,Account_External_Id__c,StageName,Location__c,Social_Security_Number__c,Student_ID__c,CloseDate,Amount, Orientation_Attended__c, Lead_Name__c, Promotion__c,CreatedDate,Contact__r.Account.Name, Contact__r.Name,Contact__r.Birthdate,Contact__r.Phone, Contact__r.MobilePhone,Contact__r.hed__AlternateEmail__c,Contact__r.Student_ID__c, Contact__r.hed__Social_Security_Number__c,Withdrawan__c,Contact__r.hed__UniversityEmail__c, Contact__r.Owner.Name,Contact__r.MailingStreet, Contact__r.MailingCity, Contact__r.MailingCountry, Contact__r.MailingPostalCode,Account.Name,Account.Phone,Account.hed__Primary_Contact__r.Name,Account.Owner.Name, Account.SSN__c, Account.BillingCity, Account.BillingCountry, Account.BillingPostalCode,Account.BillingStreet,(select id,hed__Admission_Date__c, hed__Start_Date__c, hed__End_Date__c, hed__Account__r.Name,hed__Application_Submitted_Date__c, hed__Graduation_Year__c from Program_Enrollments__r) from Opportunity WHERE StageName = 'Closed - Approved' AND External_Id__c = '' AND Withdrawan__c = false Order by Name  limit :limitSize offset :offset]; 
    }
   }
   @AuraEnabled
   public static list<Withdrawal__c> getAllWithdrawalsApxc(Integer limitSize, Integer offset){
    return [select id,Opportunity_Contact__c,Opportunity_Contact__r.External_Id__c,Opportunity_Contact__r.Account_External_Id__c,Opportunity_Contact__r.Name,name,Withdrawal_Effective_Date__c, Withdrawal_Reason__c, Disbursement_Schedule__c,LastModifiedBy.Name,CreatedById ,CreatedBy.Name, Withdrawan__c, Registration_Fee__c, Funds_Retained__c,CreatedDate,Fee_Schedule_Status__c, Funds_Received__c, Refundable_to_NSL__c, Funds_Payable_by_Student__c,LastModifiedDate from Withdrawal__c where Withdrawan__c = true Order by Name limit :limitSize offset :offset];
   }
   
    // @AuraEnabled
    // public static WithdrawalsDataWrapper getAllWithdrawalsApxc(Map<String, String> mapData,Integer limitSize, Integer offset) {
    //     DML dml = new DML();
    //     WithdrawalsDataWrapper reciprocate = getAllWithdrawalsApxc(mapData,limitSize,offset,dml);
    //     return reciprocate;
    // }
    // public static WithdrawalsDataWrapper getAllWithdrawalsApxc(Map<String, String> mapData,Integer limitSize, Integer offset,DML dml) {
    //     String querySelect = Configuration.EMPTYSTRING; 
    //     String queryFrom = Configuration.EMPTYSTRING;
    //     String queryOrderby = Configuration.EMPTYSTRING;
    //     String queryLimit = Configuration.EMPTYSTRING;
    //     String queryWhere = Configuration.EMPTYSTRING;
    //     String queryOffset = Configuration.EMPTYSTRING;
    //     WithdrawalsDataWrapper oppDataWrapper = new WithdrawalsDataWrapper();
    //     List<WithdrawalWrapper> oppsWrapper = new List<WithdrawalWrapper> ();
    //     List<Withdrawal__c > opportunities = new List<Withdrawal__c > ();
    //     if (mapData == null) {
    //         mapData = new Map<String, String>(); 
    //     }
    //     try {
    //         querySelect = 'select id,name,Withdrawal_Effective_Date__c, Withdrawal_Reason__c, Disbursement_Schedule__c,'+
    //         'LastModifiedBy.Name,CreatedById ,CreatedBy.Name, Withdrawan__c, Registration_Fee__c, Funds_Retained__c,CreatedDate,'+
    //         'Fee_Schedule_Status__c, Funds_Received__c, Refundable_to_NSL__c, Funds_Payable_by_Student__c,LastModifiedDate';
    //         queryfrom = 'from Withdrawal__c';
    //         queryWhere = 'where Withdrawan__c = true';
    //         queryOrderby = 'Order by CreatedDate DESC';
    //         queryLimit = 'limit ' + String.valueOf(limitSize);
    //         queryOffset = 'offset ' + offset; 
    //         opportunities = (List<Withdrawal__c >) dml.selectRecords( querySelect, queryFrom, queryWhere, Configuration.EMPTYSTRING, queryOrderby, queryLimit,queryOffset);
    //         for (Withdrawal__c  opportunity: opportunities) {
    //             if (!mapData.containsKey(opportunity.id)) {
    //                 mapData.put(opportunity.id, opportunity.id);
    //                 WithdrawalWrapper oppWrapper = new WithdrawalWrapper();   
    //                 oppWrapper.withdrawalHyperUrl = '/' + opportunity.Id;
    //                 oppWrapper.name = opportunity.name;
    //                 oppWrapper.withdrawalId = opportunity.Id;
    //                 oppWrapper.effectiveDate = opportunity.Withdrawal_Effective_Date__c;
    //                 oppWrapper.withdrawalReason = opportunity.Withdrawal_Reason__c;
    //                 oppWrapper.disbursementSchedule = opportunity.Disbursement_Schedule__c;
    //                 oppWrapper.lastModifiedName =  opportunity.LastModifiedBy.Name;
    //                 oppWrapper.createdByName = opportunity.CreatedBy.Name;
    //                 oppWrapper.createdByNameId = '/' + opportunity.CreatedById;
    //                 oppWrapper.withdrawan = opportunity.Withdrawan__c;
    //                 oppWrapper.registrationFee = opportunity.Registration_Fee__c;
    //                 oppWrapper.fundsRetained = opportunity.Funds_Retained__c;
    //                 oppWrapper.feeScheduleStatus = opportunity.Fee_Schedule_Status__c;
    //                 oppWrapper.fundsReceived = opportunity.Funds_Received__c;
    //                 oppWrapper.refundToNSL = opportunity.Refundable_to_NSL__c;
    //                 oppWrapper.fundsPayToStudent = opportunity.Funds_Payable_by_Student__c;
    //                 oppWrapper.createdDate = opportunity.CreatedDate;
    //                 oppWrapper.lastModifiedDate = opportunity.LastModifiedDate;
    //                 oppsWrapper.add(oppWrapper);
    //             }
    //         }
    //     } catch (Exception ex) {
    //         throw new AuraHandledException(Configuration.EXCEPTIONSTRING + ex.getMessage());
    //     }
    //     oppDataWrapper.withdrawalsDataList = oppsWrapper;
    //     oppDataWrapper.withdrawalMap = mapData;
    //     return oppDataWrapper;
    // }
    // @AuraEnabled
    // public static void syncAccountsApxc(String selectedAccountCol) {
    //     syncAccountsApxcV2(selectedAccountCol);
    // }   
    // public static void syncAccountsApxcV2(String accountsWrapper) {
    //     // Map<String, Object> accountMap = (Map<String, Object>) JSON.deserializeUntyped(accountsWrapper);
    //     // Map<String, Object> dynamicsAccountMap = new Map<String, Object>();
    //     //  // Map the Salesforce account fields to the corresponding Dynamics account fields
    //     //  dynamicsAccountMap.put('Name', accountMap.get('Name'));
    //     //  dynamicsAccountMap.put('Phone No.', accountMap.get('Phone'));
    //     //String dynamicsAPIEndpoint = 'https://api.businesscentral.dynamics.com/v2.0/c5acb22f-8e62-4ace-9283-eb2485c9bc5b/Sandbox/WS/CRONUS%20Canada%2C%20Inc./Page/CustomerAPI';
    //     // String dynamicsAPIEndpoint = 'https://api.businesscentral.dynamics.com/v2.0/c5acb22f-8e62-4ace-9283-eb2485c9bc5b/Sandbox/ODataV4/Company(\'CRONUS%20Canada%2C%20Inc.\')/CustomerAPI';
    //     // String authHeader = 'Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsIng1dCI6Ii1LSTNROW5OUjdiUm9meG1lWm9YcWJIWkdldyIsImtpZCI6Ii1LSTNROW5OUjdiUm9meG1lWm9YcWJIWkdldyJ9.eyJhdWQiOiJodHRwczovL2FwaS5idXNpbmVzc2NlbnRyYWwuZHluYW1pY3MuY29tIiwiaXNzIjoiaHR0cHM6Ly9zdHMud2luZG93cy5uZXQvYzVhY2IyMmYtOGU2Mi00YWNlLTkyODMtZWIyNDg1YzliYzViLyIsImlhdCI6MTY4NDE0MzQ2OSwibmJmIjoxNjg0MTQzNDY5LCJleHAiOjE2ODQxNDczNjksImFpbyI6IkUyWmdZUGkrUEhqZXluMmZFdFkrVE96YlUzL1dGQUE9IiwiYXBwaWQiOiI3NDg1NGI3ZC1mMzhiLTQxZmMtYjhkZS01ZjcwOGU2NzJhMTEiLCJhcHBpZGFjciI6IjEiLCJpZHAiOiJodHRwczovL3N0cy53aW5kb3dzLm5ldC9jNWFjYjIyZi04ZTYyLTRhY2UtOTI4My1lYjI0ODVjOWJjNWIvIiwiaWR0eXAiOiJhcHAiLCJvaWQiOiIwMDMzODJmMi1hYzJjLTRjMzgtOWRhNC0xMzU3N2Q1YmFmZGIiLCJyaCI6IjAuQVJnQUw3S3N4V0tPemtxU2ctc2toY204V3ozdmJabHNzMU5CaGdlbV9Ud0J1SjhZQUFBLiIsInJvbGVzIjpbIkF1dG9tYXRpb24uUmVhZFdyaXRlLkFsbCIsImFwcF9hY2Nlc3MiLCJBZG1pbkNlbnRlci5SZWFkV3JpdGUuQWxsIiwiQVBJLlJlYWRXcml0ZS5BbGwiXSwic3ViIjoiMDAzMzgyZjItYWMyYy00YzM4LTlkYTQtMTM1NzdkNWJhZmRiIiwidGlkIjoiYzVhY2IyMmYtOGU2Mi00YWNlLTkyODMtZWIyNDg1YzliYzViIiwidXRpIjoidnp0dlBfYWVGa21kalB5YnNqMDVBQSIsInZlciI6IjEuMCJ9.nKxBKfui0GiRU4yiDSVwpz1W6a929gN9LZ5a7vlIzcreYQJ6Bcbwjd5hQfQBSAcmAXYukDvifYvzux0dp14kCGJD1LqkeqbYn01tLuJ4rcU55MMesB45nLpPtRECmm952AFehG8QoyuWkE90II9CshNY0AFyt6b7r3NCeEmoSFSIt0nu3XafFbu15Qjm4VJaiCL-VqW-RC6-uEatTentDyQ-0RL3H9gaR0JqSu4m1nG9B7pTPUm3d-FaG9yw2YK06MYudbmNKlrZrHvDE9y2-yEN7W_uKKADL-9kWxwpHVck1S_BjEU1NphUzs-KFQ1piEftxsDDpg5P1jA6laKzkQ';
    //     // Http http = new Http();
    //     // HttpRequest req = new HttpRequest();
    //     // req.setEndpoint(dynamicsAPIEndpoint);
    //     // //req.setHeader('Content-Type','application/json;charset=UTF-8');
    //     // req.setHeader('Cache-Control','no-cache');
    //     // req.setHeader('Authorization', authHeader);
    //     // req.setMethod('GET');
    //     // //req.setBody(JSON.serialize(dynamicsAccountMap));
    //     // HTTPResponse res = http.send(req);
    //     // System.debug('HTTP Response>>>>>' + res.getBody());
    //     //String dynamicsAPIEndpoint =  'https://api.businesscentral.dynamics.com/v2.0/c5acb22f-8e62-4ace-9283-eb2485c9bc5b/Sandbox/ODataV4/Company("CRONUS%20Canada%2C%20Inc.')/CustomerAPI(93799638-3ecd-eb11-9f0a-000d3ae88a79)';
        
        
    //     //String authHeader = getToken();
    //     String authHeader = 'Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsIng1dCI6Ii1LSTNROW5OUjdiUm9meG1lWm9YcWJIWkdldyIsImtpZCI6Ii1LSTNROW5OUjdiUm9meG1lWm9YcWJIWkdldyJ9.eyJhdWQiOiJodHRwczovL2FwaS5idXNpbmVzc2NlbnRyYWwuZHluYW1pY3MuY29tIiwiaXNzIjoiaHR0cHM6Ly9zdHMud2luZG93cy5uZXQvYzVhY2IyMmYtOGU2Mi00YWNlLTkyODMtZWIyNDg1YzliYzViLyIsImlhdCI6MTY4NDQwODAyNSwibmJmIjoxNjg0NDA4MDI1LCJleHAiOjE2ODQ0MTE5MjUsImFpbyI6IkUyWmdZRERNVElndy9McnNUMEkwVS9GekRpVjJBQT09IiwiYXBwaWQiOiI3NDg1NGI3ZC1mMzhiLTQxZmMtYjhkZS01ZjcwOGU2NzJhMTEiLCJhcHBpZGFjciI6IjEiLCJpZHAiOiJodHRwczovL3N0cy53aW5kb3dzLm5ldC9jNWFjYjIyZi04ZTYyLTRhY2UtOTI4My1lYjI0ODVjOWJjNWIvIiwiaWR0eXAiOiJhcHAiLCJvaWQiOiIwMDMzODJmMi1hYzJjLTRjMzgtOWRhNC0xMzU3N2Q1YmFmZGIiLCJyaCI6IjAuQVJnQUw3S3N4V0tPemtxU2ctc2toY204V3ozdmJabHNzMU5CaGdlbV9Ud0J1SjhZQUFBLiIsInJvbGVzIjpbIkF1dG9tYXRpb24uUmVhZFdyaXRlLkFsbCIsImFwcF9hY2Nlc3MiLCJBZG1pbkNlbnRlci5SZWFkV3JpdGUuQWxsIiwiQVBJLlJlYWRXcml0ZS5BbGwiXSwic3ViIjoiMDAzMzgyZjItYWMyYy00YzM4LTlkYTQtMTM1NzdkNWJhZmRiIiwidGlkIjoiYzVhY2IyMmYtOGU2Mi00YWNlLTkyODMtZWIyNDg1YzliYzViIiwidXRpIjoicXdXRXJEV3NpMEcyREtsakczU1VBQSIsInZlciI6IjEuMCJ9.dKPMb63UulsvRGa2BV_LD_zF3PnV1zdd6kfUrAAe-Jn1XokO8SngLmOunJmQN6N2DvfRqEqqCw0TbHVw2n6_J4AHQadmxEW_zX8q16XOyCxrTKqFQTSOS4E6TGMegWjqNaCgJbN7AohPA7kjQZhGzu1KLZmhQCSuCYmFmW4A9gKa9yVSLBJLB6vkVDzpygT9AwzuBfSLO4sg6EwvB-OdI6HRdqFXQobhEMgwsxulp6Fm48F4fFTNlJ7AwDE8QhuaFRD7qc0NFAh5_xgRg_uFF7nlVbJyrjxZnc_-zg6gidae0FMsa2vZSevbY_J1yHr5xa0MmZxz6lizqG4ACXEYCQ';
    //     System.debug('Access Token>>>>>' + authHeader);       
    //     string URL2 = 'https://api.businesscentral.dynamics.com/v2.0/c5acb22f-8e62-4ace-9283-eb2485c9bc5b/Sandbox/ODataV4/Company(\'CRONUS%20Canada%2C%20Inc.\')/CustomerAPI';
    //     Http http = new Http();
    //     HttpRequest request = new HttpRequest();
    //     request.setEndpoint(URL2);
    //     request.setMethod('GET');
    //     request.setHeader('Authorization', authHeader); 
    //     //request.setHeader('Host', 'api.businesscentral.dynamics.com');
    //     HttpResponse response = http.send(request);
    //     System.debug('HTTP Response>>>>>' + response.getBody());
    // }

    // public static AccountsDataWrapper getAllAccountsApxc(Map<String, String> accountsMap,Integer limitSize, Integer offset,DML dml) {

    //     String querySelect = Configuration.EMPTYSTRING; 
    //     String queryFrom = Configuration.EMPTYSTRING;
    //     String queryOrderby = Configuration.EMPTYSTRING;
    //     String queryLimit = Configuration.EMPTYSTRING;
    //     String queryWhere = Configuration.EMPTYSTRING;
    //     String queryOffset = Configuration.EMPTYSTRING;
    //     AccountsDataWrapper accountsDataWrapper = new AccountsDataWrapper();
    //     List<AccountWrapper> accountsWrapper = new List<AccountWrapper> ();
    //     List<Account> accounts = new List<Account> ();

    //     if (accountsMap == null) {
    //         accountsMap = new Map<String, String>(); 
    //     }
        
    //     try {
    //         querySelect = 'SELECT Id,Name,Phone,hed__Primary_Contact__c,hed__Primary_Contact__r.Name,OwnerId,Owner.Name,SSN__c,ParentId,Parent.Name,RecordTypeId,RecordType.Name,Lead_Name__c,Description,Type,Class_Year_from_PE__c,CreatedById,CreatedBy.Name,'+
    //         'BirthDate_from_contact__c,LastModifiedById,LastModifiedBy.Name,BillingAddress, BillingStreet, BillingPostalCode, BillingCity, BillingCountry, BillingState,'+
    //         'ShippingAddress,ShippingCity, ShippingState, ShippingStreet, ShippingPostalCode, ShippingCountry';
    //         queryfrom = 'FROM Account';
    //         queryOrderby = 'Order by CreatedDate DESC';
    //         queryLimit = 'limit ' + String.valueOf(limitSize);
    //         queryOffset = 'offset ' + offset; 
    //         accounts = (List<Account>) dml.selectRecordsInList(new List<String> (accountsMap.keySet()), querySelect, queryFrom, queryWhere, Configuration.EMPTYSTRING, queryOrderby, queryLimit,queryOffset);
    //         for (Account account: accounts) {
    //             if (!accountsMap.containsKey(account.id)) {
    //                 accountsMap.put(account.id, account.id);
    //                 AccountWrapper accountWrapper = new AccountWrapper();   
    //                 accountWrapper.accountHyperUrl = '/' + account.Id;
    //                 accountWrapper.accountId = account.Id;
    //                 accountWrapper.accountName = account.Name;
    //                 accountWrapper.SSN = account.SSN__c;
    //                 accountWrapper.classYear = account.Class_Year_from_PE__c;
    //                 accountWrapper.accountOwnerId = account.OwnerId;
    //                 accountWrapper.accountOwnerName = account.Owner.Name;
    //                 accountWrapper.accountOwnerHyperUrl = '/' + account.OwnerId;
    //                 accountWrapper.Description = account.Description;
    //                 accountWrapper.leadName = account.Lead_Name__c;
    //                 accountWrapper.Type = account.Type;
    //                 accountWrapper.recordTypeId = account.RecordTypeId;
    //                 accountWrapper.recordTypeName = account.RecordType.Name;
    //                 accountWrapper.parentId = account.ParentId;
    //                 accountWrapper.parentName = account.Parent.Name;
    //                 accountWrapper.createdId = '/' + account.CreatedById;
    //                 accountWrapper.createdOwnerName = account.CreatedBy.Name;
    //                 accountWrapper.lastModifiedId = account.LastModifiedById;
    //                 accountWrapper.lastModifiedOwnerName = account.LastModifiedBy.Name;
    //                 accountWrapper.primaryContactId = account.hed__Primary_Contact__c;
    //                 accountWrapper.primaryContactName = account.hed__Primary_Contact__r.Name;
    //                 if(account.hed__Primary_Contact__c != null){
    //                     accountWrapper.contactHyperUrl = '/' + account.hed__Primary_Contact__c;
    //                 }else{
    //                     accountWrapper.contactHyperUrl = '';
    //                 }
    //                 accountWrapper.accountPhone = account.Phone;
    //                 accountWrapper.accountBillingStreet = account.BillingStreet;
    //                 accountWrapper.accountBillingCity = account.BillingCity;
    //                 accountWrapper.accountBillingPostalCode = account.BillingPostalCode;
    //                 accountWrapper.accountBillingCountry = account.BillingCountry;
    //                 accountWrapper.accountShippingStreet = account.ShippingStreet;
    //                 accountWrapper.accountShippingCity = account.ShippingCountry;
    //                 accountWrapper.accountShippingState = account.ShippingState;
    //                 accountWrapper.accountShippingPostalCode = account.ShippingPostalCode;
    //                 accountWrapper.accountShippingCountry = account.ShippingCountry;
    //                 accountWrapper.birthDate = account.BirthDate_from_contact__c;
    //                 accountsWrapper.add(accountWrapper);
    //             }
    //         }
    //     } catch (Exception ex) {
    //         throw new AuraHandledException(Configuration.EXCEPTIONSTRING + ex.getMessage());
    //     }
    //     accountsDataWrapper.accountsDataList = accountsWrapper;
    //     accountsDataWrapper.accountsMap = accountsMap;
    //     return accountsDataWrapper;
    // }
    // public class AccountsDataWrapper {
    //     @AuraEnabled public Map<String, String> accountsMap {
    //         get;
    //         set;
    //     }
    //     @AuraEnabled public List<AccountWrapper> accountsDataList {
    //         get;
    //         set;
    //     }
    // }
    // public class OpportunitiesDataWrapper {
    //     @AuraEnabled public Map<String, String> oppMap {
    //         get;
    //         set;
    //     }
    //     @AuraEnabled public List<OpportunityWrapper> oppDataList {
    //         get;
    //         set;
    //     }
    // }
    // public class WithdrawalsDataWrapper {
    //     @AuraEnabled public Map<String, String> withdrawalMap {
    //         get;
    //         set;
    //     }
    //     @AuraEnabled public List<WithdrawalWrapper> withdrawalsDataList {
    //         get;
    //         set;
    //     }
    // }
    // public class WithdrawalWrapper {
    //     @AuraEnabled public String name {
    //         get;
    //         set;
    //     }
    //     @AuraEnabled public String withdrawalId {
    //         get;
    //         set;
    //     }
    //     @AuraEnabled public String withdrawalHyperUrl {
    //         get;
    //         set;
    //     }
    //     @AuraEnabled public String createdByNameId {
    //         get;
    //         set;
    //     }
    //     @AuraEnabled public Date effectiveDate {
    //         get;
    //         set;
    //     }
    //     @AuraEnabled public String withdrawalReason {
    //         get;
    //         set;
    //     }
    //     @AuraEnabled public String disbursementSchedule {
    //         get;
    //         set;
    //     }
    //     @AuraEnabled public String feeScheduleStatus {
    //         get;
    //         set;
    //     }
    //     @AuraEnabled public Decimal fundsReceived {
    //         get;
    //         set;
    //     }
    //     @AuraEnabled public String lastModifiedName {
    //         get;
    //         set;
    //     }
    //     @AuraEnabled public String createdByName {
    //         get;
    //         set;
    //     }
    //     @AuraEnabled public Boolean withdrawan {
    //         get;
    //         set;
    //     }
    //     @AuraEnabled public Decimal registrationFee {
    //         get;
    //         set;
    //     }
    //     @AuraEnabled public Decimal fundsRetained {
    //         get;
    //         set;
    //     }
    //     @AuraEnabled public Decimal refundToNSL {
    //         get;
    //         set;
    //     }
    //     @AuraEnabled public Decimal fundsPayToStudent {
    //         get;
    //         set;
    //     }
    //     @AuraEnabled public DateTime createdDate {
    //         get;
    //         set;
    //     }
    //     @AuraEnabled public DateTime lastModifiedDate {
    //         get;
    //         set;
    //     }
    // } 
    // public class OpportunityWrapper{
    //     @AuraEnabled public Date effectiveDate {
    //         get;
    //         set;
    //     }
    //     @AuraEnabled public String withdrawalReason {
    //         get;
    //         set;
    //     }
    //     @AuraEnabled public String disbursementSchedule {
    //         get;
    //         set;
    //     }
    //     @AuraEnabled public String feeScheduleStatus {
    //         get;
    //         set;
    //     }
    //     @AuraEnabled public Decimal fundsReceived {
    //         get;
    //         set;
    //     }
    //     @AuraEnabled public String lastModifiedName {
    //         get;
    //         set;
    //     }
    //     @AuraEnabled public String createdByName {
    //         get;
    //         set;
    //     }
    //     @AuraEnabled public Boolean withdrawan {
    //         get;
    //         set;
    //     }
    //     @AuraEnabled public Decimal registrationFee {
    //         get;
    //         set;
    //     }
    //     @AuraEnabled public Decimal fundsRetained {
    //         get;
    //         set;
    //     }
    //     @AuraEnabled public Decimal refundToNSL {
    //         get;
    //         set;
    //     }
    //     @AuraEnabled public Decimal fundsPayToStudent {
    //         get;
    //         set;
    //     }
    //     @AuraEnabled public String accountBillingStreet {
    //         get;
    //         set;
    //     }
    //     @AuraEnabled public String accountBillingCountry {
    //         get;
    //         set;
    //     }
    //     @AuraEnabled public String accountBillingPostalCode {
    //         get;
    //         set;
    //     }
    //     @AuraEnabled public String accountBillingCity {
    //         get;
    //         set;
    //     }
    //     @AuraEnabled public String SSN {
    //         get;
    //         set;
    //     }
    //     @AuraEnabled public String accountOwnerName {
    //         get;
    //         set;
    //     }
    //     @AuraEnabled public String contactNameFromRelatedAccount {
    //         get;
    //         set;
    //     }
    //     @AuraEnabled public String accountPhone {
    //         get;
    //         set;
    //     }
    //     @AuraEnabled public String leadSource {
    //         get;
    //         set;
    //     }
    //     @AuraEnabled public String contactMailingPostalCode {
    //         get;
    //         set;
    //     }
    //     @AuraEnabled public String contactMailingCountry {
    //         get;
    //         set;
    //     }
    //     @AuraEnabled public String contactMailingCity {
    //         get;
    //         set;
    //     }
    //     @AuraEnabled public String contactMailingStreet {
    //         get;
    //         set;
    //     }
    //     @AuraEnabled public String contactOwnerName {
    //         get;
    //         set;
    //     }
    //     @AuraEnabled public String contactUniversityEmail {
    //         get;
    //         set;
    //     }
    //     @AuraEnabled public String contactSecurityNumber {
    //         get;
    //         set;
    //     }
    //     @AuraEnabled public String contactGovtId {
    //         get;
    //         set;
    //     }
    //     @AuraEnabled public String contactPhone {
    //         get;
    //         set;
    //     }
    //     @AuraEnabled public String contactAlternateEmail {
    //         get;
    //         set;
    //     }
    //     @AuraEnabled public String contactMobilePhone {
    //         get;
    //         set;
    //     }
    //     @AuraEnabled public String contactName {
    //         get;
    //         set;
    //     }
    //     @AuraEnabled public String accountNameFromRelatedContact {
    //         get;
    //         set;
    //     }
    //     @AuraEnabled public Date birthDate {
    //         get;
    //         set;
    //     }
    //     @AuraEnabled public String oppId {
    //         get;
    //         set;
    //     }
    //     @AuraEnabled public String oppHyperUrl {
    //         get;
    //         set;
    //     }
    //     @AuraEnabled public String oppName {
    //         get;
    //         set;
    //     }
    //     @AuraEnabled public String oppOwnerName {
    //         get;
    //         set;
    //     }
    //     @AuraEnabled public String oppOwnerHyperUrl {
    //         get;
    //         set;
    //     }
    //     @AuraEnabled public String stageName {
    //         get;
    //         set;
    //     }
    //     @AuraEnabled public String location {
    //         get;
    //         set;
    //     }
    //     @AuraEnabled public String socialSecurityNumber {
    //         get;
    //         set;
    //     }
    //     @AuraEnabled public String studentId {
    //         get;
    //         set;
    //     }
    //     @AuraEnabled public Date closeDate {
    //         get;
    //         set;
    //     }
    //     @AuraEnabled public Decimal amount {
    //         get;
    //         set;
    //     }
    //     @AuraEnabled public Boolean orientationAttended {
    //         get;
    //         set;
    //     }
    //     @AuraEnabled public String leadName {
    //         get;
    //         set;
    //     }
    //     @AuraEnabled public String promotion {
    //         get;
    //         set;
    //     }
    //     @AuraEnabled public String createdOwnerName {
    //         get;
    //         set;
    //     }
    //     @AuraEnabled public DateTime createdDate {
    //         get;
    //         set;
    //     }
    //     @AuraEnabled public DateTime lastModifiedDate {
    //         get;
    //         set;
    //     }
    //     @AuraEnabled public String accountOwnerHyperUrl {
    //         get;
    //         set;
    //     }
    //     @AuraEnabled public String accountName {
    //         get;
    //         set;
    //     }
    //     @AuraEnabled public String externalId {
    //         get;
    //         set;
    //     }
    //     @AuraEnabled public String programName {
    //         get;
    //         set;
    //     }
    //     @AuraEnabled public Date admissionDate {
    //         get;
    //         set;
    //     }
    //     @AuraEnabled public Date startDate {
    //         get;
    //         set;
    //     }
    //     @AuraEnabled public Date endDate {
    //         get;
    //         set;
    //     }
    //     @AuraEnabled public Date applicationDate {
    //         get;
    //         set;
    //     }
    //     @AuraEnabled public String programEnrollmentName {
    //         get;
    //         set;
    //     }
    //     @AuraEnabled public String classYear {
    //         get;
    //         set;
    //     }
    // }
    // public class AccountWrapper {
    //     @AuraEnabled public Boolean isSelected {
    //         get;
    //         set;
    //     }
    //     @AuraEnabled public String accountHyperUrl {
    //         get;
    //         set;
    //     }
    //     @AuraEnabled public String contactHyperUrl {
    //         get;
    //         set;
    //     }
    //     @AuraEnabled public String accountOwnerHyperUrl {
    //         get;
    //         set;
    //     }
    //     @AuraEnabled public String accountId {
    //         get;
    //         set;
    //     }
    //     @AuraEnabled public String accountName {
    //         get;
    //         set;
    //     }
    //     @AuraEnabled public Decimal accountAmount {
    //         get;
    //         set;
    //     }
    //     @AuraEnabled public String accountFirstName {
    //         get;
    //         set;
    //     }
    //     @AuraEnabled public String accountLastName {
    //         get;
    //         set;
    //     }
    //     @AuraEnabled public String accountPhone {
    //         get;
    //         set;
    //     }
    //     @AuraEnabled public String accountInternalId {
    //         get;
    //         set;
    //     }
    //     @AuraEnabled public String accountStatus {
    //         get;
    //         set;
    //     }
    //     @AuraEnabled public String accountBillingStreet {
    //         get;
    //         set;
    //     }
    //     @AuraEnabled public String accountBillingCity {
    //         get;
    //         set;
    //     }
    //     @AuraEnabled public String accountBillingState {
    //         get;
    //         set;
    //     }
    //     @AuraEnabled public String accountBillingPostalCode {
    //         get;
    //         set;
    //     }
    //     @AuraEnabled public String accountBillingCountry {
    //         get;
    //         set;
    //     }
    //     @AuraEnabled public String accountShippingCity {
    //         get;
    //         set;
    //     }
    //     @AuraEnabled public String accountShippingState {
    //         get;
    //         set;
    //     }
    //     @AuraEnabled public String accountShippingPostalCode {
    //         get;
    //         set;
    //     }
    //     @AuraEnabled public String accountShippingCountry {
    //         get;
    //         set;
    //     }
    //     @AuraEnabled public String accountShippingStreet {
    //         get;
    //         set;
    //     }
    //     @AuraEnabled public String SSN {
    //         get;
    //         set;
    //     }
    //     @AuraEnabled public String classYear {
    //         get;
    //         set;
    //     }
    //     @AuraEnabled public String Description {
    //         get;
    //         set;
    //     }
    //     @AuraEnabled public String leadName {
    //         get;
    //         set;
    //     }
    //     @AuraEnabled public String recordTypeId {
    //         get;
    //         set;
    //     }
    //     @AuraEnabled public String recordTypeName {
    //         get;
    //         set;
    //     }
    //     @AuraEnabled public String Type {
    //         get;
    //         set;
    //     }
    //     @AuraEnabled public String parentId {
    //         get;
    //         set;
    //     }
    //     @AuraEnabled public String parentName {
    //         get;
    //         set;
    //     }
    //     @AuraEnabled public String primaryContactName {
    //         get;
    //         set;
    //     }
    //     @AuraEnabled public String accountOwnerName {
    //         get;
    //         set;
    //     }
    //     @AuraEnabled public String createdOwnerName {
    //         get;
    //         set;
    //     }
    //     @AuraEnabled public String lastModifiedOwnerName {
    //         get;
    //         set;
    //     }
    //     @AuraEnabled public String primaryContactId {
    //         get;
    //         set;
    //     }
    //     @AuraEnabled public String accountOwnerId {
    //         get;
    //         set;
    //     }
    //     @AuraEnabled public String lastModifiedId {
    //         get;
    //         set;
    //     }
    //     @AuraEnabled public String createdId {
    //         get;
    //         set;
    //     }
    //     @AuraEnabled public Date birthDate {
    //         get;
    //         set;
    //     }
    // }
}