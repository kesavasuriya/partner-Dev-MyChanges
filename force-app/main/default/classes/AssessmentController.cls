public with sharing class AssessmentController {
    
    @AuraEnabled
    public static String getSAFECOHPInitialInformation(String recordId) {
        
        GetInitialWrapper initWrap = new GetInitialWrapper();
        initWrap.childInputWarpList = new List<ChildInputWarp>();
       
        initWrap.thechildsImmediatehealthneedsPicklist =  Utility.getPicklistinfo('Assessment__c','The_child_s_Immediate_health_needs__c',false);
        //Regarding many to many we have changed and command some logic 22/11/22
        List<String> personJnFields = new List<String>{'Id', 'Person__c'};
        String personJnCondition = 'Service_Case__c = \'' + String.escapeSingleQuotes(recordId) + '\' OR Investigation__c = \'' + String.escapeSingleQuotes(recordId) + '\'';
        List<SObject> personJnObjList = DataService.performQueryOperation(personJnFields, 'Person__c', personJnCondition, Utility.queryLimit);
        Set<Id> personIdSet = new Set<Id>();
        for (Person__c personIns : (List<Person__c>)personJnObjList) {
            personIdSet.add(personIns.Person__c);
        }
        /*List<String> contactFields = new List<String>{'Id', 'Name', 'Age__c', 'Date_of_Birth__c'};
        String contactCondition = '';
        if(personIdSet != null && personIdSet.size() > 0) {
            contactCondition = 'Id IN (';           
            for (Id personId : personIdSet) {
                contactCondition +='\''+String.escapeSingleQuotes(personId)+'\' ,';
            }
            contactCondition = contactCondition.removeEnd(' ,'); 
            contactCondition +=') ';
        } else {
            contactCondition = 'Id IN ('+'\''+'\''+') ';
        }

        List<SObject> contactObjList = DataService.performQueryOperation(contactFields, 'Contact', contactCondition, Utility.queryLimit);
        initWrap.conactList = (List<Contact>)contactObjList;*/

        /*List<String> contactFields = new List<String>{'Name', 'Service_Case__c', 'Investigation__c'};
        String contactCondition = 'Service_Case__c = \'' + String.escapeSingleQuotes(recordId) + '\' OR Investigation__c = \'' + String.escapeSingleQuotes(recordId) + '\'';
        List<SObject> contactsObjList = DataService.performQueryOperation(contactFields, 'Contact', contactCondition, Utility.queryLimit);
        initWrap.conactList = (List<Contact>)contactsObjList;*/

        Id recId = recordId;
        String sObjName = recId.getSObjectType().getDescribe().getName();
        List<String> assFields = new List<String>{'Id', 'Name', 'OHP_Signature_Obtained_Date__c', 'Approval_Status__c'};
        String assCondition = '( Service_Case__c = \'' + String.escapeSingleQuotes(recordId) + '\' OR Investigation__c = \'' + 
                                String.escapeSingleQuotes(recordId) + '\' ) AND Assessment_Type__c = \'SAFE-C-OHP\' ORDER BY Name';
        List<SObject> assObjList = DataService.performQueryOperation(assFields, 'Assessment__c', assCondition, Utility.queryLimit);
        initWrap.assessmentOHPList = (List<Assessment__c>)assObjList;

        if(sObjName == 'Service_Case__c') {
            List<String> serCaseFields = new List<String>{'Id', 'Status__c'};
            String serCaseCondition = 'Id = \'' + String.escapeSingleQuotes(recordId) + '\'';
            List<SObject> serCaseObjList = DataService.performQueryOperation(serCaseFields, 'Service_Case__c', serCaseCondition, Utility.queryLimit);
            if(serCaseObjList != null && serCaseObjList.size() > 0) {
                initWrap.statusService = (Service_Case__c)serCaseObjList[0];
            } 
        }
        List<Utility.pickListWrap> recPickList = new List<Utility.pickListWrap>();
        Utility.pickListWrap intialPick = new Utility.pickListWrap();
        intialPick.label = '--None--';
        intialPick.value = '';
        recPickList.add(intialPick);
        Utility.pickListWrap pick;
        
        /*for(Contact contactIns : initWrap.conactList) {
        
            pick = new Utility.pickListWrap();       
            pick.label = contactIns.Name;
            pick.value = contactIns.Id;
            recPickList.add(pick);
        }
        initWrap.cotactsNames = recPickList;*/

        //Regarding many to many we have changed and command some logic 22/11/22
        List<String> childFields = new List<String>{'Id', 'Person__c', 'Person__r.Name', 'Person__r.Casevault_PID__c',
                                    'Investigation__c', 'Person__r.Age__c'};
        String childCondition = '( Service_Case__c = \'' + String.escapeSingleQuotes(recordId) + '\' OR Investigation__c = \'' + String.escapeSingleQuotes(recordId) + '\') ' +
                                ' AND Person_Role__c  INCLUDES (\'Biological Child\',\'Other Child (Not in Household)\',\'Private Adoptive Child\') AND  Person__r.RecordType.DeveloperName = \'Persons_Involved\'  ';                             
        /* List<String> childFields = new List<String>{'Id', 'Name', 'Service_Case__c', 'Service_Case__r.Status__c', 'HEAD_OF_HOUSEHOLD__c','Service_Case__r.Name', 'Casevault_PID__c',
                                    'Investigation__c', 'Age__c'};
        String childCondition = '( Service_Case__c = \'' + String.escapeSingleQuotes(recordId) + '\' OR Investigation__c = \'' + String.escapeSingleQuotes(recordId) + '\') ' +
                                ' AND Intake_Person_Role__c INCLUDES (\'Biological Child\',\'Other Child (Not in Household)\',\'Private Adoptive Child\') ';    
        List<SObject> childsObjList = DataService.performQueryOperation(childFields, 'Contact', childCondition, Utility.queryLimit);
        initWrap.childList = (List<Contact>)childsObjList; */

        List<SObject> childsObjList = DataService.performQueryOperation(childFields, 'Person__c', childCondition, Utility.queryLimit);
        initWrap.childList = (List<Person__c>)childsObjList;

        ChildInputWarp childInputWarpTableIns;
        //if(initWrap.childList != null && initWrap.childList.size() > 0) {
            
            /*for (Contact conIns: initWrap.childList) {
                childInputWarpTableIns = new ChildInputWarp();
                childInputWarpTableIns.chidName = conIns.Name;
                childInputWarpTableIns.age = conIns.Age__c;
                childInputWarpTableIns.childId = conIns.Id;
                childInputWarpTableIns.clientId = conIns.Casevault_PID__c;
                initWrap.childInputWarpList.add(childInputWarpTableIns);
            }*/

        //}
        for (Person__c personIns : initWrap.childList) {
            childInputWarpTableIns = new ChildInputWarp();
            childInputWarpTableIns.chidName = personIns.Person__r.Name;
            childInputWarpTableIns.age = personIns.Person__r.Age__c;
            childInputWarpTableIns.childId = personIns.Person__c;
            childInputWarpTableIns.clientId = personIns.Person__r.Casevault_PID__c;
            initWrap.childInputWarpList.add(childInputWarpTableIns);
        }
        return JSON.serialize(initWrap);
    }
    
    @AuraEnabled
    public static String getAssessmentOHP(String assessmentRecordId) { 
    
        GetInitialWrapper initWrap = new GetInitialWrapper();
        List<String> assFields = new List<String>{'Id', 'Approval_Status__c', 'OHP_Child_Name__c', 'Current_Placement__c',  'Potential_Resource__c','Name_of_Placement_Resource__c','Service_Case__c',
                                'OHP_Address_Line_1__c', 'Address_Line_2__c','OHP_Zipcode__c',  'OHP_Work__c',  'OHP_Ext__c',  'OHP_Fax__c',  'Staff_Member_Interviewed_Comments__c',
                                'When_Circumstances_Suggest_That_the_Chil__c', 'Initial_Replacement_Placements__c', 'SAFEC_Before_Completing_a_case__c', 'The_child_s_Immediate_health_needs__c',  'If_the_child_was_on_medication__c',
                                'If_the_child_had_a_history_of_suicidal__c','If_the_child_had_a_history_of_aggressive__c', 'If_the_child_had_a_history_of_sexual__c', 'If_the_child_had_a_history_of_drug__c',
                                'This_child_s_sleeping_arrangements__c','This_child_s_is_or_will_be_protected__c', 'This_child_does_not_express_specific__c', 'Provider_appears_competent_coherent__c', 'Any_injuries_to_the_child__c',
                                'This_child_s_whereabouts_are_known__c','OHP_Unsafe_Influences__c', 'OHP_Safety_Decision__c', 'OHP_Child_is_Safe_Influences_1_12_Marked__c',  'OHP_Child_is_Unsafe_Any_Influence_1_12__c',
                                'OHP_Whereabouts_of_Child_Youth__c','OHP_If_Placed_with_Potential_Resource__c', 'OHP_if_they_remain_with_the_current__c',  'OHP_Comments__c',  'OHP_Signature_Obtained__c',
                                'OHP_Signature_Obtained_Date__c','OHP_Representative_Title__c', 'OHP_Local_Department__c'};
        String assCondition = 'Id = \'' + String.escapeSingleQuotes(assessmentRecordId) + '\'';
        List<SObject> sObjList = DataService.performQueryOperation(assFields, 'Assessment__c', assCondition, Utility.queryLimit);
        
        if(sObjList != null && sObjList.size() > 0) {
            initWrap.assessmentOHPRec = (Assessment__c)sObjList[0];
        }                        
        return JSON.serialize(initWrap);            
    }
    
    @AuraEnabled
    public static String getAssessment(String assessmentRecordId) {
    
        GetInitialWrapper initWrap = new GetInitialWrapper();
        initWrap.assessmentRec = new Assessment__c();
        List<String> assFields = new List<String>{'Id', 'Approval_Status__c', 'SAFEC_Date_Time_Assessment_Initiated__c','SAFEC_Case_Worker_Comments__c', 'SAFEC_Date_Time_of_Last_Safety_Plan__c', 'SAFEC_Legal_Guardian_Name__c',
                                'SAFEC_CPS_Case_ID__c', 'SAFEC_Head_of_Household__c', 'SAFEC_Relationship__c', 'SAFEC_CIS_ID__c',
                                'SAFEC_Caregiver__c', 'SAFEC_At_the_Initial_face_to_facecontact__c', 'SAFEC_At_the_completion_closure__c',
                                'SAFEC_When_The_case_Assessor_discovers__c', 'SAFEC_When_circumstances_suggest__c', 'SAFEC_Within_7_Working_days_of_case__c',
                                'SAFEC_Before_Completing_a_case__c', 'SAFEC_At_time_of_trial_home_visit__c', 'SAFEC_Within_ten_10_working_days__c',
                                'SAFEC_Out_HOME_Before_completing_a_case__c', 'SAFEC_within_7_working_days_prior__c', 'SAFEC_Within_7_working_days_prior_to__c', 
                                'SAFEC_OUT_HOME_When_the_case_assessor__c', 'SAFEC_When_circumstances_suggest_that__c', 'SAFEC_Age_0_5_Years_old__c',
                                'SAFEC_Diminished_Physical_capacity__c', 'SAFEC_Diminished_mental_capacity__c', 'SAFEC_School_age_but_not_attending__c',
                                'SAFEC_Significant_diagnosed_medical_or__c', 'SAFEC_Child_s_extreme_anxiety_or_fear__c',
                                'SAFEC_Caregiver_fails_to_protect__c', 'SAFEC_Caregiver_fails_Comments__c', 
                                'SAFEC_Caregiver_made_a_plausible_threat__c', 'SAFEC_Caregiver_made_a_Comments__c','SAFEC_When_the_safety_plan__c',
                                'SAFEC_There_has_been_current_act__c', 'SAFEC_There_has_been_current_actComments__c', 'SAFEC_Child_sexual_abuse_is_suspected__c',
                                'SAFEC_Child_sexual_abuse_Comments__c', 'SAFEC_Caregiver_describes_the_child__c', 'SAFEC_Caregiver_describes_Comments__c',
                                'SAFEC_Cargiver_s_suspected_or_observed__c', 'SAFEC_Cargiver_s_suspected_Comments__c', 'SAFEC_Caregiver_s_emotional_instability__c',
                                'SAFEC_Caregiver_s_emotional_Comments__c', 'SAFEC_Caregiver_s_explanation__c',
                                'SAFEC_Caregiver_s_explanation_Comments__c', 'SAFEC_Caregivers_justification_or_denial__c',
                                'SAFEC_Caregivers_justification_Comments__c', 'SAFEC_Caregiver_does_not_or_refuse__c', 'SAFEC_Caregiver_does_not_Comments__c',
                                'SAFEC_Domestic_violence_exists__c', 'SAFEC_Domestic_violence_Comments__c', 'SAFEC_Caregiver_does_not_meet_the_childs__c',
                                'SAFEC_Caregiver_does_not_meet_Comments__c', 'SAFEC_The_childs_whereabouts_are_unknown__c', 'SAFEC_The_childs_whereabouts_Comments__c',
                                'SAFEC_The_child_has_special_needs__c', 'SAFEC_The_child_has_special_Comments__c', 'SAFEC_The_child_is_extremely_anxious__c',
                                'SAFEC_The_child_is_extremely_Comments__c', 'SAFEC_The_child_is_unable_to_protect__c', 'SAFEC_The_child_is_unable_Comments__c',
                                'SAFEC_Previous_services_to_the_caregiver__c', 'SAFEC_Previous_services_Comments__c', 'SAFEC_There_have_been_multiple_reports__c',
                                'SAFEC_There_have_been_multiple_Comments__c', 'SAFEC_Child__c', 'SAFEC_Caregiver_is_able__c', 'SAFEC_Caregiver_is_able_and_willing__c',
                                'SAFEC_Caregiver_has_supportive__c', 'SAFEC_Caregiver_exhibits_self_control__c', 'SAFEC_There_is_evidence_of_a_healthy__c',
                                'SAFEC_Caregiver_demonstrated_effective__c', 'SAFEC_Relevant_community_services__c',
                                'SAFEC_Any_Influences_1_18_was_checked__c', 'SAFEC_Caregiver_did_not_agree_to_safety__c',
                                'SAFEC_Danger_cannot_be_addressed_via__c', 'SAFEC_LDSS__c', 'Workers_Name__c', 'Supervisor_Name__c', 'Submit_for_Approval__c',
                                'When_Circumstances_Suggest_That_the_Chil__c', 'Safety_Assessment_Approval_Date_Time__c',
                                'Safety_Assessment_Completion_Date_Time__c','Service_Case__c',
                                'SAFEC_Child_is_Conditionally_Safe_17_16__c', 'SAFEC_Child_is_Safe_Influences_1_18__c', 
                                'SAFEC_Child_is_conditionally_Safe__c', 'SAFEC_Child_is_UnSafe__c'};
        String assCondition = 'Id = \'' + String.escapeSingleQuotes(assessmentRecordId) + '\'';
        List<SObject> sObjList = DataService.performQueryOperation(assFields, 'Assessment__c', assCondition, Utility.queryLimit);
        
        if(sObjList != null && sObjList.size() > 0) {
            initWrap.assessmentRec = (Assessment__c)sObjList[0];
        }                        
        
        List<String> assSPlanFields = new List<String>{'Id', 'Specific_Danger_Influence__c', 'Responsible_Parties__c', 'Re_evaluation_Date__c',
                                        'Question_Name__c', 'Index__c', 'Date_to_be_Completed__c', 'Danger_Influence_Qeustion__c', 'Action_Required__c'};
        String assSPlanCondition = 'Assessment__c = \'' + String.escapeSingleQuotes(assessmentRecordId) + '\'';
        List<SObject> assSPlansObjList = DataService.performQueryOperation(assSPlanFields, 'Assessment_Safety_Plan__c', assSPlanCondition, Utility.queryLimit);
        initWrap.assessmentSafetyPlanList = (List<Assessment_Safety_Plan__c>)assSPlansObjList;
        return JSON.serialize(initWrap);
        
    }
    
    @AuraEnabled
    public static String getSAFECInitialInformation(String recordId) {
        
        GetInitialWrapper initWrap = new GetInitialWrapper();
        initWrap.childInputWarpList = new List<ChildInputWarp>();
        initWrap.assessmentList = new List<safecWarp>(); 
        Set<Id> inHomePersons = new Set<Id>();
        Id recId = recordId;
        String sObjName = recId.getSObjectType().getDescribe().getName();
        
        if(sObjName == 'Service_Case__c') {
            
            List<String> sCaseFields = new List<String>{'Id','Name','Status__c',' Head_of_Household__r.Name'};
            String sCaseCondition = 'Id = \'' + String.escapeSingleQuotes(recordId) + '\'';
            List<SObject> sObjList = DataService.performQueryOperation(sCaseFields, 'Service_Case__c', sCaseCondition, Utility.queryLimit);
            if(sObjList != null && sObjList.size() > 0) {
                initWrap.statusService = (Service_Case__c)sObjList[0];
                initWrap.cpsCaseName = initWrap.statusService.Name;
                initWrap.headofHouseholdName = initWrap.statusService.Head_of_Household__r.Name;
            }
            
            for(Program_Assignment__c assignmentIns : [SELECT Id, Program_Area__c, Contact__c FROM Program_Assignment__c WHERE (Service_Case__c = :recordId OR Investigation__c = :recordId) 
                                                   AND (Program_Area__c = 'In Home' OR Program_Area__c = 'Out of Home') ORDER BY Program_Area__c ASC]) 
            {
                if(assignmentIns.Program_Area__c == 'In Home') {
                    inHomePersons.add(assignmentIns.Contact__c);
                } else if(assignmentIns.Program_Area__c == 'Out of Home' && inHomePersons.contains(assignmentIns.Contact__c)) {
                    inHomePersons.remove(assignmentIns.Contact__c);
                }
            }
            
        } else if(sObjName == 'Investigation__c') {
            
            Investigation__c invIns = new Investigation__c();
            List<String> invFields = new List<String>{'Name','Head_of_Household__r.Name'};
            String invCondition = 'Id = \'' + String.escapeSingleQuotes(recordId) + '\'';
            List<SObject> sObjList = DataService.performQueryOperation(invFields, 'Investigation__c', invCondition, Utility.queryLimit);
            if(sObjList != null && sObjList.size() > 0) {
                invIns = (Investigation__c)sObjList[0];
                initWrap.cpsCaseName = invIns.Name;
                initWrap.headofHouseholdName = invIns.Head_of_Household__r.Name;
            }
        }
        
        //Regarding many to many we have changed and command some logic 22/11/22
        initWrap.caregiverDescribesTheChildPicklist =  Utility.getPicklistinfo('Assessment__c','SAFEC_Cargiver_s_suspected_or_observed__c',false);
        
        List<String> childFields = new List<String>{'Id', 'Person__c', 'Person__r.Name', 'Person__r.Casevault_PID__c',
                                    'Investigation__c', 'Person__r.Age__c'};
        String childCondition = '( Service_Case__c = \'' + String.escapeSingleQuotes(recordId) + '\' OR Investigation__c = \'' + String.escapeSingleQuotes(recordId) + '\') ' +
                                ' AND Person_Role__c INCLUDES (\'Biological Child\',\'Other Child (Not in Household)\',\'Private Adoptive Child\') AND  Person__r.RecordType.DeveloperName = \'Persons_Involved\' AND Person__r.Age__c < 18 ';  
        List<SObject> childsObjList = DataService.performQueryOperation(childFields, 'Person__c', childCondition, Utility.queryLimit);
        initWrap.childList = (List<Person__c>)childsObjList;
        
        
        Set<Id> contactIDs = new Set<Id>();
        for(Person__c personIns : [SELECT Id, Person__c FROM Person__c WHERE (Service_Case__c = :recordId OR Investigation__c = :recordId)]) {
            contactIDs.add(personIns.Person__c);
        }
        
        /*List<String> childFields = new List<String>{'Id','Name','Service_Case__c', 'Service_Case__r.Status__c', 'HEAD_OF_HOUSEHOLD__c','Service_Case__r.Name', 'Casevault_PID__c',
                                    'Investigation__c', 'Age__c'};
        String childCondition = '(Service_Case__c = \'' + String.escapeSingleQuotes(recordId) + '\' OR Investigation__c = \''+ String.escapeSingleQuotes(recordId) + 
                                '\') AND Intake_Person_Role__c INCLUDES (\'Biological Child\',\'Other Child (Not in Household)\',\'Private Adoptive Child\')';
        List<SObject> childsObjList = DataService.performQueryOperation(childFields, 'Contact', childCondition, Utility.queryLimit);
        initWrap.childList = (List<Contact>)childsObjList; */

        List<String> caregiverFields = new List<String>{'Person__c', 'Id', 'Person__r.Name','Is_Caregiver__c '};
        String caregiverCondition = '(Service_Case__c = \'' + String.escapeSingleQuotes(recordId) + '\' OR Investigation__c = \'' + String.escapeSingleQuotes(recordId) + '\') AND Person_Role__c  INCLUDES (\'Caregiver\')';
        system.debug('condition'+caregiverCondition);
        List<SObject> caregiversObjList = DataService.performQueryOperation(caregiverFields, 'Person__c', caregiverCondition, Utility.queryLimit);
        initWrap.caregiverList = (List<Person__c>)caregiversObjList; 
        system.debug('caregiverList'+initWrap.caregiverList);
        List<String> safecFields = new List<String>{'Name', 'Safety_Assessment_Completion_Date_Time__c', 'Approval_Status__c'};
        String safecCondition = '(Service_Case__c = \'' + String.escapeSingleQuotes(recordId) + '\' OR Investigation__c = \'' + String.escapeSingleQuotes(recordId) + 
                                    '\') AND Assessment_Type__c = \'SAFE-C\' ORDER BY Name';
        List<SObject> safecObjList = DataService.performQueryOperation(safecFields, 'Assessment__c', safecCondition, Utility.queryLimit);
        List<Assessment__c>  safecList = (List<Assessment__c>)safecObjList;
        safecWarp safecWarpTableIns;
        
        for(Assessment__c ass :safecList) {
        
            safecWarpTableIns = new safecWarp();
            Datetime yourDate = ass.Safety_Assessment_Completion_Date_Time__c;
            String dateOutput = yourDate.format('MM/dd/yyyy hh:mm a'); 
            safecWarpTableIns.id = ass.Id;
            safecWarpTableIns.name = ass.Name;
            safecWarpTableIns.completionDate = dateOutput;
            safecWarpTableIns.approvalStatus = ass.Approval_Status__c;
            initWrap.assessmentList.add(safecWarpTableIns);
        }
        /*List<String> hohFields = new List<String>{'Name', 'Id', 'Service_Case__c','HEAD_OF_HOUSEHOLD__c','Investigation__r.Name', 'Service_Case__r.Name', 'Investigation__c'};
        String hohCondition = '(Service_Case__c = \'' + String.escapeSingleQuotes(recordId) + '\' OR Investigation__c = \'' + String.escapeSingleQuotes(recordId) + 
                                '\') AND HEAD_OF_HOUSEHOLD__c = true ORDER BY LastModifiedDate DESC';
        List<SObject> hohSObjList = DataService.performQueryOperation(hohFields, 'Contact', hohCondition, Utility.queryLimit);
        
        if(hohSObjList != null && hohSObjList.size() > 0) {
            //Contact contactIns = new Contact();
            Contact contactIns = (Contact)hohSObjList[0];
            initWrap.headofHouseholdName = contactIns.Name;
        }*/
        
        List<Utility.pickListWrap> recPickList = new List<Utility.pickListWrap>();
        Utility.pickListWrap intialPick = new Utility.pickListWrap();
        intialPick.label = '--None--';
        intialPick.value = '';
        recPickList.add(intialPick);
        Utility.pickListWrap pick;
        for(Person__c  relationshipRec : initWrap.caregiverList) {
        
            pick = new Utility.pickListWrap();
            pick.label = relationshipRec.Person__r.Name;
            pick.value = relationshipRec.Person__r.Name;
            recPickList.add(pick);
        }
        
        initWrap.caregiverNames = recPickList;
        initwrap.submitforApprovalPickList =  Utility.getPicklistinfo('Assessment__c','Submit_for_Approval__c',false);
        
        /*if(initWrap.childList != null && initWrap.childList.size() > 0) {
            
            ChildInputWarp childInputWarpTableIns;
            for(Contact conIns: initWrap.childList) {
                childInputWarpTableIns = new ChildInputWarp();
                childInputWarpTableIns.chidName = conIns.Name;
                childInputWarpTableIns.age = conIns.Age__c;
                childInputWarpTableIns.childId = conIns.Id;
                childInputWarpTableIns.clientId = conIns.Casevault_PID__c;
                initWrap.childInputWarpList.add(childInputWarpTableIns);
            }
        }*/

        ChildInputWarp childInputWarpTableIns;
        System.debug('inHomePersons==='+inHomePersons);
        for (Person__c personIns : initWrap.childList) {

            if(inHomePersons.contains(personIns.Person__c) || sObjName == 'Investigation__c' ) {
                
                childInputWarpTableIns = new ChildInputWarp();
                childInputWarpTableIns.chidName = personIns.Person__r.Name;
                childInputWarpTableIns.age = personIns.Person__r.Age__c;
                childInputWarpTableIns.childId = personIns.Person__c;
                childInputWarpTableIns.clientId = personIns.Person__r.Casevault_PID__c;
                initWrap.childInputWarpList.add(childInputWarpTableIns);
            }
            
        }

        return JSON.serialize(initWrap);
    }
    
    @AuraEnabled
    public static String createSAFECOHP(String assessmentSAFECOHPDataJSON) {
        
        
        if(String.isNotBlank(assessmentSAFECOHPDataJSON)) {

            Assessment__c createSAFECOHPRec = (Assessment__c) JSON.deserialize(assessmentSAFECOHPDataJSON, Assessment__c.class);
            Set<String> safecOHPDmlFieldSet = createSAFECOHPRec.getPopulatedFieldsAsMap().keySet();
            
            if(String.isBlank(createSAFECOHPRec.Id)) {
                
                insert createSAFECOHPRec;                                       
            } else {

                update createSAFECOHPRec;
            }
            return createSAFECOHPRec.Id;
        } else {
            return null;
        }
    }
    
    @AuraEnabled
    public static String createSAFEC(String assessmentSAFECDataJSON, String safetyPlanQesDataJSON, String deletingSafetyPlanJSON) {
        
        if(String.isNotBlank(assessmentSAFECDataJSON)) {
            
            Assessment__c createSAFECRec = (Assessment__c) JSON.deserialize(assessmentSAFECDataJSON, Assessment__c.class);
            Set<String> safecDmlFieldSet = createSAFECRec.getPopulatedFieldsAsMap().keySet();
            if(String.isBlank(createSAFECRec.Id)) {

                insert createSAFECRec;
            } else {
                
                update createSAFECRec;
            }
            
            if(String.isNotBlank(safetyPlanQesDataJSON)) {
                
                createSafetyPlan(safetyPlanQesDataJSON, createSAFECRec);
            }
            
            if(String.isNotBlank(deletingSafetyPlanJSON)) {
                
                deleteSafetyPlan(deletingSafetyPlanJSON);
            }
            return createSAFECRec.Id;
        } else {
            return null;
        }
    }
    
    public static void createSafetyPlan(String safetyPlanQesDataJSON, Assessment__c createSAFECRec) {
        
        List<Assessment_Safety_Plan__c> insertingAssSafetyPlanList = new List<Assessment_Safety_Plan__c>();
        List<Assessment_Safety_Plan__c> updatingAssSafetyPlanList = new List<Assessment_Safety_Plan__c>();
        
        List<Assessment_Safety_Plan__c> assessmentSafetyPlanList = (List<Assessment_Safety_Plan__c>) JSON.deserialize(safetyPlanQesDataJSON, List<Assessment_Safety_Plan__c>.class);
        
        Set<String> safetyPlanDmlfieldsSet = new Set<String>();
        for(Assessment_Safety_Plan__c asp : assessmentSafetyPlanList) {
            safetyPlanDmlfieldsSet.addAll(asp.getPopulatedFieldsAsMap().keySet());
            asp.Assessment__c = createSAFECRec.Id; 
            if(String.isBlank(asp.Id)) {
                insertingAssSafetyPlanList.add(asp);    
            } else {
                updatingAssSafetyPlanList.add(asp);
            }    
        }
        if(insertingAssSafetyPlanList != null && insertingAssSafetyPlanList.size() > 0) {
            
            insert insertingAssSafetyPlanList;
        }
        
        if(updatingAssSafetyPlanList != null && updatingAssSafetyPlanList.size() > 0) {
            
            update updatingAssSafetyPlanList;
        }
    }
    
    public static void deleteSafetyPlan(String deletingSafetyPlanJSON) {
        
        List<Assessment_Safety_Plan__c> deletingSafetyPlanList = (List<Assessment_Safety_Plan__c>) JSON.deserialize(deletingSafetyPlanJSON, List<Assessment_Safety_Plan__c>.class);
        
        if(deletingSafetyPlanList != null && deletingSafetyPlanList.size() > 0) {
            
            FieldLevelSecurity.checkObjectAccessByDelete('Assessment_Safety_Plan__c');
            delete deletingSafetyPlanList;
        }
    }
    
    @AuraEnabled
    public static String onSubmitForApproval(String assessmentRecId, Id selectedSupervisorUserId){        
        
        if(String.isNotBlank(assessmentRecId) && String.isNotBlank(selectedSupervisorUserId)) {
            Assessment__c assessmentRec =  new Assessment__c ();
            assessmentRec.Id = assessmentRecId;
            assessmentRec.Supervisor_Approver__c = selectedSupervisorUserId;
            update assessmentRec;
            Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest(); 
            req.setComments('Submit For Approval');        
            req.setObjectId(assessmentRec.Id);
            Approval.ProcessResult approvalResult = Approval.process(req);
            return JSON.serialize(approvalResult);
        } else {
            return null;
        }   
        
    } 
    
    @AuraEnabled
    public static String onSubmitStatus(String assessmentRecId){        
        
        Assessment__c assesmentRec = new Assessment__c();
        List<String> assFields = new List<String>{'Id', 'Approval_Status__c'};
        String assCondition = 'Id = \'' + String.escapeSingleQuotes(assessmentRecId) + '\'';
        List<SObject> assObjList = DataService.performQueryOperation(assFields, 'Assessment__c', assCondition, 1);
        
        if(assObjList != null && assObjList.size() > 0) {
            assesmentRec = (Assessment__c)assObjList[0];
        }
        return JSON.serialize(assesmentRec); 
    } 
    
    @AuraEnabled
    public static String getFamilyRiskReassessmentInfo(String recordId, String objectApiName) {
        
        GetInitialWrapper initWrap = new GetInitialWrapper();

        initwrap.RR1options =  Utility.getPicklistinfo('Assessment__c','Household_previously_received_CPS__c',false);
        initwrap.RR2options =  Utility.getPicklistinfo('Assessment__c','Prior_CPS_response_IR_AR__c',false);
        initwrap.RR3options =  Utility.getPicklistinfo('Assessment__c','Primary_caregiver_has_a_history_of_abuse__c',false);
        initwrap.RR4options =  Utility.getPicklistinfo('Assessment__c','Characteristics_of_children_household__c',true);
        initwrap.RR5options =  Utility.getPicklistinfo('Assessment__c','New_CPS_response_of_abuse_or_neglect__c',false);
        initwrap.RR6options =  Utility.getPicklistinfo('Assessment__c','Primary_caregiver_alcohol_or_substance__c',false);
        initwrap.RR7options =  Utility.getPicklistinfo('Assessment__c','Adult_relationships_since_the_MFIRA__c',false);
        initwrap.RR7Yesoptions =  Utility.getPicklistinfo('Assessment__c','Yes_problems_with_adult_r__c',true);
        initwrap.RR8options =  Utility.getPicklistinfo('Assessment__c','Primary_caregiver_mental_health__c',false);
        initwrap.RR9options =  Utility.getPicklistinfo('Assessment__c','Primary_caregiver_provides_physical_care__c',false);
        initwrap.riskLevelOptions =  Utility.getPicklistinfo('Assessment__c','RISK_LEVEL__c',false);
        initwrap.x1options =  Utility.getPicklistinfo('Assessment__c','X1_Sexual_abuse_case_and_the_alleged__c',false);
        initwrap.x2options =  Utility.getPicklistinfo('Assessment__c','X2_Non_accidental_injury_to_a_child__c',false);
        initwrap.x3options =  Utility.getPicklistinfo('Assessment__c','X3_Severe_non_accidental_injury__c',false);
        initwrap.x4options =  Utility.getPicklistinfo('Assessment__c','X4_Caregiver_action_or_inaction_resulted__c',false);
        initwrap.x5options =  Utility.getPicklistinfo('Assessment__c','X5_If_yes_override_risk_level__c',false);
        initwrap.finalriskleveloptions =  Utility.getPicklistinfo('Assessment__c','FINAL_RISK_LEVEL__c',false);
        initwrap.plannedActionOptions =  Utility.getPicklistinfo('Assessment__c','PLANNED_ACTION__c',false);
        initwrap.approvalOptions =  Utility.getPicklistinfo('Assessment__c','Submit_for_Approval__c',false);
        initwrap.routeToSupervisorOptions =  Utility.getPicklistinfo('Assessment__c','Route_to_Supervisor__c',false);
        
        if(String.isNotBlank(recordId) && String.isNotBlank(objectApiName)) {
            
            if(objectApiName == 'Service_Case__c') {
        
                List<String> sCaseFields = new List<String>{'Id', 'Head_of_Household__r.Name', 'Name'};
                String sCaseCondition = 'Id = \'' + String.escapeSingleQuotes(recordId) + '\'';
                List<SObject> sCasesObjList = DataService.performQueryOperation(sCaseFields, 'Service_Case__c', sCaseCondition, Utility.queryLimit);
                
                if(sCasesObjList != null && sCasesObjList.size() > 0) {
                    initWrap.serviceCaseRec = (Service_Case__c)sCasesObjList[0];
                }
            } else if(objectApiName == 'Investigation__c') {
               
                List<String> invFields = new List<String>{'Id', 'Head_of_Household__r.Name', 'Name'};
                String invCondition = 'Id = \'' + String.escapeSingleQuotes(recordId) + '\'';
                List<SObject> invsObjList = DataService.performQueryOperation(invFields, 'Investigation__c', invCondition, Utility.queryLimit);
                
                if(invsObjList != null && invsObjList.size() > 0) {
                    initWrap.investigationRec = (Investigation__c)invsObjList[0];
                }
            }
 
            List<String> assFields = new List<String>{'Id','Name','FRRE_Date_Assessment_Initiated__c', 'Household_previously_received_CPS__c', 'RR1_Score__c', 
                                                        'Prior_CPS_response_IR_AR__c', 'RR2_Score__c', 'Primary_caregiver_has_a_history_of_abuse__c', 'RR3_Score__c',
                                                      'Characteristics_of_children_household__c', 'RR4_Score__c', 'New_CPS_response_of_abuse_or_neglect__c', 'RR5_Score__c', 
                                                      'Primary_caregiver_alcohol_or_substance__c', 'RR6_Score__c', 'Adult_relationships_since_the_MFIRA__c',
                                                       'Yes_problems_with_adult_r__c', 'RR7_Score__c',
                                                      'Primary_caregiver_mental_health__c', 'RR8_Score__c', 'Primary_caregiver_provides_physical_care__c',
                                                       'RR9_Score__c', 'Demonstrate_Primary_Caregiver__c', 'Does_not_Demonstrate_Primary_Caregiver__c',
                                                        'Demonstarte_SecondaryCaregiver__c', 'Does_not_Demonstarte_Secondary_Caregiver__c',
                                                      'No_Secondary_Caregiver__c', 'RR10_Score__c', 'Does_not_demonstrate_Score__c', 'No_Secondary_Score__c', 
                                                      'Total_Score__c', 'RISK_LEVEL__c', 'X1_Sexual_abuse_case_and_the_alleged__c', 'X2_Non_accidental_injury_to_a_child__c', 
                                                      'X3_Severe_non_accidental_injury__c', 'X4_Caregiver_action_or_inaction_resulted__c',
                                                      'X5_If_yes_override_risk_level__c', 'FINAL_RISK_LEVEL__c', 'FIRA_Discretionary_override_reason__c', 
                                                      'PLANNED_ACTION__c', 'Case_Worker_Name__c', 'Submit_for_Approval__c', 'Date__c', 'Route_to_Supervisor__c', 
                                                      'Caseworker_comments__c', 'Supervisor_Name__c', 'Approval_Status__c'};
                String assCondition = '(Service_Case__c = \'' + String.escapeSingleQuotes(recordId) + '\' OR Investigation__c = \'' + String.escapeSingleQuotes(recordId) + 
                                    '\') AND Assessment_Type__c = \'Family risk Reassessment\' ';
                List<SObject> assObjList = DataService.performQueryOperation(assFields, 'Assessment__c', assCondition, Utility.queryLimit); 
                initWrap.familyRiskReassessmentRec = (List<Assessment__c>)assObjList;

                //Regarding many to many we have changed and command some logic 22/11/22
                List<String> personJnFields = new List<String>{'Id', 'Person__c'};
                String personJnCondition = 'Service_Case__c = \'' + String.escapeSingleQuotes(recordId) + '\' OR Investigation__c = \'' + String.escapeSingleQuotes(recordId) + '\'';
                List<SObject> personJnObjList = DataService.performQueryOperation(personJnFields, 'Person__c', personJnCondition, Utility.queryLimit);
                Set<Id> personIdSet = new Set<Id>();
                for (Person__c personIns : (List<Person__c>)personJnObjList) {
                    personIdSet.add(personIns.Person__c);
                }
                List<String> contactFields = new List<String>{'Id', 'Name', 'Age__c', 'Date_of_Birth__c'};
                String contactCondition = ' RecordType.DeveloperName = \'Persons_Involved\' AND ';
                if(personIdSet != null && personIdSet.size() > 0) {
                    contactCondition += 'Id IN (';           
                    for (Id personId : personIdSet) {
                        contactCondition +='\''+String.escapeSingleQuotes(personId)+'\' ,';
                    }
                    contactCondition = contactCondition.removeEnd(' ,'); 
                    contactCondition +=') ';
                } else {
                    contactCondition += 'Id IN ('+'\''+'\''+') ';
                }
				System.debug('condition==='+contactCondition);	
                List<SObject> contactObjList = DataService.performQueryOperation(contactFields, 'Contact', contactCondition, Utility.queryLimit);
                initWrap.conactList = (List<Contact>)contactObjList;

                /*List<String> contactFields = new List<String>{'Id', 'Name', 'Age__c', 'Date_of_Birth__c'};
                String contactCondition = 'Service_Case__c = \'' + String.escapeSingleQuotes(recordId) + '\' OR Investigation__c = \'' + String.escapeSingleQuotes(recordId) + '\'';
                List<SObject> contactObjList = DataService.performQueryOperation(contactFields, 'Contact', contactCondition, Utility.queryLimit);
                initWrap.conactList = (List<Contact>)contactObjList;*/
            
        }   
        return JSON.serialize(initWrap);           
    }
    
    @AuraEnabled
    public static String upsertfamilyRiskReassessment(String familyRiskReassessmentJSON){
        
        if(String.isNotBlank(familyRiskReassessmentJSON)) {
        
            Assessment__c  familyRiskReassessmentRec = (Assessment__c)JSON.deserialize(familyRiskReassessmentJSON, Assessment__c.class);
            if(String.isNotBlank(familyRiskReassessmentRec.FIRA_Case_worker_Signature__c)) {
                familyRiskReassessmentRec.FIRA_Case_worker_Signature__c = familyRiskReassessmentRec.FIRA_Case_worker_Signature__c;
            }

            if(String.isNotBlank(familyRiskReassessmentRec.Supervisor_Signature__c)) {
                familyRiskReassessmentRec.Supervisor_Signature__c = familyRiskReassessmentRec.Supervisor_Signature__c;
            }
            if(String.isBlank(familyRiskReassessmentRec.Id)) {

                familyRiskReassessmentRec.FRRE_Date_Assessment_Initiated__c = System.now();
    
                insert familyRiskReassessmentRec;
            } else {

                update familyRiskReassessmentRec;
            }
            return familyRiskReassessmentRec.Id;
        } else {
            return null;
        }
        
    }
    
    @AuraEnabled
    public static String upsertfamilyApprovalSign(String familyRiskReassessmentJSON, String parent1Signature, String parent2Signature){
        
        if(String.isNotBlank(familyRiskReassessmentJSON)) {
            Assessment__c  familyRiskReassessmentRec = (Assessment__c)JSON.deserialize(familyRiskReassessmentJSON, Assessment__c.class);
            
            if(String.isNotBlank(parent1Signature)) {
                familyRiskReassessmentRec.FIRA_Case_worker_Signature__c = parent1Signature;
            }

            if(String.isNotBlank(parent2Signature)) {
                familyRiskReassessmentRec.Supervisor_Signature__c = parent2Signature;
            }
            
            if(String.isBlank(familyRiskReassessmentRec.Id)) {
                familyRiskReassessmentRec.FRRE_Date_Assessment_Initiated__c = System.now();
                Set<String> familyRiskReassDmlFieldSet = familyRiskReassessmentRec.getPopulatedFieldsAsMap().keySet();
                insert familyRiskReassessmentRec;
            } else {
                Set<String> familyRiskReassDmlFieldSet = familyRiskReassessmentRec.getPopulatedFieldsAsMap().keySet();
                update familyRiskReassessmentRec;
            }
            return familyRiskReassessmentRec.Id;
        } else {
            return null;
        }
        
    }
    
    @AuraEnabled
    public static String getFamilyInitialRiskAssessmentStagePicklist(){
        
        GetInitialWrapper initWrap = new GetInitialWrapper();
        initWrap.stages = Utility.getPicklistinfo('Assessment__c','FamilyInitialRiskAssessmentStage__c',false);
        return JSON.serialize(initWrap);
        
    }
    
    @AuraEnabled
    public static String getFamilyInitialRiskAssessmentStageInfo(String recordId){
        
        GetInitialWrapper initWrap = new GetInitialWrapper();
        
        if(String.isNotBlank(recordId)) {

            List<String> assessmentFields = new List<String>{'Id','Name', 'FRRE_Date_Assessment_Initiated__c','FamilyInitialRiskAssessmentStage__c', 'Department_is_unable_to_locate_child__c', 'Actions_Taken__c', 'Approval_Status__c'};
            String assessmentCondition = '(Service_Case__c = \''+ String.escapeSingleQuotes(recordId) +'\' OR Investigation__c = \''+ String.escapeSingleQuotes(recordId) +'\') AND Assessment_Type__c = \'Family Initial Risk Assessment\'';
            List<SObject> assessmentSObjList = DataService.performQueryOperation(assessmentFields, 'Assessment__c', assessmentCondition, Utility.queryLimit);
            initWrap.familyRiskReassessmentRec = (List<Assessment__c>)assessmentSObjList;
        } 
        return JSON.serialize(initWrap);     
    }
    
    @AuraEnabled
    public static String getFamilyAndHouseholdCompositionInfo(String serviceCaseId,String assesmentRecId, String objectApiName){
        
        GetInitialWrapper initWrap = new GetInitialWrapper();

        if(String.isNotBlank(assesmentRecId)) {

            List<String> assessmentFields = new List<String>{'Id','Service_Case__c','Investigation__c', 'FRRE_Date_Assessment_Initiated__c', 'Approval_Status__c'};
            String assessmentCondition = 'Id = \''+ String.escapeSingleQuotes(assesmentRecId) +'\'';
            List<SObject> assessmentSObjList = DataService.performQueryOperation(assessmentFields, 'Assessment__c', assessmentCondition, 1);
            
            if(assessmentSObjList != null && assessmentSObjList.size() > 0) {
                initWrap.assessmentRec = (Assessment__c)assessmentSObjList[0];
            }
        }

        if(String.isNotBlank(serviceCaseId) && String.isNotBlank(objectApiName)) {

            if(objectApiName == 'Service_Case__c') {

                List<String> serviceCaseFields = new List<String>{'Id','Name', 'Head_of_Household__r.Name'};
                String serviceCaseCondition = 'Id = \''+ String.escapeSingleQuotes(serviceCaseId) +'\'';
                List<SObject> serviceCaseSObjList = DataService.performQueryOperation(serviceCaseFields, 'Service_Case__c', serviceCaseCondition, 1);
                
                if(serviceCaseSObjList != null && serviceCaseSObjList.size() > 0) {
                    initWrap.serviceCaseRec = (Service_Case__c)serviceCaseSObjList[0];
                }
            } else if(objectApiName == 'Investigation__c') {

                List<String> investigationFields = new List<String>{'Id', 'Head_of_Household__r.Name', 'Name'};
                String investigationCondition = 'Id = \''+ String.escapeSingleQuotes(serviceCaseId) +'\'';
                List<SObject> investigationSObjList = DataService.performQueryOperation(investigationFields, 'Investigation__c', investigationCondition, 1);
                
                if(investigationSObjList != null && investigationSObjList.size() > 0) {
                    initWrap.investigationRec = (Investigation__c)investigationSObjList[0];
                } 
            }

            //Regarding many to many we have changed and command some logic 22/11/22
            List<String> personJnFields = new List<String>{'Id', 'Person__c'};
            String personJnCondition = 'Service_Case__c = \'' + String.escapeSingleQuotes(serviceCaseId) + '\' OR Investigation__c = \'' + String.escapeSingleQuotes(serviceCaseId) + '\'';
            List<SObject> personJnObjList = DataService.performQueryOperation(personJnFields, 'Person__c', personJnCondition, Utility.queryLimit);
            Set<Id> personIdSet = new Set<Id>();
            for (Person__c personIns : (List<Person__c>)personJnObjList) {
                personIdSet.add(personIns.Person__c);
            }
            List<String> contactFields = new List<String>{'Id', 'Name', 'Age__c', 'Date_of_Birth__c', 'Intake_Person_Role__c'};
            String contactCondition = ' RecordType.DeveloperName = \'Persons_Involved\' AND ';
            if(personIdSet != null && personIdSet.size() > 0) {
                contactCondition += 'Id IN (';           
                for (Id personId : personIdSet) {
                    contactCondition +='\''+String.escapeSingleQuotes(personId)+'\' ,';
                }
                contactCondition = contactCondition.removeEnd(' ,'); 
                contactCondition +=') ';
            } else {
                contactCondition += 'Id IN ('+'\''+'\''+') ';
            }

            List<SObject> contactObjList = DataService.performQueryOperation(contactFields, 'Contact', contactCondition, Utility.queryLimit);
            initWrap.conactList = (List<Contact>)contactObjList;

            /*List<String> contactFields = new List<String>{'Id', 'Name', 'Age__c', 'Date_of_Birth__c', 'Intake_Person_Role__c'};
            String contactCondition = 'Service_Case__c = \''+ String.escapeSingleQuotes(serviceCaseId) +'\' OR Investigation__c = \''+ String.escapeSingleQuotes(serviceCaseId) +'\'';
            List<SObject> contactSObjList = DataService.performQueryOperation(contactFields, 'Contact', contactCondition, Utility.queryLimit);
            initWrap.conactList = (List<Contact>)contactSObjList;*/
        }       
        return JSON.serialize(initWrap);       
    }
    
    @AuraEnabled
    public static string getNeglectedAbuseIndexPicklist(){
        
        GetInitialWrapper initWrap = new GetInitialWrapper();
        initWrap.option1 = Utility.getPicklistinfo('Assessment__c','FIRA_Current_Report_is_for__c',false);
        initWrap.option2 = Utility.getPicklistinfo('Assessment__c','FIRA_Prior_CPS_Response__c',false);
        initWrap.options2a = Utility.getPicklistinfo('Assessment__c','FIRA_Prior_Neglect__c',false);
        initWrap.options2b = Utility.getPicklistinfo('Assessment__c','FIRA_Prior_Abuse__c',false);
        initWrap.options3 = Utility.getPicklistinfo('Assessment__c','FIRA_Household_previously_had_open_IHFS__c',false);
        initWrap.options4 = Utility.getPicklistinfo('Assessment__c','FIRA_Number_of_children_identified__c',false);
        initWrap.options5 = Utility.getPicklistinfo('Assessment__c','FIRA_Prior_non_accidential_injury__c',false);
        initWrap.options6 = Utility.getPicklistinfo('Assessment__c','FIRA_Age_of_youngest_child__c',false);
        initWrap.options7 = Utility.getPicklistinfo('Assessment__c','FIRA_racterisitics_of_children__c',true);
        initWrap.options8 = Utility.getPicklistinfo('Assessment__c','FIRA_Primary_caregiver_assessment__c',true);
        initWrap.options9 = Utility.getPicklistinfo('Assessment__c','FIRA_Primary_caregiver_provides_physical__c',false);
        initWrap.options10 = Utility.getPicklistinfo('Assessment__c','FIRA_Primary_caregiver_characteristics__c',true);
        initWrap.options11 = Utility.getPicklistinfo('Assessment__c','FIRA_Primary_caregiver_has_past_mental__c',false);
        initWrap.options12 = Utility.getPicklistinfo('Assessment__c','FIRA_Primary_caregiver_past_alcohol__c',false);
        initWrap.options13 = Utility.getPicklistinfo('Assessment__c','FIRA_Secondary_Caregiver_has_alcohol__c',false);
        initWrap.options14 = Utility.getPicklistinfo('Assessment__c','FIRA_Primary_caregiver_has_history__c',false);
        initWrap.options15 = Utility.getPicklistinfo('Assessment__c','FIRA_Two_or_more_incidents__c',false);
        initWrap.options16 = Utility.getPicklistinfo('Assessment__c','FIRA_Housing__c',true);
        initWrap.optionsAlcohol = Utility.getPicklistinfo('Assessment__c','FIRA_Alcohol_values__c',false);
        initWrap.optionsDrugs = Utility.getPicklistinfo('Assessment__c','Drugs_value__c',false);
        initWrap.options11y = Utility.getPicklistinfo('Assessment__c','Primary_caregiver_has_past_Yes__c',false);
        return JSON.serialize(initWrap);
    }
    
    @AuraEnabled
    public static string getNeglectedAbuseIndexInfo(String recordId){    
        GetInitialWrapper initWrap = new GetInitialWrapper();
        
        if(String.isNotBlank(recordId)) {

            List<String> assessmentFields = new List<String>{'Id', 'FIRA_Current_Report_is_for__c', 'FIRA_Current_Report_Neglect_Score__c', 'FIRA_Current_Report_Abuse_Score__c', 'FIRA_Prior_CPS_Response__c', 'FIRA_Prior_CPS_Neglect_Score__c', 'FIRA_Prior_CPS_Abuse_Score__c',
                                                             'FIRA_Prior_Neglect__c', 'FIRA_Prior_Neglect_Score__c', 'FIRA_Prior_Abuse__c', 'FIRA_Prior_Abuse_Score__c', 'FIRA_Household_previously_had_open_IHFS__c', 'FIRA_Household_previously_Neglect_Score__c', 'FIRA_Household_previously_Abuse_Score__c','FIRA_Number_of_children_identified__c',
                                                             'FIRA_Number_of_children_neglect_score__c', 'FIRA_Number_of_children_Abuse_Score__c', 'FIRA_Prior_non_accidential_injury__c', 'FIRA_Prior_non_accidential_neglect_score__c', 'FIRA_Prior_non_accidential_Abuse_Score__c', 'FIRA_Age_of_youngest_child__c', 'FIRA_Age_of_youngest_child_neglect_score__c',
                                                             'FIRA_Age_of_youngest_child_Abuse_score__c', 'FIRA_racterisitics_of_children__c', 'FIRA_Characteristic_child_neglect_score__c', 'FIRA_Characteristic_child_Abuse_Score__c', 'FIRA_Primary_caregiver_assessment__c', 'FIRA_Primary_caregiver_neglect_score__c', 'FIRA_Primary_caregiver_abuse_score__c',
                                                             'FIRA_Primary_caregiver_provides_physical__c', 'FIRA_Primary_caregiver_provides_neglect__c', 'FIRA_Primary_caregiver_provides_abuse__c', 'FIRA_Primary_caregiver_characteristics__c', 'FIRA_Primary_caregiver_charac_neglect__c', 'FIRA_Primary_caregiver_charac_Abuse__c', 
                                                             'FIRA_Primary_caregiver_has_past_mental__c', 'FIRA_Primary_caregive_has_mental_neglect__c', 'FIRA_Primary_caregive_has_mental_abuse__c', 'FIRA_Primary_caregiver_past_alcohol__c', 'FIRA_Primary_caregiver_alcohol_neglect__c', 'FIRA_Primary_caregiver_alcohol_abuse__c', 'FIRA_Secondary_Caregiver_has_alcohol__c',
                                                             'FIRA_Secondary_care_has_alcohol_neglect__c', 'FIRA_Secondary_care_has_alcohol_abuse__c', 'FIRA_Primary_caregiver_has_history_abuse__c', 'FIRA_Primary_caregiv_has_history_neglect__c', 'FIRA_Primary_caregiver_has_history__c', 'FIRA_Two_or_more_incidents__c', 'FIRA_Two_or_more_incidents_neglect__c', 'FIRA_Two_or_more_incidents_Abuse__c',
                                                             'FIRA_Housing__c','Primary_caregiver_has_past_Yes__c', 'FIRA_Housing_Neglect_Score__c', 'Housing_Abuse_Score__c', 'Total_Neglect_Score__c', 'Total_Abuse_Score__c', 'FIRA_Alcohol_Select_one__c', 'FIRA_Alcohol_values__c', 'FIRA_Drugs_Select_One__c', 'Drugs_value__c', 'Alcohol_Select_one__c', 'FIRA_Secondary_Alcohol_values__c', 'FIRA_Secondary_Drugs_Select_One__c', 'FIRA_Secondary_Drugs_value__c', 'Approval_Status__c'};
            String assessmentCondition = 'Id = \''+ String.escapeSingleQuotes(recordId) +'\'';
            List<SObject> sObjList = DataService.performQueryOperation(assessmentFields, 'Assessment__c', assessmentCondition, 1);
            if(sObjList != null && sObjList.size() > 0) {
                initWrap.assessmentRec = (Assessment__c)sObjList[0];
            }  
        }
        return JSON.serialize(initWrap);
    }
    
    @AuraEnabled
    public static string getScoringOverridesPicklist(){
        
        GetInitialWrapper initWrap = new GetInitialWrapper();
        initwrap.x1options =  Utility.getPicklistinfo('Assessment__c','X1_Sexual_abuse_case_and_the_alleged__c',false);
        initwrap.x2options =  Utility.getPicklistinfo('Assessment__c','X2_Non_accidental_injury_to_a_child__c',false);
        initwrap.x3options =  Utility.getPicklistinfo('Assessment__c','X3_Severe_non_accidental_injury__c',false);
        initwrap.x4options =  Utility.getPicklistinfo('Assessment__c','X4_Caregiver_action_or_inaction_resulted__c',false);
        initwrap.x5options =  Utility.getPicklistinfo('Assessment__c','X5_If_yes_override_risk_level__c',false);
        initwrap.finalriskleveloptions =  Utility.getPicklistinfo('Assessment__c','FINAL_RISK_LEVEL__c',false);
        return JSON.serialize(initWrap);
    }
    
    @AuraEnabled
    public static String getScoringOverridesInfo(String recordId){
        
        GetInitialWrapper initWrap = new GetInitialWrapper();
 
        if(String.isNotBlank(recordId)) {
        
            List<String> assessmentFields = new List<String>{'Id', 'X1_Sexual_abuse_case_and_the_alleged__c', 'X2_Non_accidental_injury_to_a_child__c', 'X3_Severe_non_accidental_injury__c', 'X4_Caregiver_action_or_inaction_resulted__c', 'X5_If_yes_override_risk_level__c', 'FINAL_RISK_LEVEL__c', 'FIRA_Discretionary_override_reason__c', 'Approval_Status__c'};
            String assessmentCondition = 'Id = \''+ String.escapeSingleQuotes(recordId) +'\'';
            List<SObject> sObjList = DataService.performQueryOperation(assessmentFields, 'Assessment__c', assessmentCondition, 1);
            
            if(sObjList != null && sObjList.size() > 0) {
                initWrap.assessmentRec = (Assessment__c)sObjList[0];
            }  
        }
        
        return JSON.serialize(initWrap);
        
    }
    
    @AuraEnabled
    public static string getSupplementalQuestionPicklist(){
        
        GetInitialWrapper initWrap = new GetInitialWrapper();
        initwrap.optionS1 =  Utility.getPicklistinfo('Assessment__c','FIRA_Does_either_caregiver_have_history__c',false);
        initwrap.primaryOptions =  Utility.getPicklistinfo('Assessment__c','FIRA_Primary__c',true);
        initwrap.secondaryOptions =  Utility.getPicklistinfo('Assessment__c','FIRA_Secondary__c',true);
        return JSON.serialize(initWrap);
    }
    
    @AuraEnabled
    public static String getSupplementalQuestionInfo(String recordId){
        
        GetInitialWrapper initWrap = new GetInitialWrapper();
        if(String.isNotBlank(recordId)) {
            
            List<String> assessmentFields = new List<String>{'Id', 'FIRA_Does_either_caregiver_have_history__c', 'FIRA_Primary__c', 'FIRA_Secondary__c','Approval_Status__c'};
            String assessmentCondition = 'Id = \''+ String.escapeSingleQuotes(recordId) +'\'';
            List<SObject> sObjList = DataService.performQueryOperation(assessmentFields, 'Assessment__c', assessmentCondition, 1);
            if(sObjList != null && sObjList.size() > 0) {
                initWrap.assessmentRec = (Assessment__c)sObjList[0];
            }  
        }
        return JSON.serialize(initWrap);
        
    }
    
    @AuraEnabled
    public static string getFIRAApprovalPicklist(){
        
        GetInitialWrapper initWrap = new GetInitialWrapper();
        initwrap.rerouteSupervisorOptions =  Utility.getPicklistinfo('Assessment__c','Route_to_Supervisor__c',false);
        return JSON.serialize(initWrap);
    }
    
    @AuraEnabled
    public static String getFIRAApprovalInfo(String recordId){
        
        GetInitialWrapper initWrap = new GetInitialWrapper();
        
        if(String.isNotBlank(recordId)) {
            
            List<String> assessmentFields = new List<String>{'Id', 'Supervisor_Name__c', 'Route_to_Supervisor__c', 'Supervisor_Comments__c', 'FIRA_Supervisor_Reviewed_Date__c', 'Case_Worker_Name__c','Caseworker_comments__c','Approval_Status__c','FIRA_Case_worker_Signature__c','Supervisor_Signature__c'};
            String assessmentCondition = 'Id = \''+ String.escapeSingleQuotes(recordId) +'\'';
            List<SObject> sObjList = DataService.performQueryOperation(assessmentFields, 'Assessment__c', assessmentCondition, 1);
            
            if(sObjList != null && sObjList.size() > 0) {
                initWrap.assessmentRec = (Assessment__c)sObjList[0];
            }  
        }
        
        return JSON.serialize(initWrap);
        
    }
    
    @AuraEnabled
    public static String getActionInfo(String recordId){
        
        GetInitialWrapper initWrap = new GetInitialWrapper();
   
        if(String.isNotBlank(recordId)) {
            
            List<String> assessmentFields = new List<String>{'Id', 'Actions_Taken__c', 'Department_is_unable_to_locate_child__c', 'Approval_Status__c'};
            String assessmentCondition = 'Id = \''+ String.escapeSingleQuotes(recordId) +'\'';
            List<SObject> sObjList = DataService.performQueryOperation(assessmentFields, 'Assessment__c', assessmentCondition, 1);
            
            if(sObjList != null && sObjList.size() > 0) {
                initWrap.assessmentRec = (Assessment__c)sObjList[0];
            }  
            
        }
        return JSON.serialize(initWrap);
    }
    
    @AuraEnabled
    public static String deleteAssessment(String recordId){
        
        if(String.isNotBlank(recordId)) {
            Assessment__c assesmentRec = new Assessment__c();
            assesmentRec.Id = recordId;
            FieldLevelSecurity.checkObjectAccessByDelete('Assessment__c');
            delete assesmentRec;
            return 'Success';
        } else {
            return null;
        }
    }
    
    public Assessment__c assessmentRecord { get; set; }
    public List<Assessment_Safety_Plan__c> safetyListRecords { get; set; }
    public List<Person__c> contactRecords{ get; set; } // Changed Contact to Person jn obj regarding many to many 22/11/22
    public String currentRecordId {get; set;}
    public String safetyListComments {get; set;}
    public String comment1{get; set;}
    public String comment2{get; set;}
    public String comment3{get; set;}
    public String comment4{get; set;}
    public String comment5{get; set;}
    public String comment6{get; set;}
    public String comment7{get; set;}
    public String comment8{get; set;}
    public String comment9{get; set;}
    public String comment10{get; set;}
    public String comment11{get; set;}
    public String comment12{get; set;}
    public String comment13{get; set;}
    public String comment14{get; set;}
    public String comment15{get; set;}
    public String comment16{get; set;}
    public String comment17{get; set;}
    public String comment18{get; set;}
    
    public AssessmentController() {

        currentRecordId  = ApexPages.CurrentPage().getparameters().get('id');
        AssessmentController.GetInitialWrapper result = (AssessmentController.GetInitialWrapper)JSON.deserialize(getAssessment(currentRecordId),AssessmentController.GetInitialWrapper.class);
        assessmentRecord = result.assessmentRec;
        safetyListRecords = result.assessmentSafetyPlanList;
        AssessmentController.GetInitialWrapper contactResult = (AssessmentController.GetInitialWrapper)JSON.deserialize(getSAFECInitialInformation(result.assessmentRec.Service_Case__c),AssessmentController.GetInitialWrapper.class);
        contactRecords = contactResult.childList;
        safetyListComments = safetyListRecords.size() > 0 ? ' ' : 'No existing records found';
        comment1 = result.assessmentRec.SAFEC_Caregiver_fails_to_protect__c =='yes'? 'Comments : '+result.assessmentRec.SAFEC_Caregiver_fails_Comments__c : '' ;
        comment2 = result.assessmentRec.SAFEC_Caregiver_made_a_plausible_threat__c =='yes'? 'Comments : '+ result.assessmentRec.SAFEC_Caregiver_made_a_Comments__c : '' ;
        comment3 = result.assessmentRec.SAFEC_There_has_been_current_act__c =='yes'? 'Comments : '+result.assessmentRec.SAFEC_There_has_been_current_actComments__c : '' ;
        comment4 = result.assessmentRec.SAFEC_Child_sexual_abuse_is_suspected__c =='yes'? 'Comments : '+result.assessmentRec.SAFEC_Child_sexual_abuse_Comments__c : '' ;
        comment5 = result.assessmentRec.SAFEC_Caregiver_describes_the_child__c =='yes'? 'Comments : '+result.assessmentRec.SAFEC_Caregiver_describes_Comments__c : '' ;
        comment6 = result.assessmentRec.SAFEC_Cargiver_s_suspected_or_observed__c =='yes'? 'Comments : '+result.assessmentRec.SAFEC_Cargiver_s_suspected_Comments__c : '' ;
        comment7 = result.assessmentRec.SAFEC_Caregiver_s_emotional_instability__c =='yes'? 'Comments : '+result.assessmentRec.SAFEC_Caregiver_s_emotional_Comments__c : '' ;
        comment8 = result.assessmentRec.SAFEC_Caregiver_s_explanation__c =='yes'? 'Comments : '+result.assessmentRec.SAFEC_Caregiver_s_explanation_Comments__c : '' ;
        comment10 = result.assessmentRec.SAFEC_Caregiver_does_not_or_refuse__c =='yes'? 'Comments : '+result.assessmentRec.SAFEC_Caregiver_does_not_Comments__c : '' ;
        comment9 =  result.assessmentRec.SAFEC_Caregivers_justification_or_denial__c =='yes'?'Comments : '+result.assessmentRec.SAFEC_Caregivers_justification_Comments__c : '';
        comment11 = result.assessmentRec.SAFEC_Domestic_violence_exists__c =='yes'? 'Comments : '+result.assessmentRec.SAFEC_Domestic_violence_Comments__c : '' ;
        comment12 = result.assessmentRec.SAFEC_Caregiver_does_not_meet_the_childs__c =='yes'? 'Comments : '+result.assessmentRec.SAFEC_Caregiver_does_not_meet_Comments__c : '' ;
        comment13 = result.assessmentRec.SAFEC_The_childs_whereabouts_are_unknown__c =='yes'?'Comments : '+ result.assessmentRec.SAFEC_The_childs_whereabouts_Comments__c : '' ;
        comment14 = result.assessmentRec.SAFEC_The_child_has_special_needs__c =='yes'? 'Comments : '+result.assessmentRec.SAFEC_The_child_has_special_Comments__c : '' ;
        comment15 = result.assessmentRec.SAFEC_The_child_is_extremely_anxious__c =='yes'? 'Comments : '+result.assessmentRec.SAFEC_The_child_is_extremely_Comments__c : '' ;
        comment16 = result.assessmentRec.SAFEC_The_child_is_unable_to_protect__c =='yes'? 'Comments : '+result.assessmentRec.SAFEC_The_child_is_unable_Comments__c : '' ;
        comment17 = result.assessmentRec.SAFEC_Previous_services_to_the_caregiver__c =='yes'?'Comments : '+ result.assessmentRec.SAFEC_Previous_services_Comments__c : '' ;
        comment18 = result.assessmentRec.SAFEC_There_have_been_multiple_reports__c =='yes'?'Comments : '+ result.assessmentRec.SAFEC_There_have_been_multiple_Comments__c : '' ;        
    }
    
    
    public class GetInitialWrapper {
        
        @AuraEnabled
        public List<Utility.pickListWrap> thechildsImmediatehealthneedsPicklist;
        @AuraEnabled
        public List<Contact> conactList;
        @AuraEnabled
        public List<Person__c> caregiverList;
        @AuraEnabled
        public List<Utility.pickListWrap> cotactsNames;
        @AuraEnabled
        public List<Utility.pickListWrap> caregiverNames;
        @AuraEnabled
        public List<Utility.pickListWrap> caregiverDescribesTheChildPicklist;
        @AuraEnabled
        public List<Person__c> childList; // Changed Contact to Person jn obj regarding many to many 22/11/22
        @AuraEnabled
        public List<contact> headOfHouseHoldList;
        @AuraEnabled
        public List<ChildInputWarp> childInputWarpList;
        @AuraEnabled
        public List<Utility.pickListWrap> submitforApprovalPickList;
        @AuraEnabled
        public List<safecWarp> assessmentList;
        @AuraEnabled
        public List<Assessment__c> assessmentOHPList;
        @AuraEnabled
        public List<Assessment_Safety_Plan__c> assessmentSafetyPlanList;
        @AuraEnabled
        public Assessment__c assessmentRec; 
        @AuraEnabled
        public String cpsCaseName;
        @AuraEnabled
        public String headofHouseholdName;
        @AuraEnabled
        public Assessment__c assessmentOHPRec;
        @AuraEnabled
        public Service_Case__c statusService;
        @AuraEnabled
        public List<Utility.pickListWrap> RR1options;
        @AuraEnabled
        public List<Utility.pickListWrap> RR2options;
        @AuraEnabled
        public List<Utility.pickListWrap> RR3options;
        @AuraEnabled
        public List<Utility.pickListWrap> RR4options;
        @AuraEnabled
        public List<Utility.pickListWrap> RR5options;
        @AuraEnabled
        public List<Utility.pickListWrap> RR6options;
        @AuraEnabled
        public List<Utility.pickListWrap> RR7options;
        @AuraEnabled
        public List<Utility.pickListWrap> RR7Yesoptions;
        @AuraEnabled
        public List<Utility.pickListWrap> RR8options;
        @AuraEnabled
        public List<Utility.pickListWrap> RR9options;
        @AuraEnabled
        public List<Utility.pickListWrap> riskLevelOptions;
        @AuraEnabled
        public List<Utility.pickListWrap> x1options;
        @AuraEnabled
        public List<Utility.pickListWrap> x2options;
        @AuraEnabled
        public List<Utility.pickListWrap> x3options;
        @AuraEnabled
        public List<Utility.pickListWrap> x4options;
        @AuraEnabled
        public List<Utility.pickListWrap> x5options;
        @AuraEnabled
        public List<Utility.pickListWrap> finalriskleveloptions;
        @AuraEnabled
        public List<Utility.pickListWrap> plannedActionOptions;
        @AuraEnabled
        public List<Utility.pickListWrap> approvalOptions;
        @AuraEnabled
        public List<Utility.pickListWrap> routeToSupervisorOptions;
        @AuraEnabled
        public Service_Case__c serviceCaseRec;
        @AuraEnabled
        public Investigation__c investigationRec;
        @AuraEnabled
        public List<Assessment__c> familyRiskReassessmentRec;
        @AuraEnabled
        public List<Utility.pickListWrap> stages;
        @AuraEnabled
        public List<Utility.pickListWrap> option1;
        @AuraEnabled
        public List<Utility.pickListWrap> option2;
        @AuraEnabled
        public List<Utility.pickListWrap> options2a;
        @AuraEnabled
        public List<Utility.pickListWrap> options2b;
        @AuraEnabled
        public List<Utility.pickListWrap> options3;
        @AuraEnabled
        public List<Utility.pickListWrap> options4;
        @AuraEnabled
        public List<Utility.pickListWrap> options5;
        @AuraEnabled
        public List<Utility.pickListWrap> options6;
        @AuraEnabled
        public List<Utility.pickListWrap> options7;
        @AuraEnabled
        public List<Utility.pickListWrap> options8;
        @AuraEnabled
        public List<Utility.pickListWrap> options9;
        @AuraEnabled
        public List<Utility.pickListWrap> options10;
        @AuraEnabled
        public List<Utility.pickListWrap> options11;
        @AuraEnabled
        public List<Utility.pickListWrap> options12;
        @AuraEnabled
        public List<Utility.pickListWrap> options13;
        @AuraEnabled
        public List<Utility.pickListWrap> options14;
        @AuraEnabled
        public List<Utility.pickListWrap> options15;
        @AuraEnabled
        public List<Utility.pickListWrap> options16;
        @AuraEnabled
        public List<Utility.pickListWrap> optionS1;
        @AuraEnabled
        public List<Utility.pickListWrap> primaryOptions;
        @AuraEnabled
        public List<Utility.pickListWrap> secondaryOptions;
        @AuraEnabled
        public List<Utility.pickListWrap> rerouteSupervisorOptions;
        @AuraEnabled
        public List<Utility.pickListWrap> optionsAlcohol;
        @AuraEnabled
        public List<Utility.pickListWrap> optionsDrugs;
        @AuraEnabled
        public List<Utility.pickListWrap> options11y;
        
        public GetInitialWrapper() {
            
            thechildsImmediatehealthneedsPicklist = new List<Utility.pickListWrap>();
            cotactsNames = new List<Utility.pickListWrap>();
            caregiverNames = new List<Utility.pickListWrap>();
            caregiverDescribesTheChildPicklist = new List<Utility.pickListWrap>();
            submitforApprovalPickList = new List<Utility.pickListWrap>();    
        }
    }
    public class ChildInputWarp {
        
        @AuraEnabled
        public String chidName;
        @AuraEnabled
        public Decimal age;
        @AuraEnabled
        public String childId;
        @AuraEnabled
        public String clientId;
    }
    
    public class safecWarp {
        
        @AuraEnabled
        public String id;
        @AuraEnabled
        public String name;
        @AuraEnabled
        public String completionDate;
        @AuraEnabled
        public String approvalStatus;
    }
}