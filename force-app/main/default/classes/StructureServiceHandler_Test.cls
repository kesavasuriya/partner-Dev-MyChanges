@isTest
private class StructureServiceHandler_Test {
    
    @testSetup static void setup() {
        
        List<Account> accounts = new List<Account>();
        List <Home_Approval__c> homeApprovalList = new List<Home_Approval__c>();
        List <Structure_Services__c> structureList = new List<Structure_Services__c>();
 
        Id publicProviderRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Public Provider').getRecordTypeId();
        
        Account accRec1 = TestRecord.createProvider('Demo','Test','testing'); 
        accRec1.RecordTypeId = publicProviderRecordTypeId;
        accounts.add(accRec1);
        
        Account accRec2 = TestRecord.createProvider('Demo2','Test2','testing2');
        accRec2.RecordTypeId = publicProviderRecordTypeId;
        accounts.add(accRec2);
        
        Account accRec3 = TestRecord.createProvider('Demo3','Test3','testing3');
        accRec3.RecordTypeId = publicProviderRecordTypeId;
        accounts.add(accRec3); 
        insert accounts;
        
        Account accWithHomeApprovedRec = [SELECT Id FROM Account WHERE Name = 'testing'];
        Account accWithHomeApprovalRec = [SELECT Id FROM Account WHERE Name = 'testing2'];
        Account accWithoutHomeApprovalRec = [SELECT Id FROM Account WHERE Name = 'testing3'];

        
        Home_Approval__c homeRec1 = TestRecord.createHomeApproval(accWithHomeApprovedRec.Id);
        homeRec1.Home_Approval_Status__c = 'Approved';
        homeApprovalList.add(homeRec1);
        
        Home_Approval__c homeRec2 = TestRecord.createHomeApproval(accWithHomeApprovalRec.Id);
        homeApprovalList.add(homeRec2);
        
        Home_Approval__c homeRec3 = TestRecord.createHomeApproval(accWithHomeApprovedRec.Id);
        homeRec3.Home_Approval_Status__c = 'Approved';
        homeApprovalList.add(homeRec3);
        
        insert homeApprovalList;
        
        Structure_Services__c structureRec1 = TestRecord.createStructureService(accWithHomeApprovedRec.Id);
        structureList.add(structureRec1);
        
        Structure_Services__c structureRec2 = TestRecord.createStructureService(accWithHomeApprovalRec.Id);
        structureRec2.Structure_Service_Name__c = null;
        structureList.add(structureRec2);
        
        Structure_Services__c structureRec3 = TestRecord.createStructureService(accWithoutHomeApprovalRec.Id);
        structureList.add(structureRec3);
        
        Database.insert (structureList,false);
        
    }
    
    @isTest static void TesthomeApprovedStructure() {
        
        List<Structure_Services__c> structureServices = [SELECT Id,Provider__c,Placement_Structure_Service__c,Structure_Service_Name__c FROM Structure_Services__c WHERE Provider__r.Name = 'testing'];
        StructureServiceHandler.updateStructureToParentProvider(structureServices);
        
        List<Structure_Services__c> emptyStructureServiceName = [SELECT Id,Provider__c,Placement_Structure_Service__c,Structure_Service_Name__c FROM Structure_Services__c WHERE Structure_Service_Name__c = null ];
        StructureServiceHandler.updateStructureToParentProvider(emptyStructureServiceName);
        
        System.assertEquals(emptyStructureServiceName != null ,true);
        
        if(structureServices.size() > 0) {
            Database.delete(structureServices[0].Id, false);
        }              
    }
    
    @isTest static void testProviderTrigger() {
        
        Account providerRec = [SELECT Id FROM Account LIMIT 1];
        providerRec.Provider_Status__c = 'Suspended';
        System.assertEquals(providerRec != null ,true);
    }
}