@istest
private class CourtHearingController_Test {
    
     @testSetup static void setup(){
         
        Service_Case__c serviceCaseRec = TestRecord.serviceCase('0000123');
        insert serviceCaseRec;
         
        Investigation__c investigationRecord = TestRecord.investigation();
        insert investigationRecord;
         
        Contact contactRec = TestRecord.contact('Demo','Test');
        //contactRec.Service_Case__c = serviceCaseRec.Id;
        insert contactRec;
         
        List<Contact> childId = [SELECT Id FROM Contact];
        Court__c petitionRec = TestRecord.createPetition(childId[0].Id,'5600');
        petitionRec.Service_Case__c = serviceCaseRec.Id;
        petitionRec.Investigation__c = investigationRecord.Id;
        petitionRec.Other_Client_named_on_Petition__c = contactRec.Id;
        insert petitionRec;
         
        Court__c petitionRec1 = TestRecord.createPetition(childId[0].Id,'500');
        petitionRec1.Service_Case__c = serviceCaseRec.Id;
        petitionRec1.Investigation__c = investigationRecord.Id;
        petitionRec1.Other_Client_named_on_Petition__c = null;
        insert petitionRec1;
         
        Court_Petition_Hearing__c courtHearingRec = TestRecord.createCourtCase('400');
        courtHearingRec.Court__c = petitionRec.Id;
        courtHearingRec.Hearing_Date_and_Time__c = DateTime.now();
        insert courtHearingRec;
         
        Court_Petition_Hearing__c courtHearingRec1 = TestRecord.createCourtCase('300');
        courtHearingRec1.Court__c = petitionRec1.Id;
        insert courtHearingRec1;
     }
    
    @isTest static void testgetInitInfos() {
        
        Service_Case__c servicecaseRec = [SELECT Id FROM Service_Case__c LIMIT 1];
        Investigation__c invesRec = [SELECT Id 	FROM Investigation__c LIMIT 1];
        
        System.assertEquals(CourtHearingController.getInitInfos(servicecaseRec.Id) != null, true);
        System.assertEquals(CourtHearingController.getInitInfos(invesRec.Id) != null, true);
        System.assertEquals(CourtHearingController.getInitInfos('') == null, true);
        
    }
    
   
    @isTest static void testcreateCourtCaseRec() {
        
        Court__c courtRec = [SELECT Id, Hearing_Status__c FROM Court__c LIMIT 1];
        Court_Petition_Hearing__c courtHearingInsertRec = TestRecord.createCourtCase('600');
        System.assertEquals(CourtHearingController.createCourtCaseRec(JSON.serialize(courtHearingInsertRec)) != null, true);
        
        courtRec.County__c  = 'None';
        System.assertEquals(CourtHearingController.createCourtCaseRec(JSON.serialize(courtRec)) != null, true);
        System.assertEquals(CourtHearingController.createCourtCaseRec('') == null, true);


    }
    
    @isTest static void testgetSelectCourtCaseNumberRec() {
        
        Court__c courtRec = [SELECT Id,Court_Case_Number__c FROM Court__c LIMIT 1];
        System.assertEquals(CourtHearingController.getSelectCourtCaseNumberRec(courtRec.Id) != null, true);
        System.assertEquals(CourtHearingController.getSelectCourtCaseNumberRec(null) == null, true);

    }
    
    @isTest static void testdeleteCourtCaseNumberRec() {
        
        Court__c courtRec = [SELECT Id,Court_Case_Number__c FROM Court__c LIMIT 1];
        CourtHearingController.deleteCourtCaseNumberRec(courtRec.Id); 
        
        List<Court__c> courtLst = [SELECT Id,Court_Case_Number__c FROM Court__c WHERE Id =: courtRec.Id];
        System.assertEquals(courtLst.size() == 0, true);

    }
    
    @isTest static void testgetHearingClientsInfos() {
        
        Court__c courtRec = [SELECT Id,Court_Case_Number__c FROM Court__c LIMIT 1];
        String actualResult = CourtHearingController.getHearingClientsInfos(courtRec.Id);
        
        CourtHearingController.ClientsWrapper clientWrapperIns = new CourtHearingController.clientsWrapper();
        List<Court__c> courtList = [SELECT Id, Court_Petition_ID__c, Petition_for_Child__c, Petition_for_Child__r.Name, Other_Client_named_on_Petition__c,Other_Client_named_on_Petition__r.Name FROM Court__c WHERE Id = :courtRec.Id AND Petition_for_Child__c != null];
        if (courtList != null && courtList.size() > 0) {
            
            clientWrapperIns.clientId = courtList[0].Petition_for_Child__c;
            clientWrapperIns.clientName = courtList[0].Petition_for_Child__r.Name;
            clientWrapperIns.otherClientNames = courtList[0].Other_Client_named_on_Petition__r.Name;     
        }
        String expectedOutput = JSON.serialize(clientWrapperIns);
        
        System.assertEquals(expectedOutput, actualResult);
        System.assertEquals(CourtHearingController.getHearingClientsInfos('') == null, true);
    }
    
    @isTest static void testcreateScheduledHearingRec() {
        
         Court_Petition_Hearing__c courtHearingRec = TestRecord.createCourtCase('300');
         System.assertEquals(CourtHearingController.createScheduledHearingRec(JSON.serialize(courtHearingRec)) != null, true);
        
         Court_Petition_Hearing__c courtHearingUpdateRec = [SELECT Id, Hearing_Status__c  FROM Court_Petition_Hearing__c LIMIT 1];
         courtHearingUpdateRec.Hearing_Status__c = 'Contested Hearing';
         System.assertEquals(CourtHearingController.createScheduledHearingRec(JSON.serialize(courtHearingUpdateRec)) != null, true);
         System.assertEquals(CourtHearingController.createScheduledHearingRec('') == null, true);
    }
    
    @isTest static void testgetHearingEditRec() {
        
		Court_Petition_Hearing__c courtHearingRec = [SELECT Id FROM Court_Petition_Hearing__c LIMIT 1];
        System.assertEquals(CourtHearingController.getHearingEditRec(courtHearingRec.Id) != null, true);
        System.assertEquals(CourtHearingController.getHearingEditRec(null) == null, true);
        
    }
    
    @isTest static void testgetClientRecord() {
        
		Court_Petition_Hearing__c courtHearingRec = [SELECT Id FROM Court_Petition_Hearing__c LIMIT 1];
        System.assertEquals((CourtHearingController.getClientRec(courtHearingRec.Id)).size() > 0 ,true);
        System.assertEquals((CourtHearingController.getClientRec(null)) == null ,true);
        
    }
    
    @isTest static void testupsertHearingRec() {
        
        System.assertEquals(CourtHearingController.upsertHearingRecord(JSON.serialize(TestRecord.createCourtCase('300'))) != null, true);

        Court_Petition_Hearing__c courtHearingUpdateRec = [SELECT Id, Court_Case_Number__c, Start_Date__c FROM Court_Petition_Hearing__c LIMIT 1];
        courtHearingUpdateRec.Start_Date__c = Date.today();
        System.assertEquals(CourtHearingController.upsertHearingRecord(JSON.serialize(courtHearingUpdateRec)) != null, true);
        System.assertEquals(CourtHearingController.upsertHearingRecord('') == null, true);

    }


}