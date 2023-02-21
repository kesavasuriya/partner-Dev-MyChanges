@isTest
private class AssessmentController_Test {
    
    @testSetup static void setup() {
        
        Profile profileRec = [SELECT Id, Name FROM Profile WHERE Name = 'Casevault Supervisor' LIMIT 1];
        
        List<User> userIns = new List<User>();               
        User userRec = new User();
        userRec.LastName = 'viba';
        userRec.Email = 'viba@ss.com';
        userRec.Alias = 'vcode';
        userRec.Username = 'viba1234444@ss.com';
        userRec.CommunityNickname = 'viba07';
        userRec.LocaleSidKey = 'en_US';
        userRec.TimeZoneSidKey = 'GMT';
        userRec.ProfileID = profileRec.Id;
        userRec.LanguageLocaleKey = 'en_US';
        userRec.EmailEncodingKey = 'UTF-8';
        userIns.add(userRec);
        
        if(userIns.size() > 0)
            insert userIns;
        
        Service_Case__c serviceCaseRecord = TestRecord.serviceCase('test');
        insert serviceCaseRecord;
        
        Investigation__c investigationRec = TestRecord.investigation();
        insert investigationRec;
        
        Contact contactRec = TestRecord.contact('test', 'test');
        //contactRec.Service_Case__c = serviceCaseRecord.Id;
        //contactRec.Is_Caregiver__c = true;
        contactRec.Head_of_House__c = true;
        contactRec.Danger_to_self__c = 'Yes';
        contactRec.Danger_to_worker__c = 'Yes';
        contactRec.Appearance_of_mentally_impaired__c = 'Yes';
        contactRec.Signs_of_mental_illness__c  = 'Yes';
        contactRec.Appearance_Reason__c  = 'Test';
        contactRec.Danger_Reason__c = 'Test1';
        contactRec.Worker_Reason__c = 'Test2';
        contactRec.Sign_Reason__c = 'Test3';
        //contactRec.Investigation__c = investigationRec.Id;
        insert contactRec;
        
        List<Assessment__c> assessmentLst = new List<Assessment__c>();
        Assessment__c assessmentRec = TestRecord.assessment('SAFE-C', 'richus');
        assessmentRec.Supervisor_Approver__c = userIns[0].Id;
        assessmentRec.Safety_Assessment_Completion_Date_Time__c = DateTime.now();
        assessmentRec.Service_Case__c = serviceCaseRecord.Id;
        assessmentRec.Investigation__c = investigationRec.Id;
        assessmentLst.add(assessmentRec);
        
        Assessment__c assessmentRec2 = TestRecord.assessment('SAFE-C-OHP', 'richus');
        assessmentRec2.Supervisor_Approver__c = userIns[0].Id;
        assessmentRec2.Service_Case__c = serviceCaseRecord.Id;
        assessmentRec2.Investigation__c = investigationRec.Id;
        
        Assessment__c assessmentRec3 = TestRecord.assessment('Family Initial Risk Assessment', 'richus');
        assessmentRec3.Supervisor_Approver__c = userIns[0].Id;
        assessmentRec3.Service_Case__c = serviceCaseRecord.Id;
        assessmentRec3.Investigation__c = investigationRec.Id;
        assessmentLst.add(assessmentRec3);
        
        if(assessmentLst.size()>0)
            insert assessmentLst;
        
        
        List<Assessment_Safety_Plan__c> assesmentsafteyIns = new List<Assessment_Safety_Plan__c>();
        Assessment_Safety_Plan__c assessmentsaftey = new Assessment_Safety_Plan__c();
        assessmentsaftey.Responsible_Parties__c = 'WHO';
        assesmentsafteyIns.add(assessmentsaftey);
        if(assesmentsafteyIns.size()>0)
            insert assesmentsafteyIns;
        
        
    }
    
    @isTest  static void testPicklistMethods() {
        
        System.assertEquals(AssessmentController.getScoringOverridesPicklist() != null, true);
        System.assertEquals(AssessmentController.getSupplementalQuestionPicklist() != null, true);
        System.assertEquals(AssessmentController.getFIRAApprovalPicklist() != null, true);
        System.assertEquals(AssessmentController.getNeglectedAbuseIndexPicklist() != null, true);
        
    }
    
    @isTest  static void testgetSAFECOHPInitialInformation() {
        
        Service_Case__c serviceCaseRec = [SELECT Id FROM Service_Case__c LIMIT 1];
        
        AssessmentController.getInitialWrapper initWrap = (AssessmentController.getInitialWrapper)JSON.deserialize(AssessmentController.getSAFECOHPInitialInformation(serviceCaseRec.Id), AssessmentController.getInitialWrapper.class);
        System.assertEquals(initWrap.conactList != null, true);
        System.assertEquals(initWrap.assessmentOHPList != null, true);
        
    }
    
    @isTest  static void testgetAssessmentOHP() {
        
        Assessment__c assessmentRec = [SELECT Id, SAFEC_Legal_Guardian_Name__c FROM Assessment__c WHERE Assessment_Type__c = 'SAFE-C' LIMIT 1];
        AssessmentController.getInitialWrapper initWrap = (AssessmentController.getInitialWrapper)JSON.deserialize(AssessmentController.getAssessmentOHP(assessmentRec.Id), AssessmentController.getInitialWrapper.class);
        System.assertEquals(initWrap.assessmentOHPRec != null, true);
        
    }
    
    @isTest  static void testgetAssessment() {
        
        Assessment__c assessmentRec = [SELECT Id, SAFEC_Legal_Guardian_Name__c FROM Assessment__c WHERE Assessment_Type__c = 'SAFE-C' LIMIT 1];
        AssessmentController.getInitialWrapper initWrap = (AssessmentController.getInitialWrapper)JSON.deserialize(AssessmentController.getAssessment(assessmentRec.Id), AssessmentController.getInitialWrapper.class);
        System.assertEquals(initWrap.assessmentRec.Id, assessmentRec.Id);
        
    }
    
    @isTest  static void testgetSAFECInitialInformation() {
        
        Assessment__c assessmentRec = [SELECT Id, Name, SAFEC_Legal_Guardian_Name__c FROM Assessment__c WHERE Assessment_Type__c='SAFE-C' LIMIT 1];
        Investigation__c investigationRec = [SELECT Id FROM Investigation__c LIMIT 1];
        Service_Case__c serviceCaseRec = [SELECT Id FROM Service_Case__c LIMIT 1];
        
        
        AssessmentController.getInitialWrapper initWrap = (AssessmentController.getInitialWrapper)JSON.deserialize(AssessmentController.getSAFECInitialInformation(serviceCaseRec.Id), AssessmentController.getInitialWrapper.class);
        
        AssessmentController.getInitialWrapper initWrap1 = (AssessmentController.getInitialWrapper)JSON.deserialize(AssessmentController.getSAFECInitialInformation(investigationRec.Id), AssessmentController.getInitialWrapper.class);
        System.assertEquals(initWrap1.cpsCaseName != null, true);
        
    }
    
    @isTest  static void testcreateSAFECOHP() {
        
        Assessment__c assessmentRec = [SELECT Id, SAFEC_Legal_Guardian_Name__c FROM Assessment__c WHERE Assessment_Type__c='SAFE-C' LIMIT 1];
        System.assertEquals(AssessmentController.createSAFECOHP(JSON.serialize(assessmentRec)) != null, true);
        
        Assessment__c assessmentCreateRec = TestRecord.assessment('SAFE-C-OHP', 'richus');
        assessmentCreateRec.Safety_Assessment_Completion_Date_Time__c = DateTime.now();
        
        System.assertEquals(AssessmentController.createSAFECOHP(JSON.serialize(assessmentCreateRec)) != null, true);
        System.assertEquals(AssessmentController.createSAFECOHP('') == null, true);
        
    }
    
    @isTest  static void testcreateSAFEC() {
        
        Assessment__c assessmentRec = [SELECT Id, SAFEC_Legal_Guardian_Name__c FROM Assessment__c WHERE Assessment_Type__c = 'SAFE-C' LIMIT 1];
        List<Assessment_Safety_Plan__c> assessmentsafteyLst = new List<Assessment_Safety_Plan__c>();
        Assessment_Safety_Plan__c assessmentsafteyUpdateRec = [SELECT Id, Responsible_Parties__c FROM Assessment_Safety_Plan__c WHERE Responsible_Parties__c = 'WHO' LIMIT 1];
        assessmentsafteyLst.add(assessmentsafteyUpdateRec);
        
        Assessment_Safety_Plan__c assessmentsafteyRec = new Assessment_Safety_Plan__c();
        assessmentsafteyRec.Responsible_Parties__c = 'WHO';
        
        assessmentsafteyLst.add(assessmentsafteyRec);
        
        Assessment__c assessmentCreateRec = TestRecord.assessment('SAFE-C', 'richus');
        assessmentCreateRec.Safety_Assessment_Completion_Date_Time__c = DateTime.now();
        List<Assessment_Safety_Plan__c> assessmentsafteyDeleteLst = new List<Assessment_Safety_Plan__c>();
        
        System.assertEquals(AssessmentController.createSAFEC(JSON.serialize(assessmentRec), JSON.serialize(assessmentsafteyLst), JSON.serialize(assessmentsafteyDeleteLst)) != null, true);
        
        System.assertEquals(AssessmentController.createSAFEC('', JSON.serialize(assessmentsafteyLst), JSON.serialize(assessmentsafteyDeleteLst)) == null, true);
        assessmentsafteyDeleteLst = [SELECT Id, Responsible_Parties__c FROM Assessment_Safety_Plan__c];
        
        System.assertEquals(AssessmentController.createSAFEC(JSON.serialize(assessmentCreateRec), JSON.serialize(assessmentsafteyLst), JSON.serialize(assessmentsafteyDeleteLst)) != null, true);
    }
    
    @isTest  static void onSubmitForApproval() {
        
        Assessment__c assessmentRec = [SELECT Id, SAFEC_Legal_Guardian_Name__c, Supervisor_Approver__c, OHP_Approval_Status__c  FROM Assessment__c  LIMIT 1];
        User userRec = [SELECT Id, LastName FROM User WHERE LastName = 'viba' LIMIT 1];
        
        System.assertEquals(AssessmentController.onSubmitForApproval(assessmentRec.Id, userRec.Id) != null, true);
        System.assertEquals(AssessmentController.onSubmitForApproval('', null) == null, true);
    }
    
    @isTest  static void testonSubmitStatus() {
        
        Assessment__c assessmentRec = [SELECT Id, SAFEC_Legal_Guardian_Name__c, OHP_Approval_Status__c FROM Assessment__c LIMIT 1];        
        System.assertEquals(AssessmentController.onSubmitStatus(assessmentRec.Id) != null, true);
        
    }   
    
    @isTest  static void testgetFamilyRiskReassessmentInfo() {
        
        Service_Case__c servicecaseRec = [SELECT Id FROM Service_Case__c LIMIT 1];  
        Investigation__c investigationRec = [SELECT Id FROM Investigation__c LIMIT 1];
        System.assertEquals(AssessmentController.getFamilyRiskReassessmentInfo(servicecaseRec.Id, 'Service_Case__c') != null, true);
        System.assertEquals(AssessmentController.getFamilyRiskReassessmentInfo(investigationRec.Id, 'Investigation__c') != null, true);
        
    } 
    
    @isTest  static void testupsertfamilyRiskReassessmentAndfamilyApprovalSign() {
        
        Assessment__c assessmentRec = [SELECT Id  FROM Assessment__c  LIMIT 1];
        assessmentRec.FIRA_Case_worker_Signature__c = 'Test';
        assessmentRec.Supervisor_Signature__c = 'Test';
         
        System.assertEquals(AssessmentController.upsertfamilyRiskReassessment(JSON.serialize(assessmentRec)) != null, true);
        Assessment__c assessmentUpdateRec = TestRecord.assessment('Family Initial Risk Assessment', 'richus');
        System.assertEquals(AssessmentController.upsertfamilyRiskReassessment(JSON.serialize(assessmentUpdateRec)) != null, true);
		System.assertEquals(AssessmentController.upsertfamilyRiskReassessment('' ) == null, true);
        
        System.assertEquals(AssessmentController.upsertfamilyApprovalSign(JSON.serialize(assessmentUpdateRec), '', '') != null, true);
        System.assertEquals(AssessmentController.upsertfamilyApprovalSign(JSON.serialize(assessmentRec), 'test', 'test') != null, true);
        System.assertEquals(AssessmentController.upsertfamilyApprovalSign('', '', '') == null, true);

        
    }
        
    @isTest  static void testgetFamilyInitialRiskAssessmentStageInfo() {
        
        System.assertEquals(AssessmentController.getFamilyInitialRiskAssessmentStagePicklist() != null, true);
        Service_Case__c serviceCaseRec = [SELECT Id FROM Service_Case__c LIMIT 1];
        System.assertEquals(AssessmentController.getFamilyInitialRiskAssessmentStageInfo(serviceCaseRec.Id) != null, true);
    }
    
    @isTest  static void testgetFamilyAndHouseholdCompositionInfo() {
        
        Service_Case__c serviceCaseRec = [SELECT Id FROM Service_Case__c LIMIT 1];
        Investigation__c investigationRec = [SELECT Id FROM Investigation__c LIMIT 1];
        Assessment__c assessmentRec = [SELECT Id, SAFEC_Legal_Guardian_Name__c, OHP_Approval_Status__c FROM Assessment__c LIMIT 1];        
        
        System.assertEquals(AssessmentController.getFamilyAndHouseholdCompositionInfo(serviceCaseRec.Id, assessmentRec.Id, 'Service_Case__c') != null, true);
        System.assertEquals(AssessmentController.getFamilyAndHouseholdCompositionInfo(investigationRec.Id, 'empty', 'Investigation__c') != null, true);
        
    }
    
    @isTest  static void testAssessmentMethods() {
        
        Assessment__c assessmentRec = [SELECT Id, SAFEC_Legal_Guardian_Name__c, OHP_Approval_Status__c FROM Assessment__c LIMIT 1];        
        
        ApexPages.currentPage().getParameters().put('id', assessmentRec.Id);
        AssessmentController assessmentClass = new AssessmentController();
        
        System.assertEquals(AssessmentController.getNeglectedAbuseIndexInfo(assessmentRec.Id) != null, true);        
        System.assertEquals(AssessmentController.getScoringOverridesInfo(assessmentRec.Id) != null, true);                
        System.assertEquals(AssessmentController.getSupplementalQuestionInfo(assessmentRec.Id) != null, true);        
        System.assertEquals(AssessmentController.getFIRAApprovalInfo(assessmentRec.Id) != null, true);
        System.assertEquals(AssessmentController.getActionInfo(assessmentRec.Id) != null, true);
        AssessmentController.getInitialWrapper initWrap = (AssessmentController.getInitialWrapper)JSON.deserialize(AssessmentController.getActionInfo('empty'), AssessmentController.getInitialWrapper.class);
        System.assertEquals(initWrap.assessmentRec == null, false);        
        System.assertEquals(AssessmentController.deleteAssessment(assessmentRec.Id) != null, true);
        System.assertEquals(AssessmentController.deleteAssessment('') == null, true);
        
        
    }
        
    
}