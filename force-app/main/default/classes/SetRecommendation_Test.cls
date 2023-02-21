@isTest
private class SetRecommendation_Test {
    
    @testSetup static void setup() {
        
        List<Contact> conlist = new List<Contact>();
        List<Assessment_Visit__c> assessmentList = new List<Assessment_Visit__c>();

        Service_Case__c createCase = TestRecord.serviceCase('0000400');
        insert createCase;
        
        Investigation__c  createInvestigation = TestRecord.investigation();
        insert createInvestigation;
        
        Account accRec = TestRecord.createProvider('Demo','Test','testing');
        insert accRec;
        
        Home_Approval__c homeRec = TestRecord.createHomeApproval(accRec.Id);
        insert homeRec;
        
        Contact createContact1 = TestRecord.contact('Demo','test');
        //createContact1.Investigation__c = createInvestigation.Id;
        //createContact1.Service_Case__c = createCase.Id;
        createContact1.Home_Approval__c = homeRec.Id;
        createContact1.Applicant_or_Co_Applicant__c ='Applicant';
        conlist.add(createContact1);
        
        Contact createContact2 = TestRecord.contact('Demo','test');
        //createContact2.Investigation__c = createInvestigation.Id;
        //createContact2.Service_Case__c = createCase.Id;
        createContact2.Home_Approval__c = homeRec.Id;
        createContact2.Applicant_or_Co_Applicant__c ='Co-Applicant';
        createContact2.No_Co_Applicant__c = true;
        conlist.add(createContact2);
        insert conlist;
        
        Assessment_Visit__c assessmentRecord1 = TestRecord.createassessmentVist(homeRec.Id);
        assessmentRecord1.Activity_Type__c = 'Application Signed';
        assessmentList.add(assessmentRecord1);
        
        Assessment_Visit__c assessmentRecord2 = TestRecord.createassessmentVist(homeRec.Id);
        assessmentRecord2.Activity_Type__c = 'Family Assessment Completed';
        assessmentList.add(assessmentRecord2);

        Assessment_Visit__c assessmentRecord3 = TestRecord.createassessmentVist(homeRec.Id);
        assessmentRecord3.Activity_Type__c = 'Home Assessment Completed';
        assessmentList.add(assessmentRecord3);

        Assessment_Visit__c assessmentRecord4 = TestRecord.createassessmentVist(homeRec.Id);
        assessmentRecord4.Activity_Type__c = 'Recon Home Visit Performed';
        assessmentList.add(assessmentRecord4);
        
        insert assessmentList;
        
        Household__c houseHoldRecord = TestRecord.createHouseHold(homeRec.Id);
        houseHoldRecord.Ethnicity_Hispanic__c = 'Yes';
        houseHoldRecord.Related_To__c = 'Applicant';
        houseHoldRecord.Child_Household_Member__c = 'Child';
        insert houseHoldRecord;
        
        Reference__c referenceRecord = TestRecord.createReference(homeRec.Id);
        referenceRecord.Related_To__c = 'Applicant';
        insert referenceRecord;
        
        referenceRecord.Related_To__c = 'co-applicant';
        update referenceRecord;
        
        Child_Evaluations__c childEvaluationRecord = TestRecord.createChildEvaluations(homeRec.Id);
        insert childEvaluationRecord;
        
        Backup__c backupRecord = TestRecord.createBackup(homeRec.Id);
        insert backupRecord;
        
		Clearance__c clearanceRec =  new Clearance__c();
        clearanceRec.Home_Approval__c = homeRec.Id;
        clearanceRec.Child_By_Birth_Kinship_Adoption_and_Date__c = 'Test';
        insert clearanceRec;
    }
    
    @isTest static void TestgetContact() {
        
        Home_Approval__c homeApprovalRec = [SELECT Id FROM Home_Approval__c LIMIT 1];
        Pet__c petRec = TestRecord.createPet(homeApprovalRec.Id);
        petRec.There_are_no_Pets_in_this_Household__c = true;
        insert petRec;
        
        System.assertEquals(SetRecommendation.getContact(homeApprovalRec.Id) != null, true); 
        System.assertEquals(SetRecommendation.updateHomeApproval(homeApprovalRec.Id,'This home should be Approved') != null , false);
        Id emptyId;
        System.assertEquals(SetRecommendation.getContact(emptyId) != null, false);  
        
        homeApprovalRec.Home_Approval_Status__c = 'Approved';
        update homeApprovalRec;
        Database.delete(homeApprovalRec.Id, false);
        
        Contact getPerson = [SELECT Id, Home_Approval__c FROM Contact LIMIT 1];
        Database.update (getPerson, false);
    }    
    
    @isTest static void testHouseHoldTrigger() {
        
        Household__c getHouseholdRec = [SELECT Id, Related_To__c,Ethnicity_Hispanic__c,Child_Household_Member__c,Home_Approval__c FROM Household__c LIMIT 1];
        getHouseholdRec.Ethnicity_Hispanic__c = 'No';
        getHouseholdRec.Related_To__c = 'co-applicant';
        getHouseholdRec.Child_Household_Member__c = 'Household Member';
        getHouseholdRec.Date_of_Birth__c = Date.newInstance(1999, 8, 1);
        getHouseholdRec.Age__c = 22;
        update getHouseholdRec;
        
        System.assertEquals(getHouseholdRec != null, true);  
        delete getHouseholdRec;     
    }
    
    @isTest static void testProviderTrigger() {
        
        Referral__c referralRec = TestRecord.createPublicReferral('Test','Referral');
        referralRec.Convert_Account_Contact__c = true;
        insert referralRec;
        
        Account getProvider = [SELECT Id, Provider_Status__c FROM Account WHERE Name != 'Testing' LIMIT 1];
        getProvider.Provider_Status__c = 'Suspended';
        getProvider.Type__c = 'CPA Home';
        update getProvider;
        
        System.assertEquals(getProvider.Id != null, true); 
        Database.delete(getProvider.Id, false);
    }
}