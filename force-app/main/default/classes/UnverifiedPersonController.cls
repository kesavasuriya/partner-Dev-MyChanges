public class UnverifiedPersonController {

    @AuraEnabled
    public static String getUnverifiedPersons(String recordId) {
        
        WrapperClass initWrap = new WrapperClass();
        initwrap.selectPersonRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Select Person').getRecordTypeId();
        initWrap.unverifiedRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Unverified Person').getRecordTypeId();
      	initWrap.personInvolvedRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Persons Involved').getRecordTypeId();
        if(String.isNotBlank(recordId)) {

            Map<Id,Id> personJnMap = new Map<Id,Id>();
            Set<Id> personIDs = new Set<Id>();
            for(Person__c personIns : [SELECT Id, Person__c,Person_Role__c   FROM Person__c WHERE Person__r.RecordTypeId = :initWrap.unverifiedRecordTypeId AND (Intake__c = :recordId OR Investigation__c = :recordId)]) {
                personIDs.add(personIns.Person__c);
                system.debug('nin'+personIns);
                personJnMap.put(personIns.Person__c,personIns.Id);
            }
            if(personIDs.size() > 0) {

               /* List<String> contactFields = new List<String>{'Id','Date_of_Birth__c','FirstName','LastName','Intake_Person_Role__c ',' Name'};
                String contactCondition =  '( Intake__c = \'' + String.escapeSingleQuotes(recordId) + '\'' + ' OR ' + 'Investigation__c = \'' + String.escapeSingleQuotes(recordId) + '\') AND RecordType.Name ='+'\''+'Unverified Person'+'\'';
                List<SObject> sObjListcontact = DataService.performQueryOperation(contactFields, 'Contact', contactCondition, Utility.queryLimit);        
                initWrap.unverifiedPersonRecords = (List<Contact>)sObjListcontact;*/
                List<Contact> persons = [SELECT Id, Name, Date_of_Birth__c, FirstName, LastName, Intake_Person_Role__c FROM Contact WHERE Id IN :personIDs];
                for(Contact conIns : persons) {
                    conIns.Jn_Object_Handler__c = personJnMap.get(conIns.Id);
                }
                if(persons.size() > 0) {
                    initWrap.unverifiedPersonRecords = persons;
                }
            }
            
        }
        return JSON.serialize(initWrap);
    }

    @AuraEnabled
    public static String searchPerson(String firstName, String lastName) {

        List<contact> contactList = new List<contact> ();
        List<String> contactFields = new List<String>{'Id', 'Name', 'FirstName', 'LastName', 'Casevault_PID__c', 'SSN__c', 'Date_of_Birth__c', 'Gender__c', 'Age__c',
                                    'Address_Line_1__c',  'Address_Line_2__c', 'Address_ZipCode__c', 'Address_State__c', 'County_Address__c', 'Address_City__c','Intake__c',
                                    'Investigation__c','Service_Case__c'};
        Id recordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Persons Involved').getRecordTypeId();
        String contactJSON = '';
        contactJSON += ' LastName != null AND Home_Approval__r.Home_Approval_Status__c != \'Approved\' AND RecordTypeId = \''+ recordTypeId + '\'';
        if( String.isNotBlank(firstName) ) {
                    
            String firstNameSoundexCode = Soundex_Algorithm.calculateSoundexCode(firstName);
            if(String.isNotBlank(firstNameSoundexCode)) {
                contactJSON += ' AND Firstname_soundex_keycode__c = \''+ String.escapeSingleQuotes(firstNameSoundexCode)+ '\'';
            }
        }
        if( String.isNotBlank(lastName) ) {
            
            String lastNameSoundexCode = Soundex_Algorithm.calculateSoundexCode(lastName);
            if(String.isNotBlank(lastNameSoundexCode)) {
                contactJSON += ' AND Lastname_soundex_keycode__c = \''+ String.escapeSingleQuotes(lastNameSoundexCode)+ '\'';
            } 
        }
        return JSON.serialize(DataService.performQueryOperation(contactFields, 'Contact', contactJSON, Utility.queryLimit));

    }

    @AuraEnabled
    public static string selectPerson(String unverifiedPersonId, String selectedPersonId, String recordId, String objectApiName){
        
        if(String.isNotBlank(selectedPersonId) && String.isNotBlank(recordId) && String.isNotBlank(objectApiName)) {

            
            String parentField = objectApiName == 'Case' ? 'Intake__c' :   objectApiName == 'Investigation__c' ? 'Investigation__c' : null;
            if(String.isNotBlank(parentField)) {

                Person__c createJN = new Person__c();
                createJN.Person__c = selectedPersonId;
                createJN.put(parentField, recordId);
                insert createJN;

                Person__c unverifiedRec = [SELECT Id FROM Person__c WHERE Person__c = :unverifiedPersonId AND (Intake__c = :recordId OR Investigation__c = :recordId) LIMIT 1];
                delete unverifiedRec;

                return 'Success';
            }

            return null;
        }
        return null;
    }
    
    public class WrapperClass { 
    
        @AuraEnabled
        public List<Contact> unverifiedPersonRecords;
        @AuraEnabled
        public String unverifiedRecordTypeId;
        @AuraEnabled
        public String personInvolvedRecordTypeId;
        @AuraEnabled 
        public String selectPersonRecordTypeId;
    
    }

    
}