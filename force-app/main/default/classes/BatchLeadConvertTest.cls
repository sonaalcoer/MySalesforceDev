@isTest
public class BatchLeadConvertTest {

    /*
     @isTest
    static void testLeadBasicConvert(){
        Lead l = new Lead(
                FirstName = 'Test',
                LastName = 'Lead1',
                Company = 'Salesforce'
        );
        insert l;
        BatchLeadConvert job = new BatchLeadConvert();
        Test.startTest();
            Id jobId = Database.executeBatch(job);
        Test.stopTest();
        System.assertEquals(0, [SELECT NumberOfErrors FROM AsyncApexJob WHERE Id = :jobId].NumberOfErrors);
    }
    */

    @isTest
    static void customObjectCreatedFromEventTrigger(){
        if(!isUpdatedForEvents()){
            return;
        }
        Lead errLead = new Lead(
                LastName = 'Test DoNotConvert',
                Company = 'Test1'
        );
        insert errLead;

        BatchLeadConvert job = new BatchLeadConvert();
        Test.startTest();
            Id jobId = Database.executeBatch(job);
        try{
            Test.getEventBus().deliver();
            Test.stopTest();
            
        }catch(DmlException ex){ 
            Test.getEventBus().deliver(); /* don't fail this test if there were errors in the batch job - we want that */
        }
        //Test.getEventBus().deliver();
        

        List<BatchApexError__c> errorLogs = [SELECT id, StackTrace__c, Records__c FROM BatchApexError__c];
        List<Lead> upLead = [SELECT id, name, ExceptionType__c, dirty__c FROM Lead where id =: errLead.Id];
        system.debug('Lead Exception: '+ upLead);
        System.assertEquals(1, errorLogs.size(), 'Expected errors converting DoNotConvertLeads');
        System.assert(errorLogs[0].Records__c.contains(errLead.Id), 'Expected "Test DoNotConvert" Lead to fail to convert');
    }

    static Boolean isUpdatedForEvents(){
        ApexClass cls = [SELECT Body FROM ApexClass WHERE Name = 'AccountCRMUpdateApexBatch2'];
        return cls.body.containsIgnoreCase('Database.RaisesPlatformEvents');
    }
}