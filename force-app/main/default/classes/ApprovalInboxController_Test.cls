@istest
private class ApprovalInboxController_Test {
    
    @isTest static void TestallApprovedRecords() {
        
        Service_Case__c createCase = TestRecord.serviceCase('0000400');
        insert createCase;
        
        Investigation__c  createInvestigation = TestRecord.investigation();
        insert createInvestigation;
        
        Contact createContact=TestRecord.contact('Demo','test');
        //createContact.Investigation__c=createInvestigation.Id;
        //createContact.Service_Case__c=createCase.Id;
        insert createContact;
        
        Court__C createPetition = TestRecord.petition(createContact.Id);
        insert createPetition;
        
        Child_Removal__c createChildRemoval = TestRecord.childRemoval(createContact.Id);
        createChildRemoval.Investigation__c = createInvestigation.Id;
        createChildRemoval.Service_Case__c = createCase.Id;
        createChildRemoval.Supervisor_Approval__c = UserInfo.getUserId();
        insert createChildRemoval;
        
        Approval.ProcessSubmitRequest app = new Approval.ProcessSubmitRequest();
        app.setObjectId(createChildRemoval.Id);
        app.setSubmitterId(createChildRemoval.Supervisor_Approval__c);
        Approval.ProcessResult result = Approval.process(app);
        
        System.assertEquals(ApprovalInboxController.allPendingRecords() != null, true);
        User supervisor = [SELECT Id FROM User WHERE Id = :createChildRemoval.Supervisor_Approval__c];
        System.runAs(supervisor){
            
            Approval.ProcessWorkitemRequest req2 = new Approval.ProcessWorkitemRequest();
            req2.setComments('Approving request.');
            req2.setAction('Approve'); //This is the action that is approve in your case, you can set it to Reject also
            req2.setWorkitemId(result.newworkitemids.get(0));
            Approval.ProcessResult result2 =  Approval.process(req2);
        }
       
        System.assertEquals(ApprovalInboxController.allApprovedRecords() != null, true);
        System.assertEquals(ApprovalInboxController.allAssessmentRecords() != null, true);

        
    }
    
}