public with sharing class PermanacyPlanController {
    
    @AuraEnabled
    public static String getInitialInformation(String serviceCaseRecordId, String permanencyPlanRecordId) {  

        GetInitialWrapper initWrap = new GetInitialWrapper();
        List<String> placementFields = new List<String>{'Service_Case__c', 'Id', 'Child__c', 'Child__r.Name', 'Child__r.Intake_Person_Role__c', 'Child__r.Age__c', 'Child__r.Date_of_Birth__c', 'Exit_Approval_Status__c'};
        String placementCondition = 'Child__c != Null AND Placement_Approval_Status__c = \'Approved\' AND Service_Case__c = \''+ String.escapeSingleQuotes(serviceCaseRecordId) +'\' AND Exit_Approval_Status__c != \'Approved\' AND End_Date__c = null';
        List<SObject> placementSObjList = DataService.performQueryOperation(placementFields, 'Placement__c', placementCondition, Utility.queryLimit);
        initWrap.approvedPlacementChildList = (List<Placement__c>)placementSObjList;
       
        if(String.isNotBlank(permanencyPlanRecordId)) {
            List<String> permanencyPlanFields = new List<String>{'Id','Name', 'Primary_Permanency_Plan__c', 'Plan_Established_Date__c', 'Plan_Comments__c', 'Concurrent_Permanency_Plan__c', 'Concurrent_Plan_Established_Date__c', 'Concurrent_Comments__c', 'End_Date__c', 'End_Reason__c', 'Court_order_received_and_upload_in_CJAMS__c',
                                                                 'If_the_Permanency_plan_is_to_return_home__c', 'Explanation_Required__c','Discuss_how_the_caregiver_is_meeting__c', 'Discuss_and_explain_changes_in_the_child__c', 'Describe_how_the_worker_is_carrying_out__c', 'Document_what_steps_have_been_taken__c','Describe_how_the_worker_is_ensuring__c',
                                                                 'What_efforts_were_made_to_promote__c','Has_a_Lifebook_been_prepared__c','Describe_the_parent_s_compliance__c','Does_the_Provider_agree_permanency__c','Permanancy_Agree_Explanation_Required__c','Discuss_services_being_provided__c','Contact__c'};
            String permanencyPlanCondition = 'Id = \''+ String.escapeSingleQuotes(permanencyPlanRecordId) +'\'';
            List<SObject> permanencyPlanObjList = DataService.performQueryOperation(permanencyPlanFields, 'Permanency_Plan__c', permanencyPlanCondition, 1);
            if (permanencyPlanObjList != null && permanencyPlanObjList.size() > 0) {
                initWrap.permanencyInst = (Permanency_Plan__c)permanencyPlanObjList[0];
            }    
        }    
                                
       return JSON.serialize(initWrap);
    }

    @AuraEnabled
    public static String getInitialPermanancyDetails(String permanancyPlanId) {  
    
        GetInitialWrapper initWrap = new GetInitialWrapper();
        initWrap.guardianshipPlaningPicklist = Utility.getPicklistinfo('Permanency_Plan__c','Guardianship_Planing__c',false);
        List<String> permanencyPlanFields = new List<String>{'Id', 'Guardianship_Planing__c', 'Gender__c', 'D_O_B__c', 'Client_Name__c', 'Contact__r.Casevault_PID__c'};
        String permanencyPlanCondition = 'Id = \''+ String.escapeSingleQuotes(permanancyPlanId) +'\'';
            List<SObject> permanencyPlanObjList = DataService.performQueryOperation(permanencyPlanFields, 'Permanency_Plan__c', permanencyPlanCondition, 1);
            
            if(permanencyPlanObjList != null && permanencyPlanObjList.size() > 0) {
                initWrap.permanencyInst = (Permanency_Plan__c)permanencyPlanObjList[0];
            }  

        return JSON.serialize(initWrap);
    }
     
    public class GetInitialWrapper { 
          
        @AuraEnabled
        public List<Utility.pickListWrap> guardianshipPlaningPicklist;
        @AuraEnabled
        public Permanency_Plan__c  permanencyInst;
        @AuraEnabled
        public List<Placement__c> approvedPlacementChildList;      
    }
}