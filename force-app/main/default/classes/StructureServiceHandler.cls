public with sharing class StructureServiceHandler {

    public static void homeApprovedStructure(List<Structure_Services__c> newStructureList) {
    
        Set<Id> providerIds = new Set<Id>();
        Map<Id, List<Home_Approval__c>> providerHomeApprovalsMap = new Map<Id, List<Home_Approval__c>>();
        
        List<Structure_Services__c> filteredStructureList = new List<Structure_Services__c>();
        Id publicProviderRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Public Provider').getRecordTypeId();
        for (Structure_Services__c newStructureIns : newStructureList) {
        
            if (newStructureIns.Provider__c != null && newStructureIns.Placement_Structure_Service__c == 'Placement Structure') {
                filteredStructureList.add(newStructureIns);
                providerIds.add(newStructureIns.Provider__c);
            }
        }
        
        FieldLevelSecurity.checkFieldAccessByCriteria('RecordTypeId', 'view', 'Account',  Boolean.valueOf(Label.HasNamespace));
        List<Account> accList = [SELECT Id FROM Account WHERE Id IN :providerIds AND RecordTypeId = :publicProviderRecordTypeId LIMIT :Utility.queryLimit];
        Map<Id,Account> publicProviderMap = new Map<Id, Account>(accList);
        
        if (providerIds != null && providerIds.size() > 0) {
        
            FieldLevelSecurity.checkFieldAccessByCriteria('Provider__c, Home_Approval_Status__c', 'view', 'Home_Approval__c',  Boolean.valueOf(Label.HasNamespace));
            FieldLevelSecurity.checkFieldAccessByCriteria('RecordTypeId', 'view', 'Account',  Boolean.valueOf(Label.HasNamespace));
            for (Home_Approval__c homeApprovalIns : [SELECT Id, Provider__c, Home_Approval_Status__c FROM Home_Approval__c WHERE Provider__c IN :providerIds AND Provider__r.recordTypeId = :publicProviderRecordTypeId LIMIT :Utility.queryLimit]) {
            
                if(providerHomeApprovalsMap.containsKey(homeApprovalIns.Provider__c)) {
                    
                    providerHomeApprovalsMap.get(homeApprovalIns.Provider__c).add(homeApprovalIns);
                } else {
                    providerHomeApprovalsMap.put(homeApprovalIns.Provider__c, new List<Home_Approval__c>{homeApprovalIns});
                }
            }
            
        }
        
        if (filteredStructureList != null && filteredStructureList.size() > 0) {
        
            Boolean isError = true;
            for (Structure_Services__c newStructureIns : newStructureList) {   
            
                if(providerHomeApprovalsMap.containsKey(newStructureIns.Provider__c) && providerHomeApprovalsMap.get(newStructureIns.Provider__c).size() > 0) {
                
                        for(Home_Approval__c homeApprovalIns : providerHomeApprovalsMap.get(newStructureIns.Provider__c)) {
                        
                            if (homeApprovalIns.Home_Approval_Status__c == 'Approved') {
                                isError = false;
                                break;
                            } else {
                                newStructureIns.addError('Please ensure this provider have at least one home approved record'); 
                            }
                        } 
                 } else if (publicProviderMap.containsKey(newStructureIns.Provider__c)) {
                           newStructureIns.addError('Please ensure this provider have at least one home approval record'); 
                  }

            } 
        }
        
    }
    
    public static void updateStructureToParentProvider(List<Structure_Services__c> newStructureList) {
    
        Set<Id> providerIds = new Set<Id>();
        Map<Id, String> providerMap = new Map<Id, String>();
        List<Account> accList = new List<Account>();
        
        for (Structure_Services__c newStructureIns : newStructureList) {
        
            if (newStructureIns.Provider__c != null) {
            
                providerIds.add(newStructureIns.Provider__c);
                
                if (newStructureIns.Structure_Service_Name__c != null && !providerMap.containsKey(newStructureIns.Provider__c)) {
                    providerMap.put(newStructureIns.Provider__c, newStructureIns.Structure_Service_Name__c);
                } else {
                    String serviceName = providerMap.get(newStructureIns.Provider__c) + ','+ newStructureIns.Structure_Service_Name__c;
                    providerMap.put(newStructureIns.Provider__c, serviceName);
                    
                }                
            }
        }
        
        if (providerIds != null && providerIds.size() > 0) {
            
            FieldLevelSecurity.checkFieldAccessByCriteria('Placement_Service__c', 'view', 'Account',  Boolean.valueOf(Label.HasNamespace));
            for (Account providerRec : [SELECT Id, Placement_Service__c FROM Account WHERE Id IN :providerIds LIMIT :Utility.queryLimit]) {
               
               providerRec.Placement_Service__c = providerMap.get(providerRec.Id);
               accList.add(providerRec); 
            }
            
            if(accList != null && accList.size() > 0) {
                FieldLevelSecurity.checkFieldAccessByCriteria('Placement_Service__c', 'update', 'Account',  Boolean.valueOf(Label.HasNamespace));    
                update accList;
            }
        }
    }
}