@isTest(SeeAllData=true) 
public class LineItemOpportunityTriggerTestClass {
    
    @isTest static void myTest() {
        
        Product2 producto =new Product2();
        producto.Name='Data Analysis, Design for BI Systems';
        producto.productCode='009';
        producto.isActive = true;
        insert producto;
        
        Id pricebookId = Test.getStandardPricebookId();
        
        PricebookEntry standardPrice = new PricebookEntry(
            Pricebook2Id = pricebookId, Product2Id = producto.Id,
            UnitPrice = 10000, IsActive = true);
        insert standardPrice;
        
        Pricebook2 customPB = new Pricebook2(Name='Custom Pricebook', isActive=true);
        insert customPB;
        
        PricebookEntry customPrice = new PricebookEntry(
            Pricebook2Id = customPB.Id, Product2Id = producto.Id,
            UnitPrice = 12000, IsActive = true);
        insert customPrice;
        
        Account a = new Account(Name='TestAccount',
                                SSN__c='12342424',
                                Lead_Name__c='TestAccount',
                                Student_id__c='123245456',
                                BirthDate_from_contact__c=Date.today().addDays(90),
                                Class_Year_from_PE__c='2025',
                                Program_Start_Date_from_PE__c=Date.today().addDays(60),
                                Program_End_Date_from_PE__c=Date.today().addDays(120));
        insert a;
        
        Account acclist = [select lead_name__c from Account where id=:a.Id];
       
        Opportunity opportunityToCreate = new Opportunity();
        opportunityToCreate.StageName = 'Needs Analysis';
        opportunityToCreate.CloseDate = Date.today().addDays(31);
        opportunityToCreate.Name = 'Test OpportunityTriggers';
        opportunityToCreate.Lead_Program__c='Data Analysis, Design for BI Systems';
        opportunityToCreate.AccountId=a.id;
        opportunityToCreate.Lead_Name__c='Test OpportunityTriggers';
        opportunityToCreate.Location__c = 'Manitoba';
        insert opportunityToCreate;
        
        
    }
}