public with sharing class CPSIntakeReportController {

    public Service_Case__c serviceCase { get; set; }
    public String currentRecordId {get;set;}
    public Case caseIns { get; set; }
    
    public CPSIntakeReportController() {
    
        currentRecordId  = ApexPages.CurrentPage().getparameters().get('id');
        
        if (String.isNotBlank(currentRecordId)) {
        
            String intakeId = '';
            Id recId = currentRecordId;
            String sObjName = recId.getSObjectType().getDescribe().getName();
            
            if(sObjName == 'Service_Case__c' ) {
                FieldLevelSecurity.checkFieldAccessByCriteria('Intake__c','view','Service_Case__c', Boolean.valueOf(Label.HasNamespace));
                intakeId = [SELECT Id, Intake__c FROM Service_Case__c WHERE Id = :currentRecordId LIMIT :Utility.queryLimit].Intake__c;
            
            } else if(sObjName == 'Investigation__c') {
                FieldLevelSecurity.checkFieldAccessByCriteria('Intake__c','view','Investigation__c', Boolean.valueOf(Label.HasNamespace));
                intakeId = [SELECT Id,Intake__c FROM Investigation__c WHERE Id = :currentRecordId LIMIT :Utility.queryLimit].Intake__c;
            } else if(sObjName == 'Case') {      
                intakeId = currentRecordId;
            }
            
            if(String.isNotBlank(intakeId)) {
                FieldLevelSecurity.checkFieldAccessByCriteria('CaseNumber,SuppliedEmail, First_Name__c, Middle_Name__c, Last_Name__c, Title__c, Role__c,'+
                'Origin,Communication__c, City__c, Address_1__c, Address_2__c','view','Case', Boolean.valueOf(Label.HasNamespace));
                 caseIns = [SELECT Id, CaseNumber, First_Name__c, Middle_Name__c, Last_Name__c, Title__c, Role__c, SuppliedEmail,
                        Origin,Communication__c, City__c, Address_1__c, Address_2__c FROM Case where Id = :intakeId LIMIT :Utility.queryLimit];
            }
        }
    } 
    
    public CPSIntakeReportController(ApexPages.StandardController controller) {
        
        currentRecordId  = ApexPages.CurrentPage().getparameters().get('id');
        
        Id recId = currentRecordId;
        String sObjName = recId.getSObjectType().getDescribe().getName();
        
        if (String.isNotBlank(currentRecordId)) {
                          
            if(sObjName == 'Service_Case__c') {            
                FieldLevelSecurity.checkFieldAccessByCriteria('Intake__c','view','Service_Case__c', Boolean.valueOf(Label.HasNamespace));
                FieldLevelSecurity.checkFieldAccessByCriteria('CaseNumber','view','Case', Boolean.valueOf(Label.HasNamespace));
                serviceCase = [SELECT Id, Intake__c, Intake__r.CaseNumber FROM Service_Case__c WHERE Id = :currentRecordId LIMIT :Utility.queryLimit];
            } 
            
            if(serviceCase != null && String.isNotBlank(serviceCase.Intake__c)) {
            
                FieldLevelSecurity.checkFieldAccessByCriteria('CaseNumber, First_Name__c, Middle_Name__c, Last_Name__c, Title__c, Role__c, SuppliedEmail,'+
                'Origin,Communication__c, City__c, Address_1__c, Address_2__c','view','Case', Boolean.valueOf(Label.HasNamespace));
                caseIns = [SELECT Id, Intake__r.CaseNumber, First_Name__c, Middle_Name__c, Last_Name__c, Title__c, Role__c, SuppliedEmail,
                        Origin,Communication__c, City__c, Address_1__c, Address_2__c FROM Case WHERE Id = :serviceCase.Intake__c LIMIT :Utility.queryLimit];
            } 
        }       
    }
}