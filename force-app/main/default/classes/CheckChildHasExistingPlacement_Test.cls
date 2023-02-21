@isTest
private class CheckChildHasExistingPlacement_Test {
    
    @isTest static void testbeforeInsertTrigger() {
        
        Service_Case__c serviceCase = TestRecord.serviceCase('Test');
        insert serviceCase;
        
        Investigation__c investigationRec = TestRecord.investigation();
        insert investigationRec;
        
        Contact contactRecord = new Contact();
        contactRecord.LastName = 'test';
        contactRecord.Gender__c = 'Male';
        //contactRecord.Investigation__c = investigationRec.Id;
        //contactRecord.Service_Case__c = serviceCase.Id;
        contactRecord.Intake_Person_Role__c = 'Biological Child';
        insert contactRecord;
        
        Child_Removal__c childRemovalRecord = TestRecord.childRemoval(contactRecord.Id);
        childRemovalRecord.Service_Case__c = serviceCase.Id;
        childRemovalRecord.Removal_End_Date_Time__c = null;
        Database.insert(childRemovalRecord, false);
        
        List<Child_Removal__c> childRemovalRec = new List<Child_Removal__c>();
        
        Child_Removal__c childRemovalRecord1 = TestRecord.childRemoval(contactRecord.Id);
        childRemovalRecord1.Service_Case__c = serviceCase.Id;
        childRemovalRecord1.Removal_End_Date_Time__c=null;
        childRemovalRecord1.Child__c = contactRecord.Id;
		childRemovalRec.add(childRemovalRecord1);
        
        Child_Removal__c childRemovalRecord2 = TestRecord.childRemoval(contactRecord.Id);
        childRemovalRecord2.Service_Case__c = serviceCase.Id;
        childRemovalRecord2.Removal_End_Date_Time__c=null;
        childRemovalRec.add(childRemovalRecord2);

        Database.insert (childRemovalRec, false);
        List<Child_Removal__c> childRemovalRecEmpty = new List<Child_Removal__c>();
        insert childRemovalRecEmpty;
        List<Child_Removal__c> childRemovalQueryRec = [SELECT Id,Service_Case__c,Removal_End_Date_Time__c FROM Child_Removal__c WHERE Id =:childRemovalRecord.Id];
        system.assertEquals(childRemovalRecord.Id, childRemovalQueryRec[0].Id);   
    }

}