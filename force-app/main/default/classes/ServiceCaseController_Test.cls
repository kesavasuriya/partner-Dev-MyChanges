@istest
private class ServiceCaseController_Test {
    
    @testsetup static void setup() {
        
        List<Service_Case__c> createServiceCases = new List<Service_Case__c>();
        
        Case caseRec = TestRecord.createIntake();
        caseRec.Supervisor_Approver__c = UserInfo.getUserId();
        insert caseRec;
        
        Approval.ProcessSubmitRequest app = new Approval.ProcessSubmitRequest();
        app.setObjectId(caseRec.Id);
        app.setSubmitterId(caseRec.Supervisor_Approver__c);
        Approval.ProcessResult result = Approval.process(app);
        
        Investigation__c investigationRec = TestRecord.investigation();
        insert investigationRec;
        
        Service_Case__c serviceRec = TestRecord.serviceCase('0000600');
        serviceRec.Intake__c = caseRec.Id;
        createServiceCases.add(serviceRec);
        
        Service_Case__c closedServiceRec = TestRecord.serviceCase('0000600');
        closedServiceRec.Intake__c = caseRec.Id;
        closedServiceRec.Close_Date__c = Date.newInstance(2022,4,29);
        createServiceCases.add(closedServiceRec);
        
        insert createServiceCases; 
        List<Service_Case__c> getServiceCaseRecord = [SELECT Id FROM Service_Case__c WHERE Close_Date__c = null];
        
        if(getServiceCaseRecord.size() > 0) {
            Contact personRec = TestRecord.contact('Test', 'Child');
            //personRec.Service_Case__c = getServiceCaseRecord[0].Id;
            insert personRec;
            
            Child_Removal__c childRemovalRec = TestRecord.childRemoval(personRec.Id);
            childRemovalRec.Service_Case__c = getServiceCaseRecord[0].Id;
            insert childRemovalRec;
            
            Placement__c placementRec = TestRecord.placement(childRemovalRec.Id);
            placementRec.Service_Case__c = getServiceCaseRecord[0].Id;
            insert placementRec;
            
            Service_Case_History__c historyRec = TestRecord.createServiceCaseHistory(getServiceCaseRecord[0].Id);
            historyRec.Status__c = 'Close';
            insert historyRec;
        }
        
    }
    
    @isTest static void testgetChildRemovalRecord() {
        
        Child_Removal__c getChildRemovalRec = [SELECT Id FROM Child_Removal__c LIMIT 1];
        if(getChildRemovalRec != null){
        	System.assertEquals(ServiceCaseController.getChildRemovalRecord(getChildRemovalRec.Id) != null, true);   
        }
        System.assertEquals(ServiceCaseController.getChildRemovalRecord(null) != null, false);
    }
    
    @isTest static void testgetPlacementRecord() {
        
        Placement__c getPlacementRec = [SELECT Id FROM Placement__c LIMIT 1];
        if(getPlacementRec != null) {
            System.assertEquals(ServiceCaseController.getPlacementRecord(getPlacementRec.Id) != null, true);
        }
        System.assertEquals(ServiceCaseController.getPlacementRecord(null) != null, false);
    }
    
    
    @isTest static void testAssignment() {
        
        List<Assignment__c> assignmentRecords = new List<Assignment__c>();
		Assignment__c adminAssign = new Assignment__c();
        Assignment__c childAssign = new Assignment__c();
        Assignment__c workerAssign = new Assignment__c();
        Assignment__c invesAssign = new Assignment__c();
        
        List<Service_Case__c> getServiceCase = [SELECT Id,Intake__c FROM Service_Case__c];
        List<User> caseWorkers = [SELECT Id FROM User WHERE Profile.Name = 'Caseworker'];
        Investigation__c getInvestigationRec = [SELECT Id FROM Investigation__c LIMIT 1];
        
        adminAssign.Service_Case__c = getServiceCase[0].Id;
        adminAssign.Assign_Type__c = 'Assign to Worker';
        adminAssign.Select_a_Unit__c = 'CPS Unit 2';
        adminAssign.Assign_Start_Date__c = Date.newInstance(2022,4,29);
        adminAssign.Responsibility__c = 'Administrative';
        
        childAssign.Service_Case__c = getServiceCase[0].Id;
        childAssign.Assign_Type__c = 'Assign to Worker';
        childAssign.Select_a_Unit__c = 'CPS Unit 2';
        childAssign.Assign_Start_Date__c = Date.newInstance(2022,4,29);
        childAssign.Responsibility__c = 'Child';
        
        workerAssign.Service_Case__c = getServiceCase[0].Id;
        workerAssign.Assign_Type__c = 'Assign to Worker';
        workerAssign.Select_a_Unit__c = 'CPS Unit 2';
        workerAssign.Assign_Start_Date__c = Date.newInstance(2022,4,29);
        workerAssign.Responsibility__c = 'Family';
        
        invesAssign.Investigation__c = getInvestigationRec.Id;
        invesAssign.Assign_Type__c = 'Assign to Worker';
        invesAssign.Select_a_Unit__c = 'CPS Unit 2';
        invesAssign.Assign_Start_Date__c = Date.newInstance(2022,4,29);
        invesAssign.Responsibility__c = 'Administrative';
        
        if(caseWorkers.size() > 0) {
            
            adminAssign.Select_a_Social_Worker__c = caseWorkers[0].Id;
            childAssign.Select_a_Social_Worker__c = caseWorkers[0].Id;
            workerAssign.Select_a_Social_Worker__c = caseWorkers[0].Id;
            invesAssign.Select_a_Social_Worker__c = caseWorkers[0].Id;
        }
        
        //System.assertEquals(ServiceCaseController.createAssignments(JSON.serialize(adminAssign), 'Service_Case__c') == null, true);
        //System.assertEquals(ServiceCaseController.createAssignments(JSON.serialize(childAssign), 'Service_Case__c') == null, true);
        //System.assertEquals(ServiceCaseController.createAssignments(JSON.serialize(workerAssign), 'Service_Case__c') == null, true);
//System.assertEquals(ServiceCaseController.createAssignments(JSON.serialize(invesAssign), 'Investigation__c') == null, true);

        if( caseWorkers.size() > 1) {
            Assignment__c assignmentRecord = [SELECT Id, Service_Case__c, Investigation__c,Responsibility__c FROM Assignment__c WHERE Service_Case__c = :getServiceCase[0].Id LIMIT 1];
			assignmentRecord.Select_a_Social_Worker__c = caseWorkers[1].Id;
            System.assertEquals(ServiceCaseController.createAssignments(JSON.serialize(assignmentRecord), 'Service_Case__c') == null, true);
        }
        
        System.assertEquals(ServiceCaseController.getServicecaseRecord(getServiceCase[0].Id) != null ,true);
        System.assertEquals(ServiceCaseController.getServicecaseRecord(getServiceCase[1].Id) != null ,true);
        System.assertEquals(ServiceCaseController.getAssignmentRecords(getServiceCase[0].Id, 'Service_Case__c') != null, true);
        System.assertEquals(ServiceCaseController.getAssignmentRecords(getInvestigationRec.Id, 'Investigation__c') != null, true);
        System.assertEquals(ServiceCaseController.getAssignmentRecords(null, 'Investigation__c') != null, false);        
    }
}