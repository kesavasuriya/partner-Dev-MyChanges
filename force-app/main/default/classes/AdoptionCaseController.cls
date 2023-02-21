public with sharing class AdoptionCaseController {

    @AuraEnabled
    public static String getSubsidyAgreementIntiInfos(String adoptionCaseId) {
         
         AdoptionCaseWraper adoptionWrap = new AdoptionCaseWraper();
         
         adoptionWrap.adoptiveSubsidyIsPaidPicklist = Utility.getPicklistinfo('Case', 'adopt_if_a_subsidy_is_paid__c', false);
         adoptionWrap.childPlacedFromPicklist = Utility.getPicklistinfo('Case','Child_Placed_From__c', false);
         adoptionWrap.childPlacedByPicklist = Utility.getPicklistinfo('Case','Child_Placed_By__c', false);
         adoptionWrap.placementStructurePicklist = Utility.getPicklistinfo('Account','Placement_Structure__c',false);
         adoptionWrap.childCharPicklist = Utility.getPicklistinfo('Account','Child_Characteristics_Willing_To_Accept__c',true);
         adoptionWrap.localDeptPicklist = Utility.getPicklistinfo('Account','Local_Department__c',false);
              
         if (String.isNotBlank(adoptionCaseId)) {
         
            FieldLevelSecurity.checkFieldAccessByCriteria('Subsidy_Agreement_Start_Date__c, Subsidy_Agreement_End_Date__c, Subsidy_Agreement_Under_Appeal__c,'+
            'Offered_Adoption_subsidy__c,Offer_Accepted_Date__c,Single_Parent_Adoption_Check__c,Adoptive_Parent_1_signature_date__c,'+
            'Adoptive_Parent_2_Signature_Date__c,LDSS_Director_Designee_Signature_Date__c,Adoptive_Parent_1_Signature__c,'+
            'Adoptive_Parent_2_Signature__c,LDSS_Director_DESIGNEE_SIGNATURE__c,adopt_if_a_subsidy_is_paid__c,Medical_Assistance_only__c,'+
            'Subsidy_Agreement_Comments__c,Child_Placed_From__c,Child_Placed_By__c,Adoptive_Parent_1__c,Adoptive_Parent_2__c,Subsidy_Provider_Id__c,'+
            'Subsidy_Agreement_Approval_Status__c', 'view', 'Case',  Boolean.valueOf(Label.HasNamespace));
             adoptionWrap.adoptionCaseSubsidyAgreementRec = [SELECT Id, Subsidy_Agreement_Start_Date__c, Subsidy_Agreement_End_Date__c, Subsidy_Agreement_Under_Appeal__c, 
                                                    		Offered_Adoption_subsidy__c, Offer_Accepted_Date__c, Single_Parent_Adoption_Check__c, Adoptive_Parent_1_signature_date__c,
                                                 			Adoptive_Parent_2_Signature_Date__c, LDSS_Director_Designee_Signature_Date__c, Adoptive_Parent_1_Signature__c, 
                                                 			Adoptive_Parent_2_Signature__c, LDSS_Director_DESIGNEE_SIGNATURE__c, adopt_if_a_subsidy_is_paid__c,Medical_Assistance_only__c,
                                                 			Subsidy_Agreement_Comments__c, Child_Placed_From__c, Child_Placed_By__c, Adoptive_Parent_1__c, Adoptive_Parent_2__c, Subsidy_Provider_Id__c,
                                                 			Subsidy_Agreement_Approval_Status__c FROM Case WHERE Id=:adoptionCaseId LIMIT :Utility.queryLimit];
             return JSON.serialize(adoptionWrap);
             
          } else {
              return null;
          }
     }
     
     @AuraEnabled
     public static String getRateRecordInfo(String caseId) {
         
          AdoptionCaseWraper adoptionWrap = new AdoptionCaseWraper();
          
          if (String.isNotBlank(caseId)) {
          
                FieldLevelSecurity.checkFieldAccessByCriteria('Transaction_Date__c,Rate_Begin_Date__c,Rate_End_Date__c,SSA_Approval__c,Does_the_child_have_special_needs__c,SSA_Approval_Date__c,Primary_Basics_for_Special_Needs__c,'+
                    'Adoptive_Family_s_Relationship_to_Child__c,Note__c,Monthly_Payment_Amount__c, Approval_Date__c, Approval_Status__c, Permanency_Plan__c,'+
                    'Rate_Approval_Status__c,'+
                    'Adoption_Case_Rate_Status__c', 'view', 'Subsidy_Rate__c',  Boolean.valueOf(Label.HasNamespace));
                FieldLevelSecurity.checkFieldAccessByCriteria('Adoptive_Parent_1__c,Adoptive_Parent_2__c,Subsidy_Provider_Id__c,Subsidy_Agreement_Start_Date__c,Subsidy_Agreement_Approval_Status__c', 'view', 'Case',  Boolean.valueOf(Label.HasNamespace));
                adoptionWrap.primaryBasisPicklist = Utility.getPicklistinfo('Subsidy_Rate__c','Primary_Basics_for_Special_Needs__c', false);
                adoptionWrap.rateRecord = [SELECT Id,Transaction_Date__c, Rate_Begin_Date__c, Rate_End_Date__c, SSA_Approval__c, Does_the_child_have_special_needs__c, SSA_Approval_Date__c, Primary_Basics_for_Special_Needs__c,
                                         Adoptive_Family_s_Relationship_to_Child__c, Note__c, Monthly_Payment_Amount__c, Approval_Date__c, Approval_Status__c, Permanency_Plan__c, 
                                         Rate_Approval_Status__c, Adoption_Case__r.Adoptive_Parent_1__c, Adoption_Case__r.Adoptive_Parent_2__c, Adoption_Case__r.Subsidy_Provider_Id__c,
                                         Adoption_Case__r.Subsidy_Agreement_Approval_Status__c, Adoption_Case_Rate_Status__c
                                         FROM Subsidy_Rate__c WHERE Adoption_Case__c =:caseId AND 
                                         Adoption_Case__r.Subsidy_Agreement_Approval_Status__c='Approved' ORDER By LastmodifiedDate DESC LIMIT :Utility.queryLimit];
                                         
                adoptionWrap.caseRec = [SELECT Id, Adoptive_Parent_1__c, Adoptive_Parent_2__c, Subsidy_Provider_Id__c, Subsidy_Agreement_Start_Date__c, Subsidy_Agreement_Approval_Status__c FROM Case WHERE Id = :caseId LIMIT :Utility.queryLimit];
   
          }
         return JSON.serialize(adoptionWrap);
     }
    
    @AuraEnabled
    public static String checkAddingNewRateAndAnnualReviewStatus(String adoptionCaseId) {
    
        AdoptionCaseWraper adoptionWrap = new AdoptionCaseWraper();
        
        if (String.isNotBlank(adoptionCaseId)) {
        
            FieldLevelSecurity.checkFieldAccessByCriteria('Rate_End_Date__c,Adoption_Case__c, Adoption_Case_Rate_Status__c, Adoption_Case__c', 'view', 'Subsidy_Rate__c',  Boolean.valueOf(Label.HasNamespace));
            FieldLevelSecurity.checkFieldAccessByCriteria('Subsidy_Agreement_Approval_Status__c', 'view', 'Case',  Boolean.valueOf(Label.HasNamespace));
            adoptionWrap.subsidyRateRecord = [SELECT Id, Rate_End_Date__c,Adoption_Case__c, Adoption_Case_Rate_Status__c, Adoption_Case__r.Subsidy_Agreement_Approval_Status__c  FROM Subsidy_Rate__c
                                              WHERE Adoption_Case__c=:adoptionCaseId  ORDER By LastmodifiedDate DESC LIMIT :Utility.queryLimit];
            if(adoptionWrap.subsidyRateRecord != null && adoptionWrap.subsidyRateRecord.size() > 0) {
                FieldLevelSecurity.checkFieldAccessByCriteria('Review_Date__c, Annual_Review_Approval_Status__c', 'view', 'Annual_Review__c',  Boolean.valueOf(Label.HasNamespace));
                adoptionWrap.annualReviewRec = [SELECT Id, Review_Date__c, Annual_Review_Approval_Status__c FROM 
                                                Annual_Review__c WHERE  Adoption_Case__c = :adoptionCaseId AND 
                                                Review_Date__c = :adoptionWrap.subsidyRateRecord[0].Rate_End_Date__c
                                                ORDER By LastmodifiedDate DESC LIMIT 1];
            }
            FieldLevelSecurity.checkFieldAccessByCriteria('Subsidy_Agreement_Approval_Status__c', 'view', 'Case',  Boolean.valueOf(Label.HasNamespace));
            adoptionWrap.caseRec = [SELECT Id, Subsidy_Agreement_Approval_Status__c FROM Case
                                     WHERE Id=:adoptionCaseId LIMIT :Utility.queryLimit];
            return JSON.serialize(adoptionWrap);
       } else {
            return null;
       }
    }
    
    @AuraEnabled
    public static string getAnnualReviewInfo(String caseId) {
         
        AdoptionCaseWraper adoptionWrap = new AdoptionCaseWraper();
         
        if (String.isNotBlank(caseId)) {
            FieldLevelSecurity.checkFieldAccessByCriteria('LDSS_Director_Designee__c, Entered_By__c, Review_Date__c, Child_is_under_18_Years_old_or_Child_is__c, Child_Still_meets_special_need__c, Parent_are_Still_legally_Responsible__c,'+
            'Renewal_agreement_has_been_signed__c, Parent_Provide_financial_Support_for_the__c, Child_is_Currently_entrolled_in_School__c, if_not_School_age_document_of_immurizati__c, if_the_child_is_between_18_and_21_Years__c,'+
            'Disability_Notes__c, Notes__c, Annual_Review_Approval_Status__c', 'view', 'Annual_Review__c',  Boolean.valueOf(Label.HasNamespace));
             adoptionWrap.annualReviewRecords = [SELECT Id, LDSS_Director_Designee__c, Entered_By__c, Review_Date__c, Child_is_under_18_Years_old_or_Child_is__c, Child_Still_meets_special_need__c, Parent_are_Still_legally_Responsible__c,
                                                 Renewal_agreement_has_been_signed__c, Parent_Provide_financial_Support_for_the__c, Child_is_Currently_entrolled_in_School__c, if_not_School_age_document_of_immurizati__c, if_the_child_is_between_18_and_21_Years__c,
                                                 Disability_Notes__c, Notes__c, Annual_Review_Approval_Status__c FROM Annual_Review__c WHERE Adoption_Case__c = :caseId LIMIT :Utility.queryLimit];
            FieldLevelSecurity.checkFieldAccessByCriteria('Adoptive_Parent_1_signature_date__c, Adoptive_Parent_2_Signature_Date__c', 'view', 'Case',  Boolean.valueOf(Label.HasNamespace));
            adoptionWrap.caseRec = [SELECT Id, Adoptive_Parent_1_signature_date__c, Adoptive_Parent_2_Signature_Date__c FROM Case WHERE Id = :caseId LIMIT :Utility.queryLimit];
        }
        return JSON.serialize(adoptionWrap);
    }
 
    @AuraEnabled
    public static String updateSubsidyAgreement(String adoptionCaseJSON, String parent1Signature, String parent2Signature, String lDSSDirectorSignature) {

        if (String.isNotBlank(adoptionCaseJSON)) {
            
            Case updateSubsidyAgreementRec = (Case)JSON.deserialize(adoptionCaseJSON, Case.class);
            if(String.isNotBlank(updateSubsidyAgreementRec.Id)) {

                if(String.isNotBlank(parent1Signature)) {
                    updateSubsidyAgreementRec.Adoptive_Parent_1_Signature__c = parent1Signature;
                }
                if(String.isNotBlank(parent2Signature)) {
                    updateSubsidyAgreementRec.Adoptive_Parent_2_Signature__c = parent2Signature;
                }
                if(String.isNotBlank(lDSSDirectorSignature)) {
                    updateSubsidyAgreementRec.LDSS_Director_DESIGNEE_SIGNATURE__c = lDSSDirectorSignature;
                }
                FieldLevelSecurity.checkFieldAccessByCriteria('Subsidy_Agreement_Start_Date__c, Subsidy_Agreement_End_Date__c, Subsidy_Agreement_Under_Appeal__c,'+
                'Offered_Adoption_subsidy__c,Offer_Accepted_Date__c,Single_Parent_Adoption_Check__c,Adoptive_Parent_1_signature_date__c,'+
                'Adoptive_Parent_2_Signature_Date__c,LDSS_Director_Designee_Signature_Date__c,Adoptive_Parent_1_Signature__c,'+
                'Adoptive_Parent_2_Signature__c,LDSS_Director_DESIGNEE_SIGNATURE__c,adopt_if_a_subsidy_is_paid__c,Medical_Assistance_only__c,'+
                'Subsidy_Agreement_Comments__c,Child_Placed_From__c,Child_Placed_By__c,Adoptive_Parent_1__c,Adoptive_Parent_2__c,Subsidy_Provider_Id__c,'+
                'Subsidy_Agreement_Approval_Status__c', 'update', 'Case',  Boolean.valueOf(Label.HasNamespace));

                update updateSubsidyAgreementRec;
            }
           return updateSubsidyAgreementRec.Id;
        } else {
            return null;
        }
    }
         
    @AuraEnabled
    public static String upsertRateRecord(String raterecord) {
         
        if(String.isNotBlank(raterecord)) {
 
            Subsidy_Rate__c updateRateRecords = (Subsidy_Rate__c)JSON.deserialize(raterecord, Subsidy_Rate__c.class);
            if (String.isBlank(updateRateRecords.Id)) {
            FieldLevelSecurity.checkFieldAccessByCriteria('Transaction_Date__c,Rate_Begin_Date__c,Rate_End_Date__c,SSA_Approval__c,Does_the_child_have_special_needs__c,SSA_Approval_Date__c,Primary_Basics_for_Special_Needs__c,'+
            'Adoptive_Family_s_Relationship_to_Child__c,Note__c,Monthly_Payment_Amount__c, Approval_Date__c, Approval_Status__c, Permanency_Plan__c,'+
            'Rate_Approval_Status__c,'+
            'Adoption_Case_Rate_Status__c', 'create', 'Subsidy_Rate__c',  Boolean.valueOf(Label.HasNamespace));
             insert updateRateRecords;
            } else {
            FieldLevelSecurity.checkFieldAccessByCriteria('Transaction_Date__c,Rate_Begin_Date__c,Rate_End_Date__c,SSA_Approval__c,Does_the_child_have_special_needs__c,SSA_Approval_Date__c,Primary_Basics_for_Special_Needs__c,'+
            'Adoptive_Family_s_Relationship_to_Child__c,Note__c,Monthly_Payment_Amount__c, Approval_Date__c, Approval_Status__c, Permanency_Plan__c,'+
            'Rate_Approval_Status__c,'+
            'Adoption_Case_Rate_Status__c', 'update', 'Subsidy_Rate__c',  Boolean.valueOf(Label.HasNamespace));
             update updateRateRecords;
            }
            return updateRateRecords.Id;
        } else {
            return null;
        }
    }
 
    @AuraEnabled
    public static String upsertAnnualReviewRecord(String annualReviewrecord) {
         
         if(String.isNotBlank(annualReviewrecord)) {
 
             Annual_Review__c updateannualReviewRecords = (Annual_Review__c)JSON.deserialize(annualReviewrecord, Annual_Review__c.class);
             if (String.isBlank(updateannualReviewRecords.Id)) {
                FieldLevelSecurity.checkFieldAccessByCriteria('LDSS_Director_Designee__c, Entered_By__c, Review_Date__c, Child_is_under_18_Years_old_or_Child_is__c, Child_Still_meets_special_need__c, Parent_are_Still_legally_Responsible__c,'+
                'Renewal_agreement_has_been_signed__c, Parent_Provide_financial_Support_for_the__c, Child_is_Currently_entrolled_in_School__c, if_not_School_age_document_of_immurizati__c, if_the_child_is_between_18_and_21_Years__c,'+
                'Disability_Notes__c, Notes__c, Annual_Review_Approval_Status__c', 'create', 'Annual_Review__c',  Boolean.valueOf(Label.HasNamespace));
                 insert updateannualReviewRecords;
             } else {
                FieldLevelSecurity.checkFieldAccessByCriteria('LDSS_Director_Designee__c, Entered_By__c, Review_Date__c, Child_is_under_18_Years_old_or_Child_is__c, Child_Still_meets_special_need__c, Parent_are_Still_legally_Responsible__c,'+
                'Renewal_agreement_has_been_signed__c, Parent_Provide_financial_Support_for_the__c, Child_is_Currently_entrolled_in_School__c, if_not_School_age_document_of_immurizati__c, if_the_child_is_between_18_and_21_Years__c,'+
                'Disability_Notes__c, Notes__c, Annual_Review_Approval_Status__c', 'update', 'Annual_Review__c',  Boolean.valueOf(Label.HasNamespace));
                 update updateannualReviewRecords;
             }
             return updateannualReviewRecords.Id;
         }
         else {
             return null;
         }
     }
     
     @AuraEnabled
     public static String getSuspensionintialInfo(String adoptionCaseId){
         AdoptionCaseWraper adoptionWrap = new AdoptionCaseWraper();
         adoptionWrap.suspensionForReasonPickList = Utility.getPicklistinfo('Suspension__c','Suspension_Reason__c', false);
         if (String.isNotBlank(adoptionCaseId)) {
            FieldLevelSecurity.checkFieldAccessByCriteria('Suspension_Reason__c, Start_Date__c, End_Date__c, Notes__c,Adoption_Suspension_Approval_Status__c, Adoption_Suspension_Approved_By__c', 'view', 'Suspension__c',  Boolean.valueOf(Label.HasNamespace));
             adoptionWrap.suspensionRecordList = [SELECT Id, Suspension_Reason__c, Start_Date__c, End_Date__c, Notes__c,Adoption_Suspension_Approval_Status__c, Adoption_Suspension_Approved_By__c   
                                              FROM Suspension__c WHERE Adoption_Case__c =:adoptionCaseId ORDER By CreatedDate DESC LIMIT :Utility.queryLimit
                                             ];
            FieldLevelSecurity.checkFieldAccessByCriteria('Annual_Review_Approval_Status__c', 'view', 'Annual_Review__c',  Boolean.valueOf(Label.HasNamespace));                             
            adoptionWrap.annualReviewRec = [SELECT Id, Annual_Review_Approval_Status__c FROM Annual_Review__c WHERE Adoption_Case__c =:adoptionCaseId ORDER By CreatedDate DESC LIMIT 1];                                
         }
     return JSON.serialize(adoptionWrap);
     }
 
     @AuraEnabled
     public static String upsertSuspensionRec(String updateSuspensionRecJSON) {
         
         if(String.isNotBlank(updateSuspensionRecJSON)) {
 
             Suspension__c updateSuspensionRecord = (Suspension__c)JSON.deserialize(updateSuspensionRecJSON, Suspension__c.class);
             if (String.isBlank(updateSuspensionRecord.Id)) {
                FieldLevelSecurity.checkFieldAccessByCriteria('Suspension_Reason__c, Start_Date__c, End_Date__c, Notes__c,Adoption_Suspension_Approval_Status__c, Adoption_Suspension_Approved_By__c', 'create', 'Suspension__c',  Boolean.valueOf(Label.HasNamespace));
                 insert updateSuspensionRecord;
             } else {
                FieldLevelSecurity.checkFieldAccessByCriteria('Suspension_Reason__c, Start_Date__c, End_Date__c, Notes__c,Adoption_Suspension_Approval_Status__c, Adoption_Suspension_Approved_By__c', 'update', 'Suspension__c',  Boolean.valueOf(Label.HasNamespace));
                 update updateSuspensionRecord;
             }
             return updateSuspensionRecord.Id;
         }
         else {
             return null;
         }
     }
     
    @AuraEnabled
     public static String deleteSuspensionRec(String delSuspensionRecJSON) {
         
         if(String.isNotBlank(delSuspensionRecJSON)) {
            FieldLevelSecurity.checkObjectAccessByDelete('Suspension__c');
             Suspension__c deleteSuspensionRecord = (Suspension__c)JSON.deserialize(delSuspensionRecJSON, Suspension__c.class);
             delete deleteSuspensionRecord;
             return deleteSuspensionRecord.Id;
         }
         else {
             return null;
         }
     }

     @AuraEnabled
    public static String onSubmitSuspensionApprovalProcess(String suspensionId, Id selectedSupervisorUserId){        
        
        if (String.isNotBlank(suspensionId) && String.isNotBlank(selectedSupervisorUserId)) {

            Suspension__c suspensionRec =  new Suspension__c ();
            suspensionRec.Id = suspensionId;
            suspensionRec.Supervisor_Approval__c  = selectedSupervisorUserId;
            FieldLevelSecurity.checkFieldAccessByCriteria('Supervisor_Approval__c','update','Suspension__c', Boolean.valueOf(Label.HasNamespace));
            update suspensionRec;
            Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest(); 
            req.setComments('Suspension Record Submit For Approval');        
            req.setObjectId(suspensionRec.Id);
            Approval.ProcessResult approvalResult = Approval.process(req);
            return JSON.serialize(approvalResult);
        } else {
            return null;
        }   
         
    } 
    
    @AuraEnabled
    public static String onSubmitAnnualReviewApprovalProcess(String annualReviewId, Id selectedSupervisorUserId){        
        
        if (String.isNotBlank(annualReviewId) && String.isNotBlank(selectedSupervisorUserId)) {
            Annual_Review__c annualReviewRec =  new Annual_Review__c ();
            annualReviewRec.Id = annualReviewId;
            annualReviewRec.Supervisor_Approval__c  = selectedSupervisorUserId;
            FieldLevelSecurity.checkFieldAccessByCriteria('Supervisor_Approval__c','update','Annual_Review__c', Boolean.valueOf(Label.HasNamespace));
            update annualReviewRec;
            Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest(); 
            req.setComments('Annul ReviewRecord Submit For Approval');        
            req.setObjectId(annualReviewRec.Id);
            Approval.ProcessResult approvalResult = Approval.process(req);
            return JSON.serialize(approvalResult);
        } else {
            return null;
        }   
         
    } 
    
    @AuraEnabled
    public static String onSubmitSubsidyAgreementApprovalProcess(String adoptionCaseId, Id selectedSupervisorUserId){        
        
        if (String.isNotBlank(adoptionCaseId) && String.isNotBlank(selectedSupervisorUserId)) {
            Case adoptionCaseRecord =  new Case ();
            adoptionCaseRecord.Id = adoptionCaseId;
            adoptionCaseRecord.Supervisor_Approver__c  = selectedSupervisorUserId;
            FieldLevelSecurity.checkFieldAccessByCriteria('Supervisor_Approver__c','update','Case', Boolean.valueOf(Label.HasNamespace));
            update adoptionCaseRecord;
            Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest(); 
            req.setComments('Subsidy Agreement Record Submit For Approval');        
            req.setObjectId(adoptionCaseRecord.Id);
            Approval.ProcessResult approvalResult = Approval.process(req);
            return JSON.serialize(approvalResult);
        } else {
            return null;
        }   
         
    }
    @AuraEnabled
    public static String onSubmitSubsidyRateApprovalProcess(String subsidyRateId, Id selectedSupervisorUserId){        
        
        if (String.isNotBlank(subsidyRateId) && String.isNotBlank(selectedSupervisorUserId)) {
            Subsidy_Rate__c subsidyRateRecord =  new Subsidy_Rate__c ();
            subsidyRateRecord.Id = subsidyRateId;
            subsidyRateRecord.Supervisor_Approval__c  = selectedSupervisorUserId;
            FieldLevelSecurity.checkFieldAccessByCriteria('Supervisor_Approval__c','update','Subsidy_Rate__c', Boolean.valueOf(Label.HasNamespace));
            update subsidyRateRecord;
            Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest(); 
            req.setComments('Subsidy Agreement Record Submit For Approval');        
            req.setObjectId(subsidyRateRecord.Id);
            Approval.ProcessResult approvalResult = Approval.process(req);
            return JSON.serialize(approvalResult);
        } else {
            return null;
        }   
         
    }

    @AuraEnabled
    public static String getActiveTab(String caseId) {

        AdoptionCaseWraper adoptionWrap  = new AdoptionCaseWraper();
        if(String.isNotBlank(caseId)) {
            FieldLevelSecurity.checkFieldAccessByCriteria('Subsidy_Agreement_Approval_Status__c', 'view', 'Case',  Boolean.valueOf(Label.HasNamespace));
            FieldLevelSecurity.checkFieldAccessByCriteria('Adoption_Case_Rate_Status__c', 'view', 'Subsidy_Rate__c',  Boolean.valueOf(Label.HasNamespace));
            FieldLevelSecurity.checkFieldAccessByCriteria('Annual_Review_Approval_Status__c', 'view', 'Annual_Review__c',  Boolean.valueOf(Label.HasNamespace));
            FieldLevelSecurity.checkFieldAccessByCriteria('Adoption_Suspension_Approval_Status__c', 'view', 'Suspension__c',  Boolean.valueOf(Label.HasNamespace));
            FieldLevelSecurity.checkFieldAccessByCriteria('Name, Casevault_PID__c, Date_of_Birth__c, Gender__c', 'view', 'Contact',  Boolean.valueOf(Label.HasNamespace));
            adoptionWrap.caseRec = [SELECT Id, Subsidy_Agreement_Approval_Status__c FROM Case WHERE Id = :caseId LIMIT :Utility.queryLimit];
            adoptionWrap.subsidyRateRecord = [SELECT Id,Adoption_Case_Rate_Status__c FROM Subsidy_Rate__c 
                                              WHERE  Adoption_Case__c = :caseId AND Adoption_Case_Rate_Status__c = 'Approved' LIMIT :Utility.queryLimit];
            adoptionWrap.annualReviewRec = [SELECT Id, Annual_Review_Approval_Status__c FROM Annual_Review__c WHERE Adoption_Case__c = :caseId AND Annual_Review_Approval_Status__c = 'Approved' LIMIT :Utility.queryLimit];
            adoptionWrap.suspensionRecordList = [SELECT Id, Adoption_Suspension_Approval_Status__c FROM Suspension__c WHERE Adoption_Case__c = :caseId AND Adoption_Suspension_Approval_Status__c = 'Approved' LIMIT :Utility.queryLimit];
            //adoptionWrap.contactRec = [SELECT Id, Name, Casevault_PID__c, Date_of_Birth__c, Gender__c FROM Contact WHERE Intake__c = :caseId AND Intake_Person_Role__c INCLUDES('Biological Child') LIMIT :Utility.queryLimit];
            
        }
        return JSON.serialize(adoptionWrap);
    }
    
    @AuraEnabled
    public static String getDecision(String caseId) {
        
        AdoptionCaseWraper adoptionWrap  = new AdoptionCaseWraper();
        if(String.isNotBlank(caseId)) {
            FieldLevelSecurity.checkFieldAccessByCriteria('Decision_Approved_DateTime__c, Status, Decision_Review_Comments__c,Decision_Approval_Status__c,Supervisor_Approver__c,'+
            'Decision_Submitted_By__c, Decision_Submitter_Role__c, Intake_Recommendations__c, Decision_Approved_By__c', 'view', 'Case',  Boolean.valueOf(Label.HasNamespace));
            FieldLevelSecurity.checkFieldAccessByCriteria('Name', 'view', 'User',  Boolean.valueOf(Label.HasNamespace));
            adoptionWrap.caseList = [SELECT Id, Decision_Approved_DateTime__c, Status, Decision_Review_Comments__c,Decision_Approval_Status__c,Supervisor_Approver__r.Name,
                                     Decision_Submitted_By__c, Decision_Submitter_Role__c, Intake_Recommendations__c, Decision_Approved_By__c
                                    FROM Case WHERE Id = :caseId AND ( Decision_Approval_Status__c = 'Approved' OR Decision_Approval_Status__c = 'Submitted') LIMIT :Utility.queryLimit];
            
        }
        return JSON.serialize(adoptionWrap);
    }
     
    @AuraEnabled
    public static String getCurrentAdoptionCaseDetails(String adoptionCaseId) {

        adoptionCaseWraper adoptionWrap = new AdoptionCaseWraper();
        if (String.isNotBlank(adoptionCaseId)) {
            FieldLevelSecurity.checkFieldAccessByCriteria('CaseNumber, RecordTypeId,Status, Decision_Approval_Status__c, Decision_Submitted_By__c, Decision_Approved_By__c, Number_of_days_created_date__c, Received_Date__c', 'view', 'Case',  Boolean.valueOf(Label.HasNamespace));
            //FieldLevelSecurity.checkFieldAccessByCriteria('Intake__c, HEAD_OF_HOUSEHOLD__c, Name, Casevault_PID__c', 'view', 'Contact',  Boolean.valueOf(Label.HasNamespace));
            adoptionWrap.caseRec = [SELECT Id, CaseNumber, RecordTypeId, RecordType.Name,  Status, Decision_Approval_Status__c, Decision_Submitted_By__c, Decision_Approved_By__c,
                                    Number_of_days_created_date__c, Received_Date__c FROM Case WHERE Id =:adoptionCaseId AND RecordType.DeveloperName = 'Adoptive_Case' LIMIT :Utility.queryLimit];
            //adoptionWrap.conList = [SELECT Id, Intake__c, HEAD_OF_HOUSEHOLD__c, Name, Casevault_PID__c FROM Contact WHERE HEAD_OF_HOUSEHOLD__c=true AND Intake__c=:adoptionCaseId LIMIT :Utility.queryLimit];
            //adoptionWrap.contactRec = [SELECT Id, Casevault_PID__c  FROM Contact WHERE Intake__c = :adoptionCaseId AND Intake_Person_Role__c INCLUDES('Biological Child') LIMIT :Utility.queryLimit];
            return JSON.serialize(adoptionWrap);
        } else {
            return null;
        }
    }
    
    @AuraEnabled
    public static ContentDocument downloadFile(String fileName) {
        
            ContentDocument doc = [SELECT Id, Title FROM ContentDocument WHERE Title = :fileName LIMIT :Utility.queryLimit];
            return doc; 
    }

    @AuraEnabled
    public static String deleteFile(String fileId) {
        
        if (String.isNotBlank(fileId)) {
            ContentDocument doc = [SELECT Id FROM ContentDocument WHERE Id = :fileId LIMIT :Utility.queryLimit];
            FieldLevelSecurity.checkObjectAccessByDelete('ContentDocument');
            delete doc;
            return 'Success';
        } else {
            return null;
        }

    }

    @AuraEnabled
    public static String editFileUpload(String base64, String filename, String fileId) {

        ContentVersion cv = new ContentVersion();
        cv.VersionData = EncodingUtil.base64Decode(base64);
        cv.Title = filename;
        cv.PathOnClient = filename;
        cv.ContentDocumentId = fileId;
        FieldLevelSecurity.checkFieldAccessByCriteria('VersionData,Title,PathOnClient,ContentDocumentId','create','ContentVersion', Boolean.valueOf(Label.HasNamespace));
        insert cv;
        return cv.Id;
    }
 
    public class AdoptionCaseWraper {
     
        @AuraEnabled
        public List<Utility.pickListWrap> adoptiveSubsidyIsPaidPicklist;
        @AuraEnabled
        public List<Utility.pickListWrap> childPlacedFromPicklist;
        @AuraEnabled
        public List<Utility.pickListWrap> childPlacedByPicklist;
        @AuraEnabled
        public List<Utility.pickListWrap> placementStructurePicklist;
        @AuraEnabled
        public List<Utility.pickListWrap> childCharPicklist;
        @AuraEnabled
        public List<Utility.pickListWrap> localDeptPicklist;
        @AuraEnabled
        public Case adoptionCaseSubsidyAgreementRec;
        @AuraEnabled
        public List<Utility.pickListWrap> primaryBasisPicklist;
        @AuraEnabled
        public List<Subsidy_Rate__c> rateRecord;
        @AuraEnabled
        public List<Annual_Review__c> annualReviewRecords;
        @AuraEnabled
        public Case caseRec;
        @AuraEnabled
        public List<Utility.pickListWrap> suspensionForReasonPickList;
        @AuraEnabled
        public List<Suspension__c> suspensionRecordList;
        @AuraEnabled
        public Suspension__c adoptionSuspensionRecord;
        @AuraEnabled
        public List<Annual_Review__c> annualReviewRec;
        @AuraEnabled
        public List<Subsidy_Rate__c> subsidyRateRecord;
        @AuraEnabled
        public List<Case> caseList;
        @AuraEnabled
        public Contact contactRec;
        @AuraEnabled
        public List<contact> conList;            
     }
 }