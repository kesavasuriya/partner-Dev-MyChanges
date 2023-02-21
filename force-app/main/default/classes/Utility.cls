public with sharing class Utility {

    public static Integer queryLimit = Integer.valueOf(Label.Default_Limit);

    @AuraEnabled
    public static String getNamespacePrefix() {
        String orgNamespace = System.Label.Org_NamePrefix;
        return orgNamespace;
    }  
    
    @AuraEnabled
    public static List<pickListWrap> getPicklistinfo(String objectName, String fieldName, Boolean isMultiPicklist){
        String obj = objectName;
        String field = fieldName;
        if(Boolean.valueOf(Label.HasNamespace)) {

            String namespace = Label.Org_NamePrefix;
            obj = namespace + objectName;
            field = namespace + fieldName;
        }

        Schema.SObjectType s = Schema.getGlobalDescribe().get(obj) ;
        Schema.DescribeSObjectResult r = s.getDescribe() ;
        Map<String,Schema.SObjectField> fields = r.fields.getMap() ;
        Schema.DescribeFieldResult fieldResult = fields.get(field).getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        List<pickListWrap> recPickList = new List<pickListWrap>();
        
        if(isMultiPicklist == false){
            pickListWrap intialPick = new pickListWrap();
            intialPick.label = '--None--';
            intialPick.value = '';
            recPickList.add(intialPick);
        }
        
        for( Schema.PicklistEntry pickListVal : ple){
            pickListWrap pick = new pickListWrap();
            
            pick.label = pickListVal.getLabel();
            pick.value = pickListVal.getValue();
            
            if(pick.label != 'None'){
                recPickList.add(pick);
            }
        }  
        
        return recPickList;
    }
    
     public class pickListWrap {
     
        public String label; 
        public String value;
    }
    
}