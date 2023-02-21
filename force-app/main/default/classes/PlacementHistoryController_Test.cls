@isTest
private class PlacementHistoryController_Test {
    
    @isTest static void testPlacementHistoryController() {
        
        User supervisor = [SELECT Id FROM User WHERE Profile.Name = 'Casevault Supervisor' LIMIT 1];

        Case intakeRec = TestRecord.createIntake();
        intakeRec.Origin = 'Request for services';
        intakeRec.Supervisor_Approver__c = supervisor.Id;
        insert intakeRec;
        
        Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();          
        req.setObjectId(intakeRec.id);        
        Approval.ProcessResult result = Approval.process(req);
        
        Service_Case__c serviceCaseRec = TestRecord.serviceCase('');
        serviceCaseRec.Intake__c = intakeRec.Id;
        insert serviceCaseRec;
        
        Contact personRec = TestRecord.contact('Test', 'Child');
        //personRec.Service_Case__c = serviceCaseRec.Id;
        insert personRec;
        
        Child_Removal__c childRemovalRec = TestRecord.childRemoval(personRec.Id);
        childRemovalRec.Service_Case__c = serviceCaseRec.Id;
        insert childRemovalRec;
        
        Placement__c placementRec = TestRecord.placement(childRemovalRec.Id);
        placementRec.Service_Case__c = serviceCaseRec.Id;
        placementRec.Placement_Approval_Status__c = 'Approved';
        insert placementRec;
        
        
        Placement__c updatePlacement = new Placement__c();
        updatePlacement.Id = placementRec.Id;
        updatePlacement.Begin_Date__c = Date.newInstance(2021,4,29);
        updatePlacement.End_Date__c = Date.newInstance(2022,4,29);
        updatePlacement.Exit_Type__c = 'Change in Placement';
        updatePlacement.Exit_Date_Time__c = DateTime.newInstance(Date.newInstance(2022,4,29), Time.newInstance(1, 0, 0, 0));
        
        System.assertEquals( PlacementHistoryController.upsertPlacementAndSubmitForApproval(JSON.serialize(updatePlacement), supervisor.Id) != null, true);
        System.assertEquals(PlacementHistoryController.getCurrentRecordHistroy(placementRec.Id) != null, true);
        System.assertEquals( PlacementHistoryController.upsertPlacementAndSubmitForApproval('','') != null, false);


    }
    
}