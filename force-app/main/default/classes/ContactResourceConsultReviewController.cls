public  with sharing class ContactResourceConsultReviewController {
    
    @AuraEnabled
    public static String getResourceConsultReviewRecord(String recordId) {
        
        if(String.isNotBlank(recordId)) {
            
            ContactResourceConsultReviewWrapper wrapperObj = new ContactResourceConsultReviewWrapper();
            FieldLevelSecurity.checkFieldAccessByCriteria('User_Name_Type__c, Review_Date_Time__c, Meeting_Notes__c, Service_Case__c, Investigation__c', 'view', 'Resource_Consult_Review__c',  Boolean.valueOf(Label.HasNamespace));            
            
            wrapperObj.userTypePicklist = Utility.getPicklistinfo('Resource_Consult_Review__c','Select_User_Type__c',false);
            wrapperObj.resourceRecords = [SELECT Id, User_Name_Type__c, Review_Date_Time__c, Meeting_Notes__c FROM Resource_Consult_Review__c
                                          WHERE Service_Case__c = :recordId OR Investigation__c = :recordId LIMIT :Utility.queryLimit];
            return JSON.serialize(wrapperObj);
            
        } else {
            return null;
        }
    }
    
    @AuraEnabled
    public static String saveResource(String resourceJSON){
        
        Resource_Consult_Review__c resourceConsultReviewRec = (Resource_Consult_Review__c)JSON.deserialize(resourceJSON,Resource_Consult_Review__c.class);
        if(String.isBlank(resourceConsultReviewRec.Id)) {
            
            FieldLevelSecurity.checkFieldAccessByCriteria('User_Name_Type__c, Review_Date_Time__c, Meeting_Notes__c, Service_Case__c, Investigation__c', 'create', 'Resource_Consult_Review__c',  Boolean.valueOf(Label.HasNamespace));
            insert resourceConsultReviewRec;
            
        } else {
            
            FieldLevelSecurity.checkFieldAccessByCriteria('User_Name_Type__c, Review_Date_Time__c, Meeting_Notes__c, Service_Case__c, Investigation__c', 'update', 'Resource_Consult_Review__c',  Boolean.valueOf(Label.HasNamespace));
            update resourceConsultReviewRec;
        }
        
        return resourceConsultReviewRec.Id;
    }
    
    @AuraEnabled
    public static String deleteResource(String recordId){
        
        if(String.isNotBlank(recordId)) {
            
            FieldLevelSecurity.checkObjectAccessByDelete('Resource_Consult_Review__c');
            Resource_Consult_Review__c record = new Resource_Consult_Review__c();
            record.Id = recordId;
            delete record;
            return 'Success';
        } else {
            return null;
        }
    }
    
    public class ContactResourceConsultReviewWrapper {
        
        @AuraEnabled
        public List<Utility.pickListWrap> userTypePicklist;
        @AuraEnabled
        public List<Resource_Consult_Review__c> resourceRecords;
        
        public ContactResourceConsultReviewWrapper() {
            resourceRecords = new List<Resource_Consult_Review__c>();
        }
    }
}