public with sharing class PDFGeneratorController {

    public Case caseIns { get; set; }
    public String currentRecordId {get;set;}
    
    public PDFGeneratorController(ApexPages.StandardController controller) {
        
        currentRecordId  = ApexPages.CurrentPage().getparameters().get('id');
        if (String.isNotBlank(currentRecordId)) {
            FieldLevelSecurity.checkFieldAccessByCriteria('CaseNumber, First_Name__c, Middle_Name__c, Last_Name__c, Title__c, Role__c, SuppliedEmail, City__c, Address_1__c, Address_2__c ','view','Case', Boolean.valueOf(Label.HasNamespace));
            caseIns = [SELECT Id, CaseNumber, First_Name__c, Middle_Name__c, Last_Name__c, Title__c, Role__c, SuppliedEmail, City__c, Address_1__c, Address_2__c FROM Case where Id = :currentRecordId LIMIT :Utility.queryLimit];
        }
    }

}