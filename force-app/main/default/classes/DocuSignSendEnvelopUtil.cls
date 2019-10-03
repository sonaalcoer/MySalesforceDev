/**********************************************************************
* Name:	 DocuSignSendEnvelopUtil
* Author:   Sonal Gupta
* Date:	 27 Sept 2019
* ======================================================
* Purpose:														  
This class is responsible for sending Envelopes by making DocuSign Apex Toolkit Callouts to DocuSign 
We can extend the createEnvelope method by invoking it from triggers / scheduled apex / batch jobs 
We can also create invocable actions by referencing the createEnvelope method and use it in Process Builders 													 
* ====================================================== 
***********************************************************************/


public with sharing class DocuSignSendEnvelopUtil {

       //Get Rest Configuration Setings from Custom Metadata provided as a part of the installation source 
    private static Map<String, DocuSignRESTSettings__mdt> settingsMap { 
        //Getter Method
        get {
            //populate only if settingsMap is null
            if (settingsMap == null) {
                settingsMap = new Map<String, DocuSignRESTSettings__mdt>();
                //Query the Custom Metadata and add it to the Map
                //Query against Custom Metadata does not count against the SOQL query Limit
                for (DocuSignRESTSettings__mdt setting : [Select DeveloperName,MasterLabel, Value__c from DocuSignRESTSettings__mdt]) {
                    settingsMap.put(setting.MasterLabel, setting);
                }
            }
            return settingsMap;
        }
        //Blank Setter Method
        set {
        }
    }

    public DocuSignSendEnvelopUtil() {

    }
    String dsUsername = settingsMap.get('DSUserName').Value__c;
    //System.Debug(LoggingLevel.INFO, '**DSUserName ' + dsUsername);
    //System.Debug(LoggingLevel.INFO, dsUsername);
    
        //This method will call the DocuSign method to create an empty envelope template definition that will be subsequently completed, created, and sent
    public static dfsle.Envelope createEmptyEnvelope(String recordId) {
        Id mySourceId = recordId; // The ID of the initiating Salesforce object.

        // Create an empty envelope.
        dfsle.Envelope myEnvelope = dfsle.EnvelopeService.getEmptyEnvelope(
        new dfsle.Entity(mySourceId));
        return myEnvelope;
        // The initiating Salesforce entity.

        //Use myEnvelope for later 
    }

    public static dfsle.Envelope setRecipient(String recipientEmail, dfsle.Envelope myEnvelope) {
            //we will use a Salesforce contact record as a Recipient here
        Contact myContact = [SELECT Id, Name, Email FROM Contact where email =:recipientEmail LIMIT 1];

        //use the Recipient.fromSource method to create the Recipient
        dfsle.Recipient myRecipient = dfsle.Recipient.fromSource(
                    myContact.Name, // Recipient name
                    myContact.Email, // Recipient email
                    null, //Optional phone number
                    'Signer 1', //Role Name. Specify the exact role name from template
                    new dfsle.Entity(myContact.Id)); //source object for the Recipient

        //add Recipient to the Envelope
        myEnvelope = myEnvelope.withRecipients(new List<dfsle.Recipient> { myRecipient });
        return myEnvelope;
    }

    public static dfsle.Envelope specifyTemplate(String templateId, dfsle.Envelope myEnvelope) {
        //myTemplateId contains the DocuSign Id of the DocuSign Template
        dfsle.UUID myTemplateId = dfsle.UUID.parse('01234567-xxxx-xxxx-xxxx-456789abcdef');

        //create a new document for the Envelope
        dfsle.Document myDocument = dfsle.Document.fromTemplate(
            myTemplateId, // templateId in dfsle.UUID format
            'myTemplate'); // name of the template

        //add document to the Envelope
        myEnvelope = myEnvelope.withDocuments(new List<dfsle.Document> { myDocument });
        return myEnvelope;
    }

    public static dfsle.Envelope sendEnvelop(Boolean sendNow, dfsle.Envelope myEnvelope){
                // Send the envelope.
        myEnvelope = dfsle.EnvelopeService.sendEnvelope(
            myEnvelope, // The envelope to send
            true); // Send now
            return myEnvelope;

    }
}