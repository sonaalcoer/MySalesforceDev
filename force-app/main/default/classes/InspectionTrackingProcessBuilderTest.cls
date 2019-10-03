@isTest
public class InspectionTrackingProcessBuilderTest {
    
    @testSetup
    private static void InsertTestOpp() {

	   // Construct a test Inspection
        Inspection_Form__c  ins = new Inspection_Form__c (Make__c  = 'test model',
                                          Status__c = 'In Progres');

	   // Save this Inspection to the database
        insert ins;
    }
    
    @isTest
private static void UpdateInspectio_ChangeTracked_ProcessFired() {
        
    // Load the ispection:
    Inspection_Form__c loadedIns = [SELECT id
                             FROM Inspection_Form__c];
        
    // Set the model value to something else:
    loadedIns.Make__c = 'Model-5';
        
    // Save it to the database, and fire the process builder
    test.startTest();
        update loadedIns;
    test.stopTest();
        
    // Load the tracking record for this Opportunity
    List<Inspection_Form__c> resultIns = [SELECT id, name
                             FROM Inspection_Form__c where Make__c='Model-5'];
    
    System.assertEquals(1, resultIns.size());

}


}