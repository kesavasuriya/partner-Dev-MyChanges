@istest
private class IntakeCustomController_Test {
    
    @testSetup static void setup(){
        
        Case intakeRec = TestRecord.createIntake();
        insert intakeRec;
    }
    
    @isTest static void testupdateIntake() {
        
        Case caseRec = [SELECT Id, Origin, Communication__c, Jurisdiction__c, Received_Date__c, Status, First_Name__c, Last_Name__c, Role__c, Description FROM Case LIMIT 1];
        
        caseRec.First_Name__c = 'Test1';
        IntakeCustomController.updateIntake(JSON.serialize(caseRec));
        Case caseTestRec = [SELECT Id, First_Name__c FROM Case LIMIT 1];
        system.assert(caseTestRec.First_Name__c == 'Test1', true);
        
        IntakeCustomController.getInitialWrapper initWrap = new IntakeCustomController.getInitialWrapper();
        String caseRecResult = IntakeCustomController.getInitialInformation(caseRec.Id);
        initWrap = (IntakeCustomController.getInitialWrapper)JSON.deserialize(caseRecResult, IntakeCustomController.getInitialWrapper.class );
        System.assertEquals(caseRec.Id, initWrap.caseRecIns.Id);        
        caseRec.Status = 'Teststatus';
        
        try {
        	IntakeCustomController.updateIntake(JSON.serialize(caseRec));
        } catch (AuraHandledException e) {
            
        }
        Case caseTestRec1 = [SELECT Id, Status FROM Case LIMIT 1];
          
        
    }
    
}