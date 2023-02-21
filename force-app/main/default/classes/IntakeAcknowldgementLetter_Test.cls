@isTest
private class IntakeAcknowldgementLetter_Test {
    
    @isTest static void testIntakeAcknowldgementLetterController() {
        
        Case caseRecord = TestRecord.createIntake();
        insert caseRecord;
        ApexPages.currentPage().getParameters().put('id',caseRecord.Id);
        ApexPages.StandardController ctrl = new ApexPages.StandardController(caseRecord);
        IntakeAcknowldgementLetterController obj = new IntakeAcknowldgementLetterController(ctrl);
        system.assertEquals(caseRecord.Id != null,true);
        
    }

}