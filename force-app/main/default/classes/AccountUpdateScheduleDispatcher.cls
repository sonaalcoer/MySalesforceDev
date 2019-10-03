/**********************************************************************
* Name:	 AccountUpdateScheduleDispatcher
* Author:   Sonal Gupta
* Date:	 1 Oct 2019
* ======================================================
* Purpose:														   
Intriguing Design Pattern for Scheduled APEX is that ScheduledDispatcher Class which uses Type.forName to dynamically create a ScheduleExecuteHandler class. 
The ScheduledDispatcher class is the one that gets locked, but the ScheduleExecuteHandler isn’t, so you can update it during schedule.
* ====================================================== 
***********************************************************************/

global with sharing class AccountUpdateScheduleDispatcher implements Schedulable{

    public static final String CRON_EXP = '0 0 0-23 * * ?';
	//									   1 2 3    4 5 6
	// 1. 	Seconds
	// 2. 	Minutes
	// 3. 	Hours
	// 4.	Days of month
	// 5.	Month
	// 6.	Day of week
	// 7.	Year (optional)
	
	public interface IAccountUpdateScheduleDispatcher
	{
		void execute(SchedulableContext sc);
	}
	
	global void execute(SchedulableContext sc) 
	{
		Type t = Type.forName('AccountUpdateScheduleExecuteHandler');
		if(t != null)
		{
			IAccountUpdateScheduleDispatcher aus = (IAccountUpdateScheduleDispatcher) t.NewInstance();
      		aus.execute(sc);
		}
	}


}