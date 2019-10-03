public with sharing class AccountUpdateScheduleExecuteHandler implements AccountUpdateScheduleDispatcher.IAccountUpdateScheduleDispatcher
{
	public void execute(SchedulableContext sc)
	{
		processQueue();
	}
	
	public static void processQueue()
	{
		AccountCRMUpdateApexBatch2 batchClass = new AccountCRMUpdateApexBatch2();
		Database.executeBatch(batchClass); 
	}
}