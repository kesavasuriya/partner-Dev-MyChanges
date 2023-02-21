@isTest
private class InvestigationFindingsController_Test {
    
    @testSetup static void setup() {
        
        Contact contactRecord = TestRecord.contact('Test', 'Demo');
        insert contactRecord;
        
        Contact contactRecord1 = TestRecord.contact('Test', 'Demo1');
        insert contactRecord1;
        
        Investigation__c investigationRecord = TestRecord.investigation();
        insert investigationRecord;
        
        Investigation_Findings__c invesFindRec = TestRecord.createInvestigationFinding();
        invesFindRec.Investigation__c = investigationRecord.Id;
        invesFindRec.Contact__c = contactRecord.Id;
        invesFindRec.Alleged_Maltreators__c = contactRecord1.Id;
        insert invesFindRec;
        
        Relationship__c  relationShipRecord = TestRecord.createRelationship(contactRecord.Id, contactRecord1.Id);
        insert relationShipRecord;
    }
    
    @isTest static void TestfetchInformation() {
        
        Investigation__c invesRec = [SELECT Id FROM Investigation__c];
        system.assertEquals(InvestigationFindingsController.fetchInformation(invesRec.Id) != null, true);
    }
    
    @isTest static void TestupdateInvestigationFinding() {
        
        Investigation_Findings__c invesFindRec = [SELECT Id, Investigation__c FROM Investigation_Findings__c LIMIT 1];
        invesFindRec.Maltreatment_Type__c = 'Test';
        InvestigationFindingsController.updateInvestigationFinding(JSON.serialize(invesFindRec));
        
        Investigation_Findings__c invesFindTestRec = [SELECT Id, Investigation__c, Maltreatment_Type__c FROM Investigation_Findings__c LIMIT 1];
        system.assertEquals(invesFindTestRec.Maltreatment_Type__c == 'Test', true);
        
        invesFindRec.Abuse_Types__c = 'T1';
        try {
        	InvestigationFindingsController.updateInvestigationFinding(JSON.serialize(invesFindRec));
        } catch (AuraHandledException e){
            
        }
        
        Investigation_Findings__c invesFindTestRec1 = [SELECT Id, Investigation__c, Abuse_Types__c, Maltreatment_Type__c FROM Investigation_Findings__c LIMIT 1];
        system.assertEquals(invesFindTestRec1.Abuse_Types__c != invesFindRec.Abuse_Types__c , true);

    }

}