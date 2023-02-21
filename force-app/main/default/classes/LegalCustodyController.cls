public with sharing class LegalCustodyController {

    @AuraEnabled
    public static String getInitialInfos(String recordId) {
        
        LegalCustodyWrapper initWrap = new LegalCustodyWrapper();
        initWrap.legalCustodyList = [SELECT Id, Begin_Date__c, Legal_Custody__c, End_Date__c, Name FROM Legal_Custody__c WHERE Service_Case__c =:recordId];
        
        List<Person__c> personLst = [SELECT Id, Person__c,Name FROM Person__c WHERE Person_Role__c INCLUDES('Biological Child','Child','Child Attorney','Other Child') AND Service_Case__c =:recordId];
        
        List<Utility.pickListWrap> personsRecPickList = new List<Utility.pickListWrap>();
        Utility.pickListWrap pick;
            
            for(Person__c con : personLst) {
                
                    pick = new Utility.pickListWrap();
                    pick.label = con.Name;
                    pick.value = con.Person__c;
                    personsRecPickList.add(pick);
                
            }  
        initWrap.childPickList = personsRecPickList;
        return JSON.serialize(initWrap);
        
    }
    
    
    public class LegalCustodyWrapper{

        @AuraEnabled
        public List<Legal_Custody__c> legalCustodyList;
        @AuraEnabled
        public List<Utility.pickListWrap> childPickList;
        @AuraEnabled
        public List<Utility.pickListWrap> legalCustodianPickList;
        
       
    }
}