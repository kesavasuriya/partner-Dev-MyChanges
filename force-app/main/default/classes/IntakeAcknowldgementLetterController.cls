public with sharing class IntakeAcknowldgementLetterController {

    public String currentRecordId {get;set;}
    public Case caseIns { get; set; }

    public IntakeAcknowldgementLetterController(ApexPages.StandardController controller) {
        
        currentRecordId  = ApexPages.CurrentPage().getparameters().get('id');
        
        if (String.isNotBlank(currentRecordId)) {
        
            FieldLevelSecurity.checkFieldAccessByCriteria('First_Name__c, Middle_Name__c, Received_Date__c, Last_Name__c,Address_1__c, Address_2__c, City__c,Narrative_County__c,State__c,Email_Address__c','view','Case', Boolean.valueOf(Label.HasNamespace));
            caseIns = [SELECT Id, First_Name__c, Middle_Name__c, Received_Date__c, Last_Name__c,Address_1__c, Address_2__c, City__c,Narrative_County__c,State__c,Email_Address__c FROM Case 
                       where Id = :currentRecordId LIMIT :Utility.queryLimit];
        }
    }
}