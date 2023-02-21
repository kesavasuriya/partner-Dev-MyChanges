public  with sharing class CasePlanController {
    
    @AuraEnabled
    public static String getPlacementTableRecords(String serviceCaseId) {
    
        if(String.isNotBlank(serviceCaseId)) {

            CasePlanVersionWrapper initialRecord = new CasePlanVersionWrapper();
            Utility.pickListWrap placementPick; 
            List<String> placementFields = new List<String>{'Name','Id','Begin_Date__c', 'Child__r.Casevault_PID__c', 'Child__r.Name', 'Child__r.Date_of_Birth__c', 'Child__r.Gender__c', 'Child_Removal__r.Removal_Date_of_DT_F__c', 'Provider__r.Name'};
            String placementCondition = 'Service_Case__c = \''+ String.escapeSingleQuotes(serviceCaseId) +'\''+'AND Exit_Approval_Status__c !='+'\'Approved\'';
            List<SObject> placementsObjList = DataService.performQueryOperation(placementFields, 'Placement__c', placementCondition, Utility.queryLimit);
            initialRecord.placementRecordList = (List<Placement__c>)placementsObjList;
            
            List<String> caseFields = new List<String>{'Name','From_Date__c','To_Date__c','Placement__c'};
            String caseCondition='';
            
            if(initialRecord.placementRecordList != null && initialRecord.placementRecordList.size() >0) {
                 caseCondition += 'Placement__c IN(';
            for(Placement__c rec : initialRecord.placementRecordList) {
                placementPick = new Utility.pickListWrap();
                placementPick.label = rec.Child__r.Name;
                placementPick.value = rec.Id;
                initialRecord.placementPicklist.add(placementPick);
                caseCondition +='\''+String.escapeSingleQuotes(rec.Id)+'\' ,';
            }
                caseCondition = caseCondition.removeEnd(' ,');
 				caseCondition += ')';
            } else {
                caseCondition += 'Placement__c IN('+ '\''+'\')';
            }
            List<SObject> casePlansObjList = DataService.performQueryOperation(caseFields, 'Case_Plan__c', caseCondition, Utility.queryLimit);
            initialRecord.casePlanRecords = (List<Case_Plan__c>)casePlansObjList;
            
            return JSON.serialize(initialRecord);     
        } else {
            return null;
        }
    }
    
    @AuraEnabled
    public static String getPlacementRecords(String placementId) {
        
        CasePlanVersionWrapper initialRecord = new CasePlanVersionWrapper();
        
        if(String.isNotBlank(placementId)) {
            
            List<String> placementFields = new List<String>{'Name', 'Begin_Date__c', 'Child__r.Name', 'Child_Removal__r.Removal_Date_of_DT_F__c', 'Provider__r.Name'};
            String placementCondition = 'Id = \''+ String.escapeSingleQuotes(placementId) +'\'';
            List<SObject> placementsObjList = DataService.performQueryOperation(placementFields, 'Placement__c', placementCondition, Utility.queryLimit);
            if(placementsObjList != null && placementsObjList.size() > 0) {
                initialRecord.placementRecord = (Placement__c)placementsObjList[0];
            }
            List<String> caseFields = new List<String>{'Name','From_Date__c','To_Date__c'};
            String caseCondition = 'Placement__c = \''+ String.escapeSingleQuotes(placementId) +'\'';
            List<SObject> casePlansObjList = DataService.performQueryOperation(caseFields, 'Case_Plan__c', caseCondition, Utility.queryLimit);
            initialRecord.casePlanRecords = (List<Case_Plan__c>)casePlansObjList;
            return JSON.serialize(initialRecord);    
        } else {  
            return null;
        }
    }
    
    @AuraEnabled
    public static String getSocialHistoryRecord(String casePlanVersionId) {
        
        SocialHistoryWrapper socialHistoryRec = new SocialHistoryWrapper();
        if(String.isNotBlank(casePlanVersionId)) {
            
            Case_Plan__c casePlanRec = new Case_Plan__c();
            List<String> caseplanFields = new List<String>{'Placement__r.Child__r.Name', 'Placement__r.Child_Removal__r.Removal_Date_of_DT_F__c', 'Placement__r.Service_Case__c',
                                                           'Placement__r.Child__r.Date_of_Birth__c', 'Placement__r.Child__r.Gender__c','Placement__r.Child__r.Casevault_PID__c',
                                                           'Placement__r.Child_Removal__r.Reasonable_efforts_made_to_prevent_child__c', 'Placement__r.Child__r.Race__c',
                                                           'Placement__r.Child__r.Religion__c', 'Placement__r.Child__r.SSN__c', 'Placement__r.Child__r.Applicant_or_Co_Applicant__c', 'Placement__r.Child_Removal__r.Address_Of_Primary_Caregiver__c',
                                                           'Placement__r.Child__r.Applicant_First_Name__c', 'Placement__r.Child__r.Applicant_Last_Name__c'};
            String caseplanCondition = 'Id = \''+ String.escapeSingleQuotes(casePlanVersionId) +'\'';
            List<SObject> casePlansObjList = DataService.performQueryOperation(caseplanFields, 'Case_Plan__c', caseplanCondition, Utility.queryLimit);
        
            if(casePlansObjList != null && casePlansObjList.size() > 0) {
                 casePlanRec = (Case_Plan__c)casePlansObjList[0];
            }
            socialHistoryRec.childName = casePlanRec.Placement__r.Child__r.Name;
            socialHistoryRec.removalDate = casePlanRec.Placement__r.Child_Removal__r.Removal_Date_of_DT_F__c;
            socialHistoryRec.dob = casePlanRec.Placement__r.Child__r.Date_of_Birth__c;
            socialHistoryRec.gender = casePlanRec.Placement__r.Child__r.Gender__c;
            socialHistoryRec.clientId = casePlanRec.Placement__r.Child__r.Casevault_PID__c;
            socialHistoryRec.reasonableEffort = casePlanRec.Placement__r.Child_Removal__r.Reasonable_efforts_made_to_prevent_child__c;
            socialHistoryRec.race = casePlanRec.Placement__r.Child__r.Race__c;
            socialHistoryRec.religion = casePlanRec.Placement__r.Child__r.Religion__c;
            socialHistoryRec.ssn = casePlanRec.Placement__r.Child__r.SSN__c;
            socialHistoryRec.addressofPrimaryCaregiver = casePlanRec.Placement__r.Child_Removal__r.Address_Of_Primary_Caregiver__c;
            if(casePlanRec.Placement__r.Child__r.Applicant_or_Co_Applicant__c =='Applicant' &&  (casePlanRec.Placement__r.Child__r.Applicant_First_Name__c !=null ||  casePlanRec.Placement__r.Child__r.Applicant_Last_Name__c != null)) {
                socialHistoryRec.applicant = casePlanRec.Placement__r.Child__r.Applicant_First_Name__c+' '+casePlanRec.Placement__r.Child__r.Applicant_Last_Name__c;
            } else if(casePlanRec.Placement__r.Child__r.Applicant_First_Name__c !=null ||  casePlanRec.Placement__r.Child__r.Applicant_Last_Name__c != null) {
                socialHistoryRec.coApplicant = casePlanRec.Placement__r.Child__r.Applicant_First_Name__c+' '+casePlanRec.Placement__r.Child__r.Applicant_Last_Name__c;
            }
            List<String>  assessmentReassessmentFields = new List<String>{'Id'};
            String assessmentReassessmentCondition = 'Assessment_Type__c = \''+'SAFE-C\''+' AND Service_Case__c ='+'\''+ String.escapeSingleQuotes(casePlanRec.Placement__r.Service_Case__c)+'\''+' AND Approval_Status__c ='+'\'Approved\''+' ORDER By CreatedDate DESC';
            List<SObject> assessmentReassessmentsObjList = DataService.performQueryOperation(assessmentReassessmentFields, 'Assessment__c', assessmentReassessmentCondition, Utility.queryLimit);
            List<Assessment__c>  assessmentRecSafeC = (List<Assessment__c>)assessmentReassessmentsObjList;

            List<String>  assessmentSafeCFields = new List<String>{'Id'};
            String assessmentSafeCCondition = 'Assessment_Type__c = \''+'Family risk Reassessment\''+' AND Service_Case__c='+'\''+ String.escapeSingleQuotes(casePlanRec.Placement__r.Service_Case__c)+'\''+' AND Approval_Status__c ='+'\'Approved\''+' ORDER By CreatedDate DESC';
            List<SObject> assessmentSafeCsObjList = DataService.performQueryOperation(assessmentSafeCFields, 'Assessment__c', assessmentSafeCCondition, Utility.queryLimit);
            List<Assessment__c> assessmentRecReassessment = (List<Assessment__c>)assessmentSafeCsObjList;
            socialHistoryRec = calculateAssCompletionDate(assessmentRecSafeC, assessmentRecReassessment, socialHistoryRec);
            return JSON.serialize(socialHistoryRec);     
        } else {  
            return null;
        }
    }

    public static SocialHistoryWrapper calculateAssCompletionDate(List<Assessment__c>  assessmentRecSafeC, List<Assessment__c> assessmentRecReassessment, SocialHistoryWrapper socialHistoryRec) {

        List<String>  assessmentCompletedFields = new List<String>{'CompletedDate','TargetObjectId'};
        String  assessmentCompletedCondition = ''; 
        if((assessmentRecSafeC.size() > 0 && assessmentRecSafeC != null) && (assessmentRecReassessment != null && assessmentRecReassessment.size() > 0)) {
            String safec='';
            String reassessment='';
            safec = assessmentRecSafeC[0].Id;
            reassessment  = assessmentRecReassessment[0].Id;
            assessmentCompletedCondition +=' TargetObjectId = \''+ String.escapeSingleQuotes(safec)+'\'OR TargetObjectId ='+ '\''+String.escapeSingleQuotes(reassessment)+'\'';
        } else if (assessmentRecSafeC.size() > 0 && assessmentRecSafeC != null) {
            String safec = assessmentRecSafeC[0].Id;
            assessmentCompletedCondition +=' TargetObjectId = \''+ String.escapeSingleQuotes(safec)+'\'';
        } else if (assessmentRecReassessment.size() > 0 && assessmentRecReassessment != null){
            String reassessment  = assessmentRecReassessment[0].Id;
            assessmentCompletedCondition +=' TargetObjectId = \''+ String.escapeSingleQuotes(reassessment)+'\'';
        }
        List<ProcessInstance> assessmentCompletedDate = new List<ProcessInstance>();
        if(assessmentRecSafeC.size() > 0 || assessmentRecReassessment.size() > 0 ) {
            List<SObject>  assessmentCompletedsObjList = DataService.performQueryOperation(assessmentCompletedFields, 'ProcessInstance', assessmentCompletedCondition, Utility.queryLimit);
            assessmentCompletedDate = (List<ProcessInstance>)assessmentCompletedsObjList;
        }   
        for(ProcessInstance assementRec : assessmentCompletedDate ){
            
            if(assessmentRecSafeC.size() >0 && assementRec.TargetObjectId == assessmentRecSafeC[0].Id) {
                socialHistoryRec.safecCompletionDate = assementRec.CompletedDate;
            } else if(assessmentRecReassessment.size() >0 && assementRec.TargetObjectId == assessmentRecReassessment[0].Id) {
                socialHistoryRec.riskReassessmentCompletionDate = assementRec.CompletedDate;
            }
        }
        return socialHistoryRec;
    }
    
    @AuraEnabled
    public static String getPermanencyProgressRecord(String casePlanVersionId) {
        
        CasePlanVersionWrapper permanencyProgressRec = new CasePlanVersionWrapper();
        if(String.isNotBlank(casePlanVersionId)) {
            
            List<String> caseplanFields = new List<String>{'Placement__r.Service_Case__c', 'Placement__r.Child__r.Name', 'Placement__r.Child__r.Date_of_Birth__c',
                                                            'Placement__r.Child__r.Casevault_PID__c', 'Placement__r.Service_Case__r.Intake__r.CaseNumber', 
                                                            'From_Date__c', 'To_Date__c', 'Placement__r.Service_Case__r.Intake__r.Jurisdiction__c', 'CreatedBy.Name',
                                                            'Placement__r.Begin_Date__c', 'Placement__r.Provider__r.Name', 'Placement__r.Provider__r.BillingAddress',
                                                            'Placement__r.Placement_Structure__c', 'Placement__r.End_Date__c', 'caseworker_Service_EndDate__c', 'caseworker_Service_StartDate__c',
                                                            'Date_of_last_Progress_Report__c', 'Describe_the_parent_current_relationship__c', 'Discuss_how_the_worker_is_addressing__c', 'Discuss_parent_child_interaction__c',
                                                            'Discuss_the_visitation_plan__c', 'Follow_up_information_on_court_orders__c', 'List_mandates_of_court_order_pertaining__c', 'Referral_Made_to_Adoptuskids__c',
                                                            'What_services_are_being_provided__c','What_services_provided_to_eliminate__c', 'What_services_have_we_identified__c', 'Health_Passport__c',
                                                            'Day_Care__c', 'Reimbursement_for_Expenses__c', 'Transportation__c', 'Discussion_of_Visitation_Date__c', 'Financial_Support__c', 'Emotional_Support_or_Guidance__c',
                                                            'Special_Training__c', 'Other__c', 'Discussion_of_Childs_Needs__c', 'If_Other__c', 'Respite_Care__c', 'Discuss_each_checked_iteam__c', 'Is_the_child_co_committed__c',
                                                            'Has_youth_experienced_any_episodes__c', 'Has_the_youth_experienced_Explain__c', 'Has_youth_had_involvement__c', 'Parent_Name__c',
                                                            'Child_IN_Out_Of_Home_Placement__c', 'State_Compelling_Reason__c', 'Date_TPR_Petition_Filed__c', 'Date_of_Voluntary_signature_Mother__c', 'Date_of_Voluntary_signature_Father__c',
                                                            'Date_TPR_Granted__c', 'Date_TPR_Denied__c', 'Date_TPR_Appeal_Filed_Father__c', 'Date_TPR_Appeal_Filed_Mother__c', 'TPR_Appeal_Decision_Father__c',
                                                            'TPR_Appeal_Decision_Mother__c', 'Was_the_child_enrolled_in_school__c', 'Is_this_school_placement__c', 'Has_the_child_changed_school__c',
                                                            'Best_interest_to_change_schools__c', 'Discuss_the_appropriateness__c', 'What_Educational_services__c', 'If_child_is_pre_school_age__c',
                                                            'Child_current_report_card__c', 'Individual_Education_Program__c', 'Educational_Parent_Name__c', 'Educational_Parent_Address__c', 'Educational_Parent_Requested__c',
                                                            'At_or_near_age_level__c', 'Behavioral_problems__c', 'Problems_with_peers__c', 'Strengths__c', 'Weakness__c', 'Describe_the_child_strengths__c',
                                                            'Child_is_between_18_and_21_years_old__c', 'Does_the_child_have_any_diagnosed__c', 'Homelessness_during_reporting_period__c', 'Length_Of_Time_Child_Was_Homeless__c',
                                                            'Will_Youth_Require_Supportive_Services__c',	 'Discuss_Services_Youth_Will_Require__c', 'Passport_Record_Confirmation__c',
                                                            'Dates_Confirmed__c', 'Notes__c', 'Placement__r.Child__c',
                                                            'Child_Support_Referral_Date__c', 'Child_Support_Order_Been_Established__c' };
            
            String caseplanCondition = 'Id = \''+ String.escapeSingleQuotes(casePlanVersionId) +'\''+'AND Placement__r.Child__c != null AND Placement__r.Service_Case__r.Intake__c != null AND Placement__r.Provider__c != null';
            List<SObject> casePlansObjList = DataService.performQueryOperation(caseplanFields, 'Case_Plan__c', caseplanCondition, Utility.queryLimit);
            if(casePlansObjList != null && casePlansObjList.size() > 0) {
                permanencyProgressRec.permanencyProgressRecord = (Case_Plan__c)casePlansObjList[0];
                system.debug('rec'+permanencyProgressRec.permanencyProgressRecord);
            }
            String childName = permanencyProgressRec.permanencyProgressRecord.Placement__r.Child__r.Name;    
            if(permanencyProgressRec.permanencyProgressRecord.Id != null) {
                
                List<String>  permanencyPlanFields = new List<String>{'Discuss_how_the_caregiver_is_meeting__c', 'Discuss_and_explain_changes_in_the_child__c',
                                                                'If_the_Permanency_plan_is_to_return_home__c', 'Document_what_steps_have_been_taken__c', 'Describe_how_the_worker_is_ensuring__c',
                                                                'What_efforts_were_made_to_promote__c', 'Has_a_Lifebook_been_prepared__c', 'Describe_the_parent_s_compliance__c',
                                                                'Primary_Permanency_Plan__c', 'Concurrent_Permanency_Plan__c', 'Plan_Established_Date__c'};
                String permanencyPlanCondition = 'Placement__c = \''+String.escapeSingleQuotes(permanencyProgressRec.permanencyProgressRecord.Placement__c)+'\''+' ORDER BY CreatedDate DESC';
                List<SObject> permanencyPlansObjList = DataService.performQueryOperation(permanencyPlanFields, 'Permanency_Plan__c', permanencyPlanCondition, Utility.queryLimit);
                if(PermanencyPlansObjList != null && PermanencyPlansObjList.size() > 0) {
                    permanencyProgressRec.permanencyPlanRecord = (Permanency_Plan__c)permanencyPlansObjList[0];
                }

                List<String> notesFields = new List<String>{'Contact_Date__c'};
                String notesCondition = 'Contact_Type__c = \''+'Face to Face'+'\''+' AND Involved_Persons__c INCLUDES( \''+String.escapeSingleQuotes(childName)+'\')';
                List<SObject> notessObjList = DataService.performQueryOperation(notesFields, 'Notes__c', notesCondition, Utility.queryLimit);
                permanencyProgressRec.faceToFaceVisitsList = (List<Notes__c>)notessObjList;    
                permanencyProgressRec = getAssessmentDetails(permanencyProgressRec);
                permanencyProgressRec = getPersonDetails(permanencyProgressRec);   
            }
            return JSON.serialize(permanencyProgressRec);    
        } else {   
            return null;
        }
    }

    public static CasePlanVersionWrapper getAssessmentDetails(CasePlanVersionWrapper permanencyProgressRec) {

        List<String> assessmentFields = new List<String>{'Id', 'Assessment_Type__c', 'SAFEC_Child_is_conditionally_Safe__c', 'SAFEC_Child_is_Conditionally_Safe_17_16__c', 'FINAL_RISK_LEVEL__c',
                                                                 'SAFEC_Child_is_Safe_Influences_1_18__c', 'SAFEC_Child_is_UnSafe__c', 'OHP_Child_is_Safe_Influences_1_12_Marked__c', 'OHP_Child_is_Unsafe_Any_Influence_1_12__c','RISK_LEVEL__c'};
        String assessmentCondition = 'Approval_Status__c = \''+'Approved'+'\''+' AND Service_Case__c =\''+String.escapeSingleQuotes(permanencyProgressRec.permanencyProgressRecord.Placement__r.Service_Case__c)+'\'';
        List<SObject> assessmentsObjList = DataService.performQueryOperation(assessmentFields, 'Assessment__c', assessmentCondition, Utility.queryLimit);
        permanencyProgressRec.assessmentRecordList = (List<Assessment__c>)assessmentsObjList;
        
        List<String> assessmentCompletedDateFields = new List<String>{'CompletedDate','TargetObjectId'};
        String assessmentCompletedDateCondition = 'TargetObjectId IN (';

        if(permanencyProgressRec.assessmentRecordList.size() > 0) {
            for(Assessment__c assessmentRec : permanencyProgressRec.assessmentRecordList) {
                assessmentCompletedDateCondition += '\''+ String.escapeSingleQuotes(assessmentRec.Id) +'\'' +' ,';
            }
            assessmentCompletedDateCondition =  assessmentCompletedDateCondition.removeEnd(' ,');
        } else {
            assessmentCompletedDateCondition += '\'\'';
        }
        assessmentCompletedDateCondition += ' )';
        List<SObject> assessmentCompletedDatesObjList = DataService.performQueryOperation(assessmentCompletedDateFields, 'ProcessInstance', assessmentCompletedDateCondition, Utility.queryLimit);
        permanencyProgressRec.assessmentRecordCompletedDate = (List<ProcessInstance>)assessmentCompletedDatesObjList;
        return permanencyProgressRec;
    }

    public static CasePlanVersionWrapper getPersonDetails(CasePlanVersionWrapper permanencyProgressRec) {

        if(permanencyProgressRec.permanencyProgressRecord.Placement__r.Child__c != null) {

            List<String>  medicationFields = new List<String>{'Is_Client_Prescribed_Medication__c', 'Medication_Name__c', 'Frequency__c', 'Start_Date__c',
                                                                    'End_Date__c', 'Reason_Prescribed__c'};
            String medicationCondition = 'Contact__c = \''+String.escapeSingleQuotes(permanencyProgressRec.permanencyProgressRecord.Placement__r.Child__c)+'\'';
            List<SObject> medicationsObjList = DataService.performQueryOperation(medicationFields, 'Medication_Including_Psychotropic__c', medicationCondition, Utility.queryLimit);
            permanencyProgressRec.medicationRecords = (List<Medication_Including_Psychotropic__c>)medicationsObjList;

            List<String> personIncomeFields = new List<String>{'Income_Source__c', 'Monthly_Income__c', 'Entry_Date__c'};
            String personIncomeCondition = 'Contact__c  = \''+String.escapeSingleQuotes(permanencyProgressRec.permanencyProgressRecord.Placement__r.Child__c)+'\''+' ORDER BY CreatedDate DESC';
            List<SObject> personIncomesObjList = DataService.performQueryOperation(personIncomeFields, 'Person_Incomes__c', personIncomeCondition, Utility.queryLimit);
            permanencyProgressRec.incomeRecord = (List<Person_Incomes__c>)personIncomesObjList;

            List<String> assetFields = new List<String>{ 'Asset_Type__c', 'Market_Value__c', 'Entry_Date__c'};
            String assetCondition = 'Contact__c = \''+String.escapeSingleQuotes(permanencyProgressRec.permanencyProgressRecord.Placement__r.Child__c)+'\' ORDER BY CreatedDate DESC';
            List<SObject> assetsObjList = DataService.performQueryOperation(assetFields, 'Asset__c', assetCondition, Utility.queryLimit);
            permanencyProgressRec.assetRecord = (List<Asset__c>)assetsObjList;

            List<String> examFields = new List<String>{'Nature_of_Exam__c', 'Appointment_Date__c', 'Physician_Name__c', 'Address_Line_1__c',
                                                    'Address_Line_2__c', 'City__c', 'State__c', 'Country__c', 'Zip_Code__c'};
            String examCondition = 'Contact__c = \''+String.escapeSingleQuotes(permanencyProgressRec.permanencyProgressRecord.Placement__r.Child__c)+'\''+' AND (Nature_of_Exam__c=\''+'Initial Health Examination'+'\''+' OR Nature_of_Exam__c=\''+'Annual Health Examination'+'\''+'OR Nature_of_Exam__c=\''+'Follow-up Health Examination'+'\')';
            List<SObject> examsObjList = DataService.performQueryOperation(examFields, 'Examination__c',examCondition, Utility.queryLimit);
            List<Examination__c>  examRec = (List<Examination__c>)examsObjList; 
            for(Examination__c rec : examRec) {
                if(rec.Nature_of_Exam__c == 'Initial Health Examination') {
                    permanencyProgressRec.initialExamList.add(Rec);
                } else if(rec.Nature_of_Exam__c == 'Annual Health Examination') {
                    permanencyProgressRec.finalExamList.add(Rec);
                } else if(rec.Nature_of_Exam__c == 'Follow-up Health Examination') {
                    permanencyProgressRec.followupExamList.add(Rec);
                }
            }
            List<String> educationFields = new List<String>{'Type_of_Class__c', 'School_Setting__c', 'Date_Last_Attended__c', 'Work_Phone_Number__c', 'Current_Grade__c','Education_End_Date__c'};
            String educationCondition = 'Contact__c = \''+String.escapeSingleQuotes(permanencyProgressRec.permanencyProgressRecord.Placement__r.Child__c)+'\'';
            List<SObject> educationsObjList = DataService.performQueryOperation(educationFields, 'Education__c', educationCondition, Utility.queryLimit);
            permanencyProgressRec.educationRecords = (List<Education__c>)educationsObjList;
            List<String> childRemovalFields = new List<String>{'Primary_Caregiver__r.Name', 'Primary_Caregiver__r.Date_of_Birth__c', 'Primary_Caregiver__r.SSN__c',
                                                            'Primary_Caregiver__r.Address_Line_1__c', 'Primary_Caregiver__r.Address_Line_2__c', 'Primary_Caregiver__r.City__c',
                                                            'Primary_Caregiver__r.State__c', 'Primary_Caregiver__r.Zip_Code__c', 'Primary_Caregiver__r.County_Address__c', 'Autism_Spectrum_Disorder__c',
                                                            'Autism_Start_Diagnosis_Date__c', 'Autism_End_Resolution_Date__c', 'Cognitive_Developmental_Delay__c', 'Cognitive_Start_Diagnosis_Date__c',
                                                            'Cognitive_End_Resolution_Date__c', 'Emotionally_Disturbed__c', 'Emotionally_Start_Diagnosis_Date__c','Emotionally_End_Resolution_Date__c',	
                                                            'Hearing_Disability__c', 'Hearing_Star_Diagnosis_Date__c', 'Hearing_End_Resolution_Date__c', 'Intellectual_Disability__c',
                                                            'Intellectual_Start_Diagnosis_Date__c', 'Intellectual_End_Resolution_Date__c', 'Other_Disability__c', 'Other_Start_Diagnosis_Date__c',
                                                            'Other_End_Resolution_Date__c', 'Physical_Disability__c', 'Physical_Start_Diagnosis_Date__c', 'Physical_End_Resolution_Date__c',
                                                            'Visual_Disability__c', 'Visual_Start_Diagnosis_Date__c', 'Visual_End_Resolution_Date__c'};

            String childRemovalCondition = 'Child__c = \''+String.escapeSingleQuotes(permanencyProgressRec.permanencyProgressRecord.Placement__r.Child__c)+'\'';
            List<SObject> childRemovalsObjList = DataService.performQueryOperation(childRemovalFields, 'Child_Removal__c', childRemovalCondition, Utility.queryLimit);
            if(childRemovalsObjList != null && childRemovalsObjList.size() > 0) {
                permanencyProgressRec.childRemovalRecord = (Child_Removal__c)childRemovalsObjList[0];
            }
        }
        return permanencyProgressRec;
    }
    
    @AuraEnabled
    public static String getServicePlanRecord(String casePlanId) {
        
        CasePlanVersionWrapper servicePlanVersionRec = new CasePlanVersionWrapper();
        set<Id> servicePlanId = new set<Id>();
        if(String.isNotBlank(casePlanId)) {
            
            Case_Plan__c casePlanRec = new Case_Plan__c();
            List<String> caseFields = new List<String>{'Placement__r.Child__c, Placement__r.Service_Case__c'};
            String caseCondition = 'Id = \''+String.escapeSingleQuotes(casePlanId)+'\'';
            List<SObject> casePlansObjList = DataService.performQueryOperation(caseFields, 'Case_Plan__c', caseCondition, Utility.queryLimit);
            if(casePlansObjList != null && casePlansObjList.size() > 0) {
                casePlanRec = (Case_Plan__c)casePlansObjList[0];
            }
            if(casePlanRec.Placement__r.Child__c != null) {
              
                List<String> candidacyFields = new List<String>{'Child_Name__c', 'Service_Plan__c', 'Service_Plan__r.Name', 'Service_Plan__r.Target_End_Date__c', 'Service_Plan__r.Completion_Date__c', 
                                                                'Service_Plan__r.Start_Date__c'};
                String candidacyCondition = 'Child_Name__c = \''+String.escapeSingleQuotes(casePlanRec.Placement__r.Child__c)+'\''+' AND  Service_Plan__r.Service_Case__c =\''+String.escapeSingleQuotes(casePlanRec.Placement__r.Service_Case__c)+'\'';
                List<SObject> candidacysObjList = DataService.performQueryOperation(candidacyFields, 'Candidacy__c', candidacyCondition, Utility.queryLimit);
                servicePlanVersionRec.servicePlanRecord  = (List<Candidacy__c>)candidacysObjList;
            }
            return JSON.serialize(servicePlanVersionRec);     
        } else { 
            return null;
        }
    }
    
    @AuraEnabled
    public static String getYouthTransitionPlanRecords(String casePlanId) {
        
        CasePlanVersionWrapper youthTransitionPlanRec = new CasePlanVersionWrapper();
        if(String.isNotBlank(casePlanId)) {
                 
            Case_Plan__c casePlanRec = new Case_Plan__c();
            List<String> caseFields = new List<String>{'Placement__r.Child__c, Placement__r.Service_Case__c'};
            String caseCondition = 'Id = \''+String.escapeSingleQuotes(casePlanId)+'\'';
            List<SObject> intakesObjList = DataService.performQueryOperation(caseFields, 'Case_Plan__c', caseCondition, Utility.queryLimit);
            if(intakesObjList != null && intakesObjList.size() > 0) {
                casePlanRec = (Case_Plan__c)intakesObjList[0];
            }
            if(casePlanRec.Placement__r.Child__c != null) {

                List<String> youthTransitionPlanFields = new List<String>{'Name', 'Transition_Plan_Completed_Date__c', 'Contact__r.Name', 'CreatedDate', 'Status__c'};
                String youthTransitionPlanCondition = 'Contact__c = \''+String.escapeSingleQuotes(casePlanRec.Placement__r.Child__c)+'\''+'AND Service_Case__c= \''+String.escapeSingleQuotes(casePlanRec.Placement__r.Service_Case__c)+'\'';
                List<SObject> youthTransitionPlansObjList = DataService.performQueryOperation(youthTransitionPlanFields, 'Youth_Transition_Plan__c', youthTransitionPlanCondition, Utility.queryLimit);
                youthTransitionPlanRec.youthTransitionPlanList = (List<Youth_Transition_Plan__c>)youthTransitionPlansObjList;
                            
            }     
            return JSON.serialize(youthTransitionPlanRec);    
        } else {    
            return null;
        }
    }

    public class CasePlanVersionWrapper { 

        @AuraEnabled
        public List<Case_Plan__c> casePlanRecords;
        @AuraEnabled
        public Placement__c placementRecord;
        @AuraEnabled
        public List<Placement__c> placementRecordList;
        @AuraEnabled
        public Case_Plan__c permanencyProgressRecord;
        @AuraEnabled
        public Permanency_Plan__c permanencyPlanRecord;
        @AuraEnabled
        public List<Assessment__c> assessmentRecordList;
        @AuraEnabled
        public Child_Removal__c childRemovalRecord;
        @AuraEnabled
        public List<Person_Incomes__c> incomeRecord;
        @AuraEnabled
        public List<Asset__c> assetRecord;
        @AuraEnabled
        public List<ProcessInstance> assessmentRecordCompletedDate;
        @AuraEnabled 
        public List<Candidacy__c> servicePlanRecord;
        @AuraEnabled
        public List<Youth_Transition_Plan__c> youthTransitionPlanList;
        @AuraEnabled
        public List<Examination__c> initialExamList;
        @AuraEnabled
        public List<Examination__c> finalExamList;
        @AuraEnabled
        public List<Examination__c> followupExamList;
        @AuraEnabled
        public List<Education__c> educationRecords;
        @AuraEnabled
        public List<Notes__c> faceToFaceVisitsList;
        @AuraEnabled
        public List<Utility.pickListWrap> placementPicklist;
        @AuraEnabled
        public List<Medication_Including_Psychotropic__c> medicationRecords;
        
        public CasePlanVersionWrapper() {

            placementPicklist = new List<Utility.pickListWrap>();
            permanencyProgressRecord = new Case_Plan__c();
            permanencyPlanRecord = new Permanency_Plan__c();
            incomeRecord = new List<Person_Incomes__c>();
            childRemovalRecord = new Child_Removal__c();
            assessmentRecordList = new List<Assessment__c>();
            assetRecord = new List<Asset__c>();
            servicePlanRecord = new List<Candidacy__c>();
            initialExamList = new List<Examination__c>();
            finalExamList = new List<Examination__c>();
            followupExamList = new List<Examination__c>();
            educationRecords = new List<Education__c>();
            faceToFaceVisitsList = new List<Notes__c>();
            placementRecordList = new List<Placement__c>();
            youthTransitionPlanList = new List<Youth_Transition_Plan__c>();
            medicationRecords = new List<Medication_Including_Psychotropic__c>();    
        }
    }    
    
    public class SocialHistoryWrapper {

        @AuraEnabled
        public String childName;
        @AuraEnabled
        public Date removalDate;
        @AuraEnabled
        public Date dob;
        @AuraEnabled
        public String gender;
        @AuraEnabled
        public String clientId;
        @AuraEnabled
        public String reasonableEffort;
        @AuraEnabled
        public String race;
        @AuraEnabled
        public String religion;
        @AuraEnabled
        public String ssn;
        @AuraEnabled
        public String applicant = '';
        @AuraEnabled
        public String coApplicant = '';
        @AuraEnabled
        public String addressofPrimaryCaregiver;
        @AuraEnabled
        public Datetime safecCompletionDate;
        @AuraEnabled
        public Datetime riskReassessmentCompletionDate;    
    }
}