public with sharing class PermanacyPlanProceedController {

    @AuraEnabled
    public static Suspension__c deleteSuspensionRec(String suspensionJSONRec) {
    
        if (String.isNotBlank(suspensionJSONRec)) {
        
            Suspension__c deletesuspensionRec = (Suspension__c) JSON.deserialize(suspensionJSONRec, Suspension__c.class);
            FieldLevelSecurity.checkObjectAccessByDelete('Suspension__c');
            delete deletesuspensionRec;
            return deletesuspensionRec;
        } else {
            return null;
        }
    }
    
    @AuraEnabled
    public static String getApplicationInitialInformation(String permanencyPlanId) {
    
        GetInitialWrapper initWrap = new GetInitialWrapper();
        if (String.isNotBlank(permanencyPlanId)) {
                    
            List<String> permanencyPlanFields = new List<String>{'Id', 'Placement__c', 'Placement__r.Provider_Type__c', 'Placement__r.CPA_Home_Id__c', 'Placement__r.Provider__c',
                                                                'Placement__r.Provider__r.Casevault_ProID__c', 'Placement__r.Provider__r.BillingStreet', 'Placement__r.Provider__r.BillingCity',
                                                                'Placement__r.Provider__r.BillingState', 'Placement__r.Provider__r.BillingPostalCode',
                                                                'Placement__r.Provider__r.BillingCountry', 'Guardian_One_Name__c', 'Guardian_Two_Name__c',
                                                                'Guardian_One_SSN__c', 'Guardian_Two_SSN__c', 'Primary_Guardian_Relationship__c', 
                                                                'Guardian_Two_DOB__c', 'Guardian_One_DOB__c', 'Secondary_Guardian_Relationship__c', 'Guardianship_Planing__c'};
           
		    String permanencyPlanCondition = 'Id = \''+ String.escapeSingleQuotes(permanencyPlanId) +'\' AND Placement__c!= null AND Placement__r.Provider__c != null';
            List<SObject> permanencyPlansObjList = DataService.performQueryOperation(permanencyPlanFields, 'Permanency_Plan__c', permanencyPlanCondition, Utility.queryLimit);
            initWrap.permanencyPlanRecord = new Permanency_Plan__c();
            
            if(permanencyPlansObjList != null && permanencyPlansObjList.size() > 0) {
                initWrap.permanencyPlanRecord = (Permanency_Plan__c)permanencyPlansObjList[0];
            }
                    
            if(initWrap.permanencyPlanRecord != null && (initWrap.permanencyPlanRecord.Placement__r.Provider_Type__c == 'Public_Provider' || initWrap.permanencyPlanRecord.Placement__r.Provider_Type__c == '')) {
                
                List<String>  contactFields = new List<String>{'Id', 'Name', 'Date_of_Birth__c', 'SSN__c', 'Applicant_or_Co_Applicant__c','No_Co_Applicant__c'};
                String contactCondition = 'AccountId = \''+ String.escapeSingleQuotes(initWrap.permanencyPlanRecord.Placement__r.Provider__c) +'\'';
                List<SObject> contactsObjList = DataService.performQueryOperation(contactFields, 'Contact', contactCondition, Utility.queryLimit);
                initWrap.applicantCoApplList = (List<Contact>)contactsObjList;
            } else {   
                                       
                if(initWrap.permanencyPlanRecord != null && String.isNotBlank(initWrap.permanencyPlanRecord.Placement__r.CPA_Home_Id__c)) {
                
                    List<String>  contactFields = new List<String>{'Id', 'Name', 'Date_of_Birth__c', 'SSN__c', 'Applicant_or_Co_Applicant__c','No_Co_Applicant__c'};
                    String contactCondition = 'AccountId = \''+ String.escapeSingleQuotes(initWrap.permanencyPlanRecord.Placement__r.Provider__c) +'\'';
                    List<SObject> contactsObjList = DataService.performQueryOperation(contactFields, 'Contact', contactCondition, Utility.queryLimit);
                    initWrap.applicantCoApplList = (List<Contact>)contactsObjList;    
                    List<String>  accountFields = new List<String>{'Id','Casevault_ProID__c', 'BillingStreet', 'BillingCity', 'BillingState', 'BillingPostalCode', 'BillingCountry'};
                    String accountCondition = 'Id = \''+ String.escapeSingleQuotes(initWrap.permanencyPlanRecord.Placement__r.CPA_home_Id__c) +'\'';
                    List<SObject> accountsObjList = DataService.performQueryOperation(accountFields, 'Account', accountCondition, Utility.queryLimit);
                    
                    if(accountsObjList != null && accountsObjList.size() > 0) {
                        initWrap.cpaProviderId = (Account)accountsObjList[0];
                    }
                }
            }
        }                        
        return JSON.serialize(initWrap);
    }
    
    @AuraEnabled
    public static String getAgreementInitialInformation(String permanencyPlanId) {
    
        GetInitialWrapper initWrap = new GetInitialWrapper();
        initWrap.rateTypePicklist = Utility.getPicklistinfo('Rate__c','Rate_Type__c',false);
        
        if(String.isNotBlank(permanencyPlanId)) {
            
            List<String> permanencyPlanFields = new List<String>{'Id', 'Placement__r.Provider__c','Placement__r.End_Date__c', 'Placement__r.Provider__r.Casevault_ProID__c', 'Guardian_One_Name__c', 'Guardian_Two_Name__c', 'Primary_Guardian_Relationship__c', 'Secondary_Guardian_Relationship__c', 'Guardianship_Planing__c', 'Agreement_Start_Date__c', 'Placement__r.Provider_Type__c', 'Placement__r.CPA_Home_Id__c', 'All_Placements_and_Removal_have_been_End__c'};
           
		    String permanencyPlanCondition = 'Id = \''+ String.escapeSingleQuotes(permanencyPlanId) +'\'AND Placement__c!= null AND Placement__r.Provider__c != null';
            List<SObject> permanencyPlansObjList = DataService.performQueryOperation(permanencyPlanFields, 'Permanency_Plan__c', permanencyPlanCondition, Utility.queryLimit);
            if (permanencyPlansObjList != null && permanencyPlansObjList.size() > 0) {
                initWrap.permanencyPlanRecord = (Permanency_Plan__c)permanencyPlansObjList[0];
            }

            List<String> rateFields = new List<String>{'Id', 'Provider_Id__c', 'Rate_Type__c', 'Rate_Begin_Date__c', 'Rate_End_Date__c', 'Rate_Approval_Date__c', 
                                                        'Negotiated_Amount__c', 'Negotiated_Date__c', 'Notes__c', 'Is_Child_receiving_TCA__c','Permanency_Plan__c',
                                                        'TCA_Amount__c', 'Has_notification_been_sent_to_TCA__c', 'Child_support_has_been_notified__c', 'Approval_Status__c'};
           
		    String rateCondition = 'Permanency_Plan__c = \''+ String.escapeSingleQuotes(permanencyPlanId) +'\'ORDER BY LastModifiedDate DESC';
            List<SObject> ratesObjList = DataService.performQueryOperation(rateFields, 'Rate__c', rateCondition, Utility.queryLimit);
            initWrap.rateRecList = (List<Rate__c>)ratesObjList;
            rateCondition = 'Permanency_Plan__c = \''+ String.escapeSingleQuotes(permanencyPlanId)+'\'' +'AND Approval_Status__c !='+'\''+'Approved\''+' ORDER BY LastModifiedDate DESC';
            ratesObjList = DataService.performQueryOperation(rateFields, 'Rate__c', rateCondition, Utility.queryLimit);
            initWrap.existingRateRec = (List<Rate__c>)ratesObjList;
           
            if(initWrap.permanencyPlanRecord != null && (initWrap.permanencyPlanRecord.Placement__r.Provider_Type__c == 'Public_Provider' || initWrap.permanencyPlanRecord.Placement__r.Provider_Type__c == '')){
                
                List<String>  contactFields = new List<String>{'Id', 'Name', 'Date_of_Birth__c', 'SSN__c', 'Applicant_or_Co_Applicant__c','No_Co_Applicant__c'};
                String contactCondition = 'AccountId = \''+ String.escapeSingleQuotes(initWrap.permanencyPlanRecord.Placement__r.Provider__c) +'\'';
                List<SObject> contactsObjList = DataService.performQueryOperation(contactFields, 'Contact', contactCondition, Utility.queryLimit);
                initWrap.applicantCoApplList = (List<Contact>)contactsObjList;
                
            } else {                          
            
                if(initWrap.permanencyPlanRecord != null && String.isNotBlank(initWrap.permanencyPlanRecord.Placement__r.CPA_Home_Id__c)) {

                    List<String>  contactFields = new List<String>{'Id', 'Name', 'Date_of_Birth__c', 'SSN__c', 'Applicant_or_Co_Applicant__c','No_Co_Applicant__c'};
                    String contactCondition = 'AccountId = \''+ String.escapeSingleQuotes(initWrap.permanencyPlanRecord.Placement__r.Provider__c) +'\'';
                    List<SObject> contactsObjList = DataService.performQueryOperation(contactFields, 'Contact', contactCondition, Utility.queryLimit);
                    initWrap.applicantCoApplList = (List<Contact>)contactsObjList;
                    List<String>  accountFields = new List<String>{'Id','Casevault_ProID__c', 'BillingStreet', 'BillingCity', 'BillingState', 'BillingPostalCode', 'BillingCountry'};
                    String accountCondition = 'Id = \''+ String.escapeSingleQuotes(initWrap.permanencyPlanRecord.Placement__r.CPA_home_Id__c) +'\'';
                    List<SObject> accountsObjList = DataService.performQueryOperation(accountFields, 'Account', accountCondition, Utility.queryLimit);
                    
                    if(accountsObjList != null && accountsObjList.size() > 0) {
                        initWrap.cpaProviderId = (Account)accountsObjList[0];
                    }
                }    
            }
        }     
        return JSON.serialize(initWrap);
    }
    
    @AuraEnabled
    public static String getAnnuvalReviewsInitialInformation(String permanencyPlanId) {
    
        GetInitialWrapper initWrap = new GetInitialWrapper();
        
        if(String.isNotBlank(permanencyPlanId)) {

            List<String>  annualReviewsFields = new List<String>{'Id', 'Review_Date__c', 'Approval_Status__c'};
            String annualReviewsCondition='';
            annualReviewsCondition += 'Permanency_Plan__c = \''+ String.escapeSingleQuotes(permanencyPlanId) +'\'';
            List<SObject> annualReviewssObjList = DataService.performQueryOperation(annualReviewsFields, 'Annual_Review__c', annualReviewsCondition, Utility.queryLimit);
            initWrap.annualReviewsList = (List<Annual_Review__c>)annualReviewssObjList;
            annualReviewsFields =  new List<String>{'Id', 'Review_Date__c', 'Guardian_is_legally_responsible__c', 'Guardian_provides_financial_support__c', 'Child_currently_resides_with_guardian__c', 'Child_is_currently_attending_school__c', 'Is_the_requried_document__c', 'Will_the_child_reach_18th_birthday__c', 'Child_has_a_mental_or_physical__c', 'Child_is_enrolled_in_educational__c', 'Child_is_participating_in_a_program__c', 'Provide_a_field_to_indicate__c', 'Completed__c', 'Primary_Caregiver_Sign_Date__c', 'Secondary_Caregiver_Sign_Date__c', 'Director_Sign_Date__c', 
                                                    'Approval_Status__c'};
            annualReviewsCondition = 'Permanency_Plan__c = \''+ String.escapeSingleQuotes(permanencyPlanId) +'\' AND  Approval_Status__c !='+'\''+'Approved\''+' ORDER BY LastModifiedDate DESC';
            annualReviewssObjList = DataService.performQueryOperation(annualReviewsFields, 'Annual_Review__c', annualReviewsCondition, Utility.queryLimit);
            initWrap.existingAnnualReviewRec = (List<Annual_Review__c>)annualReviewssObjList;
        }
        return JSON.serialize(initWrap);
    }
    
    @AuraEnabled
    public static String getSuspensionInitialInformation(String permanencyPlanId) {
    
        GetInitialWrapper initWrap = new GetInitialWrapper();
        initWrap.suspensionReasonPicklist = Utility.getPicklistinfo('Suspension__c','Suspension_Reason__c',false);
        
        if(String.isNotBlank(permanencyPlanId)) {
        
            List<String>  suspensionFields = new List<String>{'Suspension_Reason__c', 'Start_Date__c', 'End_Date__c', 'Notes__c', 'Permanency_Plan__c', 'Approval_Status__c'};
            String suspensionCondition='';
            suspensionCondition += 'Permanency_Plan__c = \''+ String.escapeSingleQuotes(permanencyPlanId) +'\' ORDER By CreatedDate DESC';
            List<SObject>suspensionsObjList = DataService.performQueryOperation(suspensionFields, 'Suspension__c', suspensionCondition, Utility.queryLimit);
            initWrap.suspensionList = (List<Suspension__c>)suspensionsObjList;
            suspensionCondition = 'Permanency_Plan__c = \''+ String.escapeSingleQuotes(permanencyPlanId) +'\' AND  Approval_Status__c !='+'\''+'Approved\''+'ORDER BY LastModifiedDate DESC';
            suspensionsObjList = DataService.performQueryOperation(suspensionFields, 'Suspension__c', suspensionCondition, Utility.queryLimit);
            
            if(suspensionsObjList != null && suspensionsObjList.size() > 0) {
                initWrap.existingSuspensionRec = (List<Suspension__c>)suspensionsObjList;
            }
        }               
        return JSON.serialize(initWrap);
    }
    
    @AuraEnabled
    public static String addRateAnnualRec(String permanencyPlanId) {
    
        if(String.isNotBlank(permanencyPlanId)) {
          
            RateAnnualWrapper rateAnnualWrapperIns = new RateAnnualWrapper();
            List<String>  rateFields = new List<String>{'Id', 'Rate_Type__c', 'Rate_Begin_Date__c', 'Rate_End_Date__c', 'Rate_Approval_Date__c', 'Approval_Status__c'};
            String rateCondition = 'Permanency_Plan__c = \''+ String.escapeSingleQuotes(permanencyPlanId) +'\' ORDER By LastmodifiedDate DESC';
            List<SObject> ratesObjList = DataService.performQueryOperation(rateFields, 'Rate__c', rateCondition, Utility.queryLimit);
                rateAnnualWrapperIns.rateRec = (List<Rate__c>)ratesObjList;
             Date rateEndDate;
            
             if(ratesObjList != null && ratesObjList.size()>0) {
                rateEndDate = rateAnnualWrapperIns.rateRec[0].Rate_End_Date__c;
            }
             
            if(rateAnnualWrapperIns.rateRec != null && rateAnnualWrapperIns.rateRec.size() > 0 ) {
            
                List<String>  annualReviewsFields = new List<String>{'Id', 'Review_Date__c', 'Approval_Status__c'};
                String annualReviewsCondition='';
                annualReviewsCondition = 'Permanency_Plan__c = \''+ String.escapeSingleQuotes(permanencyPlanId) +'\' AND Review_Date__c='+String.valueOf(rateEndDate)+' ORDER By LastmodifiedDate DESC';   
                List<SObject> annualReviewssObjList = DataService.performQueryOperation(annualReviewsFields, 'Annual_Review__c', annualReviewsCondition, Utility.queryLimit);
                rateAnnualWrapperIns.annualReviewRec = (List<Annual_Review__c>)annualReviewssObjList;
            }
            return JSON.serialize(rateAnnualWrapperIns);
        } else {
            return null;
        }
    }
    
    @AuraEnabled
    public static String addSuspensionRec(String permanencyPlanId) {
    
        if(String.isNotBlank(permanencyPlanId)) {
        
            List<Suspension__c> exstingSuspensionRec = new List<Suspension__c>();
            List<String>  suspensionFields = new List<String>{'Id', 'End_Date__c', 'Suspension_Reason__c', 'Start_Date__c', 'Notes__c', 'Permanency_Plan__c', 'Name', 'Approval_Status__c'};
            String suspensionCondition = 'Permanency_Plan__c = \''+ String.escapeSingleQuotes(permanencyPlanId) +'\' ORDER By CreatedDate DESC';
            List<SObject> suspensionsObjList = DataService.performQueryOperation(suspensionFields, 'Suspension__c', suspensionCondition, Utility.queryLimit);
            exstingSuspensionRec = (List<Suspension__c>)suspensionsObjList;
            
        return JSON.serialize(exstingSuspensionRec);
        } else {
            return null;
        }
    }
    
    @AuraEnabled
    public static String upsertSuspension(String suspensionDataJSON) {
    
        if(String.isNotBlank(suspensionDataJSON)) {
        
            Suspension__c createuspensionRec = (Suspension__c) JSON.deserialize(suspensionDataJSON, Suspension__c.class);
            Set<String> suspensionDmlFieldSet = createuspensionRec.getPopulatedFieldsAsMap().keySet();
            if(String.isBlank(createuspensionRec.Id)) {
            
                //FieldLevelSecurity.checkFieldAccessByCriteria(suspensionDmlFieldSet, 'create', 'Suspension__c');
                insert createuspensionRec;
            } else {
            
                //FieldLevelSecurity.checkFieldAccessByCriteria(suspensionDmlFieldSet, 'update', 'Suspension__c');
                update createuspensionRec;
            }
            return createuspensionRec.Id;
        } else {
            return null;
        }        
    }
    
    @AuraEnabled
    public static String upsertRate(String rateDataJSON) {
        
        if(String.isNotBlank(rateDataJSON)) {
            Rate__c createRateRec = (Rate__c) JSON.deserialize(rateDataJSON , Rate__c.class);
            Set<String> rateDmlFieldSet = createRateRec.getPopulatedFieldsAsMap().keySet();   
            if(String.isBlank(createRateRec.Id)) {
                //FieldLevelSecurity.checkFieldAccessByCriteria(rateDmlFieldSet, 'create', 'Rate__c');
                insert createRateRec;
            } else {
                //FieldLevelSecurity.checkFieldAccessByCriteria(rateDmlFieldSet, 'update', 'Rate__c');
                update createRateRec;    
            }
            return createRateRec.Id;
            } else {
                return null;
        }
    }

    public Boolean checkUserProfile() {

        Id profileId = UserInfo.getProfileId();
        String profileName = '';
        List<String> profileFields = new List<String>{'Id', 'Name'};
        String profileCondition = 'Id = \''+ String.escapeSingleQuotes(profileId) +'\'';
        List<SObject> profilesObjList = DataService.performQueryOperation(profileFields, 'Profile', profileCondition, Utility.queryLimit);
        if(profilesObjList != null && profilesObjList.size() > 0) {
            profileName = ((Profile)profilesObjList[0]).Name;
        }
        if(profileName == 'Casevault Supervisor') {
            return false;
        } else {
            return true;
        }
    }

    public class GetInitialWrapper {

        @AuraEnabled
        public List<Utility.pickListWrap> suspensionReasonPicklist;
        @AuraEnabled
        public List<Utility.pickListWrap> rateTypePicklist;
        @AuraEnabled
        public Permanency_Plan__c permanencyPlanRecord;
        @AuraEnabled
        public List<Rate__c> rateRecList;
        @AuraEnabled
        public List<Rate__c> existingRateRec;
        @AuraEnabled
        public List<Annual_Review__c> annualReviewsList;
        @AuraEnabled
        public List<Annual_Review__c> existingAnnualReviewRec;
        @AuraEnabled
        public List<Contact> applicantCoApplList;
        @AuraEnabled
        public Account cpaProviderId;
        @AuraEnabled
        public List<Suspension__c> suspensionList;
        @AuraEnabled
        public List<Suspension__c> existingSuspensionRec;
     }
    
     public class RateAnnualWrapper {
         
        @AuraEnabled
        public List<Rate__c> rateRec;
        @AuraEnabled
        public List<Annual_Review__c> annualReviewRec;
        
        public RateAnnualWrapper() {
        
          rateRec = new List<Rate__c> ();
          annualReviewRec = new List<Annual_Review__c>();
        }
    }

}