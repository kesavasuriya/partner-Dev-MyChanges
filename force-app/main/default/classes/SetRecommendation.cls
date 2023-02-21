public with sharing class SetRecommendation {

    @AuraEnabled
    public static String getContact(Id homeApprovalId) {
    
        if (String.isNotBlank(homeApprovalId)) {
            WrapperRecommendation workerRecommenWrapper = new WrapperRecommendation();
            
            FieldLevelSecurity.checkFieldAccessByCriteria('Family_Assessment_Verified__c, Verified_Checklist__c, Provider__c, Filled_Household__c, Application_Signed__c, At_Least_One_Home_Visit__c, Family_Assessment__c, Home_Assessment__c, Recommendations_Entered__c, Restricted_Clients_Identified__c, Motivation_Verified__c, Family_System_Verified__c, Reason__c, Provider_Name__c, Provider_Id__c, Home_Approval_Type__c, Isfilled_Clearance__c, Set_Recommendation__c', 'view', 'Home_Approval__c',  Boolean.valueOf(Label.HasNamespace));
            Home_Approval__c homeApprovalIns = [SELECT Id, Family_Assessment_Verified__c, Verified_Checklist__c, Provider__c, Filled_Household__c, Application_Signed__c, At_Least_One_Home_Visit__c, Family_Assessment__c, Home_Assessment__c, Recommendations_Entered__c, Restricted_Clients_Identified__c, Motivation_Verified__c, Family_System_Verified__c, Reason__c, Provider_Name__c, Provider_Id__c, Home_Approval_Type__c, Isfilled_Clearance__c, Set_Recommendation__c  FROM Home_Approval__c WHERE Id = :homeApprovalId LIMIT :Utility.queryLimit];
            
            FieldLevelSecurity.checkFieldAccessByCriteria('Applicant_or_Co_Applicant__c, PersonalInfo_Verified__c, Clerance_Verified__c, Background_Verified__c, Childhood_Verified__c, Adulthood_Verified__c, No_Co_Applicant__c', 'view', 'Contact',  Boolean.valueOf(Label.HasNamespace));
            List<Contact> appCoAppList = [SELECT Id, Applicant_or_Co_Applicant__c, PersonalInfo_Verified__c, Clerance_Verified__c, Background_Verified__c, Childhood_Verified__c, Adulthood_Verified__c, No_Co_Applicant__c FROM Contact WHERE Home_Approval__c = :homeApprovalId ORDER BY CreatedDate LIMIT :Utility.queryLimit]; 
             
            FieldLevelSecurity.checkFieldAccessByCriteria('Activity_Type__c', 'view', 'Assessment_Visit__c',  Boolean.valueOf(Label.HasNamespace));
            List<Assessment_Visit__c> assesmentVisitList = [SELECT Id, Activity_Type__c FROM Assessment_Visit__c WHERE Home_Approval__c = :homeApprovalId LIMIT :Utility.queryLimit];
            
            FieldLevelSecurity.checkFieldAccessByCriteria('Home_Approval__c', 'view', 'Household__c',  Boolean.valueOf(Label.HasNamespace));
            List<Household__c> householdList = [SELECT Id FROM Household__c WHERE Home_Approval__c = :homeApprovalId Limit 1];
            
            FieldLevelSecurity.checkFieldAccessByCriteria('Home_Approval__c', 'view', 'Pet__c',  Boolean.valueOf(Label.HasNamespace));
            List<Pet__c> petList = [SELECT Id FROM Pet__c WHERE Home_Approval__c = :homeApprovalId Limit 1];
            
            FieldLevelSecurity.checkFieldAccessByCriteria('Home_Approval__c', 'view', 'Child_Evaluations__c',  Boolean.valueOf(Label.HasNamespace));
            List<Child_Evaluations__c> childEvalList = [SELECT Id FROM Child_Evaluations__c WHERE Home_Approval__c = :homeApprovalId Limit 1];
            
            FieldLevelSecurity.checkFieldAccessByCriteria('Home_Approval__c', 'view', 'Reference__c',  Boolean.valueOf(Label.HasNamespace));
            List<Reference__c> referenceList = [SELECT Id FROM Reference__c WHERE Home_Approval__c = :homeApprovalId Limit 1];
            
            FieldLevelSecurity.checkFieldAccessByCriteria('Home_Approval__c', 'view', 'Backup__c',  Boolean.valueOf(Label.HasNamespace));
            List<Backup__c> backupList = [SELECT Id FROM Backup__c WHERE Home_Approval__c = :homeApprovalId Limit 1];
    
            
            for (Assessment_Visit__c assesmentVisitIns : assesmentVisitList) {
            
                if (assesmentVisitIns.Activity_Type__c == 'Application Signed') {
                    workerRecommenWrapper.applicationSigned = true;               
                } else if (assesmentVisitIns.Activity_Type__c == 'Family Assessment Completed') {
                    workerRecommenWrapper.familyAssessment = true;
                } else if (assesmentVisitIns.Activity_Type__c == 'Home Assessment Completed') {
                    workerRecommenWrapper.homeAssessment = true;
                } else if(assesmentVisitIns.Activity_Type__c == 'Recon Home Visit Performed') {
                    workerRecommenWrapper.atleastOneHomeVisit = true;
                } /*else if(assesmentVisitIns.Activity_Type__c == 'Application Received, Not Yet Assigned') {
                    workerRecommenWrapper.recommendationsEntered = true;
                }*/
            }
            
            for (Contact appCoAppIns : appCoAppList) {
            
                if (appCoAppIns.Applicant_or_Co_Applicant__c == 'Applicant') {
                    workerRecommenWrapper.personalInfoStatus = appCoAppIns.PersonalInfo_Verified__c;
                    workerRecommenWrapper.clearanceStatus = appCoAppIns.Clerance_Verified__c;
                    workerRecommenWrapper.backgroudStatus = appCoAppIns.Background_Verified__c;
                    workerRecommenWrapper.childhoodStatus = appCoAppIns.Childhood_Verified__c;
                    workerRecommenWrapper.adulthoodStatus = appCoAppIns.Adulthood_Verified__c; 
                } else if (appCoAppIns.Applicant_or_Co_Applicant__c == 'Co-Applicant') {
                    workerRecommenWrapper.co_personalInfoStatus = appCoAppIns.PersonalInfo_Verified__c;
                    workerRecommenWrapper.co_clearanceStatus = appCoAppIns.Clerance_Verified__c;
                    workerRecommenWrapper.co_backgroudStatus = appCoAppIns.Background_Verified__c;
                    workerRecommenWrapper.co_childhoodStatus = appCoAppIns.Childhood_Verified__c;
                    workerRecommenWrapper.co_adulthoodStatus = appCoAppIns.Adulthood_Verified__c;
                } 
                
                if(appCoAppIns.No_Co_Applicant__c) {                
                    workerRecommenWrapper.co_personalInfoStatus = appCoAppIns.PersonalInfo_Verified__c;
                    workerRecommenWrapper.co_clearanceStatus = appCoAppIns.Clerance_Verified__c;
                    workerRecommenWrapper.co_backgroudStatus = appCoAppIns.Background_Verified__c;
                    workerRecommenWrapper.co_childhoodStatus = appCoAppIns.Childhood_Verified__c;
                    workerRecommenWrapper.co_adulthoodStatus = appCoAppIns.Adulthood_Verified__c;
                }          
            }    
            if (householdList != null && householdList.size() > 0) {
                
                workerRecommenWrapper.householdStatus = true;
            }
            workerRecommenWrapper.clearanceTabStatus = homeApprovalIns.Isfilled_Clearance__c;
            if (petList != null && petList.size() > 0) {
                
                workerRecommenWrapper.petsStatus = true;
            }
            if (childEvalList != null && childEvalList.size() > 0) {
                
                workerRecommenWrapper.childEvaluStatus = true;
            }
            if (referenceList != null && referenceList.size() > 0) {
                
                workerRecommenWrapper.referenceStatus = true;
            }
            if (backupList != null && backupList.size() > 0) {
                
                workerRecommenWrapper.backupStatus = true;
            } 
            String providerId = homeApprovalIns.Provider__c;
            //workerRecommenWrapper.atleastOneHomeVisit = homeApprovalIns.At_Least_One_Home_Visit__c;
            workerRecommenWrapper.recommendationsEntered = true; //homeApprovalIns.Recommendations_Entered__c;
            workerRecommenWrapper.restrictedClientsIdenitify = true; //homeApprovalIns.Restricted_Clients_Identified__c;
            workerRecommenWrapper.recondetailStatus = true;
            workerRecommenWrapper.motivationStatus = homeApprovalIns.Motivation_Verified__c;
            workerRecommenWrapper.familyAsAStatus = homeApprovalIns.Family_System_Verified__c;
            workerRecommenWrapper.providerName = homeApprovalIns.Provider_Name__c;
            workerRecommenWrapper.providerId = homeApprovalIns.Provider_Id__c;
            workerRecommenWrapper.reason = homeApprovalIns.Reason__c;
            workerRecommenWrapper.homeType = homeApprovalIns.Home_Approval_Type__c;
            workerRecommenWrapper.familyAssesStatus = homeApprovalIns.Family_Assessment_Verified__c;
            workerRecommenWrapper.checklistStatus = homeApprovalIns.Verified_Checklist__c;
            workerRecommenWrapper.homeRecommendation = homeApprovalIns.Set_Recommendation__c; 
            return JSON.serialize(workerRecommenWrapper);
        } else {
            return null;
        }
    }
    
    @AuraEnabled
    public static void updateHomeApproval(String homeApprovalId, String recommendationValue) {
    	
        FieldLevelSecurity.checkFieldAccessByCriteria('Set_Recommendation__c', 'update', 'Home_Approval__c',  Boolean.valueOf(Label.HasNamespace));
        if (String.isNotBlank(homeApprovalId)) {
            Home_Approval__c updateHomeApprovalIns = new Home_Approval__c();
            updateHomeApprovalIns.Id = homeApprovalId;
            updateHomeApprovalIns.Set_Recommendation__c = recommendationValue;
            update updateHomeApprovalIns;
        }
    }
    
    public class WrapperRecommendation {
    
        String providerName;
        String providerId;
        String homeType;
        String homeRecommendation;
        String reason;
        Boolean applicationSigned;
        Boolean homeAssessment;
        Boolean familyAssessment;
        Boolean atleastOneHomeVisit;
        Boolean recommendationsEntered;
        Boolean restrictedClientsIdenitify;
        Boolean personalInfoStatus;
        Boolean clearanceStatus;
        Boolean backgroudStatus;
        Boolean childhoodStatus;
        Boolean adulthoodStatus;
        Boolean co_personalInfoStatus;
        Boolean co_clearanceStatus;
        Boolean co_backgroudStatus;
        Boolean co_childhoodStatus;
        Boolean co_adulthoodStatus;
        Boolean householdStatus;
        Boolean clearanceTabStatus;
        Boolean petsStatus;
        Boolean motivationStatus;
        Boolean childEvaluStatus;
        Boolean familyAsAStatus;
        Boolean referenceStatus;
        Boolean backupStatus;
        Boolean checklistStatus;
        Boolean familyAssesStatus;
        Boolean recondetailStatus;
        public WrapperRecommendation() {
            applicationSigned = false;
            homeAssessment = false;
            familyAssessment = false;
            atleastOneHomeVisit = false;    
            recommendationsEntered = false;
            restrictedClientsIdenitify = false;
            personalInfoStatus = false;
            clearanceStatus = false;
            backgroudStatus = false;
            childhoodStatus = false;
            adulthoodStatus = false;
            co_personalInfoStatus = false;
            co_clearanceStatus = false;
            co_backgroudStatus = false;
            co_childhoodStatus = false;
            co_adulthoodStatus = false;
        }
    }
}