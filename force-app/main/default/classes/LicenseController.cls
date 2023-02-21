public with sharing class LicenseController {

    public License__c licenseIns { get; set; }
    public String currentRecordId {get;set;}
    
   
    
    public LicenseController(ApexPages.StandardController controller) {
        
        currentRecordId  = ApexPages.CurrentPage().getparameters().get('id');
        if (String.isNotBlank(currentRecordId)) {
            FieldLevelSecurity.checkFieldAccessByCriteria('Name, Activity_Date__c, Address__c, Activity_Type__c, Authorized_individuals__c','view','License__c', Boolean.valueOf(Label.HasNamespace));
            licenseIns = [SELECT Id, Name, Activity_Date__c, Address__c, Activity_Type__c, Authorized_individuals__c FROM License__c where Id = :currentRecordId];
        }    
    }
}