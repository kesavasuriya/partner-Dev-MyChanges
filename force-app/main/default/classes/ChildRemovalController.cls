public with sharing class ChildRemovalController {

    @AuraEnabled
    public static String getInitialInfo(Id childRemovalId) {
   
       GetInitialWrapper initWrap = new GetInitialWrapper();
       
       FieldLevelSecurity.checkFieldAccessByCriteria('Does_the_person_have_disabilities__c, Autism_Spectrum_Disorder__c, Cognitive_Developmental_Delay__c, Emotionally_Disturbed__c, Hearing_Disability__c, Intellectual_Disability__c, Other_Disability__c, Physical_Disability__c, Visual_Disability__c, Autism_Comments__c, Autism_Diagnosed_Diability__c, Autism_End_Resolution_Date__c, Autism_Evaluation_Date__c, Autism_Evaluator_Clinician_Name__c, Autism_Personal_Hygiene__c, Autism_Special_Needs__c, Autism_Start_Diagnosis_Date__c,'+
       'Cognitive_Comments__c, Cognitive_Diagnosed_Diability__c, Cognitive_End_Resolution_Date__c, Cognitive_Evaluation_Date__c, Cognitive_Evaluator_Clinician_Name__c, Cognitive_Personal_Hygiene__c, Cognitive_Special_Needs__c, Cognitive_Start_Diagnosis_Date__c,'+
       'Emotionally_Comments__c, Emotionally_Diagnosed_Diability__c, Emotionally_End_Resolution_Date__c, Emotionally_Evaluation_Date__c, Emotionally_Evaluator_Clinician_Name__c, Emotionally_Personal_Hygiene__c, Emotionally_Special_Needs__c, Emotionally_Start_Diagnosis_Date__c,'+
       'Hearing_Comments__c, Hearing_Diagnosed_Diability__c, Hearing_End_Resolution_Date__c, Hearing_Evaluation_Date__c, Hearing_Evaluator_Clinician_Name__c, Hearing_Personal_Hygiene__c, Hearing_Special_Needs__c, Hearing_Star_Diagnosis_Date__c,'+
       'Intellectual_Comments__c, Intellectual_Diagnosed_Diability__c, Intellectual_End_Resolution_Date__c, Intellectual_Evaluation_Date__c, Intellectual_Evaluator_Clinician_Name__c, Intellectual_Special_Needs__c, Personal_Hygiene__c, Intellectual_Start_Diagnosis_Date__c,'+
       'Other_Comments__c, Other_Diagnosed_Diability__c, Other_End_Resolution_Date__c, Other_Evaluation_Date__c, Other_Evaluator_Clinician_Name__c, Other_Personal_Hygiene__c, Other_Special_Needs__c, Other_Start_Diagnosis_Date__c,'+
       'Physical_Comments__c, Physical_Diagnosed_Diability__c, Physical_End_Resolution_Date__c, Physical_Evaluation_Date__c, Physical_Evaluator_Clinician_Name__c, Physical_Personal_Hygiene__c, Physical_Special_Needs__c, Physical_Start_Diagnosis_Date__c,'+
       'Visual_Comments__c, Visual_Diagnosed_Diability__c, Visual_End_Resolution_Date__c, Visual_Evaluation_Date__c, Visual_Evaluator_Clinician_Name__c, Visual_Personal_Hygiene__c, Visual_Special_Needs__c, Visual_Start_Diagnosis_Date__c','view','Child_Removal__c', Boolean.valueOf(Label.HasNamespace));
       
       /*initWrap.childRemovalRecord = [SELECT Id, Does_the_person_have_disabilities__c, Autism_Spectrum_Disorder__c, Cognitive_Developmental_Delay__c, Emotionally_Disturbed__c, Hearing_Disability__c, Intellectual_Disability__c, Other_Disability__c, Physical_Disability__c, Visual_Disability__c, Autism_Comments__c, Autism_Diagnosed_Diability__c, Autism_End_Resolution_Date__c, Autism_Evaluation_Date__c, Autism_Evaluator_Clinician_Name__c, Autism_Personal_Hygiene__c, Autism_Special_Needs__c, Autism_Start_Diagnosis_Date__c,
                Cognitive_Comments__c, Cognitive_Diagnosed_Diability__c, Cognitive_End_Resolution_Date__c, Cognitive_Evaluation_Date__c, Cognitive_Evaluator_Clinician_Name__c, Cognitive_Personal_Hygiene__c, Cognitive_Special_Needs__c, Cognitive_Start_Diagnosis_Date__c,
                Emotionally_Comments__c, Emotionally_Diagnosed_Diability__c, Emotionally_End_Resolution_Date__c, Emotionally_Evaluation_Date__c, Emotionally_Evaluator_Clinician_Name__c, Emotionally_Personal_Hygiene__c, Emotionally_Special_Needs__c, Emotionally_Start_Diagnosis_Date__c,
                Hearing_Comments__c, Hearing_Diagnosed_Diability__c, Hearing_End_Resolution_Date__c, Hearing_Evaluation_Date__c, Hearing_Evaluator_Clinician_Name__c, Hearing_Personal_Hygiene__c, Hearing_Special_Needs__c, Hearing_Star_Diagnosis_Date__c,
                Intellectual_Comments__c, Intellectual_Diagnosed_Diability__c, Intellectual_End_Resolution_Date__c, Intellectual_Evaluation_Date__c, Intellectual_Evaluator_Clinician_Name__c, Intellectual_Special_Needs__c, Personal_Hygiene__c, Intellectual_Start_Diagnosis_Date__c,
                Other_Comments__c, Other_Diagnosed_Diability__c, Other_End_Resolution_Date__c, Other_Evaluation_Date__c, Other_Evaluator_Clinician_Name__c, Other_Personal_Hygiene__c, Other_Special_Needs__c, Other_Start_Diagnosis_Date__c,
                Physical_Comments__c, Physical_Diagnosed_Diability__c, Physical_End_Resolution_Date__c, Physical_Evaluation_Date__c, Physical_Evaluator_Clinician_Name__c, Physical_Personal_Hygiene__c, Physical_Special_Needs__c, Physical_Start_Diagnosis_Date__c,
                Visual_Comments__c, Visual_Diagnosed_Diability__c, Visual_End_Resolution_Date__c, Visual_Evaluation_Date__c, Visual_Evaluator_Clinician_Name__c, Visual_Personal_Hygiene__c, Visual_Special_Needs__c, Visual_Start_Diagnosis_Date__c FROM Child_Removal__c 
                                      WHERE Id = :childRemovalId LIMIT 1];*/
       initWrap.personalHygienePicklist = Utility.getPicklistinfo('Child_Removal__c','Autism_Personal_Hygiene__c',false);
       initWrap.specialNeedsPicklist = Utility.getPicklistinfo('Child_Removal__c','Autism_Special_Needs__c',false);
       return JSON.serialize(initWrap);
    }
     
    @AuraEnabled
    public static void updateChildRemoval(String updatingChildRemovalIns) {
    
        if (String.isNotBlank(updatingChildRemovalIns)) {
            Child_Removal__c updatingRemovalRec = (Child_Removal__c)System.JSON.deserialize(updatingChildRemovalIns, Child_Removal__c.class);
            FieldLevelSecurity.checkFieldAccessByCriteria('Does_the_person_have_disabilities__c, Autism_Spectrum_Disorder__c, Cognitive_Developmental_Delay__c, Emotionally_Disturbed__c, Hearing_Disability__c, Intellectual_Disability__c, Other_Disability__c, Physical_Disability__c, Visual_Disability__c, Autism_Comments__c, Autism_Diagnosed_Diability__c, Autism_End_Resolution_Date__c, Autism_Evaluation_Date__c, Autism_Evaluator_Clinician_Name__c, Autism_Personal_Hygiene__c, Autism_Special_Needs__c, Autism_Start_Diagnosis_Date__c,'+
                                                            'Cognitive_Comments__c, Cognitive_Diagnosed_Diability__c, Cognitive_End_Resolution_Date__c, Cognitive_Evaluation_Date__c, Cognitive_Evaluator_Clinician_Name__c, Cognitive_Personal_Hygiene__c, Cognitive_Special_Needs__c, Cognitive_Start_Diagnosis_Date__c,'+
                                                            'Emotionally_Comments__c, Emotionally_Diagnosed_Diability__c, Emotionally_End_Resolution_Date__c, Emotionally_Evaluation_Date__c, Emotionally_Evaluator_Clinician_Name__c, Emotionally_Personal_Hygiene__c, Emotionally_Special_Needs__c, Emotionally_Start_Diagnosis_Date__c,'+
                                                            'Hearing_Comments__c, Hearing_Diagnosed_Diability__c, Hearing_End_Resolution_Date__c, Hearing_Evaluation_Date__c, Hearing_Evaluator_Clinician_Name__c, Hearing_Personal_Hygiene__c, Hearing_Special_Needs__c, Hearing_Star_Diagnosis_Date__c,'+
                                                            'Intellectual_Comments__c, Intellectual_Diagnosed_Diability__c, Intellectual_End_Resolution_Date__c, Intellectual_Evaluation_Date__c, Intellectual_Evaluator_Clinician_Name__c, Intellectual_Special_Needs__c, Personal_Hygiene__c, Intellectual_Start_Diagnosis_Date__c,'+
                                                            'Other_Comments__c, Other_Diagnosed_Diability__c, Other_End_Resolution_Date__c, Other_Evaluation_Date__c, Other_Evaluator_Clinician_Name__c, Other_Personal_Hygiene__c, Other_Special_Needs__c, Other_Start_Diagnosis_Date__c,'+
                                                            'Physical_Comments__c, Physical_Diagnosed_Diability__c, Physical_End_Resolution_Date__c, Physical_Evaluation_Date__c, Physical_Evaluator_Clinician_Name__c, Physical_Personal_Hygiene__c, Physical_Special_Needs__c, Physical_Start_Diagnosis_Date__c,'+
                                                            'Visual_Comments__c, Visual_Diagnosed_Diability__c, Visual_End_Resolution_Date__c, Visual_Evaluation_Date__c, Visual_Evaluator_Clinician_Name__c, Visual_Personal_Hygiene__c, Visual_Special_Needs__c, Visual_Start_Diagnosis_Date__c','update','Child_Removal__c', Boolean.valueOf(Label.HasNamespace));
            update updatingRemovalRec;
        }         
    }
      
    public class GetInitialWrapper { 
    
        @AuraEnabled
        public Child_Removal__c childRemovalRecord;
        @AuraEnabled
        public List<Utility.pickListWrap> personalHygienePicklist;
        @AuraEnabled
        public List<Utility.pickListWrap> specialNeedsPicklist;
    }    
    
}