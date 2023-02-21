public with sharing class CustomLookUpController {

    /*@AuraEnabled
    public static List <sObject> fetchLookUpValues( String ObjectName, String searchKeyWord, String fieldNames, String fieldCondition ) {
        
        List < sObject > returnList = new List < sObject > ();
        String sQuery =  'SELECT Id, Name ';
        
        if(!String.isEmpty(fieldNames)) {
            
            sQuery = sQuery+', ' + String.escapeSingleQuotes(fieldNames);
        }
        sQuery = sQuery+ ' FROM ' + String.escapeSingleQuotes(ObjectName) + ' WHERE ';
        if(!String.isEmpty(fieldCondition)) {
            
            sQuery = sQuery+ 'Profile.Name ='+ '\''+ String.escapeSingleQuotes(fieldCondition) +'\''+ ' AND ';
        }
        sQuery = sQuery + 'Name LIKE \''+'%'+String.escapeSingleQuotes(searchKeyWord)+'%'+'\' limit 10';
        List < sObject > lstOfRecords = Database.query(sQuery);
        
        for (sObject obj: lstOfRecords) {
            returnList.add(obj);
        }
        return returnList;
    }
    
    @AuraEnabled(cacheable = true)
    public static List<SObject> findRecords(String searchKey, String objectName, String searchField) {
    
        String key = '%' + String.escapeSingleQuotes(searchKey) + '%';
        String profileName = 'Casevault Supervisor';
        Integer queryLimit = Utility.queryLimit;
        FieldLevelSecurity.checkFieldAccessByCriteria('Id,'+searchField, 'view', objectName, true);
        String QUERY = 'SELECT Id, '+String.escapeSingleQuotes(searchField)+' FROM '+String.escapeSingleQuotes(objectName)+' WHERE '+String.escapeSingleQuotes(searchField)+
            			' LIKE :key AND Profile.Name LIKE :profileName LIMIT :queryLimit';
        List<SObject> sObjectList = Database.query(QUERY);
        return sObjectList;
    }*/

    @AuraEnabled
    public static String getSupervisors() {

        CustomLookupWrapper wrapperIns = new CustomLookupWrapper();
        wrapperIns.pickLists = new List<Utility.pickListWrap>();
        Map<Id, User> userRecords = new Map<Id, User>([SELECT Id, Name, ManagerId FROM User WHERE (Profile.Name = 'Casevault Supervisor' OR Id = :UserInfo.getUserId())]);
        for(User userRecord : userRecords.values()) {

            if(userRecord.Id == UserInfo.getUserId()) {

                if(userRecord.ManagerId != null && userRecords.keySet().contains(userRecord.ManagerId)) {
                    wrapperIns.defaultSupervisorId = userRecord.ManagerId;
                }

            } else {

                Utility.pickListWrap pickListIns = new Utility.pickListWrap();
                pickListIns.label = userRecord.Name;
                pickListIns.value = userRecord.Id;
                wrapperIns.pickLists.add(pickListIns);
            }
                    
        }

        return JSON.serialize(wrapperIns);
        
    }

    public class CustomLookupWrapper {

        @AuraEnabled
        public List<Utility.pickListWrap> pickLists;
        @AuraEnabled
        public String defaultSupervisorId;
    }
}