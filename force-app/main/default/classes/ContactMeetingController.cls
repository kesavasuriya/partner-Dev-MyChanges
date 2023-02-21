public with sharing class ContactMeetingController {
    
    @AuraEnabled
    public static String getMeetingInfo(String recordId, String objectName){
        
        ContactMeetingWrapperClass wrap = new ContactMeetingWrapperClass();
        
        if(String.isNotBlank(recordId)) {
            
            if(objectName != 'Meeting__c') {

                /*List<String> contactFields = new List<String>{'Id','Name'};
                String contactCondition = '(Service_Case__c = \''+ String.escapeSingleQuotes(recordId) +'\''+' OR ';
                contactCondition +='Investigation__c = \''+ String.escapeSingleQuotes(recordId) +'\')';
                
                List<SObject> childsObjList = DataService.performQueryOperation(contactFields, 'Contact', contactCondition, Utility.queryLimit);
                wrap.childContact = (List<Contact>)childsObjList;*/
                
                List<String> personJnFields = new List<String>{'Id','Person__c','Person__r.Name'};
                String personJnCondition = 'Person__r.RecordType.DeveloperName = \'Persons_Involved\' AND (Service_Case__c = \''+ String.escapeSingleQuotes(recordId) +'\''+' OR ';
                personJnCondition +='Investigation__c = \''+ String.escapeSingleQuotes(recordId) +'\')';
                
                List<SObject> childsObjList = DataService.performQueryOperation(personJnFields, 'Person__c', personJnCondition, Utility.queryLimit);
                wrap.childContact = (List<Person__c>)childsObjList;
                        
                List<String> meetingFields = new List<String>{'Id','Date_of_Meeting__c', 'Name_of_the_person_completing_the_report__c', 'Select_Child_Family_Member__c', 'Type_of_the_Meeting__c', 'Meeting_Status__c',
                                                              'Meeting_Notes__c', 'Additional_Comments__c', 'Follow_up_Meeting__c', 'Follow_up_meeting_Start_date__c', 'Meeting_Decision__c'};
                String meetingCondition = '(Service_Case__c = \''+ String.escapeSingleQuotes(recordId) +'\''+' OR ';
                meetingCondition +='Investigation__c = \''+ String.escapeSingleQuotes(recordId) +'\') ';
                
                List<SObject> meetingsObjList = DataService.performQueryOperation(meetingFields, 'Meeting__c', meetingCondition, Utility.queryLimit);
                wrap.meetings = (List<Meeting__c>)meetingsObjList;
                
            } else {
                
                List<String> meetingFields = new List<String>{'Id','Service_Case__c','Date_of_Meeting__c','Investigation__c','Select_Child_Family_Member__c','Follow_up_Meeting__c','Type_of_the_Meeting__c','Follow_up_meeting_Start_date__c'};
                String meetingCondition = 'Id = \''+ String.escapeSingleQuotes(recordId) +'\'';
                
                List<SObject> meetingsObjList = DataService.performQueryOperation(meetingFields, 'Meeting__c', meetingCondition, Utility.queryLimit);
                wrap.meetingRecord = (Meeting__c)meetingsObjList[0];
                
                List<String> personJnFields = new List<String>{'Id','Person__r.Name','Person__c'};
                String personJnCondition =' Person__r.RecordType.DeveloperName = \'Persons_Involved\' AND ';
                
                if(wrap.meetingRecord.Service_Case__c != null) {
                    personJnCondition += 'Service_Case__c = \''+ String.escapeSingleQuotes(wrap.meetingRecord.Service_Case__c) +'\'';
                } else {
                    personJnCondition += 'Investigation__c = \''+ String.escapeSingleQuotes(wrap.meetingRecord.Investigation__c) +'\'';
                }
                
                List<SObject> childsObjList = DataService.performQueryOperation(personJnFields, 'Person__c', personJnCondition, Utility.queryLimit);
                wrap.childContact = (List<Person__c>)childsObjList;
    
            }
            List<Utility.pickListWrap> childFamilyMemberPicklist = new List<Utility.picklistWrap>();
            Utility.picklistWrap pick;
            
            /*for(Contact contactRec : wrap.childContact) {
            
                if(String.isNotBlank(contactRec.Id)) {
                    pick = new Utility.picklistWrap();
                    pick.label = contactRec.Name;
                    pick.value = contactRec.Id;
                    childFamilyMemberPicklist.add(pick);
                }
            }*/
            for(Person__c contactRec : wrap.childContact) {
            
                if(String.isNotBlank(contactRec.Id)) {
                    pick = new Utility.picklistWrap();
                    pick.label = contactRec.Person__r.Name;
                    pick.value = contactRec.Person__c;
                    childFamilyMemberPicklist.add(pick);
                }
            }
            
            wrap.childFamilyMembers = childFamilyMemberPicklist; 
            
            return JSON.serialize(wrap);
            
        }  else {
            return null;
        }   
    }

    @AuraEnabled
    public static String createContentVersion(String base64, String filename) {
        
        
        ContentVersion cv = new ContentVersion();
        cv.VersionData = EncodingUtil.base64Decode(base64);
        cv.Title = filename;
        cv.PathOnClient = filename;
        //FieldLevelSecurity.checkFieldAccessByCriteria('VersionData,Title,PathOnClient','create','ContentVersion', Boolean.valueOf(Label.HasNamespace));
        insert cv;
        ContentVersion contentVersionRec = [SELECT ContentDocumentId FROM ContentVersion 
                                            WHERE Id = :cv.Id LIMIT :Utility.queryLimit];
        return contentVersionRec.ContentDocumentId;
    }
    
    @AuraEnabled
    public static String createContentLink(List<String> contentDocumentIds, String recordId) {
        
        List<ContentDocumentLink> contentDocumentLinks = new List<ContentDocumentLink>();
        ContentDocumentLink cdl;
        for(String str : contentDocumentIds) {
            cdl = new ContentDocumentLink();
            cdl.ContentDocumentId = str;
            cdl.LinkedEntityId = recordId;
            cdl.ShareType = 'V';
            contentDocumentLinks.add(cdl);
        }
        if(contentDocumentLinks.size() > 0) {
            insert contentDocumentLinks;
        }
        
        return 'Success';   
    }
        
    public class ContactMeetingWrapperClass {
        
        @AuraEnabled
        public List<Utility.pickListWrap> childFamilyMembers;
        @AuraEnabled
        public  List<Meeting__c> meetings;
        @AuraEnabled
        public  List<Person__c> childContact;
        @AuraEnabled
        public  Meeting__c meetingRecord;     
    }

}