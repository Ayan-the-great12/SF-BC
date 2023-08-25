public without sharing class WithdrawalExtension {
    public Withdrawal__c wdal {get;set;}
    public Boolean firstSection{get;set;}
    public Boolean secondSection{get;set;}
    public Boolean thirdSection{get;set;}
    public Boolean fourthSection{get;set;}
    public static String selectedWithdrawalReason{get;set;}
    Public static Decimal FundsReceived{get;set;}
    Public static Decimal RegistrationFee{get;set;}
    Public static Decimal FundsRetained{get;set;}
    Public static Decimal RefundableToNSL{get;set;}
    Public static Decimal FundsPayableByStudent{get;set;}
    
    Public String alreadyWithdrawan='No';
    Public String OppName='';
    Public String WithdrawDate='';
    

    public WithdrawalExtension(ApexPages.StandardController stdController){
         this.wdal= (Withdrawal__c)stdController.getRecord();
         firstSection=true;
         secondSection=false;
    }
    
    public static List<SelectOption> getWithdrawalOptions() {
        List<SelectOption> wdlOptions = new List<SelectOption>();
        wdlOptions.add(new SelectOption('No Withdrawal','No Withdrawal'));
        wdlOptions.add(new SelectOption('Early Completion','Early Completion'));
        wdlOptions.add(new SelectOption('Never Attended','Never Attended'));
        wdlOptions.add(new SelectOption('Withdrew from Studies','Withdrew from Studies'));
        

        return wdlOptions;
    }
    
    public static List<SelectOption> getfeeSchedulestatus() {
        List<SelectOption> fwd = new List<SelectOption>();
       fwd.add(new SelectOption('No Withdrawal','No Withdrawal'));
        fwd.add(new SelectOption('0% Tuition Fee','0% Tuition Fee'));
        fwd.add(new SelectOption('25% Tuition Fee','25% Tuition Fee'));
        fwd.add(new SelectOption('60% Tuition Fee','60% Tuition Fee'));
        fwd.add(new SelectOption('100% Tuition Fee','100% Tuition Fee'));
        

        return fwd;
    }
    
    
    
    public List<SelectOption> getMSPicklist {
        get {
            List<SelectOption> options = new List<SelectOption>();
            for( Schema.PicklistEntry obj : Withdrawal__c.Disbursement_Schedule__c.getDescribe().getPicklistValues()) {
                options.add(new SelectOption(obj.getValue(), obj.getLabel()));
            } 
            return options;
        }  
        set;
    }
    
    
    
    
    
     public String[] MSItems { 
        get {
            List<String> selected = new List<String>();List<SelectOption> options = this.getMSPicklist;
            for(SelectOption obj : options) {if (this.wdal.Disbursement_Schedule__c !=null && this.wdal.Disbursement_Schedule__c.contains(obj.getValue()))selected.add(obj.getValue());}
            return selected;
        }public set {
            String selectedCheckBox = '';for(String s : value) {if (selectedCheckBox == '') selectedCheckBox += s;
                else selectedCheckBox += ';' + s;
            }
            wdal.Disbursement_Schedule__c = selectedCheckBox;
          
        }
    } 
    
    public void FirstPagetoSecondPageNextButton()
    {
        if(wdal.opportunity_contact__c==null)
        {
      
        firstSection=true;
        secondSection=false;
        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'Must select an Opportunity Contact to proceed'));
        }
        else
        {
       
        if(wdal.opportunity_contact__c!=null && alreadyWithdrawan=='Yes')
        {firstSection=true;secondSection=false;ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'The '+OppName+' has been withdrawn on '+ WithdrawDate));
        }
        if(wdal.opportunity_contact__c!=null && alreadyWithdrawan=='No')
        {
        if(wdal.Opportunity_Stage__c!='Closed - Rejected' && wdal.Opportunity_Stage__c!='Closed - Approved')
            {firstSection=true;secondSection=false;ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'Must Select Opportunity which is  in Closed Status to proceed'));}
            else
            {firstSection=false;secondSection=true;  
            }}}}
         
           

        
    
    public void FirstPageFromSecondPagePrevButton()
    {
        firstSection=true;
        secondSection=false;
    }
    
    public void SecondPagetoThirdPageNextButton()
    {
        firstSection=false;
        secondSection=false;
        thirdSection=true;
        
    }
    
      public void SecondPageFromThirdPagePrevButton()
    {
        firstSection=false;
        secondSection=true;
        thirdSection=false;
        
    }
    
   
    
      public void ThirdPagetoFourthPageNextButton()
    {
        firstSection=false;secondSection=false;thirdSection=false;fourthSection=true;upsert wdal;Withdrawal__c wdret=[select id,Funds_Received__c,Registration_Fee__c,Funds_Retained__c,Refundable_to_NSL__c,Funds_Payable_by_Student__c from Withdrawal__c where id=:wdal.id];FundsReceived=wdret.Funds_Received__c;RegistrationFee=wdret.Registration_Fee__c;FundsRetained=wdret.Funds_Retained__c;RefundableToNSL=wdret.Refundable_to_NSL__c;FundsPayableByStudent=wdret.Funds_Payable_by_Student__c;
        
    }
      public void ThirdPageFromFourthPagePrevButton()
    {
        firstSection=false;
        secondSection=false;
        thirdSection=true;
        fourthSection=false;
        
    }
   public PageReference save() {insert wdal;PageReference wdlPage = new PageReference('/' + wdal.id);wdlPage.setRedirect(true);return wdlPage;}
    public void OppSelected()
    {
        alreadyWithdrawan='No';
        Opportunity Opp = [Select Id, /*Student_ID__c,*/Lead_program__c,StageName,location__c,Amount,Withdrawan__c,BirthDate_from_contact__c,Program_Start_Date_from_PE__c,Program_End_Date_from_PE__c,Social_Security_Number_from_Contact__c,Class_Year_from_PE__c,Name from Opportunity where Id = :wdal.Opportunity_Contact__c];
        wdal.Programs__c=  Opp.Lead_program__c;
        //wdal.Student_ID__c=Opp.Student_ID__c;
        wdal.location__c=Opp.location__c;
        wdal.BirthDate__c=String.valueOf(Opp.BirthDate_from_contact__c);
        wdal.Program_Start_Date__c =String.valueOf(Opp.Program_Start_Date_from_PE__c);wdal.Program_End_Date__c=String.valueOf(Opp.Program_End_Date_from_PE__c);wdal.Social_Security_Number__c=Opp.Social_Security_Number_from_Contact__c;wdal.Funding_Year__c=Opp.Class_Year_from_PE__c;wdal.Program_Fee__c=Opp.Amount;wdal.opportunity_stage__c=opp.StageName;
    if(Opp.Withdrawan__c==True)
    {
        alreadyWithdrawan='Yes';
        OppName=Opp.Name;
        Withdrawal__c ww=[select Withdrawal_Effective_Date__c from Withdrawal__c where Opportunity_Contact__c In(select id from Opportunity where id  = :wdal.Opportunity_Contact__c)]; WithdrawDate=String.valueOf(ww.Withdrawal_Effective_Date__c);            }
        else
        alreadyWithdrawan='No';}}