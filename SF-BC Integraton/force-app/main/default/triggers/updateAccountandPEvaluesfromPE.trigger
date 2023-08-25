trigger updateAccountandPEvaluesfromPE on hed__Program_Enrollment__c(after insert, after update,before update,before insert){
    Trigger_Settings__c TS = Trigger_Settings__c.getValues('Program Enrollment Trigger');
    if(TS.IsActive__c == TRUE){
        Set<Id> contactIds = new Set<Id>();
        for(hed__Program_Enrollment__c child : trigger.new){
            contactIds.add(child.hed__Contact__c);
        }
        Map<Id,Contact> parentRecords = new Map<Id,Contact>([Select accountId from Contact where id in :contactIds]);
        
        Set<Id> accountIds = new Set<Id>();
        for(Contact parentRecord : parentRecords.values())
            accountIds.add(parentRecord.accountId);
        Map<Id,Account> grandParentRecords = new Map<Id,Account>([Select id, Program_Start_Date_from_PE__c, (select Id,name from opportunities),
                                                                  Program_End_Date_from_PE__c, Class_Year_from_PE__c 
                                                                  from Account where id in : accountIds]);
        
        if(Trigger.isBefore &&(Trigger.IsInsert || Trigger.IsUpdate))
        {
            //for(hed__Program_Enrollment__c childPE : trigger.new){
               // Account getaccountRec=grandParentRecords.get(parentRecords.get(childPE.hed__Contact__c).accountid);
                //String oppId=[select id,accountId,Alberta_Student_Enrolment_Number__c 
                  //            from Opportunity where accountId=:getaccountRec.id Order By CreatedDate Desc limit 1].id;
                //   String conId=[select id,accountId 
                //               from Contact where  accountId=:getaccountRec.id].id;
                
                //childPE.Opportunity__c=oppId;
                //childPE.hed__Contact__c=conId;
            //}
        }
        
        if(Trigger.isAfter &&(Trigger.IsInsert || Trigger.IsUpdate))
        {           
            for(hed__Program_Enrollment__c childPE : trigger.new){
                if(parentRecords.containsKey(childPE.hed__Contact__c) && 
                   grandParentRecords.containsKey(parentRecords.get(childPE.hed__Contact__c).accountId))
                {
                    if(childPE.hed__Start_Date__c !=Null)
                        grandParentRecords.get(parentRecords.get(childPE.hed__Contact__c).accountId).Program_Start_Date_from_PE__c =
                        childPE.hed__Start_Date__c ;
                    
                    if(childPE.hed__End_Date__c !=Null)
                        grandParentRecords.get(parentRecords.get(childPE.hed__Contact__c).accountId).Program_End_Date_from_PE__c=
                        childPE.hed__End_Date__c;
                    
                    if(childPE.hed__Graduation_Year__c!='')
                        grandParentRecords.get(parentRecords.get(childPE.hed__Contact__c).accountId).Class_Year_from_PE__c=
                        childPE.hed__Graduation_Year__c;
                    
                    if(childPE.Name!='')
                        grandParentRecords.get(parentRecords.get(childPE.hed__Contact__c).accountId).Alberta_Student_Enrolment_Number__c=
                        childPE.Name;
                }
            }           
            update grandParentRecords.values();
        }
    }
}