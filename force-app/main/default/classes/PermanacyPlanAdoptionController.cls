public with sharing class PermanacyPlanAdoptionController {

    @AuraEnabled
    public static String getAdoptionInitialInfos(String permanencyPlanId) {
    
        PermanencyPlanAdoptionWrapper adoptionWrap = new PermanencyPlanAdoptionWrapper();
        adoptionWrap.adoptionPlanPicklist = Utility.getPicklistinfo('Permanency_Plan__c','Adoption_Planning__c',false);
        
        if(String.isNotBlank(permanencyPlanId)) {
            
            List<String> permanencyPlanFields = new List<String>{'Id', 'Placement__c', 'Service_Case__c', 'Contact__r.Name', 'Contact__r.Date_of_Birth__c', 'Contact__r.Gender__c', 'Adoption_Planning__c'};
            String permanencyPlanCondition = 'Id = \''+ String.escapeSingleQuotes(permanencyPlanId) +'\'';
            List<SObject> permanencyPlanSObjList = DataService.performQueryOperation(permanencyPlanFields, 'Permanency_Plan__c', permanencyPlanCondition, Utility.queryLimit);
           
            if(permanencyPlanSObjList != null && permanencyPlanSObjList.size() > 0) {
                adoptionWrap.permanencyPlanRec = (Permanency_Plan__c)permanencyPlanSObjList[0];
            } 

            List<String> legalCustodyFields = new List<String>{'Id', 'Child_Name__c'};
            String legalCustodyCondition = 'Legal_Custody__c = \''+ 'Guardianship to DSS'+'\''+' AND  Child_Name__r.Service_Case__c = \''+String.escapeSingleQuotes(adoptionWrap.permanencyPlanRec.Service_Case__c)+'\'';
            List<SObject> legalCustodySObjList = DataService.performQueryOperation(legalCustodyFields, 'Legal_Custody__c', legalCustodyCondition, Utility.queryLimit);
            adoptionWrap.legalCustody = (List<Legal_Custody__c>)legalCustodySObjList;           
            List<String> placementFields = new List<String>{'Id'};
            String placementCondition = 'Id= \''+String.escapeSingleQuotes(adoptionWrap.permanencyPlanRec.Placement__c)+'\' AND Placement_Structure__c = \''+'Pre-Finalized Adoptive Home'+'\'';
            List<SObject> placementSObjList = DataService.performQueryOperation(placementFields, 'Placement__c', placementCondition, Utility.queryLimit);
            adoptionWrap.placementRec = (List<Placement__c>)placementSObjList;
            List<String> tprFields = new List<String>{'Id'};
            String tprCondition = 'Permanency_Plan__c= \''+String.escapeSingleQuotes(permanencyPlanId)+'\'';
            List<SObject> tprSObjList = DataService.performQueryOperation(tprFields, 'TPR__c', tprCondition, Utility.queryLimit);
            adoptionWrap.tpRList = (List<TPR__c>)tprSObjList;
            List<String> subSidyFields = new List<String>{'Id','Rate_Approval_Status__c'};
            String subSidyCondition = 'Permanency_Plan__c= \''+String.escapeSingleQuotes(permanencyPlanId)+'\'';
            List<SObject> subSidySObjList = DataService.performQueryOperation(subSidyFields, 'Subsidy_Rate__c', subSidyCondition, Utility.queryLimit);
            adoptionWrap.subSidyRecList = (List<Subsidy_Rate__c>)subSidySObjList;
        }
        return JSON.serialize(adoptionWrap);
    }
    
    @AuraEnabled(cacheable=true)
    public static String getTPRRecommendationInitialInfos(String permanencyPlanId) {
        
        PermanencyPlanAdoptionWrapper adoptionWrap = new PermanencyPlanAdoptionWrapper();

        if(String.isNotBlank(permanencyPlanId)) {
             
            List<String> permanencyPlanFields = new List<String>{'Id', 'Contact__c', 'Child_in_care_15_out_of_last_22_months__c', 'Court_hearing_occurs__c', 'Information_for_either_parent_is_unknown__c', 'Reason_for_Recommendation__c',
                                                                'Court_order_of_TPR_for_parents__c', 'Petition_for_TPR_sent_to_court__c', 'Primary_Permanacy_Plan_is_adoption__c', 'Adoption_Planning__c'};
            String permanencyPlanCondition = 'Id = \''+ String.escapeSingleQuotes(permanencyPlanId) +'\'';
            List<SObject> permanencyPlanSObjList = DataService.performQueryOperation(permanencyPlanFields, 'Permanency_Plan__c', permanencyPlanCondition, Utility.queryLimit);
            
            if(permanencyPlanSObjList != null && permanencyPlanSObjList.size() > 0) {
                adoptionWrap.permanencyPlanRec = (Permanency_Plan__c)permanencyPlanSObjList[0];
            } 
            
            List<String> courtFields = new List<String>{ 'Id'};
            String courtCondition = '(Court__r.Type_of_Petition__c = \''+'TPR'+'\' OR Court__r.Type_of_Petition__c = \'' +'Adoption' +'\') AND Scheduled_Hearing_Type__c ';
            courtCondition += 'INCLUDES (\''+'Adoption;TPR/Guardianship- Contested'+'\') AND Court__r.Hearing_Outcome__c INCLUDES(\''+'Adoption Granted'+'\','+'\''+'TPR Granted'+'\')';
            if(adoptionWrap.permanencyPlanRec.Contact__c != null) {
            	courtCondition += 'AND Court__r.Petition_for_Child__c = \''+ String.escapeSingleQuotes(adoptionWrap.permanencyPlanRec.Contact__c)+'\'';
            } else {
                courtCondition += 'AND Court__r.Petition_for_Child__c = \''+'\'';
            }
            List<SObject> courtSObjList = DataService.performQueryOperation(courtFields, 'Court_Petition_Hearing__c', courtCondition, Utility.queryLimit);
            adoptionWrap.courtHearingRec = (List<Court_Petition_Hearing__c>)courtSObjList;
        }
        return JSON.serialize(adoptionWrap);    
    }
    
    @AuraEnabled
    public static String getAdoptionPlanningStageInitialInfos(String permanencyPlanId) {

        PermanencyPlanAdoptionWrapper adoptionWrap = new PermanencyPlanAdoptionWrapper();
        adoptionWrap.adoptionPlanningStagePicklist = Utility.getPicklistinfo('Permanency_Plan__c','Adoption_Planning_Stage__c',false);
        adoptionWrap.hasTheChildBeenInCarePicklist = Utility.getPicklistinfo('Permanency_Plan__c','Has_the_child_been_in_care__c',false);
        adoptionWrap.checkTheAgeOfChildTheChildPicklist = Utility.getPicklistinfo('Permanency_Plan__c','Check_the_age_of_the_child__c',false);
        adoptionWrap.specialNeedsPicklist = Utility.getPicklistinfo('Permanency_Plan__c','One_of_following_special_needs_factors__c', false);
       
        if(String.isNotBlank(permanencyPlanId)) {

            List<String> permanencyPlanFields = new List<String>{ 'Id', 'Child_Birth_Date__c', 'Federal_Fiscal_Year_Adoption_Date__c', 'Check_the_age_of_the_child__c', 'Has_the_child_been_in_care__c', 'Is_the_child_a_sibling_to_a_child__c',
                                                                'An_involuntary_removal_in_accordance__c', 'Date_of_removal__c', 'Date_of_first_court_order_CTW__c', 'A_voluntary_placement_agreement__c',
                                                                'Child_Removal_Date_VPA__c', 'Voluntary_relinquishment__c', 'Date_of_relinquishment__c', 'medical_or_disability_requirements__c',
                                                                'child_residing_in_a_foster_family_home__c', 'All_medical_disability_requirements_SSI__c', 'One_of_following_special_needs_factors__c','Adoption_Planning_Stage__c', 
                                                                'Reasonable_but_unsuccessful_efforts__c', 'Reasonable_unsuccessful_effort_comments__c', 'If_instead_the_child_is_being_adopted_b__c', 'If_instead_child_being_adopted_comments__c',
                                                                'Was_the_child_eligible_for_adoption__c', 'Document_explanation_in_case_record__c', 'Previous_Adoptive_Parent_s_TPR__c',
                                                                'Previous_Adoptive_Parent_s_Death_date__c', 'Is_the_child_currently_Title_1V_E_foster__c', 'Is_the_child_currently_SSI_eligibile__c','Resubmission_Signature__c', 'Caseworker_Signature__c',
                                                                'Applicable_Child_Approval_Status__c', 'child_be_returned_to_the_home_of_parent__c', 'Caseworker_Name__c', 'Caseworker_Date__c', 'Resubmission_Case_Worker_Name__c', 'Resubmission_Request_Date__c'};
            String permanencyPlanCondition = 'Id = \''+ String.escapeSingleQuotes(permanencyPlanId) +'\'';
            List<SObject> permanencyPlanSObjList = DataService.performQueryOperation(permanencyPlanFields, 'Permanency_Plan__c', permanencyPlanCondition, Utility.queryLimit);
            
            if(permanencyPlanSObjList != null && permanencyPlanSObjList.size() > 0) {
                adoptionWrap.adoptionPlanningStageRec = (Permanency_Plan__c)permanencyPlanSObjList[0];
                adoptionWrap.applicableChildAssRec = (Permanency_Plan__c)permanencyPlanSObjList[0];
            } 
            
        }
        return JSON.serialize(adoptionWrap);
    }
    
    
    @AuraEnabled
    public static String getAdoptionPlanningNarrativeInitialInfos(String permanencyPlanId) {
    
        if(String.isNotBlank(permanencyPlanId)) {
            PermanencyPlanAdoptionWrapper permanencyPlanWrapper = new PermanencyPlanAdoptionWrapper();
            List<String> permanencyPlanFields = new List<String>{ 'Id', 'Adoption_Plan_Begin_Date__c', 'Notes_for_narrative__c'};
            String permanencyPlanCondition = 'Id = \''+ String.escapeSingleQuotes(permanencyPlanId) +'\'';
            List<SObject> permanencyPlanSObjList = DataService.performQueryOperation(permanencyPlanFields, 'Permanency_Plan__c', permanencyPlanCondition, Utility.queryLimit);
            
            if(permanencyPlanSObjList != null && permanencyPlanSObjList.size() > 0) {
                permanencyPlanWrapper.permanencyPlanRec = (Permanency_Plan__c)permanencyPlanSObjList[0];
            } 
           
            return JSON.serialize(permanencyPlanWrapper);
        }
        return null;
    }
    
    @AuraEnabled
    public static String updateAdoptionPlanning(String adoptionPlanningJSON) {
        
        if(String.isNotBlank(adoptionPlanningJSON)) {
            
            Permanency_Plan__c permanencyRec = (Permanency_Plan__c)JSON.deserialize(adoptionPlanningJSON, Permanency_Plan__c.class);
            //FieldLevelSecurity.checkFieldAccessByCriteria(permanencyRec.getPopulatedFieldsAsMap().keySet(), 'update', 'Permanency_Plan__c');
            update permanencyRec;
            return permanencyRec.Id;     
        } else {
            return null;
        }
            
    }
     
    @AuraEnabled
    public static String updateApplicableChildAssessmentRec (String applicableChildAssessmentRecJSON, String resubmissionsign, String caseworkerSign) {
        
        if(String.isNotBlank(applicableChildAssessmentRecJSON)) {
            
            Permanency_Plan__c applicableChildAssessmentRec = (Permanency_Plan__c)JSON.deserialize(applicableChildAssessmentRecJSON, Permanency_Plan__c.class);
            
            if(String.isNotBlank(resubmissionsign)){
            	applicableChildAssessmentRec.Resubmission_Signature__c = resubmissionsign;
            }
            
            if(String.isNotBlank(caseworkerSign)) {
            	applicableChildAssessmentRec.Caseworker_Signature__c = caseworkerSign;
            }
            //FieldLevelSecurity.checkFieldAccessByCriteria(applicableChildAssessmentRec.getPopulatedFieldsAsMap().keySet(), 'update', 'Permanency_Plan__c');
            update applicableChildAssessmentRec;
        return applicableChildAssessmentRec.Id;    
        } else {
            return null;
        }
            
    }
    
    @AuraEnabled
    public static String getSelectProviderDetail(String providerId) {
        PermanencyPlanAdoptionWrapper adoptionWrap = new PermanencyPlanAdoptionWrapper();
        
        if(String.isNotBlank(providerId)) {
                        
            List<String> contactFields = new List<String>{'Id', 'Provider_Id__c', 'AccountId', 'Name', 'Applicant_or_Co_Applicant__c'};
            String contactCondition = 'AccountId = \''+ String.escapeSingleQuotes(providerId) +'\'';
            List<SObject> contactSObjList = DataService.performQueryOperation(contactFields, 'Contact', contactCondition, Utility.queryLimit);
            adoptionWrap.providerList = (List<Contact>)contactSObjList;
            
            return JSON.serialize(adoptionWrap.providerList);
        } else {
            return null;
        }
    }
    
    

    @AuraEnabled
    public static String getBreakthelinkRecord(String permanencyPlanId) {
        PermanencyPlanAdoptionWrapper adoptionWrap = new PermanencyPlanAdoptionWrapper();
        
        if(String.isNotBlank(permanencyPlanId)) {      

            List<String> permanencyPlanFields = new List<String>{'Id', 'Placement__c', 'Contact__c', 'Adoption_Plan_Begin_Date__c','Disclosure_Approval_Status__c', 'Break_Line_Approval_Status__c', 'Child_is_Legally_free__c', 'Child_was_in_an_Approved_Pre_Adoptive__c', 'Adoptive_Placement_Agreement_signed__c','Date_Agreement_signed__c','Case_Creation_Date__c'};
            String permanencyPlanCondition = 'Id = \''+ String.escapeSingleQuotes(permanencyPlanId) +'\'';
            List<SObject> permanencyPlanSObjList = DataService.performQueryOperation(permanencyPlanFields, 'Permanency_Plan__c', permanencyPlanCondition, Utility.queryLimit);
            
            if(permanencyPlanSObjList != null && permanencyPlanSObjList.size() > 0) {
                adoptionWrap.breaktheLinkRecord = (Permanency_Plan__c)permanencyPlanSObjList[0];
            }

            List<String> tprFields = new List<String>{'Id',  'Permanency_Plan__c', 'TPR_Decision_Date__c'};
            String tprCondition = 'Permanency_Plan__c= \''+String.escapeSingleQuotes(permanencyPlanId)+'\'';
            List<SObject> tprSObjList = DataService.performQueryOperation(tprFields, 'TPR__c', tprCondition, Utility.queryLimit);
            adoptionWrap.tpRList = (List<TPR__c>)tprSObjList;

            List<String> placementFields = new List<String>{'Id', 'Placement_Structure__c', 'Provider__c', 'Provider__r.Name', 'Begin_Date__c', 'End_Date__c', 'Placement_Approval_Status__c'};
            String placementCondition ='';
            if(adoptionWrap.breaktheLinkRecord.Placement__c != null) {
            	 placementCondition = 'Id= \''+String.escapeSingleQuotes(adoptionWrap.breaktheLinkRecord.Placement__c)+'\' AND Placement_Structure__c = \''+'Pre-Finalized Adoptive Home'+'\'';
            } else {
                placementCondition = 'Id= \''+'\' AND Placement_Structure__c = \''+'Pre-Finalized Adoptive Home'+'\'';
            }
            List<SObject> placementSObjList = DataService.performQueryOperation(placementFields, 'Placement__c', placementCondition, Utility.queryLimit);
            adoptionWrap.placementRec = (List<Placement__c>)placementSObjList;
            
            List<String> courtFields = new List<String>{ 'Id', 'Court__r.Court_Order_Date__c' };
            String courtCondition = '(Court__r.Type_of_Petition__c = \''+'TPR'+'\' OR Court__r.Type_of_Petition__c = \'' +'Adoption' +'\') AND Scheduled_Hearing_Type__c';
            courtCondition += ' INCLUDES (\''+'Adoption;TPR/Guardianship- Contested'+'\') AND Court__r.Hearing_Outcome__c INCLUDES(\''+'Adoption Granted'+'\','+'\''+'TPR Granted'+'\')';
            if(adoptionWrap.breaktheLinkRecord.Contact__c !=null) {
            	courtCondition += 'AND Court__r.Petition_for_Child__c = \''+ String.escapeSingleQuotes(adoptionWrap.breaktheLinkRecord.Contact__c)+'\' ORDER BY CreatedDate DESC';
            } else {
                courtCondition += 'AND Court__r.Petition_for_Child__c = \''+'\' ORDER BY CreatedDate DESC';
            }
            List<SObject> courtSObjList = DataService.performQueryOperation(courtFields, 'Court_Petition_Hearing__c', courtCondition, Utility.queryLimit);
            adoptionWrap.courtHearingRec = (List<Court_Petition_Hearing__c>)courtSObjList;
        
            return JSON.serialize(adoptionWrap);
        } else {
            
            return null;
        }
    }

	@AuraEnabled
    public static String onSubmitForApproval(String permanencyRecId, Id selectedSupervisorUserId){        
        
        if(String.isNotBlank(permanencyRecId) && String.isNotBlank(selectedSupervisorUserId)) {
          
            Permanency_Plan__c permanencyRec =  new Permanency_Plan__c ();
            permanencyRec.Id = permanencyRecId;
            permanencyRec.Supervisor_Approval__c  = selectedSupervisorUserId;
            //FieldLevelSecurity.checkFieldAccessByCriteria(permanencyRec.getPopulatedFieldsAsMap().keySet(), 'update', 'Permanency_Plan__c');
            update permanencyRec;
            Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest(); 
            req.setComments('Adoption Planning Record Submit For Approval');        
            req.setObjectId(permanencyRec.Id);
            Approval.ProcessResult approvalResult = Approval.process(req);
            return JSON.serialize(approvalResult);
        } else {
            return null;
        }   
         
    } 
    
    @AuraEnabled
    public static String subsidySubmitForApproval(String subsidyRateRecId, Id selectedSupervisorUserId){        
        
        if(String.isNotBlank(subsidyRateRecId) && String.isNotBlank(selectedSupervisorUserId)) {
          
            Subsidy_Rate__c subsidyRateRec =  new Subsidy_Rate__c ();
            subsidyRateRec.Id = subsidyRateRecId;
            subsidyRateRec.Supervisor_Approval__c  = selectedSupervisorUserId;
            //FieldLevelSecurity.checkFieldAccessByCriteria(subsidyRateRec.getPopulatedFieldsAsMap().keySet(), 'update', 'Subsidy_Rate__c');
            update subsidyRateRec;
            Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest(); 
            req.setComments('Subsidy Rate Record Submit For Approval');        
            req.setObjectId(subsidyRateRec.Id);
            Approval.ProcessResult approvalResult = Approval.process(req);
            return JSON.serialize(approvalResult);
        } else {
            return null;
        }   
         
    }  
    
    @AuraEnabled
    public static String getActiveTab(String permanencyRecId) {

        Permanency_Plan__c  activetab = new Permanency_Plan__c();
        
        if(String.isNotBlank(permanencyRecId)) {
            
            List<String> permanencyPlanFields = new List<String>{'Id','Subsidy_Approval_Status__c'};
            String permanencyPlanCondition = 'Id = \''+ String.escapeSingleQuotes(permanencyRecId) +'\'';
            List<SObject> permanencyPlanSObjList = DataService.performQueryOperation(permanencyPlanFields, 'Permanency_Plan__c', permanencyPlanCondition, Utility.queryLimit);
            
            if(permanencyPlanSObjList != null && permanencyPlanSObjList.size() > 0) {
                activetab= (Permanency_Plan__c)permanencyPlanSObjList[0];
            }

        }
        return JSON.serialize(activetab);
    }
    
    @AuraEnabled
    public static String getPersons(String recordId) {
        
            List<Person__c> clientList = new List<Person__c>();
        
            /*List<String> contactFields = new List<String>{'Id','Name'};
            String contactCondition = 'Service_Case__c = \''+ String.escapeSingleQuotes(recordId) + '\' AND Intake_Person_Role__c EXCLUDES(\'Biological Child\')';
            
            List<SObject> sObjListContact = DataService.performQueryOperation(contactFields, 'Contact', contactCondition, Utility.queryLimit);
            clientList = (List<Contact>)sObjListContact;*/
        
        	List<String> personFields = new List<String>{'Id','Person__c','Person__r.Name'};
            String personCondition = 'Service_Case__c = \''+ String.escapeSingleQuotes(recordId) + '\' AND Person__r.Intake_Person_Role__c EXCLUDES(\'Biological Child\')';
            
            List<SObject> sObjListContact = DataService.performQueryOperation(personFields, 'Person__c', personCondition, Utility.queryLimit);
            clientList = (List<Person__c>)sObjListContact;
            
            List<Utility.pickListWrap> clientRecPickList = new List<Utility.pickListWrap>();
            Utility.pickListWrap picklist = new Utility.pickListWrap();
            picklist.label = '--None--';
            picklist.value = '';
            clientRecPickList.add(picklist);

            for(Person__c con : clientList) {
                
                if (String.isNotBlank(con.Id)) {
                    picklist = new Utility.pickListWrap();
                    picklist.label = con.Person__r.Name;
                    picklist.value = con.Person__c;
                    clientRecPickList.add(picklist);
                }
            }  
          return JSON.serialize(clientRecPickList);
    }
    
     public class PermanencyPlanAdoptionWrapper {
    
        @AuraEnabled
        public List<Utility.pickListWrap> adoptionPlanPicklist;
        @AuraEnabled
        public Permanency_Plan__c permanencyPlanRec;
        @AuraEnabled
        public List<Court_Petition_Hearing__c> courtHearingRec; 
        @AuraEnabled
        public List<Utility.pickListWrap> adoptionPlanningStagePicklist;
        @AuraEnabled
        public Permanency_Plan__c adoptionPlanningStageRec;
        @AuraEnabled
        public List<TPR__c> tpRList;
        @AuraEnabled
        public List<Utility.pickListWrap> hasTheChildBeenInCarePicklist;
        @AuraEnabled
        public List<Utility.pickListWrap> checkTheAgeOfChildTheChildPicklist;
        @AuraEnabled
        public Permanency_Plan__c applicableChildAssRec;
        @AuraEnabled
        public List<Utility.pickListWrap> specialNeedsPicklist;
        @AuraEnabled
        public List<Legal_Custody__c> legalCustody;
        @AuraEnabled
        public List<Placement__c> placementRec;
        @AuraEnabled
        public List<Contact> providerList;
        @AuraEnabled
        public Permanency_Plan__c breaktheLinkRecord;
        @AuraEnabled
        public List<Subsidy_Rate__c> subSidyRecList;
        
        public PermanencyPlanAdoptionWrapper() {
        
            placementRec = new List<Placement__c>();
        }
     }   
    
}