public  with sharing class ContactNotesController {
    @AuraEnabled
    public static String getNotesInitialInformation(String recordId){
        NotesWrapper notesWrap = new NotesWrapper();
        notesWrap.contactPurposePicklist = Utility.getPicklistinfo('Notes__c','Contact_Purpose__c',false);
        notesWrap.contactTypePicklist = Utility.getPicklistinfo('Notes__c','Contact_Type__c',false);
        notesWrap.contactLoactionPicklist = Utility.getPicklistinfo('Notes__c','Contact_Location__c',false);
        notesWrap.contactAttemptedPicklist = Utility.getPicklistinfo('Notes__c','Contact_was_Attempted_Completed__c',false);
        notesWrap.contactInitiatedPicklist = Utility.getPicklistinfo('Notes__c','Contact_was_initiated_received__c',false);
        if(String.isNotBlank(recordId)) {

             List<String> jnObjFields = new List<String>{'Id', 'Person__c'};
                String jnObjCondition = 'Intake__c = \'' + String.escapeSingleQuotes(recordId) + '\'' + ' OR ' + 
                'Investigation__c = \'' + String.escapeSingleQuotes(recordId) + '\'' + ' OR ' + 
                'Service_Case__c = \'' + String.escapeSingleQuotes(recordId) + '\'' + ' OR ' + 'Person__c = \'' + String.escapeSingleQuotes(recordId) + '\'';
            List<Person__c> jnObjList = DataService.performQueryOperation(jnObjFields, 'Person__c', jnObjCondition, Utility.queryLimit); 
            String conIds='';
        if(jnObjList.size() > 0) {
            conIds +='IN (';

            for(Person__c rec : jnObjList) {
                conIds +='\''+String.escapeSingleQuotes(rec.Person__c)+'\',';
            }
            conIds = conIds.removeEnd(',');
            conIds +=')';
        }
        else{
            conIds +='IN('+'\''+'\')';
        }
        List<String> contactFields = new List<String>{'Id', 'Name','Intake_Person_Role__c'};
		   /* String contactCondition = 'Service_Case__c = \''+ String.escapeSingleQuotes(recordId) +'\''+' OR ';
            contactCondition +='Investigation__c = \''+ String.escapeSingleQuotes(recordId) +'\''+' OR ';
            contactCondition +='Intake__c = \''+ String.escapeSingleQuotes(recordId) +'\''; */
                        String contactCondition = 'Id ' + conIds+'AND RecordType.DeveloperName ='+'\'Persons_Involved\'';

            List<SObject> contactsObjList = DataService.performQueryOperation(contactFields, 'Contact', contactCondition, Utility.queryLimit);
            notesWrap.contactList = (List<Contact>)contactsObjList;

            List<Utility.pickListWrap> personsRecPickList = new List<Utility.pickListWrap>();
            Utility.pickListWrap pick;
            
            for(Contact con : notesWrap.contactList) {
                
                if (String.isNotBlank(con.Id)) {
                    pick = new Utility.pickListWrap();
                    pick.label = con.Name;
                    pick.value = con.Id;
                    personsRecPickList.add(pick);
                }
            }  
            notesWrap.involvedPersonPicklist = personsRecPickList;
            List<String> notesFields = new List<String>{'Id','Name', 'Contact_Purpose__c', 'Contact_Date__c', 'Contact_Location__c', 'Contact_Type__c',
                                                        'Start_Time__c', 'Contact_Duration__c', 'End_Time__c', 'Involved_Persons_txt__c', 'CreatedDate', 'Owner.Name',  
                                                        'Contact_was_Attempted_Completed__c', 'Notes__c', 'Travel_Duration__c', 'Contact_was_initiated_received__c'};
            
            String notesCondition = 'Service_Case__c = \''+ String.escapeSingleQuotes(recordId) +'\''+' OR ';
            notesCondition +='Investigation__c = \''+ String.escapeSingleQuotes(recordId) +'\''+' OR ';
            notesCondition +='Intake__c = \''+ String.escapeSingleQuotes(recordId) +'\'';
            List<SObject> notessObjList = DataService.performQueryOperation(notesFields, 'Notes__c', notesCondition, Utility.queryLimit);
            notesWrap.notesList = (List<Notes__C>)notessObjList;
            //FieldLevelSecurity.checkFieldAccessByCriteria('Name', 'view', 'Contact',  Boolean.valueOf(Label.HasNamespace));
        }
        return JSON.serialize(notesWrap);
    }
    
    @AuraEnabled
    public static String createNotesRecord(String notesJOSN, List<String> contentDocumentIds) {
        if(String.isNotBlank(notesJOSN)) {
            Notes__c notesRec = (Notes__c)JSON.deserialize(notesJOSN, Notes__c.class);
            if (String.isBlank(notesRec.Id)) {
                FieldLevelSecurity.checkFieldAccessByCriteria('Contact_Purpose__c, Contact_Date__c, Contact_Location__c, Contact_Type__c,'+
                'Start_Time__c, Contact_Duration__c, End_Time__c, Involved_Persons__c, Contact_was_Attempted_Completed__c, Notes__c, Travel_Duration__c, Contact_was_initiated_received__c', 'create', 'Notes__c',  Boolean.valueOf(Label.HasNamespace));
                insert notesRec;
            } else {
                FieldLevelSecurity.checkFieldAccessByCriteria('Contact_Purpose__c, Contact_Date__c, Contact_Location__c, Contact_Type__c,'+
                'Start_Time__c, Contact_Duration__c, End_Time__c, Involved_Persons__c, Contact_was_Attempted_Completed__c, Notes__c, Travel_Duration__c, Contact_was_initiated_received__c', 'update', 'Notes__c',  Boolean.valueOf(Label.HasNamespace));
                update notesRec;
            }
            if(contentDocumentIds.size() > 0) {
                String result = ContactMeetingController.createContentLink(contentDocumentIds,notesRec.Id);
            }
            return notesRec.Id;
        } else {
            return null;
        }
    }
    
    @AuraEnabled
    public static String createQualityCareRecord(String qualityJOSN) {
        if(String.isNotBlank(qualityJOSN)) {
            Quality_Of_Care__c qualityCareRec = (Quality_Of_Care__c)JSON.deserialize(qualityJOSN, Quality_Of_Care__c.class);
            if (String.isBlank(qualityCareRec.Id)) {
                FieldLevelSecurity.checkFieldAccessByCriteria('Describe_the_quality_of_care__c, Describe_a_the_child_s_adjustment__c,Describe_child_s_adjustment_to_foster__c', 'create', 'Quality_Of_Care__c',  Boolean.valueOf(Label.HasNamespace));
                insert qualityCareRec;
            } else {
                FieldLevelSecurity.checkFieldAccessByCriteria('Describe_the_quality_of_care__c, Describe_a_the_child_s_adjustment__c,Describe_child_s_adjustment_to_foster__c', 'update', 'Quality_Of_Care__c',  Boolean.valueOf(Label.HasNamespace));
                update qualityCareRec;
            }
            return qualityCareRec.Id;
        } else {
            return null;
        }
    }
    
    @AuraEnabled
    public static String deleteNotesRecord(String notesJOSN) {
        if(String.isNotBlank(notesJOSN)) {
            Notes__c notesRec = (Notes__c)JSON.deserialize(notesJOSN, Notes__c.class);
            if (String.isNotBlank(notesRec.Id)) {
                FieldLevelSecurity.checkObjectAccessByDelete('Notes__c');            
                delete notesRec;
            } 
            return notesRec.Id;  
        } else {
            return null;
        }
    }
    
    @AuraEnabled
    public static String createContentVersion(String base64, String filename) {
        ContentVersion cv = new ContentVersion();
        cv.VersionData = EncodingUtil.base64Decode(base64);
        cv.Title = filename;
        cv.PathOnClient = filename;
        FieldLevelSecurity.checkFieldAccessByCriteria('VersionData,Title,PathOnClient','create','ContentVersion', Boolean.valueOf(Label.HasNamespace));
        insert cv;
        ContentVersion contentVersionRec = [SELECT ContentDocumentId FROM ContentVersion 
                                            WHERE Id = :cv.Id LIMIT :Utility.queryLimit];
        return contentVersionRec.ContentDocumentId;
    }
    
    @AuraEnabled
    public static String getNotesHistories(String notesRecId) {
        NotesWrapper notesWrap = new NotesWrapper ();
        if(String.isNotBlank(notesRecId)) {
            FieldLevelSecurity.checkFieldAccessByCriteria('Name, Contact_Purpose__c, Contact_Type__c, Contact_Location__c,'+
            'Travel_Duration__c, Contact_was_Attempted_Completed__c, Person_Contact__c,Modified_Name__c, Notes_Comments__c, Notes__c, Modified_Date__c,Source__c', 'view', 'Notes_History__c',  Boolean.valueOf(Label.HasNamespace));
            notesWrap.notesHistoryList = [SELECT Id, Name, Contact_Purpose__c, Contact_Type__c, Contact_Location__c, 
                                          Travel_Duration__c, Contact_was_Attempted_Completed__c, Person_Contact__c, 
                                          Modified_Name__c, Notes_Comments__c, Notes__c, Modified_Date__c, Owner.Name, 
                                          Source__c FROM Notes_History__c WHERE Notes__c =:notesRecId LIMIT :Utility.queryLimit];
            return JSON.serialize(notesWrap);
        } else {
            return null;
        }
        
    }
    
    
    @AuraEnabled
    public static String getpersonInvolved(String notesRecId) {
        if(String.isNotBlank(notesRecId)) {
            List<Notes_Person_Involved__c> personInvolved = [SELECT Id,Person__c , Person__r.Name, Notes__c                                                   
                                                     			   FROM Notes_Person_Involved__c  
                                                                   WHERE Notes__c =:notesRecId LIMIT :Utility.queryLimit];                
            system.debug('value '+personInvolved);
            return JSON.serialize(personInvolved);
        } else {
            return null;
        }
        
    }
    
    
    @AuraEnabled
    public static void createPersonInvolved(String personJSON) {
        if(String.isNotBlank(personJSON)) {
            List<Notes_Person_Involved__c>  personInvolvedRec = (List<Notes_Person_Involved__c>)JSON.deserialize(personJSON, List<Notes_Person_Involved__c>.class);
            insert personInvolvedRec;
           
        }
    }
    
    @AuraEnabled
    public static void deleteJnRecords(String deleteRecordJSON) {
        if(String.isNotBlank(deleteRecordJSON)) {
            List<Notes_Person_Involved__c>  personInvolvedRec = (List<Notes_Person_Involved__c>)JSON.deserialize(deleteRecordJSON, List<Notes_Person_Involved__c>.class);
            delete personInvolvedRec;
           
        }
    }
    
    
    public class NotesWrapper{
        @AuraEnabled
        public List<Utility.pickListWrap> contactPurposePicklist;
        @AuraEnabled
        public List<Utility.pickListWrap> contactTypePicklist;
        @AuraEnabled
        public List<Utility.pickListWrap> contactLoactionPicklist;
        @AuraEnabled
        public List<Utility.pickListWrap> involvedPersonPicklist;
        @AuraEnabled
        public List<Utility.pickListWrap> contactInitiatedPicklist;
        @AuraEnabled
        public List<Utility.pickListWrap> contactAttemptedPicklist;
        @AuraEnabled
        public List<Notes__c> notesList;
        @AuraEnabled
        public Notes__c notesRecord;
        @AuraEnabled
        public List<Notes_History__c> notesHistoryList;
        @AuraEnabled
        public List<Contact> contactList;
        
       
    }
}