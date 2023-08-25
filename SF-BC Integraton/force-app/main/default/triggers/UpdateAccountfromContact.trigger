trigger UpdateAccountfromContact on Contact (after update) { 
 /*
    Trigger_Settings__c TS = Trigger_Settings__c.getValues('Contact Trigger');
    if(TS.IsActive__c == TRUE){
        Map<ID, Account> parentAccounts = new Map<ID, Account>(); 
        List<Id> listIds = new List<Id>();
        
        for (Contact childObj : Trigger.new) {
            listIds.add(childObj.accountId);
        }
        
        parentAccounts = new Map<Id, Account>([SELECT id,
                                               BirthDate_from_contact__c,
                                               SSN__c,
                                               (SELECT ID,hed__Social_Security_Number__c,Birthdate,Student_ID__c,accountId FROM Contacts) 
                                               FROM Account WHERE ID IN :listIds]);
        for (Contact con: Trigger.new){
            Account myAccount = parentAccounts.get(con.AccountId);
            if(con.Birthdate!=Null)
            {
                myAccount.BirthDate_from_contact__c=con.Birthdate;
            }
            if(con.hed__Social_Security_Number__c!=Null)
            {
                myAccount.SSN__c=con.hed__Social_Security_Number__c;
            }
            if(con.Student_ID__c!=Null || con.Student_ID__c!='')
            {
                myAccount.Student_ID__c=con.Student_ID__c;
                update myAccount;
            }           
        }       
        update parentAccounts.values();
    }
*/
}