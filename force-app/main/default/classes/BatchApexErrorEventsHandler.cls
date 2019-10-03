/**********************************************************************
* Name:	 BatchApexErrorEventsHandler
* Author:   Sonal Gupta
* Date:	 1 Oct 2019
* ======================================================
* Purpose:														  
* This handler class will call from BatchApexErrorEvent trigger subscription to handle standard platform event for error batch apex records being raised from the system. 
* This class helps persists logging errors to custom object.														 
* ====================================================== 
***********************************************************************/
 
public class BatchApexErrorEventsHandler {
    
    private List<BatchApexErrorEvent> events;
    
    public BatchApexErrorEventsHandler(List<BatchApexErrorEvent> events) { 
        this.events = events;
    }
    
    public void handle() {
        List<BatchApexError__c > List_batchApexError = new List<BatchApexError__c >();
        Set<Id> asyncApexJobIds = new Set<Id>();
        system.debug('start batchApexError###');
        
        for(BatchApexErrorEvent evt:events){
            asyncApexJobIds.add(evt.AsyncApexJobId);
            system.debug('event batchApexError###'+ evt);
        }
        Map<Id, JobInfo> jobs = new RuntimeJobInfoResolver().resolveById(asyncApexJobIds);
        // Map<Id,AsyncApexJob> jobs = new Map<Id,AsyncApexJob>([SELECT id, ApexClass.Name FROM AsyncApexJob WHERE Id IN :asyncApexJobIds]);
        
        List<Account> accList  = new List<Account>();
        
        for(BatchApexErrorEvent evt: events){
            Id jobId = evt.AsyncApexJobId;
            JobInfo asyncApexJob = jobs.get(jobId);
            
            BatchApexError__c  baError = new BatchApexError__c ();
            baError.AsyncApexJobId__c = evt.AsyncApexJobId;
            
            baError.Records__c = evt.JobScope;
            baError.StackTrace__c = evt.StackTrace;
            baError.ExceptionType__c = evt.ExceptionType;
            //Decomposing BatchApexErrorEvent into Custom Objects
            List_batchApexError.add(baError);
            
            system.debug('event batchApexError Job###'+ jobs);

            
            
        }
        
        if(List_batchApexError != null && List_batchApexError.size() > 0){
            insert List_batchApexError;
            system.debug('List_batchApexError###'+ List_batchApexError);
        }
        
  /*      If(accList != null && accList.size() > 0 ){
            system.debug('updating event exception to related object list ###'+ accList);
            update accList;
        }
  */
        
        
    }
    
    // Abstract queries made against AsyncApexJob to aid testability
    public abstract class JobInfoResolver {
        public abstract Map<Id, JobInfo> resolveById(Set<Id> jobIds);
    }
    public class RuntimeJobInfoResolver extends JobInfoResolver {
        public override Map<Id, JobInfo> resolveById(Set<Id> jobIds) {            
            Map<Id, JobInfo> jobsById = new Map<Id, JobInfo>();
            for(AsyncApexJob job : [select id, CreatedDate, ApexClass.Name from AsyncApexJob where Id IN :jobIds]) {
                JobInfo jobInfo = new JobInfo();
                jobInfo.Id = job.Id;
                jobInfo.ApexClassName = job.ApexClass.Name;
                jobInfo.CreatedDate = job.CreatedDate;
                jobsById.put(jobInfo.Id, jobInfo);
            }
            
            return jobsById;
        }
    }
    public class JobInfo {
        public Id Id;
        public String ApexClassName;
        public DateTime CreatedDate;
    }
    
}