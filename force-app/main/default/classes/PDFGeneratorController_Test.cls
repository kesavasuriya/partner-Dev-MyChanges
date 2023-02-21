@isTest
private class PDFGeneratorController_Test {
    
    @isTest static void testPDFGeneratorController() {
        
        Case caseRecord = TestRecord.createIntake();
        insert caseRecord;
        Case caseRec = [SELECT Id, CaseNumber, First_Name__c, Middle_Name__c, Last_Name__c, Title__c, Role__c, SuppliedEmail, City__c, Address_1__c, Address_2__c FROM Case where Id = :caseRecord.Id];

        ApexPages.currentPage().getParameters().put('id',caseRecord.Id);
        ApexPages.StandardController ctrl = new ApexPages.StandardController(caseRecord);
        PDFGeneratorController obj = new PDFGeneratorController(ctrl);
        System.assertEquals(obj.caseIns, caseRec);
    }

}