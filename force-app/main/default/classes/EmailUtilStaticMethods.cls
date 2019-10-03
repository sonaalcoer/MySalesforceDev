/**********************************************************************
* Name:	 EmailUtilStaticMethods
* Author:   Sonal Gupta
* Date:	 1 Oct 2019
* ======================================================
* Purpose:														  
* This class helps to send email and use for code refactore and reuse purpose.														 
* ====================================================== 
***********************************************************************/
public with sharing class EmailUtilStaticMethods {

        public static Boolean sendEmail(String body)
    {
    	return sendEmail('Debug Info', body, new String[] {'sonaalcoer@gmail.com'});
    }
    public static Boolean sendEmail(String subject, String body, String toAddress)
    {
    	return sendEmail(subject, body, new String[] {toAddress});
    }
    public static Boolean sendEmail(String subject, String body, String[] toAddresses)
    {
    	Boolean retVal = false;
    	
        if(canEmail() && subject != null && body != null && toAddresses != null && toAddresses.size() > 0) 
        {
              Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
              mail.setToAddresses(toAddresses);
              mail.setSubject(subject);
              mail.setPlainTextBody(body);
              Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
              retVal = true;
        }
        
        return retVal;
    }
	private static Boolean canEmail()
	{
		return (System.Limits.getLimitEmailInvocations() - System.Limits.getEmailInvocations() > 0);
	}
}