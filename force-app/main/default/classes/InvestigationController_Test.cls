@istest
private class InvestigationController_Test {
    
    @testSetup static void setup(){
        
        Case caseRec = TestRecord.createIntake();
        insert caseRec;
        
        Investigation__c investigationRec = TestRecord.investigation();
        investigationRec.Intake__c = caseRec.Id;
        insert investigationRec;
        
        Contact contactRec = TestRecord.contact('Demo','Test');
        contactRec.Intake_Person_Role__c = 'Biological Child';
        //contactRec.Investigation__c = investigationRec.Id;
        insert contactRec;
        
        Child_Removal__c childRemovalRecord = TestRecord.childRemoval(contactRec.Id);
        childRemovalRecord.Investigation__c = investigationRec.Id;
        childRemovalRecord.Removal_End_Date_Time__c = null;
        insert childRemovalRecord;
        
    }
    
    @isTest static void TestgetInvestigationRecord() {
        
        Investigation__c investigationRec = [SELECT Id FROM Investigation__c LIMIT 1];
        
        System.assertEquals(InvestigationController.getInvestigationRecord(investigationRec.Id, 'Investigation__c') != null, true);
        
        Child_Removal__c childRemovalRec = [SELECT Id FROM Child_Removal__c LIMIT 1];
        
        System.assertEquals(InvestigationController.getInvestigationRecord(childRemovalRec.Id, 'Child_Removal__c') != null, true);
        System.assertEquals(InvestigationController.getInvestigationRecord(null, 'Investigation__c') == null, true);
    }
}