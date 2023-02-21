@isTest
private class AdoptionCaseController_Test {
    
    @testSetup static void testData() {
        
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
        permanencyPlanRec.Contact__c = personChildRec.Id;
        insert permanencyPlanRec;
        
        permanencyPlanRec.Break_Line_Approval_Status__c = 'Approved';
        update permanencyPlanRec;
    }
    
    @isTest static void testGetSubsidyAgreementIntiInfos() {
        
        Case adoptionCase = [SELECT Id FROM Case LIMIT 1];
        Id adoptionCaseId = adoptionCase.Id;
        
        System.assertEquals(AdoptionCaseController.getSubsidyAgreementIntiInfos(adoptionCaseId) != null, true);
        System.assertEquals(AdoptionCaseController.getSubsidyAgreementIntiInfos('') == null, true);
        
        System.assertEquals(AdoptionCaseController.getRateRecordInfo(adoptionCaseId) != null, true);
        
        System.assertEquals(AdoptionCaseController.checkAddingNewRateAndAnnualReviewStatus(adoptionCaseId) != null, true);
        System.assertEquals(AdoptionCaseController.checkAddingNewRateAndAnnualReviewStatus('') == null, true);
        
        System.assertEquals(AdoptionCaseController.getAnnualReviewInfo(adoptionCaseId) != null, true);
       
        
        System.assertEquals(AdoptionCaseController.updateSubsidyAgreement(JSON.serialize(adoptionCase), 'test', 'test', 'test') != null, true);
        System.assertEquals(AdoptionCaseController.updateSubsidyAgreement('','','','') == null, true);
        
        System.assertEquals(AdoptionCaseController.getSuspensionintialInfo(adoptionCaseId) != null, true);
        
        System.assertEquals(AdoptionCaseController.getActiveTab(adoptionCaseId) != null, true);
        
        System.assertEquals(AdoptionCaseController.getDecision(adoptionCaseId) != null, true);
        
        System.assertEquals(AdoptionCaseController.getCurrentAdoptionCaseDetails(adoptionCaseId) != null, true);
        System.assertEquals(AdoptionCaseController.getCurrentAdoptionCaseDetails('') == null, true);
    }
    
    @isTest static void testRate() {
        
        Case adoptionCase = [SELECT Id FROM Case LIMIT 1];
        Id adoptionCaseId = adoptionCase.Id;
        Id supervisorId = [SELECT Id FROM User WHERE Profile.Name = 'Casevault Supervisor' LIMIT 1].Id;
              
        Subsidy_Rate__c rateRec = new Subsidy_Rate__c();
        rateRec.Adoption_Case__c = adoptionCaseId;
        rateRec.Rate_Begin_Date__c = Date.newInstance(2021, 7, 14);
        rateRec.Rate_End_Date__c = Date.newInstance(2022, 7, 14);
        rateRec.Transaction_Date__c = Date.newInstance(2021, 7, 14);
        
        Id rateId = AdoptionCaseController.upsertRateRecord(JSON.serialize(rateRec));
        rateRec.Id = rateId;
        System.assertEquals(AdoptionCaseController.upsertRateRecord(JSON.serialize(rateRec)) != null, true);
        System.assertEquals(AdoptionCaseController.upsertRateRecord('') == null, true);
        
        System.assertEquals(AdoptionCaseController.checkAddingNewRateAndAnnualReviewStatus(adoptionCaseId) != null, true);
        
        adoptionCase.Subsidy_Agreement_Approval_Status__c = 'Approved';
        update adoptionCase;
        System.assertEquals(AdoptionCaseController.onSubmitSubsidyRateApprovalProcess(rateId, supervisorId) != null, true);
        System.assertEquals(AdoptionCaseController.onSubmitSubsidyRateApprovalProcess('', supervisorId) == null, true);
    }
    
    @isTest static void testAnnualReview() {
        
        Id adoptionCaseId = [SELECT Id FROM Case LIMIT 1].Id;
        Id supervisorId = [SELECT Id FROM User WHERE Profile.Name = 'Casevault Supervisor' LIMIT 1].Id;
        
        Annual_Review__c annualReviewRec = new Annual_Review__c();
        annualReviewRec.Adoption_Case__c = adoptionCaseId;
        annualReviewRec.Review_Date__c =  Date.newInstance(2022, 7, 14);
        
        Id annualReviewId = AdoptionCaseController.upsertAnnualReviewRecord(JSON.serialize(annualReviewRec));
        annualReviewRec.Id = annualReviewId;
        System.assertEquals(AdoptionCaseController.upsertAnnualReviewRecord(JSON.serialize(annualReviewRec)) != null, true);
        System.assertEquals(AdoptionCaseController.upsertAnnualReviewRecord('') == null, true);
        
        System.assertEquals(AdoptionCaseController.onSubmitSubsidyAgreementApprovalProcess(adoptionCaseId, supervisorId) != null, true);
        System.assertEquals(AdoptionCaseController.onSubmitSubsidyAgreementApprovalProcess('', supervisorId) == null, true);
        
        System.assertEquals(AdoptionCaseController.onSubmitAnnualReviewApprovalProcess(annualReviewId, supervisorId) != null, true);
        System.assertEquals(AdoptionCaseController.onSubmitAnnualReviewApprovalProcess('', supervisorId) == null, true);        
    }
    
    @isTest static void testSuspension() {
        
        Id adoptionCaseId = [SELECT Id FROM Case LIMIT 1].Id;
        Id supervisorId = [SELECT Id FROM User WHERE Profile.Name = 'Casevault Supervisor' LIMIT 1].Id;
        
        Suspension__c suspensionRec = new Suspension__c();
        suspensionRec.Adoption_Case__c = adoptionCaseId;
        suspensionRec.Start_Date__c = Date.newInstance(2021, 6, 1);
        suspensionRec.End_Date__c = Date.newInstance(2021, 6, 25);
        
        Id suspensionId = AdoptionCaseController.upsertSuspensionRec(JSON.serialize(suspensionRec));
        suspensionRec.Id = suspensionId;
        System.assertEquals(AdoptionCaseController.upsertSuspensionRec(JSON.serialize(suspensionRec)) != null, true);
        System.assertEquals(AdoptionCaseController.upsertSuspensionRec('') == null, true);
        
        System.assertEquals(AdoptionCaseController.onSubmitSuspensionApprovalProcess(suspensionId,supervisorId) != null, true);
        System.assertEquals(AdoptionCaseController.onSubmitSuspensionApprovalProcess('',supervisorId) == null, true);
        
        System.assertEquals(AdoptionCaseController.deleteSuspensionRec(JSON.serialize(suspensionRec)) != null, true);
        System.assertEquals(AdoptionCaseController.deleteSuspensionRec('') == null, true);
    }
    
    @isTest static void testFileUpload() {
        
        String contentDocumentId = ContactNotesController.createContentVersion('test', 'ABC');
        System.assertEquals(AdoptionCaseController.editFileUpload('Edit test', 'ABC', contentDocumentId) != null, true);
        System.assertEquals(AdoptionCaseController.downloadFile('ABC') != null, true);
        
        System.assertEquals(AdoptionCaseController.deleteFile(contentDocumentId) != null, true);
        System.assertEquals(AdoptionCaseController.deleteFile('') == null, true);
    }
}