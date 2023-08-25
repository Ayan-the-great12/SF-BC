@isTest
public class PreventLeadConvertNoOppTriggerTest {
    @testSetup static void createData(){
        Lead leadd = new Lead();
        leadd.LeadSource = 'Website';
        leadd.LastName = 'lname1';
        leadd.Phone = '123';
        leadd.Status = 'Working - Contacted';
        leadd.Email = 'Email@gmail.com';
        leadd.Company = 'Company1';
        insert leadd;
    }
    @isTest static void StartProcess(){
        Lead led = [select id,IsConverted,phone from Lead
                   where Phone = '123' limit 1];
        led.Phone = '1234';
        //led.IsConverted = true;
        update led;
    }
}