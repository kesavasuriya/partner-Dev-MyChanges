@isTest
private class VisitationLogController_Test {

    @isTest static void testVisitationLogController() {
        
        Service_Case__c serviceCaseRec = TestRecord.serviceCase('');
        insert serviceCaseRec;
        
        Contact personRec = TestRecord.contact('Test', 'Person');
        //personRec.Service_Case__c = serviceCaseRec.Id;
        insert personRec;
        
        Collateral__c collateralRec = TestRecord.createCollateral();
        collateralRec.Service_Case__c = serviceCaseRec.Id;
        insert collateralRec;
        
        Visitation_Log__c visitationLogRec = TestRecord.createVisitationLog();
        visitationLogRec.Service_Case__c = serviceCaseRec.Id;
        visitationLogRec.Client__c = personRec.Id;
        
        System.assertEquals( VisitationLogController.createVisitationLogRecord(JSON.serialize(visitationLogRec)) != null, true);
        
        Visitation_Log__c getVisitationLogRec = [SELECT Id, Service_Case__c, Client__c, Visit_Date__c FROM Visitation_Log__c LIMIT 1 ];
        getVisitationLogRec.Visit_Date__c = System.today();
        
        System.assertEquals( VisitationLogController.createVisitationLogRecord(JSON.serialize(getVisitationLogRec)) != null, true);        
        System.assertEquals( VisitationLogController.getInitialInformation(serviceCaseRec.Id) != null, true);        
        System.assertEquals( VisitationLogController.deleteVisitationRec(JSON.serialize(getVisitationLogRec)) != null, true);   
        System.assertEquals( VisitationLogController.createVisitationLogRecord('') == null, true);
        System.assertEquals( VisitationLogController.deleteVisitationRec('') == null, true);          
    }
}