@isTest
private class ServicePlanController_Test {

    @isTest static void testServicePlanController() {
        
        Service_Case__c serviceCaseRec = TestRecord.serviceCase('');
        insert serviceCaseRec;
        
        Service_Plan__c servicePlanRec = TestRecord.createServicePlan();
        servicePlanRec.Service_Case__c = serviceCaseRec.Id;
        insert servicePlanRec;
        
        Service_Plan_Version__c servicePlanVersionRec = TestRecord.createServicePlanVersion();
        servicePlanVersionRec.Service_Plan__c = servicePlanRec.Id;
        servicePlanVersionRec.Persons_Benefitizing__c = 'Test Person';
        
        Goal__c goalRec = TestRecord.createGoal();
        goalRec.Service_Plan__c = servicePlanRec.Id;
        insert goalRec;
        
        Objective__c objectiveRec = TestRecord.createObjective();
        objectiveRec.Goal__c = goalRec.Id;
        insert objectiveRec;
        
        Collateral__c collateralRec = TestRecord.createCollateral();
        collateralRec.Service_Case__c = serviceCaseRec.Id;
        insert collateralRec;
        
        Contact personRec = TestRecord.contact('Test', 'Person');
        //personRec.Service_Case__c = serviceCaseRec.Id;
        insert personRec;
        
        Goal_Action__c goalActionRec = TestRecord.createGoalAction();
        goalActionRec.Person_Benefitizing__c = 'Test Person';
        goalActionRec.Person_Responsible__c = 'Test Person';
        goalActionRec.Goal_Objective__c = objectiveRec.Id;
        
        Visitation_Plan__c visitationPlanRec = TestRecord.createVisitationPlan();
        visitationPlanRec.Service_Plan__c = servicePlanRec.Id;
        
        String visitationPlanId = ServicePlanController.createVisitationPlanRecord(JSON.serialize(visitationPlanRec));
        System.assertEquals( visitationPlanId != null , true);
        
        Visitation_Plan__c getVisitationPlan = [SELECT Id, Established_Date__c FROM Visitation_Plan__c WHERE Id = :visitationPlanId];
        getVisitationPlan.Established_Date__c = Date.newInstance(2022,5,29);
        System.assertEquals(ServicePlanController.createVisitationPlanRecord(JSON.serialize(getVisitationPlan)) != null, true);
        System.assertEquals(ServicePlanController.createVisitationPlanRecord('') == null, true);
        
        System.assertEquals(ServicePlanController.getIntiVisitationInfo(servicePlanRec.Id) != null, true);
        
        System.assertEquals(ServicePlanController.getVisitationPlanRec(visitationPlanId) != null, true);
        
        ServicePlanController.deleteVisitationPlanRec(JSON.serialize(getVisitationPlan));
        
        String goalActionId = ServicePlanController.upsertGoalActions(JSON.serialize(goalActionRec));
        System.assertEquals( goalActionId != null, true);
        
        goalActionRec.Id = goalActionId;
        System.assertEquals(ServicePlanController.upsertGoalActions(JSON.serialize(goalActionRec)) != null, true);
        System.assertEquals(ServicePlanController.upsertGoalActions('') == null, true);

        System.assertEquals(ServicePlanController.getActionsInitialInfo(objectiveRec.Id) != null, true);
       
        String servicePlanVersionId = ServicePlanController.upsertServicePlanVersions(JSON.serialize(servicePlanVersionRec));
        System.assertEquals( servicePlanVersionId != null, true);
        
       	servicePlanVersionRec.Id = servicePlanVersionId;
        System.assertEquals(ServicePlanController.upsertServicePlanVersions(JSON.serialize(servicePlanVersionRec)) != null, true);
        System.assertEquals(ServicePlanController.upsertServicePlanVersions('') == null, true);
        
        System.assertEquals(ServicePlanController.getServicePlanVersionsInitInfo(servicePlanRec.Id) != null, true);        
    }
}