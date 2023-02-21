public class RelatedListController {
    
    @AuraEnabled(cacheable=true)
    public static List<Sobject> getRecords(String recordId, String queryDetails) {
        
        queryWrapper queryValue = (QueryWrapper)JSON.deserialize(queryDetails, QueryWrapper.class);
        List<String> fields = queryValue.fieldValue;
        String condition = '';
        if(queryValue.filterValue != null) {
            if(!String.isBlank(recordId)) {
            	condition = queryValue.filterValue+'\''+String.escapeSingleQuotes(recordId)+'\' ORDER BY createdDate DESC';
            } else {
                condition = queryValue.filterValue;

            }
        } else {
            Id recordIdValue = String.escapeSingleQuotes(recordId);
            String sObjName = recordIdValue.getSObjectType().getDescribe().getName();
            condition = sObjName+'=\''+String.escapeSingleQuotes(recordId)+'\'';
            if(queryValue.whereField != null) {
               condition += 'AND '+ queryValue.whereField;
            }
        }
        List<SObject> result = DataService.performQueryOperation(fields,queryValue.objectApiName , condition, Utility.queryLimit);
        system.debug(result);
        return result;
    }
    
    @AuraEnabled
    public static String getPersons(String recordId) {
        
            List<Contact> clientList = new List<Contact>();
        
            List<String> contactFields = new List<String>{'Id','Name'};
            String contactCondition = 'Service_Case__c = \''+ String.escapeSingleQuotes(recordId) + '\' OR Investigation__c = \'' + String.escapeSingleQuotes(recordId) + '\' OR Intake__c = \'' + String.escapeSingleQuotes(recordId) +'\'';
            
            List<SObject> sObjListContact = DataService.performQueryOperation(contactFields, 'Contact', contactCondition, Utility.queryLimit);
            clientList = (List<Contact>)sObjListContact;
            
            List<Utility.pickListWrap> clientRecPickList = new List<Utility.pickListWrap>();
            Utility.pickListWrap picklist = new Utility.pickListWrap();
            picklist.label = '--None--';
            picklist.value = '';
            clientRecPickList.add(picklist);

            for(Contact con : clientList) {
                
                if (String.isNotBlank(con.Id)) {
                    picklist = new Utility.pickListWrap();
                    picklist.label = con.Name;
                    picklist.value = con.Id;
                    clientRecPickList.add(picklist);
                }
            }  
          return JSON.serialize(clientRecPickList);
    }
    
    @AuraEnabled
    public static String getPicklistinfo(String objectName, String fieldName, Boolean isMultiPicklist) {
        
        If(String.isNotBlank(objectName) && String.isNotBlank(fieldName)) {
       		return JSON.serialize(Utility.getPicklistinfo(objectName,fieldName,isMultiPicklist));
        } else {
            return null;
        }
    }
    
    
    
    public class QueryWrapper{
        
        @AuraEnabled
        public List<String> fieldValue;
        @AuraEnabled
        public String filterValue;
        @AuraEnabled
        public String objectApiName;
        @AuraEnabled
        public String whereField;
        @AuraEnabled
        public String whereFieldValue;
    }
}