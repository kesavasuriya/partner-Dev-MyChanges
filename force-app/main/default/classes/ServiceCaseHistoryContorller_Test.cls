@isTest
private class ServiceCaseHistoryContorller_Test {

    @isTest static void testServiceCaseHistoryContorller() {
        
        Case intakeRec = TestRecord.createIntake();
        intakeRec.Origin = 'Request for services';
        insert intakeRec;
        
        User supervisor = [SELECT Id FROM User WHERE Profile.Name = 'Casevault Supervisor' LIMIT 1];
        intakeRec.Supervisor_Approver__c = supervisor.Id;
        intakeRec.Intake_Approval_Status__c = 'Approved';
        update intakeRec;
        
        Service_Case__c serviceCaseRec = [SELECT Id FROM Service_Case__c LIMIT 1];
        Service_Case_History__c serviceCaseHistoryRec = new Service_Case_History__c();
        serviceCaseHistoryRec.Service_Case__c = serviceCaseRec.Id;
        serviceCaseHistoryRec.Status__c = 'Close';
        insert serviceCaseHistoryRec;
        
        System.assertEquals( ServiceCaseHistoryContorller.getService(serviceCaseRec.Id) != null, true );
        
    }
}