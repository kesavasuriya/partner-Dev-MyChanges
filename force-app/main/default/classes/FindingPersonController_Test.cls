@isTest
private class FindingPersonController_Test {

    @isTest static void testGetInitialInformation() {
        
        System.assertEquals(FindingPersonController.getInitialInformation() != null, true);
    }
     
    @isTest static void testGetPersons() {
        
        Contact personRec = TestRecord.contact('Test', 'Person');
        personRec.SSN__c = '1569622458';
        personRec.State_Id_Drivers_License__c = '202020';
        personRec.Address_Line_1__c = '8015 Delhaven Rd';
        personRec.Address_Line_2__c = '1758 Stokesley Road';
        personRec.Address_ZipCode__c = '21222';
        personRec.Address_State__c = 'Maryland';
        personRec.Address_City__c = 'Dundalk';
		personRec.County_Address__c = 'Baltimore County';
		insert personRec;
        
        Contact getPerson = [SELECT Id, Casevault_PID__c, Age__c FROM Contact WHERE Id = :personRec.Id];
        
		FindingPersonController.SearchInputWrapper searchIns = new FindingPersonController.SearchInputWrapper();
        searchIns.firstName = personRec.FirstName;
        searchIns.lastName = personRec.LastName;
        searchIns.dob = personRec.Date_of_Birth__c;
        searchIns.casevaultPId = getPerson.Casevault_PID__c;
        searchIns.ssn = personRec.SSN__c;
        searchIns.stateId = personRec.State_Id_Drivers_License__c;
        searchIns.gender = personRec.Gender__c;
        searchIns.approxAge = getPerson.Age__c;
        searchIns.addLine1 = personRec.Address_Line_1__c;
        searchIns.addLine2 = personRec.Address_Line_2__c;
        searchIns.zipCode = personRec.Address_ZipCode__c;
        searchIns.state = personRec.Address_State__c;
        searchIns.city = personRec.Address_City__c;
        searchIns.country = personRec.County_Address__c;
        System.assertEquals(FindingPersonController.getPersons(JSON.serialize(searchIns)) != null, true);
        System.assertEquals(FindingPersonController.getPersons('') == null, true);
        
		System.assertEquals(FindingPersonController.updatePerson(JSON.serialize(personRec)) != null, true);
		System.assertEquals(FindingPersonController.updatePerson('') == null, true);                           
    }
}