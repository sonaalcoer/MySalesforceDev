/**********************************************************************
* Name:	 AccountCRMUpdateApexBatch2
* Author:   Sonal Gupta
* Date:	 1 Oct 2019
* ======================================================
* Purpose:														  
This class is to process eligible accounts records to update related contact				
This class can be called from trigger bulk operation OR batch schedule
* ====================================================== 
***********************************************************************/
global without sharing class AccountCRMUpdateApexBatch2 implements database.Batchable<SObject> , Database.RaisesPlatformEvents, Database.Stateful
//,Schedulable

{
    public Set<ID> accountIds;
    global List<Contact> errorContactList {get; private set;}
    
    public AccountCRMUpdateApexBatch2(Set<ID> ids)
    {
        accountIds = ids;
        this.errorContactList = new List<Contact>();
    }

    public AccountCRMUpdateApexBatch2()
    {
        accountIds = null;
        this.errorContactList = new List<Contact>();
    }
    /*
     public void execute(SchedulableContext sc) {
        Database.executeBatch(this,200);
    }
    */
    public Database.QueryLocator Start(Database.BatchableContext bc)
    {
        //Database.executeBatch(this, 200);
        //List<Contact> cts = [Select ID, crm__c, AccountID from Contact where AccountID in :accountIds];
        String queryString = 'Select ID, crm__c, AccountID from Contact ';
        if(accountIds!=null) queryString+= ' where AccountID in :accountIds';
        return Database.getQueryLocator(queryString);
    }
    
    public void Execute(Database.BatchableContext bc, List<Contact> scope)
    {
        List<Contact> contactsToUpdate = new List<Contact>();
        
        Set<ID> scopeAccountIds = new Set<ID>();
        for(Contact ct: scope) scopeAccountIds.add(ct.AccountID);
        
        Map<ID, Account> accountMap = new Map<ID, Account>([Select ID, crm__c from Account where ID in :scopeAccountIds]);
        
        for(Contact ct: scope)
        {
            if(ct.crm__c != accountMap.get(ct.AccountId).crm__c) {
                ct.crm__c = accountMap.get(ct.AccountId).crm__c;
                contactsToUpdate.add(ct);
            }
        }
        try{
        update contactsToUpdate;
        }
        Catch (Exception ex){
            this.errorContactList.addAll(contactsToUpdate);
        }
    }
    
    public void Finish(Database.BatchableContext bc)
    {
        if(this.errorContactList.size() > 0)
		{
			String body = '';
			body += 'The following batch records were not processed: \n\n';
			for(Contact con : this.errorContactList)
				body += URL.getSalesforceBaseUrl().toExternalForm() + '/' + con.Id + ' for accountID:' + con.AccountId + '\r\n';
			EmailUtilStaticMethods.sendEmail('Account contact crm update Errors', body, 'sonaalcoer@gmail.com');
		}
    }
    
}