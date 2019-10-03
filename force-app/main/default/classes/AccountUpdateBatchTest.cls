@istest
public class AccountUpdateBatchTest {

    public static final Integer accountCount = 2;
    public static final Integer contactsOnEachAccount = 2; 
    
    @testsetup
    public static void initializeClassTestData()
    {
        CreateTestAccounts(accountCount, contactsOnEachAccount, true);
    }
    
    @istest
    public static void testBasicOperation()
    {
        List<Account> accounts = [Select Id, OwnerId from Account];
        
        User u = getTestuser();
        System.runAs(u)
        {
            for(Account act: accounts)
            {
                act.crm__c = u.id;
            }
            
            Test.startTest();
            update accounts;
            Test.stopTest();
            
            List<Contact> updatedContacts = [Select Id, crm__c from Contact];
            for(Contact ct: updatedContacts)
            {
                System.assertEquals(u.id, ct.crm__c, 'Account and contact crm does not match');
            }
            
        }
        
    }
    
 public static List<account> prepareAccounts(Integer numAccounts, Boolean insertNow, Database.DMLOptions dml)
    {
       List<account> accountList = new List<Account>();
        for(Integer a = 0; a< numAccounts; a++)
        {
            accountList.add(new Account(Name='Test Company'+ String.ValueOf(a), BillingPostalCode ='12345', crm__c=getTestuser().id));
        }
        if(insertNow)
         Database.insert( accountList, dml);
        return accountList;
    }
    
    public static void createTestAccounts(Integer numAccounts, Integer contactsPerAccount, Boolean allowDuplicateSave)
    {
        Database.DMLOptions dml = new Database.DMLOptions();
        dml.DuplicateRuleHeader.allowSave = false;
        
        List<account> accountList = prepareAccounts(numAccounts, true, dml);
                
        List<Contact> contacts = new List<Contact>();
        
        for(Account act: accountList)
        {
            for(Integer c = 0; c< contactsPerAccount; c++)
            {
                contacts.add(new Contact(FirstName='Test'+ String.ValueOf(c), LastName = 'Smith' + String.ValueOf(c), AccountID = act.id, email='sonaalcoer@gmail.com'));
            }
        }
        
		Database.insert( contacts, dml);        
        
    }
        @isTest
    static void customObjectCreatedFromEventTrigger(){
        if(!isUpdatedForEvents()){
            return;
        }
        List<Account> accounts = [Select Id, OwnerId from Account];
        
        User u = getTestuser2();
        /*
        Group testGroup = new Group(Name='test group', Type='Queue');
		insert testGroup;
        QueuesObject testQueue = new QueueSObject(QueueID = testGroup.id, SObjectType = 'Case');
    	insert testQueue;
		//case owner id = testQueue.id
		*/

        System.runAs(u)
        {


            for(Account act: accounts)
            {
                act.crm__c = null;                
            }
             try{
            Test.startTest();
            update accounts;

           //CreateTestAccounts(2,2,false);
           //AccountCRMUpdateApexBatch2 job = new AccountCRMUpdateApexBatch2();
           // Id jobId = Database.executeBatch(job);
       
            Test.getEventBus().deliver();
            
            
        }catch(DmlException ex){ 
            system.debug('exception : ' + ex.getMessage());
            Test.getEventBus().deliver(); /* don't fail this test if there were errors in the batch job - we want that */
        }
        //Test.getEventBus().deliver();
        Test.stopTest();
        

        List<BatchApexError__c> errorLogs = [SELECT id, StackTrace__c, Records__c FROM BatchApexError__c];
        List<Account> errAccount = [SELECT id, name, ExceptionType__c, dirty__c FROM Account ];
        system.debug('Account errorLogs: '+ errorLogs + ' Account List:'+ errAccount);
        //System.assert(errorLogs.size()>0, 'Expected errors');
        //System.assert(errorLogs[0].Records__c.contains(errAccount.Id), 'Expected');
        }
       
    }

        @isTest
	static void testscheduleExecute()
	{
		Test.startTest();
		String tmpId = System.schedule('AccountUpdateScheduleExecute', AccountUpdateScheduleDispatcher.CRON_EXP, new AccountUpdateScheduleDispatcher());
		system.assert(tmpId != null);
		Test.stopTest();
	}
	
    static Boolean isUpdatedForEvents(){
        ApexClass cls = [SELECT Body FROM ApexClass WHERE Name = 'AccountCRMUpdateApexBatch2'];
        return cls.body.containsIgnoreCase('Database.RaisesPlatformEvents');
    }
    public static User getTestuser()
    {
        User u = new User(Alias = 'usr1', 
                          Email = 'sonaalcoer@gmail.com', 
                          FirstName='Sonal', LastName= 'GuptaTest', 
                          TimeZoneSidKey = 'America/Los_Angeles', 
                          UserName = 'sonaalcoer@gmail.com.coer0',
                          ProfileID = UserInfo.getProfileId(),
                          LocaleSidKey='en_US', 
                          EmailEncodingKey='UTF-8', 
                          LanguageLocaleKey = 'en_US');
        return u;
    }
    
        public static User getTestuser2()
    {
        User u = new User(Alias = 'usr2', 
                          Email = 'sonaalcoer@gmail.com', 
                          FirstName='Sonal2', LastName= 'GuptaTest2', 
                          TimeZoneSidKey = 'America/Los_Angeles', 
                          UserName = 'sonaalcoer@gmail.com.coer1',
                          ProfileID = UserInfo.getProfileId(),
                          LocaleSidKey='en_US', 
                          EmailEncodingKey='UTF-8', 
                          LanguageLocaleKey = 'en_US');
        return u;
    }
    
}