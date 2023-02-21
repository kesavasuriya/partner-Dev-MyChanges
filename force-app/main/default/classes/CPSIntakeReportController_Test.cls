@isTest
private class CPSIntakeReportController_Test {
    
    @testSetup static void setup() {
        
        Case caseRec = TestRecord.createIntake();
        insert caseRec;
        
        Investigation__c investigationRec = TestRecord.investigation();
        insert investigationRec;
        
        Service_Case__c serviceCaseRec = TestRecord.serviceCase('test');
        serviceCaseRec.Intake__c = caseRec.Id;
        insert serviceCaseRec;
    }
    
    @isTest static void testCPSIntakeReportController() {
        
        List<Service_Case__c> servicecaseLst = [SELECT Id, Intake__c FROM Service_Case__c ];
        ApexPages.currentPage().getParameters().put('id', servicecaseLst[0].Id);
        CPSIntakeReportController obj = new CPSIntakeReportController();
        
        ApexPages.StandardController ctrl = new ApexPages.StandardController(servicecaseLst[0]);
        CPSIntakeReportController obj2 = new CPSIntakeReportController(ctrl);
        system.assertEquals(servicecaseLst[0].Id != null, true);
        
    }
    
    @isTest static void testCPSIntakeReportController2() {
        
        List<Investigation__c> investigationLst = [SELECT Id, Name FROM Investigation__c];
        ApexPages.currentPage().getParameters().put('id', investigationLst[0].Id);
        CPSIntakeReportController obj = new CPSIntakeReportController();
        system.assertEquals(investigationLst[0].Id != null, true);
        
    }
    
    @isTest static void testCPSIntakeReportController3() {
        
        List<Case> caselst = [SELECT Id FROM Case];
        ApexPages.currentPage().getParameters().put('id', caselst[0].Id);
        CPSIntakeReportController obj = new CPSIntakeReportController();
        system.assertEquals(caselst[0].Id != null, true);

        
    }

}