@isTest
private class CourtController_Test {
    
    @testSetup static void setup(){
        
        Service_Case__c servicecaseRec = TestRecord.serviceCase('0000123');
        insert servicecaseRec;
        
        Contact contactRec = TestRecord.contact('Demo','Test');
        //contactRec.Service_Case__c = servicecaseRec.Id;
        contactRec.Intake_Person_Role__c = 'Advocate';
        insert contactRec;
        
        Contact contactRec1 = TestRecord.contact('Demo','Test1');
        //contactRec1.Service_Case__c = servicecaseRec.Id;
        contactRec1.Intake_Person_Role__c = 'Casehead';
        insert contactRec1;
        
        Court__c courtRec = TestRecord.petition(contactRec.Id);
        insert courtRec;
        
        Sibling__c siblingRec = new Sibling__c();
        siblingRec.Court__c = courtRec.Id;
        insert siblingRec;
        
        Subpoenaed__c SubpoenaedRec = new Subpoenaed__c();
        SubpoenaedRec.Court__c = courtRec.Id;
        insert SubpoenaedRec;
    }
    
    @isTest static void TestgetInitialInfos() {
        
        Service_Case__c servicecaseRec = [SELECT Id FROM Service_Case__c LIMIT 1];
        System.assertEquals(CourtController.getInitialInfos(servicecaseRec.Id) != null, true);
        
    }
    
    @isTest static void TestdeletePetition() {
        
        Court__c courtRec = [SELECT Id, Type_of_Petition__c, Petition_for_Child__c, Petition_Date__c FROM Court__c LIMIT 1];
        CourtController.deletePetition(JSON.serialize(courtRec));
        
        List<Court__c> courtLst = [SELECT Id, Type_of_Petition__c, Petition_for_Child__c, Petition_Date__c FROM Court__c LIMIT 1];
        System.assertEquals(courtLst.size() == 0, true);
        
        System.assertEquals(CourtController.deletePetition('') == null, true);
    }
    
    @isTest static void TestupsertPetition() {
        
        Contact contactRec = [SELECT Id FROM Contact LIMIT 1];
        Court__c courtInsertRec = TestRecord.petition(contactRec.Id);
        System.assertEquals(CourtController.upsertPetition(JSON.serialize(courtInsertRec), '', '') != null, true);
        
        Court__c courtRec = [SELECT Id, Type_of_Petition__c, Petition_for_Child__c, Petition_Date__c FROM Court__c LIMIT 1];
        List<Sibling__c> siblingRec = [SELECT Id FROM Sibling__c LIMIT 1];
        List<Subpoenaed__c> SubpoenaedRec = [SELECT Id FROM Subpoenaed__c LIMIT 1];
            
        System.assertEquals(CourtController.upsertPetition(JSON.serialize(courtRec), JSON.serialize(siblingRec), JSON.serialize(SubpoenaedRec)) != null, true);
    	System.assertEquals(CourtController.upsertPetition('' , '' ,'') == null, true);
        
        Sibling__c siblingInsertRec = new Sibling__c();
        siblingInsertRec.Court__c = courtRec.Id;
        List<Sibling__c> siblingLst = new List<Sibling__c>();
        siblingLst.add(siblingInsertRec);
        
        Subpoenaed__c SubpoenaedInsertRec = new Subpoenaed__c();
        SubpoenaedInsertRec.Court__c = courtRec.Id;
        List<Subpoenaed__c> SubpoenaedLst = new List<Subpoenaed__c>();
        SubpoenaedLst.add(SubpoenaedInsertRec);
        
        System.assertEquals(CourtController.upsertPetition(JSON.serialize(courtRec), JSON.serialize(siblingLst), JSON.serialize(SubpoenaedLst)) != null, true);
              
    }
    
    @isTest static void TestgetCourtChildDetails() {
        
        Court__c courtRec = [SELECT Id, Type_of_Petition__c, Petition_for_Child__c ,Petition_Date__c FROM Court__c LIMIT 1];
        System.assertEquals(CourtController.getCourtChildDetails(courtRec.Id) != null, true);
        
    }
    
    @isTest static void TestdeleteSiblingRec() {
        
        Sibling__c siblingRec = [SELECT Id, Court__c FROM Sibling__c LIMIT 1];
        
        CourtController.deleteSiblingRec(JSON.serialize(siblingRec));
        List<Sibling__c> siblingLst = [SELECT Id, Court__c FROM Sibling__c LIMIT 1];
        System.assertEquals(siblingLst.size() == 0, true);
        
        System.assertEquals(CourtController.deleteSiblingRec('') == null, true);
    }
    
    @isTest static void TestdeleteSubpoenaed() {
        Subpoenaed__c SubpoenaedRec = [SELECT Id, Court__c FROM Subpoenaed__c LIMIT 1];
        
        CourtController.deleteSubpoenaed(JSON.serialize(SubpoenaedRec));
        List<Subpoenaed__c> SubpoenaedLst = [SELECT Id, Court__c FROM Subpoenaed__c LIMIT 1];
        System.assertEquals(SubpoenaedLst.size() == 0, true);
        
        System.assertEquals(CourtController.deleteSubpoenaed('') == null, true);
        
        
        
    }
}