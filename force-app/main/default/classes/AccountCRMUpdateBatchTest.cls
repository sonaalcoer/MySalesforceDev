@istest
public class AccountCRMUpdateBatchTest {

    public static final Integer accountCount = 20;
    public static final Integer contactsOnEachAccount = 11; 
    
    @testsetup
    public static void initializeClassTestData()
    {
        CreateTestAccounts(accountCount, contactsOnEachAccount);
    }
    
    @istest
    public static void TestBasicOperation()
    {
        List<Account> accounts = [Select Id, OwnerId from Account];
        
        User u = getTestuser();
        System.runAs(u)
        {
            for(Account act: accounts)
            {
                act.OwnerId = u.id;
            }
            
            Test.startTest();
            update accounts;
            Test.stopTest();
            
            List<Contact> updatedContacts = [Select Id, OwnerId from Contact];
            for(Contact ct: updatedContacts)
            {
                System.assertEquals(u.id, ct.OwnerId, 'Account and contact owner does not match');
            }
            
        }
        
    }
    
 
    
    public static void CreateTestAccounts(Integer accounts, Integer contactsPerAccount)
    {
        Database.DMLOptions dml = new Database.DMLOptions();
        dml.DuplicateRuleHeader.allowSave = true;
        
        List<account> accountList = new List<Account>();
        for(Integer a = 0; a< accounts; a++)
        {
            accountList.add(new Account(Name='Test Company'+ String.ValueOf(a)));
        }
        database.insert( accountList, dml);
        
        List<Contact> contacts = new List<Contact>();
        
        for(Account act: accountList)
        {
            for(Integer c = 0; c< contactsPerAccount; c++)
            {
                contacts.add(new Contact(FirstName='Test'+ String.ValueOf(c), LastName = 'Smith' + String.ValueOf(c), AccountID = act.id));
            }
        }
        
		Database.insert( contacts, dml);        
        
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