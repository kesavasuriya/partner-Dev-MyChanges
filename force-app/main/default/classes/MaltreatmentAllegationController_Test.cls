@isTest
private class MaltreatmentAllegationController_Test {
    
    @testSetup static void setup() {
        
        Investigation_Findings__c invesFindRec = TestRecord.createInvestigationFinding();
        insert invesFindRec;
        
        Investigation__c invesRec = TestRecord.investigation();
        insert invesRec;
        
        Contact conRec = TestRecord.contact('test', 'demo');
        insert conRec;
        
        Maltreatment_Allegation__c maltreatmentAllegationRec = TestRecord.MaltreatmentRec(conRec.Id);
        maltreatmentAllegationRec.Investigation__c = invesRec.Id;
        insert maltreatmentAllegationRec;
    }
    
    @isTest static void TestfetchInformation() {
        
        Investigation_Findings__c invesFindRec = [SELECT Id FROM Investigation_Findings__c LIMIT 1];
        
        system.assertEquals(MaltreatmentAllegationController.fetchInformation(invesFindRec.Id) != null, true);
        
        system.assertEquals(MaltreatmentAllegationController.fetchInformation('') == null, true);
    }
    
    @isTest static void TestfetchMaltreatmentRecords() {
        
        Maltreatment_Allegation__c maltreatmentRec = [SELECT Id FROM Maltreatment_Allegation__c];
        Contact contactRec = [SELECT Id FROM Contact LIMIT 1];
        
        system.assertEquals(MaltreatmentAllegationController.fetchMaltreatmentRecords(maltreatmentRec.Id, contactRec.Id) != null, true);
        
        system.assertEquals(MaltreatmentAllegationController.fetchMaltreatmentRecords('', '') == null, true);
    }
    
    @isTest static void TestdeleteMaltreatmentAllegation() {
        
        List<Maltreatment_Allegation__c> maltreatmentLst = [SELECT Id, Abuse_Types__c, Investigation__c FROM Maltreatment_Allegation__c LIMIT 1];
        List<List<Maltreatment_Allegation__c>> maltreatmentLstofLst = new  List<List<Maltreatment_Allegation__c>>();
        
        maltreatmentLstofLst.add(maltreatmentLst);
        MaltreatmentAllegationController.deleteMaltreatmentAllegation(maltreatmentLstofLst);
        
        List<Maltreatment_Allegation__c> maltreatmentRec = [SELECT Id, Abuse_Types__c FROM Maltreatment_Allegation__c WHERE Id =: maltreatmentLst[0].Id];
        system.assertEquals((maltreatmentRec.size() == 0), true);
    }
    
    @isTest static void TestupdateMaltreatmentAllegation() {
        
        Maltreatment_Allegation__c maltreatmentRec = [SELECT Id, Abuse_Types__c, This_maltreatment_is_not_applicable__c, Investigation__c FROM Maltreatment_Allegation__c];
        
        MaltreatmentAllegationController.updateMaltreatmentAllegation(maltreatmentRec.Id, true);
        Maltreatment_Allegation__c maltreatmentRec1 = [SELECT Id, Abuse_Types__c, This_maltreatment_is_not_applicable__c, Investigation__c FROM Maltreatment_Allegation__c WHERE Id =: maltreatmentRec.Id];
        system.assertEquals(maltreatmentRec1.This_maltreatment_is_not_applicable__c == true, true);
    }
}