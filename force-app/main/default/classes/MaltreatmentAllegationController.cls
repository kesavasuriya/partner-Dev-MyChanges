Public with sharing class MaltreatmentAllegationController {
    
    @AuraEnabled
    public static String fetchInformation(String investigationId) {
        
        if (String.isNotBlank(investigationId)) {
            
            getInitialWrapper initWrap = new getInitialWrapper();
            
            List<String> personFields = new List<String>{'Id','Person__c','Person_Role__c','Person__r.Name', 
            						'Person__r.Age__c','Person__r.Gender__c ','Person__r.Date_of_Birth__c'
            						};
            String personCondition = 'Investigation__c = \'' + String.escapeSingleQuotes(investigationId) + '\' AND  Person_Role__c  INCLUDES( '+'\''+'Alleged Victim'+'\')';
            personCondition +=  ' AND Person__r.RecordType.Name ='+'\''+'Persons Involved'+'\'';
        List<SObject> sObjListcontact = DataService.performQueryOperation(personFields, 'Person__c', personCondition, Utility.queryLimit);       
        initWrap.victimList = (List<Person__c>)sObjListcontact;
            
            /*FieldLevelSecurity.checkFieldAccessByCriteria('Name,Date_of_Birth__c, Gender__c, Age__c, Intake_Person_Role__c,Investigation__c','view','Contact', Boolean.valueOf(Label.HasNamespace));
            initWrap.victimList = [SELECT Id, Name, Date_of_Birth__c, Gender__c, Age__c, Intake_Person_Role__c FROM Contact 
                                   WHERE Investigation__c = :investigationId AND Intake_Person_Role__c INCLUDES('Alleged Victim') AND 
                                   RecordTypeId = :Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Persons Involved').getRecordTypeId() LIMIT :Utility.queryLimit];
            */return JSON.serialize(initWrap);
        } else {
            return null;
        }
    }
    
    @AuraEnabled
    public static String fetchMaltreatmentRecords(String investigationId, String childId) {
        
        if (String.isNotBlank(investigationId) && String.isNotBlank(childId)) {
            FieldLevelSecurity.checkFieldAccessByCriteria('Name, Completed__c,Child__c,Accordion_Label__c,This_maltreatment_is_not_applicable__c,Investigation__c','view','Maltreatment_Allegation__c', Boolean.valueOf(Label.HasNamespace));
            List<Maltreatment_Allegation__c> maltreatmentList = [SELECT Id, Name, Completed__c, Accordion_Label__c, This_maltreatment_is_not_applicable__c FROM Maltreatment_Allegation__c WHERE Child__c = :childId AND Investigation__c = :investigationId LIMIT :Utility.queryLimit];
            return JSON.serialize(maltreatmentList);
        } else {
            return null;
        }
    }
    
    @InvocableMethod(callout=true label='Delete Maltreatment Allegation') 
    public static void deleteMaltreatmentAllegation(List<List<Maltreatment_Allegation__c>> malrec) {
        
        if(malrec.size()>0) {
            List<String>abuseType = new List<String>();
            List<Maltreatment_Allegation__c> records = new List<Maltreatment_Allegation__c>();
            records = malrec[0];
            
            String investigationId = records[0].Investigation__c;
            for(Maltreatment_Allegation__c rec : records) {
                abuseType.add(rec.Abuse_Types__c);
            }
            FieldLevelSecurity.checkFieldAccessByCriteria('Investigation__c, Abuse_Types__c','view','Maltreatment_Allegation__c', Boolean.valueOf(Label.HasNamespace));           
            List<Maltreatment_Allegation__c> deleteRecords = [SELECT Id FROM Maltreatment_Allegation__c WHERE Investigation__c =:investigationId AND Abuse_Types__c IN :abuseType LIMIT :Utility.queryLimit];
            FieldLevelSecurity.checkObjectAccessByDelete('Maltreatment_Allegation__c');            

            if(deleteRecords.size()>0) {
                delete deleteRecords;
            }
        }
    }
    
    @AuraEnabled
    public static void updateMaltreatmentAllegation(String recordId, Boolean field) {
        
        if(String.isNotBlank(recordId)) {
            FieldLevelSecurity.checkFieldAccessByCriteria('This_maltreatment_is_not_applicable__c','update','Maltreatment_Allegation__c', Boolean.valueOf(Label.HasNamespace));           
            Maltreatment_Allegation__c MaltreatmentAllegationIns = new Maltreatment_Allegation__c();
            MaltreatmentAllegationIns.Id = recordId;
            MaltreatmentAllegationIns.This_maltreatment_is_not_applicable__c = field;
            update MaltreatmentAllegationIns;
        }
    }
    public class getInitialWrapper { 
        @AuraEnabled
        public List<Person__c> victimList;
    }
}