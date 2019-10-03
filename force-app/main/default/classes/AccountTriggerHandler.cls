/**********************************************************************
* Name:	 AccountTriggerHandler
* Author:   Sonal Gupta
* Date:	 1 Oct 2019
* ======================================================
* Purpose:														  
* This handler class is to call from account trigger to handle trigger processed records being inserted, updated, upserted, deleted from the system. 
* This class helps ensure per trigger logic is executed in conrolled manner.														 
* ====================================================== 
***********************************************************************/

public without sharing class AccountTriggerHandler {

    public class CustomAccountHandlerException extends exception{
            }
    
    private static Map<ID, ID> realCRMId = new Map<ID, ID>();
    
    //updating crm on related account's contacts using trigger
    /*
    public static void HandleAccountAfterUpdate(list<Account> newList, Map<ID, Account> oldMap)
    {
        
        List<Account> changedAccounts = new List<Account>();
        
        for(Account act: newList)
        {
            if(act.crm__c != ((realCRMId.containsKey(act.id))? realCRMId.get(act.id): oldMap.get(act.id).crm__c))
            {
                changedAccounts.add(act);
                realCRMId.put(act.id, act.crm__c);
            }
        }
        
        if(changedAccounts.size()==0) return;
        
        Map<ID, Account> accountsMap = new Map<ID, Account>(changedAccounts);
        
        List<Contact> contacts = [Select ID, crm__c, AccountID from Contact where AccountID in :accountsMap.keyset()];
        
        List<Contact> contactsToUpdate = new List<Contact>();
        
        for(contact ct: contacts)
        {
            ID newOwnerID = accountsMap.get(ct.AccountID).crm__c;
            if(ct.crm__c!= newOwnerID) 
            {
                ct.crm__c = newOwnerID;
                contactsToUpdate.add(ct);
            }
        }
        
        update contactsToUpdate;
        
    }
	*/
    
    //sending eligible account id for crm change to batch job to execute
    public static void HandleAccountAfterUpdate(list<Account> newList, Map<ID, Account> oldMap)
    {
        
        List<Account> changedAccounts = new List<Account>();
        
        for(Account act: newList)
        {
            if(act.crm__c != ((realCRMId.containsKey(act.id))? realCRMId.get(act.id): oldMap.get(act.id).crm__c))
            {
                changedAccounts.add(act);
                realCRMId.put(act.id, act.crm__c);
                if(act.crm__c==null) { 
      				throw new CustomAccountHandlerException('No CRM account');
    			}
            }
        }
        
        if(changedAccounts.size()==0) return;
        
        Map<ID, Account> accountsMap = new Map<ID, Account>(changedAccounts);
        
        
        AccountCRMUpdateApexBatch2 batchClass = new AccountCRMUpdateApexBatch2(accountsMap.keySet());
        //Set batch size to max 2000 while calling from apex test, The maximum batch size of an Apex object trigger is 200  (platform event trigger is 2000)
		Database.executeBatch(batchClass, (Test.isRunningTest())?2000: 200); 
    }
    
}