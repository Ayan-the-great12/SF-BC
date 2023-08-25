trigger UpdateAccounttoOpportunity on Account (after update) {

    /*
    Trigger_Settings__c TS = Trigger_Settings__c.getValues('Account Trigger');
    if(TS.IsActive__c == TRUE){
        Map <Id, Account > mapAccount = new Map <Id, Account >();
        List < Opportunity > listOpp = new List< Opportunity >();
        List<contact> clist=new List<contact>();
        Set<Id> accountIds = new Set<Id>();
        //if(trigger.isBefore && Trigger.isInsert){
            //for ( Account acct1 : trigger.new )
              //  acct1.Name=acct1.Lead_Name__c;
        //}
        if(trigger.isAfter && (Trigger.isUpdate)){
            if(!checkRecursive2.Secondcall){
                checkRecursive2.Secondcall= true;
                for ( Account acct : trigger.new ){
                    if ( acct.SSN__c !='' || acct.Student_id__c!='' || acct.BirthDate_from_contact__c!=Null || acct.Class_Year_from_PE__c != Null
                        || acct.Program_Start_Date_from_PE__c!=Null || acct.Program_End_Date_from_PE__c!=Null )
                        accountIds.add(acct.id);
                    mapAccount.put(acct.Id, acct);
                }
                if(accountIds.size() > 0){
                    List<Contact> updates = [select Id, AccountId,hed__Social_Security_Number__c,Student_Id__c,Birthdate 
                                             from Contact 
                                             where AccountId in:accountIds];  
                    for (Contact c : updates) {
                        Account a = Trigger.newMap.get(c.AccountId);
                        c.hed__Social_Security_Number__c = a.SSN__c;
                        c.Birthdate = a.BirthDate_from_contact__c;
                        c.Student_Id__c = a.Student_id__c;
                        clist.add(c);
                    }
                    update clist;
                }
                if ( mapAccount.size() > 0 ) {
                    listOpp= [ SELECT Program_Start_Date_from_PE__c,BirthDate_from_contact__c, Social_Security_Number_from_Contact__c,
                              Program_End_Date_from_PE__c, AccountId, Class_Year_from_PE__c,Alberta_Student_Enrolment_Number__c 
                              FROM Opportunity 
                              WHERE AccountId IN : mapAccount.keySet() ];
                    if  (listOpp.size() > 0 ) {
                        for  (Opportunity opp : listOpp){
                            if(mapAccount.get( opp.AccountId ).Program_Start_Date_from_PE__c!=null || 
                               mapAccount.get( opp.AccountId ).Program_End_Date_from_PE__c!=null || mapAccount.get( opp.AccountId ).SSN__c!='' ||
                               mapAccount.get( opp.AccountId ).Class_Year_from_PE__c!='' ||
                               mapAccount.get( opp.AccountId ).BirthDate_from_contact__c!=null){
                                   opp.Program_Start_Date_from_PE__c = mapAccount.get( opp.AccountId ).Program_Start_Date_from_PE__c;
                                   opp.Program_End_Date_from_PE__c = mapAccount.get( opp.AccountId ).Program_End_Date_from_PE__c;
                                   opp.Social_Security_Number_from_Contact__c = mapAccount.get( opp.AccountId ).SSN__c ;
                                   opp.Class_Year_from_PE__c = mapAccount.get( opp.AccountId ).Class_Year_from_PE__c;
                                   opp.BirthDate_from_contact__c = mapAccount.get( opp.AccountId ).BirthDate_from_contact__c;
                                   opp.Student_ID__c = mapAccount.get( opp.AccountId ).Student_ID__c;
                                   opp.Alberta_Student_Enrolment_Number__c=mapAccount.get(opp.AccountId ).Alberta_Student_Enrolment_Number__c;
                               }
                        }
                        update listOpp;
                    }
                }
            }
        }
    }
*/
}