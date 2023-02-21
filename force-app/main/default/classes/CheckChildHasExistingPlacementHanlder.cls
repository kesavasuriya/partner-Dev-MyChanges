public with sharing class CheckChildHasExistingPlacementHanlder {
    
    public void beforeInsertTrigger(List<Child_Removal__c> childRemovalList) {
    
        Set<Id> childIdSet = new Set<Id> ();
        Set<Id> serviceCaseIdSet = new Set<Id>();  
        List<Child_Removal__c> filterChildRemovalList = new  List<Child_Removal__c>();
        List<Child_Removal__c> existingChildRemovalList = new  List<Child_Removal__c>();
        
        Map<Id,List<Child_Removal__c>> existingChildRemovalMap = new Map<Id,List<Child_Removal__c>>();
        
        for(Child_Removal__c childRemoval :childRemovalList) {
            if(childRemoval.Service_Case__c != NULL) { 
            
                serviceCaseIdSet.add(childRemoval.Service_Case__c);
                filterChildRemovalList.add(childRemoval);
            }
            if(childRemoval.Child__c != NULL) {
                childIdSet.add(childRemoval.Child__c);
            }
        }
        FieldLevelSecurity.checkFieldAccessByCriteria('Service_Case__c, Child__c, Removal_End_Date_Time__c','view','Child_Removal__c', Boolean.valueOf(Label.HasNamespace));
        existingChildRemovalList = [SELECT Id, Service_Case__c, Child__c, Removal_End_Date_Time__c FROM Child_Removal__c
                                   WHERE Service_Case__c IN :serviceCaseIdSet  AND Child__c IN :childIdSet AND 
                                   Removal_End_Date_Time__c = Null LIMIT :Utility.queryLimit];
        
        if(!existingChildRemovalList.isEmpty()) {
            for(Child_Removal__c existingChildRemoval :existingChildRemovalList) {
            
                if(!existingChildRemovalMap.containsKey(existingChildRemoval.Service_Case__c)) {
                    existingChildRemovalMap.put(existingChildRemoval.Service_Case__c, new List<Child_Removal__c>{existingChildRemoval});
                } else {
                   existingChildRemovalMap.get(existingChildRemoval.Service_Case__c).add(existingChildRemoval);
                }
            }     
        }
        
        for(Child_Removal__c filterChildRemoval :filterChildRemovalList) {
        
            List<Child_Removal__c> childHasPlacementList = existingChildRemovalMap.get(filterChildRemoval.Service_Case__c);
            
            if(childHasPlacementList != Null && childHasPlacementList.size() > 0) {
                filterChildRemoval.addError('Child already has Placement. Please exit the child from Placement.');
            }
        }
    }
}