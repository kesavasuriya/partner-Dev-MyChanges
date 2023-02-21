public with sharing class InvestigationFindingsController {
    
    @AuraEnabled
    public static String fetchInformation(Id investigationId) {
        
        getInitialWrapper initWrap = new getInitialWrapper();
        if (String.isNotBlank(investigationId)) {
            
            FieldLevelSecurity.checkFieldAccessByCriteria('Name,accordionLabel__c, Abuse_Types__c, Sibling_s_Explanation__c, Relevant_Criminal_History__c, Physician_or_other_medical_Assessment_s__c, Parent_Legal_Guardian_s_Explanation__c, Other_Professional_or_Expert_Assessments__c, Law_Enforcement_Involvement__c, Findings__c, Condition_of_the_Home__c, Collateral_Interviews_CPS_Interview__c, Alleged_Victim_s_Explanation__c,'+ 
                                                          'Alleged_Maltreator_s_Explanation__c, Contact__c,A_Physical_injury__c,The_injury_was_caused__c,Alleged_Maltreator__c,Victim_Name__c,The_victim_was_a_child__c,Relationship_to_Maltreator__c,Harm_to_a_child__c,During_the_incident__c,The_injury_was_not_caused_by_accidental__c,Contributing_factor_in_the_family__c ','view','Investigation_Findings__c', Boolean.valueOf(Label.HasNamespace));
            FieldLevelSecurity.checkFieldAccessByCriteria(' Name','view','Contact', Boolean.valueOf(Label.HasNamespace));
            initWrap.investigationFindingsList = [SELECT Id, Name, accordionLabel__c, Abuse_Types__c, Sibling_s_Explanation__c, Relevant_Criminal_History__c, Physician_or_other_medical_Assessment_s__c, Parent_Legal_Guardian_s_Explanation__c, Other_Professional_or_Expert_Assessments__c, Law_Enforcement_Involvement__c, Findings__c, Condition_of_the_Home__c, Collateral_Interviews_CPS_Interview__c,
                                                  Alleged_Victim_s_Explanation__c, Alleged_Maltreator_s_Explanation__c, Contact__r.Name,A_Physical_injury__c,The_injury_was_caused__c,The_victim_was_a_child__c,
                                                  Harm_to_a_child__c,During_the_incident__c,The_injury_was_not_caused_by_accidental__c, Alleged_Maltreators__c,Contact__c,Alleged_Maltreators__r.Name,
                                                  Relationship_to_Maltreator__c, Contributing_factor_in_the_family__c   FROM Investigation_Findings__c WHERE Investigation__c = :investigationId LIMIT :Utility.queryLimit];
            //String Alleged_Maltreator;
            //String Alleged_Victim;
            List<String> investigationFindingsVictims = new List<String>();
            List<String> investigationFindingsMaltreators = new List<String>();
            for(Investigation_Findings__c investigationFindingsRecord : initWrap.investigationFindingsList) {
                if(investigationFindingsRecord.Contact__c != null) {
                    investigationFindingsVictims.add(investigationFindingsRecord.Contact__c);
                }
                if(investigationFindingsRecord.Alleged_Maltreators__c != null){
                    investigationFindingsMaltreators.add(investigationFindingsRecord.Alleged_Maltreators__c);
                }
            }
            /*if(initWrap.investigationFindingsList.size() > 0) {
                Alleged_Maltreator =  initWrap.investigationFindingsList[0].Alleged_Maltreators__c;
                Alleged_Victim = initWrap.investigationFindingsList[0].Contact__c;
                initWrap.allegedMaltreator = initWrap.investigationFindingsList[0].Alleged_Maltreators__r.Name;
                initWrap.allegedVictim = initWrap.investigationFindingsList[0].Contact__r.Name;
            }*/
            FieldLevelSecurity.checkFieldAccessByCriteria('Relationship_Values__c, Person__c, Person_Related_To__c','view','Relationship__c', Boolean.valueOf(Label.HasNamespace));
            initWrap.relationshipValues = new List<String>();
            //List<Relationship__c> relationshipName = [SELECT Id, Relationship_Values__c FROM Relationship__c WHERE Person__c =: Alleged_Victim AND Person_Related_To__c =: Alleged_Maltreator LIMIT :Utility.queryLimit];
            List<Relationship__c> relationshipRecords = [SELECT Id, Relationship_Values__c,Person__c,Person_Related_To__c FROM Relationship__c WHERE Person__c IN  :investigationFindingsVictims AND Person_Related_To__c IN :investigationFindingsMaltreators LIMIT :Utility.queryLimit];
            for(Investigation_Findings__c investigationFindingsRecord : initWrap.investigationFindingsList){
                String relationshipValue = 'Unknown';
                for(Relationship__c relationshipRecord : relationshipRecords) {
                    if(relationshipRecord.Person__c == investigationFindingsRecord.Contact__c && relationshipRecord.Person_Related_To__c == investigationFindingsRecord.Alleged_Maltreators__c) {
                        relationshipValue = relationshipRecord.Relationship_Values__c;
                    }
                }
                initWrap.relationshipValues.add(relationshipValue);
            }
            /*if(relationshipName.size() > 0) {
            	initWrap.personRole = relationshipName[0].Relationship_Values__c;
            }*/
            
        }
        initWrap.findingsPicklist = Utility.getPicklistinfo('Investigation_Findings__c','Findings__c',false);
        initWrap.ContributingFactorPicklist = Utility.getPicklistinfo('Investigation_Findings__c','Contributing_factor_in_the_family__c',false);
        PermanacyPlanProceedController obj = new PermanacyPlanProceedController();
        initWrap.showApprovalBtn = obj.checkUserProfile();  
        return JSON.serialize(initWrap);
    }
    
    @AuraEnabled
    public static void updateInvestigationFinding(String UpdatingInvestigationFindingStr) {
        
        
        try {
            if (String.isNotBlank(UpdatingInvestigationFindingStr)) {
                Investigation_Findings__c updatingInvestigationFindingRec = (Investigation_Findings__c)System.JSON.deserialize(UpdatingInvestigationFindingStr, Investigation_Findings__c.class);
                FieldLevelSecurity.checkFieldAccessByCriteria('Findings__c, A_Physical_injury__c, The_injury_was_caused__c, Contributing_factor_in_the_family__c , The_victim_was_a_child__c, Harm_to_a_child__c, During_the_incident__c, The_injury_was_not_caused_by_accidental__c, Abuse_Types__c, During_the_incident__c, Alleged_Victim_s_Explanation__c, Sibling_s_Explanation__c, Parent_Legal_Guardian_s_Explanation__c, Alleged_Maltreator_s_Explanation__c, Physician_or_other_medical_Assessment_s__c, Other_Professional_or_Expert_Assessments__c, Collateral_Interviews_CPS_Interview__c, Law_Enforcement_Involvement__c, Relevant_Criminal_History__c','update','Investigation_Findings__c', Boolean.valueOf(Label.HasNamespace));
                update updatingInvestigationFindingRec;
            }    
       } catch (Exception e) {
            
            throw new AuraHandledException('Something went wrong: '+ e.getMessage());    
        }
    }
    
    public class getInitialWrapper { 
        
        @AuraEnabled
        public List<Investigation_Findings__c> investigationFindingsList;
        @AuraEnabled
        public List<Utility.pickListWrap> findingsPicklist;
        @AuraEnabled
        public List<Utility.pickListWrap> ContributingFactorPicklist;
        @AuraEnabled
        public String allegedVictim ='';
        @AuraEnabled
        public String allegedMaltreator ='';
        @AuraEnabled
        public String personRole ='';
        @AuraEnabled
        public Boolean showApprovalBtn;
        @AuraEnabled
        public List<String> relationshipValues;
        
        public getInitialWrapper() {
            investigationFindingsList = new List<Investigation_Findings__c>();
        }
    }  
}