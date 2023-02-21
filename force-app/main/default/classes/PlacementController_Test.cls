@isTest
private class PlacementController_Test {
    
    @testSetup static void setup () {
        
        List<Service_Case__c> serviceCases = new List<Service_Case__c>();
        Service_Case__c openServiceCase = TestRecord.serviceCase('');
        serviceCases.add(openServiceCase); 
        
        Service_Case__c closedServiceCase = TestRecord.serviceCase('');
        closedServiceCase.Status__c = 'Close';
        serviceCases.add(closedServiceCase);
        insert serviceCases;
        
        Service_Case__c serviceCaseRec = [SELECT Id FROM Service_Case__c WHERE Status__c != 'Close' LIMIT 1];
        
        Contact personRec = TestRecord.contact('Demo','Test');
        //personRec.Service_Case__c = serviceCaseRec.Id;
        insert personRec;
        
        Child_Removal__c childRemovalRec = TestRecord.childRemoval(personRec.Id);
        childRemovalRec.Service_Case__c = serviceCaseRec.Id;
        insert childRemovalRec;
        
        Account providerRec = new Account();
        providerRec.Name = 'testAcc';
        providerRec.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Public Provider').getRecordTypeId();
        providerRec.Individual_First_Name__c = 'firstAcc';
        providerRec.Individual_Middle_Name__c = 'middleAcc';
        providerRec.Individual_Last_Name__c = 'lastAcc';
        providerRec.Child_Characteristics_Willing_To_Accept__c  = 'Aggression - Verbal To Adults';
        providerRec.Local_Department__c  = 'Baltimore City';
        insert providerRec;
        
        Placement__c placementRec = TestRecord.placement(childRemovalRec.Id);
        placementRec.Child__c = personRec.Id;
        placementRec.Service_Case__c = serviceCaseRec.Id;
        placementRec.Is_Placement_Reimbursible__c = 'Assigned dynamically';
        placementRec.Provider__c = providerRec.Id;
        placementRec.Begin_Date__c = Date.newInstance(2021, 2, 1);
        insert placementRec;
        
        Structure_Services__c structureServiceRec = new Structure_Services__c ();
        structureServiceRec.Provider__c = providerRec.Id;
        structureServiceRec.Structure_Service_Name__c = '10_Regular Foster Care';
        structureServiceRec.Start_Date__c = System.today();
        insert structureServiceRec;
        
        CWS_Contract__c contractRec = new CWS_Contract__c();
        contractRec.Provider__c = providerRec.Id;
        insert contractRec;
        
        Program__c programRec = new Program__c();
        programRec.Contracts__c = contractRec.Id;
        insert programRec;
        
        CPA_home__c cpahomeRec = new CPA_home__c();
        cpahomeRec.Program__c = programRec.Id;
        cpahomeRec.CPA_Home_Provider_Name__c = providerRec.Id;
        insert cpahomeRec;
    }
       
    @isTest static void testPlacementController() {
        
        Placement__c getPlacement = [SELECT Id, Name, Is_Placement_Reimbursible__c, Begin_Date__c, Service_Case__c, Child__c FROM Placement__c LIMIT 1];
        System.assertEquals(PlacementController.upsertPlacementRec(JSON.serialize(getPlacement)), null);
        
        getPlacement.Begin_Date__c = null;
        
        System.assertEquals(PlacementController.upsertPlacementRec(JSON.serialize(getPlacement)) != null, true);
        System.assertEquals(PlacementController.upsertPlacementRec('') == null, true);
        System.assertEquals(PlacementController.onSavePlacementCPAHome(JSON.serialize(getPlacement)), getPlacement.Id);
        System.assertEquals(PlacementController.onSavePlacementCPAHome('') == null, true);
        System.assertEquals(PlacementController.getChildRemovalRecords(getPlacement.Service_Case__c) != null, true);
        System.assertEquals(PlacementController.getPlacementUnderChildRemoval(getPlacement.Service_Case__c) != null, true);
        System.assertEquals(PlacementController.getInitialInfoCPAHome(getPlacement.Id) != null, true);
        System.assertEquals(PlacementController.getInitialInformation(getPlacement.Id) != null, true);
        System.assertEquals(PlacementController.getCurrentCaseRecord(getPlacement.Id) != null, true);
        System.assertEquals(PlacementController.getCurrentPlacementApprovalDetails(getPlacement.Id) != null, true);
        
        Service_Case__c closedServiceCaseRec = [SELECT Id FROM Service_Case__c WHERE Status__c = 'Close' LIMIT 1];
        System.assertEquals(PlacementController.getPlacementUnderChildRemoval(closedServiceCaseRec.Id) != null, true);
    }
        
    @isTest static void testFetchAccount() {
        
        PlacementController.SearchInputWrapper publicProviderIns = new PlacementController.SearchInputWrapper();
        publicProviderIns.providerName = 'testAcc';
        publicProviderIns.providerType = 'Public Provider';
        publicProviderIns.firstName = 'first';
        publicProviderIns.middleName = 'middle';
        publicProviderIns.lastName = 'last';
        publicProviderIns.childCharacter = 'Aggression - Verbal To Adults';
        publicProviderIns.localDept = 'Baltimore City';
        publicProviderIns.providerId = '1';
        publicProviderIns.placementStructure = 'Regular Foster Care';
        System.assertEquals(PlacementController.fetchAccount(JSON.serialize(publicProviderIns)) != null, true);
        
        PlacementController.SearchInputWrapper privateProviderIns = new PlacementController.SearchInputWrapper();
        privateProviderIns.providerName = 'testAcc2';
        privateProviderIns.providerType = 'Private Provider Org';
        privateProviderIns.firstName = 'first2';
        privateProviderIns.middleName = 'middle2';
        privateProviderIns.lastName = 'last2';
        privateProviderIns.childCharacter = 'Aggression - Verbal To Adults';
        privateProviderIns.localDept = 'Baltimore City';
        privateProviderIns.providerId = '1';
        privateProviderIns.placementStructure = 'Regular Foster Care';
        System.assertEquals(PlacementController.fetchAccount(JSON.serialize(privateProviderIns)) != null, true);         
    }
    
    @isTest static void testPlacementTrigger() {
        
        Placement__c getPlacement = [SELECT Id FROM Placement__c LIMIT 1];
        getPlacement.Placement_Approval_Status__c = 'Approved';
        update getPlacement;
        
        System.assertEquals(getPlacement.Id != null, true);
        Database.delete(getPlacement.Id, false);
		        
    }
    
}