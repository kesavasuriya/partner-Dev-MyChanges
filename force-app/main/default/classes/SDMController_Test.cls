@isTest
private class SDMController_Test {
    
    @testSetup static void setup() {
        /*CPS_Response__c createCPS = new CPS_Response__c();
        createCPS.Response_Id__c = 1400;
        createCPS.Response__c='Testing';
        insert createCPS;*/
        
        Case caseRec = TestRecord.createIntake();
        insert caseRec;
        
        Investigation__c investigationRec = TestRecord.investigation();
        insert investigationRec;
      
        Service_Case__c createCase = TestRecord.serviceCase('0000190');
        insert createCase;
        
        Contact contact1 = TestRecord.contact('test','test');
        //contact1.Service_Case__c = createCase.Id;
        //contact1.Intake__c = caseRec.Id;
        //contact1.Investigation__c = investigationRec.Id;
        insert contact1;
        Contact c1 = new Contact();
        c1.Id = contact1.Id;
        c1.Intake_Person_Role__c = 'Alleged Victim';
        update c1;
        
        Contact contact2 = TestRecord.contact('test2', 'test2');
        //contact2.Service_Case__c = createCase.Id;
        //contact2.Intake__c = caseRec.Id;
        //contact2.Investigation__c = investigationRec.Id;
        insert contact2;
               
        Contact c2 = new Contact();
        c2.Id = contact2.Id;
        c2.Intake_Person_Role__c = 'Alleged Maltreator';
        update c2;
        
        List<CPS_Response__c> cpsLst = new List<CPS_Response__c>();
        CPS_Response__c cpsResponseRec = new CPS_Response__c ();
        cpsResponseRec.Response_Id__c = 1;
        cpsResponseRec.Response__c = 'test1';
        cpsLst.add(cpsResponseRec);
        
        CPS_Response__c cpsResponseRec2 = new CPS_Response__c ();
        cpsResponseRec2.Response_Id__c = 2;
        cpsResponseRec2.Response__c = 'test2';
        cpsLst.add(cpsResponseRec2);
        insert cpsLst;
        
        SDM_Rule__c sdmRec = new SDM_Rule__c ();
        sdmRec.CPS_Response_Type__c = 'CPS-IR';
        sdmRec.X33446__c = 'YES';
        sdmRec.Abuse_Type__c = 'Sexual Abuse';
        //sdmRec.Abuse_Name__c = 'Sexual molestation of a child';
        insert sdmRec;
        
        SDM__c createSDM = new SDM__c();
        createSDM.Service_Case__c = createCase.Id;
        createSDM.Alleged_Victim_s__c = contact1.Id;
        createSDM.Alleged_Maltreator_s__c = contact2.Id;
        createSDM.Intake__c = caseRec.Id;
        insert createSDM;
    }
    
    @isTest static void TestgetExpenses() {
        
        Case getIntakeRec = [SELECT Id FROM Case LIMIT 1];
        String result = SDMController.getExpenses(getIntakeRec.Id);
        SDMController.SDMWrapper SDMWrapperIns = (SDMController.SDMWrapper)JSON.deserialize(result, SDMController.SDMWrapper.class);
        List<SDM__c> lst = [SELECT Id FROM SDM__c LIMIT 1];
        String result2 = SDMController.getCPSResponse(lst[0].Id, SDMWrapperIns.CPSResponseMap);
        system.assertEquals(result2 == null, true);
        
    }
    

}