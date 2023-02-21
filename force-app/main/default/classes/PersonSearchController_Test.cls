@isTest
private class PersonSearchController_Test {

    @isTest static void testPersonSearchController() {
        
        Case intakeRec = TestRecord.createIntake();
        insert intakeRec;
        
        Contact personRec = TestRecord.contact('Test', 'Person');
        personRec.SSN__c = '123456789';
        personRec.State_Id_Drivers_License__c = '202020';
        //personRec.Intake__c = intakeRec.Id;
        insert personRec;
        
        Contact getPersonRec = [SELECT Id, Casevault_PID__c FROM  Contact WHERE Id = :personRec.Id];
        PersonSearchController.SearchInputWrapper searchIns = new PersonSearchController.SearchInputWrapper();
        searchIns.firstName = personRec.FirstName;
        searchIns.lastName = personRec.LastName;
        searchIns.dob = personRec.Date_of_Birth__c;
        searchIns.casevaultPid = getPersonRec.Casevault_PID__c;
        searchIns.ssn = personRec.SSN__c;
        searchIns.dlNo = personRec.State_Id_Drivers_License__c;
        
        System.assertEquals(PersonSearchController.getContacts(JSON.serialize(searchIns)) != null, true);
        System.assertEquals(PersonSearchController.getContacts('') == null, true);     
    }
}