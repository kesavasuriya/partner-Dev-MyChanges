@isTest
private class LicenseController_Test {
    
    @isTest static void testLicenseController() {
        
        
        License__c licenseRec = new License__c();
        insert licenseRec;
        
        Sanction__c sanctionRec = new Sanction__c();
        sanctionRec.License__c = licenseRec.Id;
        insert sanctionRec;

        ApexPages.currentPage().getParameters().put('id',licenseRec.Id);
        ApexPages.StandardController ctrl = new ApexPages.StandardController(licenseRec);
        LicenseController obj = new LicenseController(ctrl);
        
        License__c license = [SELECT Id, Name, Activity_Date__c, Address__c, Activity_Type__c, Authorized_individuals__c FROM License__c where Id = :licenseRec.Id];
        System.assertEquals(obj.licenseIns, license);
             
    }

}