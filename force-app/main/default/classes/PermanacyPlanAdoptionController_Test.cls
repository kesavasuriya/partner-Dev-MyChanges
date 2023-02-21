@isTest
private class PermanacyPlanAdoptionController_Test {
    
    /*@testSetup static void testRecords() {
        
        List<Contact> persons = new List<Contact>();
        
        Service_Case__c serviceCaseRec = TestRecord.serviceCase('');
        insert serviceCaseRec;
        
        Contact personChildRec = TestRecord.contact('Test', 'Child');
        //personChildRec.Service_Case__c = serviceCaseRec.Id;
        persons.add(personChildRec);
        
        Contact personCargiverRec = TestRecord.contact('Test', 'Caregiver');
        personCargiverRec.Intake_Person_Role__c = 'Biological Parent';
        //personCargiverRec.Service_Case__c = serviceCaseRec.Id; 
        persons.add(personCargiverRec);        
        insert persons;
        
        Account providerRec = TestRecord.createProvider('Test', 'Provider', 'Test');
        providerRec.Number_of_Beds__c = 20;
        providerRec.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Public Provider').getRecordTypeId();
        insert providerRec;
        
        Child_Removal__c childRemovalRec = TestRecord.childRemoval(personChildRec.Id);
        childRemovalRec.Primary_Caregiver__c = personCargiverRec.Id;
        childRemovalRec.Child_Removal_Approval_Status__c = 'Approved';
        childRemovalRec.Service_Case__c = serviceCaseRec.Id;
        insert childRemovalRec;
        
        Placement__c placementRec = [SELECT Id FROM Placement__c LIMIT 1];
        placementRec.Provider__c = providerRec.Id;
        placementRec.Placement_Approval_Status__c = 'Approved';
        update placementRec;
        
        Permanency_Plan__c permanencyPlanRec = TestRecord.permanencyPlan();
        permanencyPlanRec.Primary_Permanency_Plan__c = 'Adoption by a relative';
        permanencyPlanRec.Plan_Established_Date__c = Date.today();
        permanencyPlanRec.Concurrent_Permanency_Plan__c = 'Adoption by a non-relative';
        permanencyPlanRec.Service_Case__c = serviceCaseRec.Id;
        permanencyPlanRec.Placement__c = placementRec.Id;
        insert permanencyPlanRec;
    }
    
    @isTest static void testGetAdoptionInitialInfos() {
        
        Id permanencyPlanId = [SELECT Id FROM Permanency_Plan__c LIMIT 1].Id;
        Id providerId = [SELECT Id FROM Account LIMIT 1].Id;
        System.assertEquals(PermanacyPlanAdoptionController.getAdoptionInitialInfos(permanencyPlanId) != null, true);
        System.assertEquals(PermanacyPlanAdoptionController.getTPRRecommendationInitialInfos(permanencyPlanId) != null, true);
        System.assertEquals(PermanacyPlanAdoptionController.getAdoptionPlanningStageInitialInfos(permanencyPlanId) != null, true);
        
        System.assertEquals(PermanacyPlanAdoptionController.getAdoptionPlanningEmotionalInitialInfos(permanencyPlanId) != null, true);
        System.assertEquals(PermanacyPlanAdoptionController.getAdoptionPlanningEmotionalInitialInfos('') == null, true);
        
        System.assertEquals(PermanacyPlanAdoptionController.getAdoptionPlanningNarrativeInitialInfos(permanencyPlanId) != null, true);
        System.assertEquals(PermanacyPlanAdoptionController.getAdoptionPlanningNarrativeInitialInfos('') == null, true);
        
        System.assertEquals(PermanacyPlanAdoptionController.getTPRInitialInfos(permanencyPlanId) != null, true);
        System.assertEquals(PermanacyPlanAdoptionController.getAdoptionEffortsInfo(permanencyPlanId) != null, true);
        System.assertEquals(PermanacyPlanAdoptionController.getRateRecordInfo(permanencyPlanId) != null, true);
        
        System.assertEquals(PermanacyPlanAdoptionController.getSubsidyAgreementIntiInfos(permanencyPlanId) != null, true);
        System.assertEquals(PermanacyPlanAdoptionController.getSubsidyAgreementIntiInfos('') == null, true);
        
        System.assertEquals(PermanacyPlanAdoptionController.getEmotionalTiesInitInfo(permanencyPlanId) != null, true);        
        System.assertEquals(PermanacyPlanAdoptionController.getEmotionalTiesInitInfo('') == null, true);        
        
        System.assertEquals(PermanacyPlanAdoptionController.getDisclosureChecklistRecord(permanencyPlanId) != null, true);
        System.assertEquals(PermanacyPlanAdoptionController.getDisclosureChecklistRecord('') == null, true);
        
        System.assertEquals(PermanacyPlanAdoptionController.getBreakthelinkRecord(permanencyPlanId) != null, true);
        System.assertEquals(PermanacyPlanAdoptionController.getBreakthelinkRecord('') == null, true);
        
        System.assertEquals(PermanacyPlanAdoptionController.getActiveTab(permanencyPlanId) != null, true);
        
        Id supervisorId = [SELECT Id FROM User WHERE Profile.Name = 'Casevault Supervisor' LIMIT 1].Id; 
        System.assertEquals(PermanacyPlanAdoptionController.onSubmitForApproval(permanencyPlanId,supervisorId) != null, true);
        System.assertEquals(PermanacyPlanAdoptionController.onSubmitForApproval(null,null) == null, true);
        
        System.assertEquals(PermanacyPlanAdoptionController.getSelectProviderDetail(providerId) != null, true);
        System.assertEquals(PermanacyPlanAdoptionController.getSelectProviderDetail('') == null, true);
        
        Permanency_Plan__c permanencyPlanRec = new Permanency_Plan__c();
        permanencyPlanRec.Id = permanencyPlanId;
        System.assertEquals(PermanacyPlanAdoptionController.updateAdoptionPlanning(JSON.serialize(permanencyPlanRec)) != null, true);
        System.assertEquals(PermanacyPlanAdoptionController.updateAdoptionPlanning('') == null, true);
        
        System.assertEquals(PermanacyPlanAdoptionController.updateApplicableChildAssessmentRec(JSON.serialize(permanencyPlanRec), 'Test', 'Test') != null, true);
        System.assertEquals(PermanacyPlanAdoptionController.updateApplicableChildAssessmentRec('', '','') == null, true); 
        
        System.assertEquals(PermanacyPlanAdoptionController.updateBreaktheLinkRec(JSON.serialize(permanencyPlanRec)) != null, true);
        System.assertEquals(PermanacyPlanAdoptionController.updateBreaktheLinkRec('') == null, true);
        
        System.assertEquals(PermanacyPlanAdoptionController.updateSubsidyAgreement(JSON.serialize(permanencyPlanRec), 'TEST', 'TEST', 'TEST') != null, true);
        System.assertEquals(PermanacyPlanAdoptionController.updateSubsidyAgreement('', '','','') == null, true);
    }
    
    @isTest static void testTPR() {
        
        Id permanencyPlanId = [SELECT Id FROM Permanency_Plan__c LIMIT 1].Id;
        Id caregiverId = [SELECT Id FROM Contact WHERE Name = 'Test Caregiver' LIMIT 1].Id;
        
        TPR__c tprRec = new TPR__c();
        tprRec.ParentName__c = caregiverId;
        tprRec.TPR_Decision_Date__c = Date.today();
        tprRec.TPR_Status__c = 'TPR Granted';
        Id tprId = PermanacyPlanAdoptionController.updateTPR(JSON.serialize(tprRec));
        tprRec.Id = tprId;
        
        System.assertEquals(PermanacyPlanAdoptionController.updateTPR(JSON.serialize(tprRec)) != null, true);
        System.assertEquals(PermanacyPlanAdoptionController.updateTPR('') == null, true);
        
        System.assertEquals(PermanacyPlanAdoptionController.deleteTPR(tprId) != null, true);
        System.assertEquals(PermanacyPlanAdoptionController.deleteTPR(null) == null, true);
    }
    
    @isTest static void testAdoptionEfforts() {
        
        Id permanencyPlanId = [SELECT Id FROM Permanency_Plan__c LIMIT 1].Id;
        
        Adoption_Efforts__c adoptionEffortRec = new Adoption_Efforts__c();
        adoptionEffortRec.Permanency_Plan__c = permanencyPlanId;
        adoptionEffortRec.Effort_Date__c = Date.today();
        
        Id effortId = PermanacyPlanAdoptionController.upsertEffortsRecord(JSON.serialize(adoptionEffortRec));
        adoptionEffortRec.Id = effortId;
        System.assertEquals(PermanacyPlanAdoptionController.upsertEffortsRecord(JSON.serialize(adoptionEffortRec)) != null, true);
        System.assertEquals(PermanacyPlanAdoptionController.upsertEffortsRecord('') == null, true);
        
        System.assertEquals(PermanacyPlanAdoptionController.deleteEffortsRecord(effortId) != null, true);
        System.assertEquals(PermanacyPlanAdoptionController.deleteEffortsRecord(null) == null, true);        
    }
    
    @isTest static void testEmotionalTie() {
        
        Id permanencyPlanId = [SELECT Id FROM Permanency_Plan__c LIMIT 1].Id;
        Emotional_tie__c emotionalTieRec = new Emotional_tie__c();
        emotionalTieRec.Permanency_Plan__c = permanencyPlanId;
        emotionalTieRec.Type__c = 'Other'; 
        emotionalTieRec.Last_Name__c = 'Test';
        
        Id emotionalTieId = PermanacyPlanAdoptionController.upsertEmotionalTies(JSON.serialize(emotionalTieRec));
        emotionalTieRec.Id = emotionalTieId;
        System.assertEquals(PermanacyPlanAdoptionController.upsertEmotionalTies(JSON.serialize(emotionalTieRec)) != null, true);
        System.assertEquals(PermanacyPlanAdoptionController.upsertEmotionalTies('') == null, true);
    }
    
    @isTest static void testRate() {
        
        Id permanencyPlanId = [SELECT Id FROM Permanency_Plan__c LIMIT 1].Id;
        Id supervisorId = [SELECT Id FROM User WHERE Profile.Name = 'Casevault Supervisor' LIMIT 1].Id; 
        Permanency_Plan__c permanencyPlanRec = new Permanency_Plan__c();
        permanencyPlanRec.Id = permanencyPlanId;
        permanencyPlanRec.Subsidy_Approval_Status__c   = 'Approved';
        permanencyPlanRec.Approval_Status__c = 'Approved';
        update permanencyPlanRec;
        
        Subsidy_Rate__c rateRec = new Subsidy_Rate__c(); 
        rateRec.Permanency_Plan__c = permanencyPlanId;
        rateRec.Transaction_Date__c = Date.newInstance(2021, 6, 1);
        rateRec.Rate_Begin_Date__c = Date.newInstance(2021, 6, 1);
        rateRec.Rate_End_Date__c = Date.newInstance(2022, 6, 1);
        
        Id rateId = PermanacyPlanAdoptionController.upsertRateRecord(JSON.serialize(rateRec));
        rateRec.Id = rateId;
        
        System.assertEquals(PermanacyPlanAdoptionController.upsertRateRecord(JSON.serialize(rateRec)) != null, true);
        System.assertEquals(PermanacyPlanAdoptionController.upsertRateRecord('') == null, true); 
        System.assertEquals(PermanacyPlanAdoptionController.getRateRecord(rateId) != null, true);        
        System.assertEquals(PermanacyPlanAdoptionController.subsidySubmitForApproval(rateId,supervisorId) != null, true);
        System.assertEquals(PermanacyPlanAdoptionController.subsidySubmitForApproval('',supervisorId) == null, true);        
    }*/
}