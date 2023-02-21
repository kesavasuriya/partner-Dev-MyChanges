@RestResource(urlMapping='/GetMobileAppInitDetails/*')
global class CasevaultMobileAppInitRestResource {

    @HttpGet
    global static String getMobileAppInitDetails() {
        
        MobileInitWrapper mobileWrapIns = new MobileInitWrapper();
        
        ObjectDescribeWrapper scDescribeIns = new ObjectDescribeWrapper();
        scDescribeIns.objectName = 'Service_Case__c';
        scDescribeIns.valueDetail = Service_Case__c.sObjectType.getDescribe();
        mobileWrapIns.serviceCaseDescribe.add(scDescribeIns);
        
       /* ObjectDescribeWrapper contactDescribeIns = new ObjectDescribeWrapper();
        contactDescribeIns.objectName = 'Contact';
        contactDescribeIns.valueDetail = Contact.sObjectType.getDescribe();
        mobileWrapIns.personDescribe.add(contactDescribeIns);*/
        
        ObjectDescribeWrapper assDescribeIns = new ObjectDescribeWrapper();
        assDescribeIns.objectName = 'Assessment__c';
        assDescribeIns.valueDetail = Assessment__c.sObjectType.getDescribe();
        mobileWrapIns.assessmentDescribe.add(assDescribeIns);
            
        Map<Id, Service_Case__c> serviceCaseMap = new Map<Id, Service_Case__c>([SELECT Id, Name, Number_of_days__c ,Head_of_Household__r.Name, Intake__r.Casenumber, Status__c FROM Service_Case__c ORDER BY CreatedDate DESC LIMIT 10]);
        mobileWrapIns.serviceCaseList = serviceCaseMap.values();
        
        Map<Id, List<Person__c>> personSCMap = new Map<Id, List<Person__c>>();
        List<Person__c> jnPerson;
        for(Person__c personJnIns : [SELECT Person__c,Person_Role__c, Service_Case__c FROM Person__c WHERE Service_Case__c IN :serviceCaseMap.keySet()]) { 
            
            if(personSCMap.keySet().size() > 0 && personSCMap.keySet().contains(personJnIns.Person__c) && personSCMap.get(personJnIns.Person__c).size() > 0) {
                
                jnPerson = personSCMap.get(personJnIns.Person__c);
                jnPerson.add(personJnIns);
                personSCMap.put(personJnIns.Person__c, jnPerson);
                
            } else {
                
                jnPerson = new List<Person__c>();
                jnPerson.add(personJnIns);
                personSCMap.put(personJnIns.Person__c, jnPerson);
            }
              
        }
        Map<Id, List<Contact>> scPersonMap = new Map<Id, List<Contact>>();
        List<Contact> contacts;
        for(Contact contactIns : [SELECT Id, FirstName, LastName, Intake_Suffix__c, Primary_Language__c, Approximate_Date__c, Secondary_Language__c, Date_of_Death__c, Name, 
                                  Date_of_Birth__c,Intake_Person_Role__c, Head_of_House__c,
                                  Physical_Marks__c,Is_a_US_citizen__c,Gender__c,Primary_Citizenship_of__c,Has_Child_Ever_Been_Adopted__c,Secondary__c,
                                  Living_Situation__c,Nationality_del_del__c,Living_Situation_Description__c,Alien_Status__c,SSN__c,State_Id_Drivers_License__c,Allien_Registartion_Number__c,
                                  Height_in_Feet__c,SSN_Verified__c,Height_in_Inches__c,Race__c,Weight_in_Pounds__c,Intake_Ethnicity__c,Weight_in_Ounces__c,Occupation__c, Tattoo1__c,
                                  Tribal_Association__c,Glasses__c,Religion__c,Hair_Color__c,Also_known_As_AKA__c,Hair_Texture__c,Known_danger_at_address__c,Sex_Offender_resigtery_checked__c,
                                  Judiciary_case_search__c,Substance_exposed_new_born__c,Safe_haven_baby__c,Martial_Status__c,Danger_to_self__c,Danger_Reason__c,Appearance_of_mentally_impaired__c,
                                  Appearance_Reason__c,Danger_to_worker__c,Worker_Reason__c,Signs_of_mental_illness__c,Sign_Reason__c,Active_Program_Area__c FROM Contact WHERE Id IN :personSCMap.keySet()]) {
                                      for(Person__c personJnIns : personSCMap.get(contactIns.Id)) {

                                            contactIns.Intake_Person_Role__c = personJnIns.Person_Role__c;
                                          if(scPersonMap.keySet().size() > 0 && scPersonMap.keySet().contains(personJnIns.Service_Case__c) && scPersonMap.get(personJnIns.Service_Case__c).size() > 0) {
                
                                                contacts = scPersonMap.get(personJnIns.Service_Case__c);
                                                contacts.add(contactIns);
                                                scPersonMap.put(personJnIns.Service_Case__c, contacts);
                                                
                                            } else {
                                                
                                                contacts = new List<Contact>();
                                                contacts.add(contactIns);
                                                scPersonMap.put(personJnIns.Service_Case__c, contacts);
                                            }
                                      }
            
        }
        
        
        Map<Id, List<Assessment__c>> scAssMap = new Map<Id, List<Assessment__c>>();
        List<Assessment__c> assessments;
        for(Assessment__c assessmentIns : [SELECT Id,Name, Safety_Assessment_Completion_Date_Time__c,Approval_Status__c,Assessment_Type__c,SAFEC_Date_Time_Assessment_Initiated__c, SAFEC_Case_Worker_Comments__c, SAFEC_Date_Time_of_Last_Safety_Plan__c, SAFEC_Legal_Guardian_Name__c, 
                                            SAFEC_CPS_Case_ID__c, SAFEC_Head_of_Household__c, SAFEC_Relationship__c, SAFEC_CIS_ID__c,
                                            SAFEC_Caregiver__c, SAFEC_At_the_Initial_face_to_facecontact__c, SAFEC_At_the_completion_closure__c,
                                            SAFEC_When_The_case_Assessor_discovers__c, SAFEC_When_circumstances_suggest__c, SAFEC_Within_7_Working_days_of_case__c,
                                            SAFEC_Before_Completing_a_case__c, SAFEC_At_time_of_trial_home_visit__c, SAFEC_Within_ten_10_working_days__c,
                                            SAFEC_Out_HOME_Before_completing_a_case__c, SAFEC_within_7_working_days_prior__c, SAFEC_Within_7_working_days_prior_to__c, 
                                            SAFEC_OUT_HOME_When_the_case_assessor__c, SAFEC_When_circumstances_suggest_that__c, SAFEC_Age_0_5_Years_old__c,
                                            SAFEC_Diminished_Physical_capacity__c, SAFEC_Diminished_mental_capacity__c, SAFEC_School_age_but_not_attending__c,
                                            SAFEC_Significant_diagnosed_medical_or__c, SAFEC_Child_s_extreme_anxiety_or_fear__c,
                                            SAFEC_Caregiver_fails_to_protect__c, SAFEC_Caregiver_fails_Comments__c, SAFEC_Caregiver_made_a_plausible_threat__c, SAFEC_Caregiver_made_a_Comments__c,
                                            SAFEC_There_has_been_current_act__c, SAFEC_There_has_been_current_actComments__c, SAFEC_Child_sexual_abuse_is_suspected__c,
                                            SAFEC_Child_sexual_abuse_Comments__c, SAFEC_Caregiver_describes_the_child__c, SAFEC_Caregiver_describes_Comments__c,
                                            SAFEC_Cargiver_s_suspected_or_observed__c, SAFEC_Cargiver_s_suspected_Comments__c, SAFEC_Caregiver_s_emotional_instability__c,
                                            SAFEC_Caregiver_s_emotional_Comments__c, SAFEC_Caregiver_s_explanation__c, SAFEC_Caregiver_s_explanation_Comments__c, SAFEC_Caregivers_justification_or_denial__c,
                                            SAFEC_Caregivers_justification_Comments__c, SAFEC_Caregiver_does_not_or_refuse__c, SAFEC_Caregiver_does_not_Comments__c,
                                            SAFEC_Domestic_violence_exists__c, SAFEC_Domestic_violence_Comments__c, SAFEC_Caregiver_does_not_meet_the_childs__c,
                                            SAFEC_Caregiver_does_not_meet_Comments__c, SAFEC_The_childs_whereabouts_are_unknown__c, SAFEC_The_childs_whereabouts_Comments__c,
                                            SAFEC_The_child_has_special_needs__c, SAFEC_The_child_has_special_Comments__c, SAFEC_The_child_is_extremely_anxious__c,
                                            SAFEC_The_child_is_extremely_Comments__c, SAFEC_The_child_is_unable_to_protect__c, SAFEC_The_child_is_unable_Comments__c,
                                            SAFEC_Previous_services_to_the_caregiver__c, SAFEC_Previous_services_Comments__c, SAFEC_There_have_been_multiple_reports__c,
                                            SAFEC_There_have_been_multiple_Comments__c, SAFEC_Child__c, SAFEC_Caregiver_is_able__c, SAFEC_Caregiver_is_able_and_willing__c,
                                            SAFEC_Caregiver_has_supportive__c, SAFEC_Caregiver_exhibits_self_control__c, SAFEC_There_is_evidence_of_a_healthy__c,
                                            SAFEC_Caregiver_demonstrated_effective__c, SAFEC_Relevant_community_services__c,
                                            SAFEC_Any_Influences_1_18_was_checked__c, SAFEC_Caregiver_did_not_agree_to_safety__c,
                                            SAFEC_Danger_cannot_be_addressed_via__c, SAFEC_LDSS__c, Workers_Name__c, Supervisor_Name__c, Submit_for_Approval__c,
                                            When_Circumstances_Suggest_That_the_Chil__c, Safety_Assessment_Approval_Date_Time__c,
                                            SAFEC_Child_is_Conditionally_Safe_17_16__c, SAFEC_Child_is_Safe_Influences_1_18__c,Current_Placement__c,Potential_Resource__c,
                                            Name_of_Placement_Resource__c,OHP_Address_Line_1__c,Address_Line_2__c,OHP_Zipcode__c,OHP_Work__c,OHP_Ext__c,OHP_Fax__c,Staff_Member_Interviewed_Comments__c,
                                            Initial_Replacement_Placements__c,The_child_s_Immediate_health_needs__c,If_the_child_was_on_medication__c,If_the_child_had_a_history_of_suicidal__c,If_the_child_had_a_history_of_aggressive__c,
                                            If_the_child_had_a_history_of_sexual__c,If_the_child_had_a_history_of_drug__c,This_child_s_sleeping_arrangements__c,This_child_s_is_or_will_be_protected__c,This_child_does_not_express_specific__c,
                                            Provider_appears_competent_coherent__c,Any_injuries_to_the_child__c,This_child_s_whereabouts_are_known__c,OHP_Unsafe_Influences__c,OHP_Safety_Decision__c,OHP_Child_is_Safe_Influences_1_12_Marked__c,
                                            OHP_Child_is_Unsafe_Any_Influence_1_12__c,OHP_Whereabouts_of_Child_Youth__c,OHP_If_Placed_with_Potential_Resource__c,OHP_if_they_remain_with_the_current__c,OHP_Comments__c,
                                            OHP_Signature_Obtained__c,OHP_Signature_Obtained_Date__c,OHP_Representative_Title__c,OHP_Local_Department__c,Service_Case__r.Name,
                                           SAFEC_Child_is_conditionally_Safe__c, SAFEC_Child_is_UnSafe__c,Service_Case__c,createddate FROM Assessment__c WHERE Service_Case__c IN :serviceCaseMap.keySet() AND (Assessment_Type__c='SAFE-C-OHP' OR Assessment_Type__c='SAFE-C')]) {
                                               
                                               if(scAssMap.keySet().size() > 0 && scAssMap.keySet().contains(assessmentIns.Service_Case__c) && scAssMap.get(assessmentIns.Service_Case__c).size() > 0) {
                
                                                assessments = scAssMap.get(assessmentIns.Service_Case__c);
                                                assessments.add(assessmentIns);
                                                scAssMap.put(assessmentIns.Service_Case__c, assessments);
                                                
                                                } else {
                                                    
                                                    assessments = new List<Assessment__c>();
                                                    assessments.add(assessmentIns);
                                                    scAssMap.put(assessmentIns.Service_Case__c, assessments);
                                                }
                                               
         }
        
        Map<Id, List<Assessment_Safety_Plan__c>> scAssSPMap = new Map<Id, List<Assessment_Safety_Plan__c>>();
        List<Assessment_Safety_Plan__c> assessmentSafetyPlan;
        for(Assessment_Safety_Plan__c assSafetyPlanIns : [SELECT Id,Question_Name__c,Specific_Danger_Influence__c,Action_Required__c,Date_to_be_Completed__c,Responsible_Parties__c,Re_evaluation_Date__c,Assessment__c,
                                                          Assessment__r.Service_Case__c FROM Assessment_Safety_Plan__c WHERE Assessment__r.Service_Case__c IN :serviceCaseMap.keySet()]) {
                                                              
                                                              if(scAssSPMap.keySet().size() > 0 && scAssSPMap.keySet().contains(assSafetyPlanIns.Assessment__r.Service_Case__c) && scAssSPMap.get(assSafetyPlanIns.Assessment__r.Service_Case__c).size() > 0) {
                
                                                                assessmentSafetyPlan = scAssSPMap.get(assSafetyPlanIns.Assessment__r.Service_Case__c);
                                                                assessmentSafetyPlan.add(assSafetyPlanIns);
                                                                scAssSPMap.put(assSafetyPlanIns.Assessment__r.Service_Case__c, assessmentSafetyPlan);
                                                                
                                                                } else {
                                                                    
                                                                    assessmentSafetyPlan = new List<Assessment_Safety_Plan__c>();
                                                                    assessmentSafetyPlan.add(assSafetyPlanIns);
                                                                    scAssSPMap.put(assSafetyPlanIns.Assessment__r.Service_Case__c, assessmentSafetyPlan);
                                                               }
                                                              
        }
        
        for(Id scId : serviceCaseMap.keySet()) {
            
            if(scPersonMap.keySet().size() > 0 && scPersonMap.keySet().contains(scId) && scPersonMap.get(scId).size() > 0) {
                
                PersonWrapper personWrapperIns = new PersonWrapper();
                personWrapperIns.ServiceId = scId;
                personWrapperIns.valueDetail = scPersonMap.get(scId);
                System.debug('personWrapperIns===='+scId+'===='+personWrapperIns.valueDetail.size()); 
                mobileWrapIns.personList.add(personWrapperIns);
            } else {
                
                PersonWrapper personWrapperIns = new PersonWrapper();
                personWrapperIns.ServiceId = scId;
                personWrapperIns.valueDetail = new List<Contact>();
                mobileWrapIns.personList.add(personWrapperIns);
            }
            
            if(scAssMap.keySet().size() > 0 && scAssMap.keySet().contains(scId) && scAssMap.get(scId).size() > 0) {
                
                AssessmentWrapper assessmentWrapperIns = new AssessmentWrapper();
                assessmentWrapperIns.ServiceId = scId;
                assessmentWrapperIns.valueDetail = scAssMap.get(scId);
                mobileWrapIns.assessmentList.add(assessmentWrapperIns);
            } else {
                AssessmentWrapper assessmentWrapperIns = new AssessmentWrapper();
                assessmentWrapperIns.ServiceId = scId;
                assessmentWrapperIns.valueDetail = new List<Assessment__c>();
                mobileWrapIns.assessmentList.add(assessmentWrapperIns);
            }
            
            if(scAssSPMap.keySet().size() > 0 && scAssSPMap.keySet().contains(scId) && scAssSPMap.get(scId).size() > 0) {
                
                AssessmentSafetyListWrapper assSafteyPlanWrapperIns = new AssessmentSafetyListWrapper();
                assSafteyPlanWrapperIns.ServiceId = scId;
                assSafteyPlanWrapperIns.valueDetail = scAssSPMap.get(scId);
                mobileWrapIns.assessmentSafetyList.add(assSafteyPlanWrapperIns);
            } else {
                AssessmentSafetyListWrapper assSafteyPlanWrapperIns = new AssessmentSafetyListWrapper();
                assSafteyPlanWrapperIns.ServiceId = scId;
                assSafteyPlanWrapperIns.valueDetail = new List<Assessment_Safety_Plan__c>();
                mobileWrapIns.assessmentSafetyList.add(assSafteyPlanWrapperIns);
            }
                            
        }
        mobileWrapIns.approverList = [SELECT Id, Name FROM User WHERE Profile.Name = 'Casevault Supervisor'];
        System.debug('serviceCaseDescribe==='+mobileWrapIns.serviceCaseDescribe);
        //System.debug('personDescribe==='+JSON.serialize(mobileWrapIns.personDescribe[0].valueDetail.fields));
        System.debug('assessmentDescribe==='+mobileWrapIns.assessmentDescribe);
        System.debug('serviceCaseList==='+mobileWrapIns.serviceCaseList);
        System.debug('personList==='+mobileWrapIns.personList.size());
        System.debug('assessmentList==='+mobileWrapIns.assessmentList.size());
        System.debug('assessmentSafetyList==='+mobileWrapIns.assessmentSafetyList);
        System.debug('approverList==='+mobileWrapIns.approverList);
        //return mobileWrapIns;
        return JSON.serialize(mobileWrapIns);
    }
    
    global class MobileInitWrapper {
        
         global List<ObjectDescribeWrapper> serviceCaseDescribe;
         global List<ObjectDescribeWrapper> personDescribe;
         global List<ObjectDescribeWrapper> assessmentDescribe;
         global List<Service_Case__c> serviceCaseList;
         global List<PersonWrapper> personList;
         global List<AssessmentWrapper> assessmentList;
         global List<AssessmentSafetyListWrapper> assessmentSafetyList;
         global List<User> approverList;
        
        global MobileInitWrapper() {
            
            serviceCaseDescribe = new List<ObjectDescribeWrapper>();
            personDescribe = new List<ObjectDescribeWrapper>();
            assessmentDescribe = new List<ObjectDescribeWrapper>();
            serviceCaseList = new List<Service_Case__c>();
            personList = new List<PersonWrapper>();
            assessmentList = new List<AssessmentWrapper>();
            assessmentSafetyList = new List<AssessmentSafetyListWrapper>();
            approverList = new List<User>();
            
        }

    }
    
    global class ObjectDescribeWrapper {
        
        global String objectName;
        global Schema.DescribeSObjectResult valueDetail;
    }
    
    global class PersonWrapper {
        
         global String ServiceId;
         global List<Contact> valueDetail;
    }
    
    global class AssessmentWrapper {
        
        global String ServiceId;
        global List<Assessment__c> valueDetail;
        
    }
    
    global class AssessmentSafetyListWrapper {
        
        global String ServiceId;
        global List<Assessment_Safety_Plan__c> valueDetail;
    }
    
    
}