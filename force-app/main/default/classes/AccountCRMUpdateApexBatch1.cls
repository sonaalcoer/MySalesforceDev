/**********************************************************************
* Name:	 AccountCRMUpdateApexBatch1
* Author:   Sonal Gupta
* Date:	 1 Oct 2019
* ======================================================
* Purpose:														  
* This batch apex class is deprecated by new batch apex class AccountCRMUpdateApexBatch2 due to nested 
sub query burn more CPU time														 
* ====================================================== 
***********************************************************************/
public without sharing class AccountCRMUpdateApexBatch1 implements database.Batchable<SObject> {

    public Set<ID> accountIds;
    
    public AccountCRMUpdateApexBatch1(Set<ID> ids)
    {
        accountIds = ids;
    }
    
    public Database.QueryLocator Start(Database.BatchableContext bc)
    {
        //List<Account> acts = [Select ID, crm__c, (Select ID, crm__c, AccountID from Contacts) from Account where ID in :accountIds];
        return Database.getQueryLocator('Select ID, crm__c, (Select ID, crm__c, AccountID from Contacts) from Account where ID in :accountIds');
    }
    
    public void Execute(Database.BatchableContext bc, List<Account> scope)
    {
        List<Contact> contactsToUpdate = new List<Contact>();
        
        for(Account act:scope)
        {
            for(Contact ct: act.contacts)
            {
                if(ct.crm__c != act.crm__c) {
                    ct.crm__c = act.crm__c;
                    contactsToUpdate.add(ct);
                }
            }
        }
        update contactsToUpdate;
    }
    
    public void Finish(Database.BatchableContext bc)
    {
        
    }
    
    
    
}