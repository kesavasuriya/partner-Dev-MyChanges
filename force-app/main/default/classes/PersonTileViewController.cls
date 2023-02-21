public with sharing class PersonTileViewController {
    
    @AuraEnabled
    public static String getPersons(String recordId, String objectApiName) {
        
        WrapperClass initWrap = new WrapperClass();

        /*List<String> contactFields = new List<String>{'Name','Intake_Person_Role__c', 'Age__c','Date_of_Death__c ','Date_of_Birth__c', 'Casevault_PID__c','Address_City__c','Address_State__c','Active_Program_Area__c',
            'Address_ZipCode__c','County_Address__c','Address_Line_1__c','Address_Line_2__c','Program_Area_Url__c','Person_Image_URL__c ','Program_Area__c'};
                String contactCondition = '(Service_Case__c = \'' + String.escapeSingleQuotes(recordId) + '\'' + ' OR ' + 
                'Intake__c = \'' + String.escapeSingleQuotes(recordId) + '\'' + ' OR ' + 'Investigation__c = \'' + String.escapeSingleQuotes(recordId)+ '\') AND RecordType.Name ='+'\''+'Persons Involved'+'\'';
        List<SObject> sObjListcontact = DataService.performQueryOperation(contactFields, 'Contact', contactCondition, Utility.queryLimit);       
        initWrap.personRecords = (List<Contact>)sObjListcontact;*/
        
        List<String> personFields = new List<String>{'Id','Person__c','Person__r.Name','Person__r.Intake_Person_Role__c', 
            						'Person__r.Age__c','Person__r.Date_of_Death__c ','Person__r.Date_of_Birth__c', 
            						'Person__r.Casevault_PID__c','Person__r.Address_City__c',
            						'Person__r.Address_State__c','Person__r.Active_Program_Area__c','Person_Role__c',
            						'Person__r.Address_ZipCode__c','Person__r.County_Address__c','Person__r.Address_Line_1__c',
            						'Person__r.Address_Line_2__c','Person__r.Person_Image_URL__c '};
                String personCondition = '(Service_Case__c = \'' + String.escapeSingleQuotes(recordId) + '\'' + ' OR ' + 
                'Intake__c = \'' + String.escapeSingleQuotes(recordId) + '\'' + ' OR ' + 'Investigation__c = \'' + String.escapeSingleQuotes(recordId)+ '\') AND Person__r.RecordType.Name ='+'\''+'Persons Involved'+'\'';
        List<SObject> sObjListcontact = DataService.performQueryOperation(personFields, 'Person__c', personCondition, Utility.queryLimit);       
        initWrap.personRecords = (List<Person__c>)sObjListcontact;
        
        
        System.debug('persons '+initWrap.personRecords);
        String personIds='';
        if(initWrap.personRecords.size() > 0) {
            personIds +='IN(';
            for(Person__c rec : initWrap.personRecords) {
                personIds +='\''+String.escapeSingleQuotes(rec.Person__c)+'\',';
            }
            personIds = personIds.removeEnd(',');
            personIds +=')';
        } else {
            personIds +='IN('+'\''+'\')';
        }
        
        if(objectApiName != 'Case') {
            initWrap.placementRecords = getPlacements(personIds, recordId);
            initWrap.programAssignmentRecords = getProgramAssignment(personIds);
            initWrap.childRemovalRecords = getchildRemoval(personIds,recordId);
            initWrap.legalCustodyRecords = getLegalCustody(personIds,recordId);
            initWrap.courtHearingRecords = getCourtHearing(personIds, recordId);
            initWrap.titleIVeRecords = getTitleIve(personIds,recordId);
        } else {
            initWrap.placementRecords = new List<Placement__c>(); 
            initWrap.programAssignmentRecords = new List<Program_Assignment__c>();
            initWrap.childRemovalRecords = new List<Child_Removal__c>();
            initWrap.legalCustodyRecords = new List<Legal_Custody__c>();
            initWrap.courtHearingRecords = new List<Court_Petition_Hearing__c>();
            initWrap.titleIVeRecords = new List<Title_Iv_E__c>();
        }
        return JSON.serialize(initWrap);
    }
    
    public static List<Placement__c> getPlacements(string personIds, string recordId) {
        
        List<String> placementFields = new List<String>{'Name','Begin_Date__c','Child__c','Placement_Structure__c','Provider__c','Provider__r.BillingAddress','Provider__r.BillingState ','Provider__r.BillingCity','Provider__r.BillingCountry','Provider__r.BillingStreet','Provider__r.BillingPostalCode'};
 		String placementCondition = '(Service_Case__c = \''+ String.escapeSingleQuotes(recordId) +'\''+') AND ';
        placementCondition += ' Child__c '+personIds+' AND Exit_Approval_Status__c !='+'\''+'Approved'+'\' ORDER BY CreatedDate DESC';
        List<SObject> sObjListPlacement = DataService.performQueryOperation(placementFields, 'Placement__c', placementCondition, Utility.queryLimit);        
        return (List<Placement__c>)sObjListPlacement;
        
    }
    
    public static List<Child_Removal__c> getchildRemoval(string personIds, string recordId) {
        
        List<String> childRemovalFields = new List<String>{'Name','Removal_End_Date_Time__c ','Child__c','Removal_Date_of_DT_F__c',' Primary_Caregiver__r.Name'};
        String childRemovalCondition = '(Service_Case__c = \''+ String.escapeSingleQuotes(recordId) +'\''+' OR ';
        childRemovalCondition += 'Investigation__c = \''+ String.escapeSingleQuotes(recordId) +'\') AND';
        childRemovalCondition += ' Child__c '+personIds+'ORDER BY CreatedDate DESC';
        List<SObject> sObjListchildRemoval = DataService.performQueryOperation(childRemovalFields, 'Child_Removal__c', childRemovalCondition,  Utility.queryLimit);        
        return (List<Child_Removal__c>)sObjListchildRemoval;
        
    }
    
    public static List<Legal_Custody__c > getLegalCustody(string personIds, string recordId) {
        
        List<String> legalCustodyFields = new List<String>{'Name','Begin_Date__c','Child_Name__c '};
            String legalCustodyCondition = '(Service_Case__c = \''+ String.escapeSingleQuotes(recordId) +'\''+' OR ';
            legalCustodyCondition += 'Investigation__c = \''+ String.escapeSingleQuotes(recordId) +'\') AND';
            legalCustodyCondition = ' Child_Name__c  '+personIds+'ORDER BY CreatedDate DESC';
        List<SObject> sObjListlegalCustody = DataService.performQueryOperation(legalCustodyFields, 'Legal_Custody__c', legalCustodyCondition,  Utility.queryLimit);        
        return (List<Legal_Custody__c>)sObjListlegalCustody;
        
    }
    
    public static List<Court_Petition_Hearing__c > getCourtHearing(string personIds, string recordId) {
        
        List<String> courtHearingFields = new List<String>{'Id','Name','Hearing_Status__c ','Hearing_Date_and_Time__c','Court__r.Petition_for_Child__c'};
        String courtHearingCondition = '(Service_Case__c = \''+ String.escapeSingleQuotes(recordId) +'\''+' OR ';
        courtHearingCondition += 'Investigation__c = \''+ String.escapeSingleQuotes(recordId) +'\') AND';
        courtHearingCondition = ' Court__r.Petition_for_Child__c '+personIds+' AND Hearing_Status__c ='+'\''+'Concluded'+'\' ORDER BY CreatedDate DESC';
        List<SObject> sObjListcourtHearing = DataService.performQueryOperation(courtHearingFields, 'Court_Petition_Hearing__c ', courtHearingCondition,  Utility.queryLimit);        
        return (List<Court_Petition_Hearing__c >)sObjListcourtHearing;
        
    }
    
    public static List<Program_Assignment__c> getProgramAssignment(string personIds) {
        
        List<String> programAssignmentFields = new List<String>{'Name','Contact__c'};
            String programAssignmentCondition = ' Contact__c '+personIds+' AND End_Date__c =NULL';
        List<SObject> sObjListprogramAssignment = DataService.performQueryOperation(programAssignmentFields, 'Program_Assignment__c', programAssignmentCondition, Utility.queryLimit);        
        return (List<Program_Assignment__c>)sObjListprogramAssignment;
        
    }

    public static List<Title_Iv_E__c> getTitleIve(string personIds, string recordId) {
        
        List<String> titleIveFields = new List<String>{'Name','Status__c','Child_Removal__r.Child__c'};
            String titleIveCondition = ' Child_Removal__r.Child__c '+personIds+' AND Service_Case__c='+'\''+String.escapeSingleQuotes(recordId)+'\' ORDER BY CreatedDate DESC';
        List<SObject> sObjListtitleIve = DataService.performQueryOperation(titleIveFields, 'Title_Iv_E__c', titleIveCondition, Utility.queryLimit);        
        return (List<Title_Iv_E__c>)sObjListtitleIve;
        
    }
    
    
    public class WrapperClass { 
        
        @AuraEnabled
        public List<Person__c> personRecords;
        @AuraEnabled
        public List<Placement__c> placementRecords;
        @AuraEnabled
        public List<Program_Assignment__c> programAssignmentRecords;
        @AuraEnabled
        public List<Child_Removal__c > childRemovalRecords;
        @AuraEnabled
        public List<Legal_Custody__c >legalCustodyRecords;
        @AuraEnabled
        public List<Court_Petition_Hearing__c >courtHearingRecords;
        @AuraEnabled
        public List<Title_Iv_E__c>titleIVeRecords;
        
    }
}