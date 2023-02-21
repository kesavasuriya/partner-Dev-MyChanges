@isTest
private class CasePlanController_Test {
    
    @testSetup static void setup(){
        Case caseRec = TestRecord.createIntake();
        insert caseRec;
        
        Service_Case__c servicecaseRec = TestRecord.serviceCase('0000123');
        servicecaseRec.Intake__c = caseRec.Id;
        insert servicecaseRec;
        
        Investigation__c investigationRec = TestRecord.investigation();
        insert investigationRec;
        
        Account providerRec = TestRecord.createProvider('Test', 'User 1', 'TestUser1');
        insert providerRec;
        
        Contact contactRec = TestRecord.contact('Demo','Test');
        //contactRec.Service_Case__c = servicecaseRec.Id;
        contactRec.Applicant_or_Co_Applicant__c = 'Applicant';
        contactRec.Applicant_First_Name__c = 'Applicant1';
        contactRec.Intake_Person_Role__c = 'Biological Child';
        //contactRec.Investigation__c = investigationRec.Id;
        insert contactRec;
               
        
        Medication_Including_Psychotropic__c medicationRec = TestRecord.createMedication(contactRec.Id);
        insert medicationRec;
        
        Notes__c notesRec = TestRecord.createNotes(contactRec.FirstName+' '+contactRec.LastName);
        insert notesRec;
        
        Youth_Transition_Plan__c youthTransPlanRec = TestRecord.createYouthTransitionPlan(contactRec.Id);
        youthTransPlanRec.Service_Case__c = servicecaseRec.Id;
        insert youthTransPlanRec;
        
        Service_Plan__c  servicePlanRec = TestRecord.createServicePlan(servicecaseRec.Id);
        insert servicePlanRec;
        
        Candidacy__c candidacyRec = TestRecord.createCandidacy(contactRec.Id, servicePlanRec.Id);
        insert candidacyRec;
        
        Person_Incomes__c personIncomeRec = TestRecord.createPersonIncome(contactRec.Id);
        insert personIncomeRec;
        
        Asset__c assetRec = TestRecord.createAsset(contactRec.Id);
        insert assetRec;
        
        Education__c educationRec = TestRecord.createEducation(contactRec.Id);
        insert educationRec;
        
        List<Examination__c> examLst = new List<Examination__c>();
        Examination__c examRec = TestRecord.createExamination(contactRec.Id, 'Initial Health Examination');
        examLst.add(examRec);
        Examination__c examRec1 = TestRecord.createExamination(contactRec.Id, 'Annual Health Examination');
        examLst.add(examRec1);
        Examination__c examRec2 = TestRecord.createExamination(contactRec.Id, 'Follow-up Health Examination');
        examLst.add(examRec2);
        insert examLst;
        
        Child_Removal__c childRemovalRecord = TestRecord.childRemoval(contactRec.Id);
        childRemovalRecord.Service_Case__c = servicecaseRec.Id;
        childRemovalRecord.Removal_End_Date_Time__c = null;
        insert childRemovalRecord;
        
        Placement__c placementRec = TestRecord.placement(childRemovalRecord.Id);
        placementRec.Child__c = childRemovalRecord.Child__c;
        placementRec.Provider__c = providerRec.Id;
        placementRec.Service_Case__c = servicecaseRec.Id;
        insert placementRec;
        
        
        Case_Plan__c casePlanRec = TestRecord.createCasePlan(placementRec.Id);
        insert casePlanRec;
        
        
        User approver = [SELECT Id FROM User WHERE Profile.Name ='Casevault Supervisor' LIMIT 1];
        
        Assessment__c assessmentRec = TestRecord.assessment('Family risk Reassessment', 'richus');
        assessmentRec.Service_Case__c = servicecaseRec.Id;
        assessmentRec.Investigation__c = investigationRec.Id;
        assessmentRec.Supervisor_Approver__c  = approver.Id;
        insert assessmentRec;
       
        
        Approval.ProcessSubmitRequest app = new Approval.ProcessSubmitRequest();
        app.setObjectId(assessmentRec.Id);
        app.setSubmitterId(UserInfo.getUserId());
        Approval.ProcessResult result = Approval.process(app);
        
        System.runAs(approver){
            
            Approval.ProcessWorkitemRequest req2 = new Approval.ProcessWorkitemRequest();
            req2.setComments('Approving request.');
            req2.setAction('Approve'); 
            req2.setWorkitemId(result.newworkitemids.get(0));
            Approval.ProcessResult result1 =  Approval.process(req2);
        }
        
        
        
        
        Permanency_Plan__c permanencyPlanRec = TestRecord.permanencyPlan();
        permanencyPlanRec.Placement__c = placementRec.Id;
        insert permanencyPlanRec;
        
    }
    
    @isTest static void TestgetPlacementTableRecords() {
        
        Service_Case__c servicecaseRec = [SELECT Id FROM Service_Case__c LIMIT 1];
        System.assertEquals(CasePlanController.getPlacementTableRecords(servicecaseRec.Id) != null, true);
        System.assertEquals(CasePlanController.getPlacementTableRecords('') == null, true);
        
    }
    
    @isTest static void TestgetPlacementRecordsAndCasePlanVersionRecord() {
        
        Placement__c placementRec = [SELECT Id FROM Placement__c LIMIT 1];
        System.assertEquals(CasePlanController.getPlacementRecords(placementRec.Id) != null, true);
        System.assertEquals(CasePlanController.getPlacementRecords('') == null, true);
        
       // System.assertEquals(CasePlanController.getCasePlanVersionRecord(placementRec.Id) != null, true);
       // System.assertEquals(CasePlanController.getCasePlanVersionRecord('') == null, true);
        
    }
    
    @isTest static void TestcreateCasePlanVersion() {
        
        Placement__c placementRec = [SELECT Id FROM Placement__c LIMIT 1];
        Case_Plan__c casePlanRec = TestRecord.createCasePlan(placementRec.Id);
        
       // System.assertEquals(CasePlanController.createCasePlanVersion(JSON.serialize(casePlanRec)) != null, true);
       // System.assertEquals(CasePlanController.createCasePlanVersion('') == null, true);
        
    }
    
    @isTest static void TestgetSocialHistoryRecordTest1() {
        
        Case_Plan__c casePlanRec = [SELECT Id FROM Case_Plan__c LIMIT 1];
        
        System.assertEquals(CasePlanController.getSocialHistoryRecord(casePlanRec.Id) != null, true);        
        System.assertEquals(CasePlanController.getSocialHistoryRecord('') == null, true);
        
    }
    
    @isTest static void TestgetSocialHistoryRecordTest2() {
        
        User approver = [SELECT Id FROM User WHERE Profile.Name = 'Casevault Supervisor' LIMIT 1];
        
        Placement__c placementRec = [SELECT Id, Service_Case__c, Child__c FROM Placement__c LIMIT 1];
        
        Contact personRec = [SELECT Id, Applicant_Last_Name__c FROM Contact WHERE Id =: placementRec.Child__c];
        
        Case caseRec = TestRecord.createIntake();
        insert caseRec;
        
        Service_Case__c servicecaseRec = TestRecord.serviceCase('0000123');
        servicecaseRec.Intake__c = caseRec.Id;
        insert servicecaseRec;
        
        placementRec.Service_Case__c = servicecaseRec.Id;
        update placementRec;
        
        
        Case_Plan__c casePlanRec = TestRecord.createCasePlan(placementRec.Id);
        insert casePlanRec;
        
        Assessment__c assessmentRec = TestRecord.assessment('SAFE-C', 'richus');
        assessmentRec.Safety_Assessment_Completion_Date_Time__c = DateTime.now();
        assessmentRec.Service_Case__c = servicecaseRec.Id;
        assessmentRec.Supervisor_Approver__c  = approver.Id;
        insert assessmentRec;
        
        Approval.ProcessSubmitRequest app = new Approval.ProcessSubmitRequest();
        app.setObjectId(assessmentRec.Id);
        app.setSubmitterId(UserInfo.getUserId());
        Approval.ProcessResult result = Approval.process(app);
        
        System.runAs(approver){
            
            Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
            req.setComments('Approving request.');
            req.setAction('Approve'); 
            req.setWorkitemId(result.newworkitemids.get(0));
            Approval.ProcessResult resultFinal =  Approval.process(req);
        }
        
        System.assertEquals(CasePlanController.getSocialHistoryRecord(casePlanRec.Id) != null, true);
              
        
        Assessment__c assessmentRec1 = TestRecord.assessment('Family risk Reassessment', 'richus');
        assessmentRec1.Safety_Assessment_Completion_Date_Time__c = DateTime.now();
        assessmentRec1.Service_Case__c = servicecaseRec.Id;
        assessmentRec1.Supervisor_Approver__c  = approver.Id;
        insert assessmentRec1;
        
        Approval.ProcessSubmitRequest app1 = new Approval.ProcessSubmitRequest();
        app1.setObjectId(assessmentRec1.Id);
        app1.setSubmitterId(UserInfo.getUserId());
        Approval.ProcessResult result1 = Approval.process(app1);
        
        System.runAs(approver){
            
            Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
            req.setComments('Approving request.');
            req.setAction('Approve'); 
            req.setWorkitemId(result1.newworkitemids.get(0));
            Approval.ProcessResult resultFinal1 =  Approval.process(req);
        }
        
        System.assertEquals(CasePlanController.getSocialHistoryRecord(casePlanRec.Id) != null, true);
        
        personRec.Applicant_or_Co_Applicant__c = 'Co-Applicant	';
        update personRec;
        
        System.assertEquals(CasePlanController.getSocialHistoryRecord(casePlanRec.Id) != null, true);

        
    }
    
    @isTest static void TestgetPermanencyProgressRecord() {
        
        Case_Plan__c casePlanRec = [SELECT Id FROM Case_Plan__c LIMIT 1];
        
        System.assertEquals(CasePlanController.getPermanencyProgressRecord(casePlanRec.Id) != null, true);
        System.assertEquals(CasePlanController.getPermanencyProgressRecord('') == null, true);
        
    }
    
    @isTest static void TestupdatePermanencyProgressRecord() {
        
        Case_Plan__c casePlanRec = [SELECT Id FROM Case_Plan__c LIMIT 1];
        casePlanRec.Behavioral_problems__c = true;
        //System.assertEquals(CasePlanController.updatePermanencyProgressRecord(JSON.serialize(casePlanRec)) != null, true);
        //System.assertEquals(CasePlanController.updatePermanencyProgressRecord('') == null, true);
        
    }
    
    @isTest static void TestgetServicePlanRecordAndgetYouthTransitionPlanRecords() {
        
        Case_Plan__c casePlanRec = [SELECT Id FROM Case_Plan__c LIMIT 1];
        System.assertEquals(CasePlanController.getServicePlanRecord(casePlanRec.Id) != null, true);
        System.assertEquals(CasePlanController.getServicePlanRecord('') == null, true);
        
        System.assertEquals(CasePlanController.getYouthTransitionPlanRecords(casePlanRec.Id) != null, true);
        System.assertEquals(CasePlanController.getYouthTransitionPlanRecords('') == null, true);
        
    }
}