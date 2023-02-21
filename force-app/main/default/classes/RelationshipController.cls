public with sharing class RelationshipController {
    
    @AuraEnabled
    public static String getAllPersons(String recordId) {
        
        getInitialWrapper initWrap = new getInitialWrapper ();
        Id personInvolvedRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Persons Involved').getRecordTypeId();

        initWrap.relationshipPicklist = Utility.getPicklistinfo('Relationship__c','Relationship_Values__c',false);
        FieldLevelSecurity.checkFieldAccessByCriteria('Name, Age__c,Gender__c,Date_of_Birth__c, Casevault_PID__c', 'view', 'Contact',  Boolean.valueOf(Label.HasNamespace));
         List<String> jnObjFields = new List<String>{'Id', 'Person__c','Is_Caregiver__c'};
                String jnObjCondition = 'Person__r.RecordTypeId = \''+ String.escapeSingleQuotes(personInvolvedRecordTypeId)+ '\''+'AND (Intake__c = \'' + String.escapeSingleQuotes(recordId) + '\'' + ' OR ' + 
                'Investigation__c = \'' + String.escapeSingleQuotes(recordId) + '\'' + ' OR ' + 
                'Service_Case__c = \'' + String.escapeSingleQuotes(recordId) + '\'' + ' OR ' + 'Person__c = \'' + String.escapeSingleQuotes(recordId) + '\')';
        List<Person__c> jnObjList = DataService.performQueryOperation(jnObjFields, 'Person__c', jnObjCondition, Utility.queryLimit);        
        initWrap.jnObjectRecords = (List<Person__c>)jnObjList;
        
                    String contactCondition = '';


        String conIds='';
         if(jnObjList.size() > 0) {
            conIds +=' IN (';

       for(Person__c rec : jnObjList) {
                conIds +='\''+String.escapeSingleQuotes(rec.Person__c)+'\',';
            }
            conIds = conIds.removeEnd(',');
            conIds +=')';

         }
          else{
            conIds +=' IN('+'\''+'\')';
        }
                    contactCondition += ' Id  '+ conIds;     


        
        List<String> contactFields = new List<String>{'Id','Name', 'Age__c','Gender__c','Date_of_Birth__c', 'Casevault_PID__c'};
       /* String contactCondition = 'Service_Case__c = \'' + String.escapeSingleQuotes(recordId) + '\'' + ' OR ' + 
                                   'Intake__c = \'' + String.escapeSingleQuotes(recordId) + '\'' + ' OR ' + 'Investigation__c = \'' + String.escapeSingleQuotes(recordId) + '\'';*/
        List<SObject> sObjListcontact = DataService.performQueryOperation(contactFields, 'Contact', contactCondition, Utility.queryLimit);        
        if(sObjListcontact.size() > 0) {
            initWrap.contactList = (List<Contact>) sObjListcontact;
        }
        
        return JSON.serialize(initWrap);
    }
    
    @AuraEnabled
    public static String getRelationRecord(String personId) {
        
        if(String.isNotBlank(personId)) {

            List<String> relationFields = new List<String>{'Person__c', 'Person_Related_To__c', 'Relationship_Values__c', 'Is_Caregiver__c'};
            String relationCondition = 'Person__c = \'' + String.escapeSingleQuotes(personId) + '\'';
            List<SObject> sObjListrelation = DataService.performQueryOperation(relationFields, 'Relationship__c', relationCondition, Utility.queryLimit);
            List<Relationship__c> relationships = (List<Relationship__c>)sObjListrelation;
        	return JSON.serialize(relationships);
        } else {
            return null;
        }
    }
    
    @AuraEnabled
    public static String saveRelationship(String relationshipJSON, String recordId) {
        
        if (String.isNotBlank(relationshipJSON)) {
            Relationship__c relationship = (Relationship__c)JSON.deserialize(relationshipJSON,Relationship__c.class);
            //FieldLevelSecurity.checkFieldAccessByCriteria('Is_Caregiver__c', 'update', 'Contact',  Boolean.valueOf(Label.HasNamespace));
            /*Contact contactRecord = new Contact();
            contactRecord.Is_Caregiver__c = relationship.Is_Caregiver__c;
            contactRecord.Id = relationship.Person_Related_To__c;
            update contactRecord;*/
            
            Id personInvolvedRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Persons Involved').getRecordTypeId();
            
            List<String> jnObjFields = new List<String>{'Id', 'Person__c'};
                String jnObjCondition = 'Person__r.RecordTypeId = \''+ String.escapeSingleQuotes(personInvolvedRecordTypeId)+ '\''+'AND (Intake__c = \'' + String.escapeSingleQuotes(recordId) + '\'' + ' OR ' + 
                'Investigation__c = \'' + String.escapeSingleQuotes(recordId) + '\'' + ' OR ' + 
                'Service_Case__c = \'' + String.escapeSingleQuotes(recordId) + '\')' + ' AND ' + 'Person__c = \'' + String.escapeSingleQuotes(relationship.Person_Related_To__c) + '\'';
        	List<Person__c> jnObjList = DataService.performQueryOperation(jnObjFields, 'Person__c', jnObjCondition, 1);     
            List<Person__c> updatePersonRec = (List<Person__c>)jnObjList;
            updatePersonRec[0].Is_Caregiver__c = relationship.Is_Caregiver__c;
            
            update updatePersonRec;
            
            if (String.isBlank(relationship.Id)) {
                FieldLevelSecurity.checkFieldAccessByCriteria('Person__c, Person_Related_To__c, Relationship_Values__c, Is_Caregiver__c', 'create', 'Relationship__c',  Boolean.valueOf(Label.HasNamespace));
                insert relationship;
            } else {
                FieldLevelSecurity.checkFieldAccessByCriteria('Person__c, Person_Related_To__c, Relationship_Values__c, Is_Caregiver__c', 'update', 'Relationship__c',  Boolean.valueOf(Label.HasNamespace));
                update relationship;
            }
          return relationship.Id;
       } else {
        return null;
       }
        
    }

    public class getInitialWrapper { 
    	
        @AuraEnabled
        public List<Utility.pickListWrap> relationshipPicklist;
        @AuraEnabled
        public List<Contact> contactList;
        @AuraEnabled
        public List<Person__c> jnObjectRecords;
        
    }
}