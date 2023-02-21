public with sharing class SDMAllegedVictimAndMaltreatorHandler {
    
    public static void deleteMaltreatmentandAllegation(List<SDM_Alleged_Victim_and_Maltreator__c> records) {
        
        List<String>allegedVictim = new List<String>();
        List<String>allegedMaltreator = new List<String>();
        
        if(records.size() > 0) {
            for(SDM_Alleged_Victim_and_Maltreator__c rec : records) {
                if(rec.Alleged_Victim_s__c != NULL) {
                    allegedVictim.add(rec.Alleged_Victim_s__c);
                } else if(rec.Alleged_Maltreator_s__c != NULL) {
                    allegedMaltreator.add(rec.Alleged_Maltreator_s__c);
                }
            }
            
            List<Maltreatment_Allegation__c> deleteRecords = [SELECT Id FROM Maltreatment_Allegation__c WHERE Child__c IN :allegedVictim OR Alleged_Maltreator__c IN :allegedMaltreator LIMIT :Utility.queryLimit];
            if(deleteRecords.size()>0) {
                FieldLevelSecurity.checkObjectAccessByDelete('Maltreatment_Allegation__c');            
                delete deleteRecords;
            }
        }
    }
}