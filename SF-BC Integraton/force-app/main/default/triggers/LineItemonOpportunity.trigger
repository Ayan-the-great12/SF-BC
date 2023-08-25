trigger LineItemonOpportunity on Opportunity (after insert,before update) {
    
    Trigger_Settings__c TS = Trigger_Settings__c.getValues('Opportunity Trigger');
    
    List<OpportunityLineItem> oliList = new List<OpportunityLineItem>();
    Set<Id> oppIdlist=new set<Id>();
    for(Opportunity opp:Trigger.new){
        if(Trigger.isBefore && Trigger.isUpdate){
            if(opp.StageName == 'Closed - Approved'){
                List<hed__Program_Enrollment__c> countofPE=[Select id,Opportunity__c,Opportunity__r.Student_id__c 
                                                            from hed__Program_Enrollment__c 
                                                            where Opportunity__c=: opp.Id];
                if(countofPE.size()==0){
                    opp.addError('Cannot close opportunity without a Program Enrollment');
                }
            }
        }
        if(Trigger.isAfter && Trigger.isinsert){
            if(opp.Lead_Program__c != null){
                
                String LeadProgram=[select Lead_Program__c from Opportunity where id=:opp.Id].Lead_Program__c;
                List<PriceBookEntry> priceBookList = [SELECT Id, Product2Id, Product2.Id, Product2.Name 
                                                      FROM PriceBookEntry 
                                                      WHERE Product2.name=:LeadProgram AND PriceBook2.isStandard=false LIMIT 1];
                
                OpportunityLineItem oli = new OpportunityLineItem();
                oli.OpportunityId=opp.Id;
                
                oli.PricebookEntryId=priceBookList[0].Id ;
                oliList.add(oli);  
                upsert oliList;
                
            }
        }
    }
    
}