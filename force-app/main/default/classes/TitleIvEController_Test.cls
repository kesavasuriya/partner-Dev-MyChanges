@isTest
private class TitleIvEController_Test {

    @testSetup static void setup(){
        
        Case caseRec = TestRecord.createIntake();
        insert caseRec;
        
        
        Service_Case__c servicecaseRec = TestRecord.serviceCase('0000123');
        servicecaseRec.Intake__c = caseRec.Id;
        insert servicecaseRec;
        
        
        Account providerRec = TestRecord.createProvider('Test', 'User 1', 'TestUser1');
        insert providerRec;
        
        Contact contactRec = TestRecord.contact('Demo','Test');
        contactRec.Date_of_Birth__c = Date.newInstance(2016, 12, 9);
        //contactRec.Service_Case__c = servicecaseRec.Id;
        insert contactRec;
        
        
        Child_Removal__c childRemovalRecord = TestRecord.childRemoval(contactRec.Id);
        childRemovalRecord.Service_Case__c = servicecaseRec.Id;
        childRemovalRecord.Removal_End_Date_Time__c = null;
        insert childRemovalRecord;
        
        Placement__c placementRec = TestRecord.placement(childRemovalRecord.Id);
        placementRec.Child__c = contactRec.Id;
        placementRec.Provider__c = providerRec.Id;
        placementRec.Service_Case__c = servicecaseRec.Id;
        placementRec.Begin_Date__c = DateTime.newInstance(2022, 06, 8, 6, 32, 30);
        insert placementRec;
        
        Title_Iv_E__c titleIvERec = TestRecord.titleIvE(childRemovalRecord.Id, placementRec.Id, servicecaseRec.Id);
        titleIvERec.Period__c = 'Initial';
        titleIvERec.Agency_opted_to_suspend_SSI_claim_IV_E__c = 'Yes';
        titleIvERec.Eligible_Status__c = 'Pending';
        insert titleIvERec;
        
        Title_Iv_E__c titleIvERec1 = TestRecord.titleIvE(childRemovalRecord.Id, placementRec.Id, servicecaseRec.Id);
        titleIvERec1.Period__c = 'Redetermination';
        titleIvERec1.Title_Iv_E__c = titleIvERec.Id;
        titleIvERec1.Eligible_Status__c = 'Pending';
        titleIvERec1.IsThe_Agency_TheRepresentativePayee__c = 'Yes';
        titleIvERec1.Agency_opted_to_suspend_SSI_claim_IV_E__c = 'Yes';
        titleIvERec1.child_receive_SSI_SSA_during_review__c = 'Yes';
        insert titleIvERec1;
        
        titleIvERec.Title_Iv_E__c = titleIvERec1.Id;
        update titleIvERec;
        
        Income_Summary__c incomeSummaryRec = TestRecord.createIncomeSummary(titleIvERec.Id, childRemovalRecord.Child__c);
        incomeSummaryRec.In_AU__c = 'Yes';
        insert incomeSummaryRec;
        
        Person_Incomes__c personIncomeRec = TestRecord.createPersonIncome(contactRec.Id);
        personIncomeRec.Income_Summary__c = incomeSummaryRec.Id;
        insert personIncomeRec;
        
        Asset__c assetRec = new Asset__c();
        assetRec.Contact__c = childRemovalRecord.Child__c;
        insert assetRec;
 
        
        Court__c courtRec = TestRecord.createCourt();
        courtRec.Service_Case__c = servicecaseRec.Id;
        courtRec.Hearing_Outcome__c = 'Shelter Granted';
        courtRec.Petition_for_Child__c = contactRec.Id;
        insert courtRec;
        
        Deprivation__c deprivationRec = TestRecord.createDeprivation(titleIvERec.Id, contactRec.Id);
        insert deprivationRec;
        
    }
    
    @isTest static void TestgetTitleIveRecords() {
        
        Title_Iv_E__c titleIvERec = [SELECT Id, Service_Case__c, Placement__c, Title_Iv_E__c, Child_Removal__c  FROM Title_Iv_E__c  WHERE Period__c = 'Redetermination' LIMIT 1];
        
        System.assertEquals(TitleIvEController.getTitleIveRecords() != null, true);
        System.assertEquals(TitleIvEController.getInitialInfo() != null, true);
        
        System.assertEquals(TitleIvEController.getTitleIVERec(titleIvERec.Id) != null, true);
        System.assertEquals(TitleIvEController.getIncomeSummaries(titleIvERec.Id) != null, true);
        System.assertEquals(TitleIvEController.getAllPeriodTitleIVERec(titleIvERec.Id) != null, true);
        System.assertEquals(TitleIvEController.upserttitleIVE(JSON.serialize(titleIvERec)) != null, true);
        
        Title_Iv_E__c titleIvERecInsert = TestRecord.titleIvE(titleIvERec.Child_Removal__c, titleIvERec.Placement__c, titleIvERec.Service_Case__c);
        System.assertEquals(TitleIvEController.upserttitleIVE(JSON.serialize(titleIvERecInsert)) != null, true);
        System.assertEquals(TitleIvEController.upserttitleIVE('') == null, true);
        
        Title_Iv_E__c titleIvERecInsert1 = TestRecord.titleIvE(titleIvERec.Child_Removal__c, titleIvERec.Placement__c, titleIvERec.Service_Case__c);
        System.assertEquals(TitleIvEController.upsertPlacement(JSON.serialize(titleIvERec)) != null, true);
        System.assertEquals(TitleIvEController.upsertPlacement(JSON.serialize(titleIvERecInsert1)) != null, true);
        System.assertEquals(TitleIvEController.upsertPlacement('') == null, true);
        
        System.assertEquals(TitleIvEController.getDeprivationRecord(titleIvERec.Id) != null, true);
        System.assertEquals(TitleIvEController.getDeprivationRecord(null) == null, true);
        System.assertEquals(TitleIvEController.getDeprivationPicklist(titleIvERec.Id) != null, true);
        
        System.assertEquals(TitleIvEController.updateNattrive(JSON.serialize(titleIvERec)) != null, true);
        System.assertEquals(TitleIvEController.updateNattrive('') == null, true);
        
        System.assertEquals(TitleIvEController.getPlacementPickList() != null, true);
        //System.assertEquals(TitleIvEController.getEligibilityDetailRec(titleIvERec.Id) != null, true);
        System.assertEquals(TitleIvEController.updateTitleIveRec(titleIvERec.Id) == null, true);
        
        System.assertEquals(TitleIvEController.getRelatedTitleRecs(titleIvERec.Title_Iv_E__c, titleIvERec.Id, 'Initial') != null, true);
        System.assertEquals(TitleIvEController.getRelatedTitleRecs(titleIvERec.Title_Iv_E__c, titleIvERec.Id, 'Redetermination') != null, true);
        
        System.assertEquals(TitleIvEController.updateSignature('Test', JSON.serialize(titleIvERec)) != null, true);
        System.assertEquals(TitleIvEController.updateSignature('Test', '') == null, true);
        
    }
    
    @isTest static void TestgetPersonIncomes() {
        
        Contact contactRec = [SELECT Id FROM Contact LIMIT 1];
        
        System.assertEquals(TitleIvEController.getPersonIncomes(contactRec.Id) != null, true);
        

    }
    
    @isTest static void TestupdateIncomeSummaryRec() {
        
        List<Income_Summary__c> incomeSummaryLst = [SELECT Id FROM Income_Summary__c];
        incomeSummaryLst[0].In_AU__c = 'Yes';   
        
        TitleIvEController.updateIncomeSummaryRec(JSON.serialize(incomeSummaryLst));
        List<Income_Summary__c> incomeSummaryQueryLst = [SELECT Id FROM Income_Summary__c WHERE In_AU__c = 'Yes'];
        System.assertEquals(incomeSummaryQueryLst.size() > 0 , true);
        
        TitleIvEController.deleteIncomeSummaryRec(JSON.serialize(incomeSummaryQueryLst[0]));
        List<Income_Summary__c> incomeSummaryQueryLst1 = [SELECT Id FROM Income_Summary__c WHERE In_AU__c = 'Yes'];
        

    }
    
    @isTest static void TestgetCourtRecord() {
        
        Child_Removal__c childRemovalRec = [SELECT Id, Child__c, Service_Case__c  FROM Child_Removal__c LIMIT 1];
        
        System.assertEquals(TitleIvEController.getCourtRecord(childRemovalRec.Service_Case__c, childRemovalRec.Child__c) != null, true);
        

    }
    
    @isTest static void TestDeprivationMethod() {
        
        Deprivation__c deprivationRec = [SELECT Id  FROM Deprivation__c LIMIT 1];
        Contact contactRec = [SELECT Id  FROM Contact LIMIT 1];
        Title_Iv_E__c titleIvERec = [SELECT Id  FROM Title_Iv_E__c LIMIT 1];
        
        System.assertEquals(TitleIvEController.upsertDeprivationRecord(JSON.serialize(deprivationRec)) != null, true);
        System.assertEquals(TitleIvEController.upsertDeprivationRecord('') == null, true);
        
        Deprivation__c deprivationInsertRec = TestRecord.createDeprivation(titleIvERec.Id, contactRec.Id);
        System.assertEquals(TitleIvEController.upsertDeprivationRecord(JSON.serialize(deprivationInsertRec)) != null, true);
        
        TitleIvEController.deleteDeprivationRecord(deprivationRec.Id);
        List<Deprivation__c> deprivationLst = [SELECT Id  FROM Deprivation__c WHERE Id =: deprivationInsertRec.Id];
        System.assertEquals(deprivationLst.size() == 0, true);
    }
    
    @isTest static void TestonSubmitForApproval() {
        
        Title_Iv_E__c titleIvERec = [SELECT Id  FROM Title_Iv_E__c LIMIT 1];
        titleIvERec.IV_E_Specialist_Signature_Date__c = Date.today();
        User approver = [SELECT Id FROM User WHERE Profile.Name ='Casevault Supervisor' LIMIT 1];
        
        System.assertEquals(TitleIvEController.onSubmitForApproval(titleIvERec.Id, approver.Id) != null, true);
        System.assertEquals(TitleIvEController.onSubmitForApproval('', null) == null, true);
        

    }
    
    @isTest static void TestsubmitDetermineEligibleAPITest1() {
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        List<String> titleIVEIdLst = new List<String>();   
        Contact contactRec = [SELECT Id, Date_of_Birth__c, Is_a_US_citizen__c FROM Contact LIMIT 1];
        Child_Removal__c childRemovalRec = [SELECT Id FROM Child_Removal__c LIMIT 1];
        Court__c courtRec = [SELECT Id FROM Court__c LIMIT 1];
        Placement__c placementRec = [SELECT Id FROM Placement__c LIMIT 1];
            
        Title_Iv_E__c titleIvERec1 = [SELECT Id, Review_Period_Start_Date__c, Service_Case__c  FROM Title_Iv_E__c WHERE Period__c = 'Initial' LIMIT 1];
        titleIvERec1.Review_Period_Start_Date__c = Date.newInstance(2020, 12, 9);
        update titleIvERec1;
        titleIVEIdLst.add(titleIvERec1.Id);
        
        Deprivation__c deprivationRec = TestRecord.createDeprivation(titleIvERec1.Id, contactRec.Id);
        deprivationRec.Child_deprived_of_parental_support__c = 'Yes';
        insert deprivationRec;
        
        Asset__c assetRec = [SELECT Id FROM Asset__c LIMIT 1];
        assetRec.Market_Value__c = 200;
        update assetRec;
        
        
        System.assertEquals(TitleIvEController.getEligibilityDetailRecords(titleIVEIdLst) != null, true);
        Test.startTest();
        System.assertEquals(TitleIvEController.submitDetermineEligibleAPI(titleIVEIdLst) == null, true);
        Test.stopTest();
        
    }
    
    @isTest static void TestsubmitDetermineEligibleAPI() {
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        List<String> titleIvEIds = TestData();
        Test.startTest();
        System.assertEquals(TitleIvEController.submitDetermineEligibleAPI(titleIvEIds) == null, true);
        Test.stopTest();
    }
    
    
    
    @isTest static void TestCalloutWithNull() {

        Test.setMock(HttpCalloutMock.class, new EligibilityApiCallout_Test());
        List<String> titleIvEIds = TestData();
        Test.startTest();
        System.assertEquals(TitleIvEController.submitDetermineEligibleAPI(titleIvEIds) == null, true);
        Test.stopTest();
             
    }
    
    @isTest static void TestgetSearchTitles() {
        
        Contact contactRec = [SELECT Id, Casevault_PID__c, FirstName, LastName, Date_of_Birth__c, Is_a_US_citizen__c FROM Contact LIMIT 1];
        Child_Removal__c childRemovalRec = [SELECT Id FROM Child_Removal__c LIMIT 1];
        
        List<Title_Iv_E__c> titleIvELst = [SELECT Id, Title_Iv_E__c  FROM Title_Iv_E__c ];
        for(Title_Iv_E__c rec  : titleIvELst) {
            rec.Title_Iv_E__c = null;
        }
        
        update titleIvELst;
        
        TitleIvEController.searchTitleIVEIns searchTitleIns = new TitleIvEController.searchTitleIVEIns();
        searchTitleIns.clientId = contactRec.Casevault_PID__c ;
        searchTitleIns.eligibleStatus = 'Pending';
        searchTitleIns.firstName = contactRec.FirstName;
        searchTitleIns.lastName = contactRec.LastName;
        
        System.assertEquals(TitleIvEController.getSearchTitles(JSON.serialize(searchTitleIns)) != null, true);

    }
    
    Public static List<String> TestData() {
    
        List<String> titleIVEIdLst = new List<String>();   
        Contact contactRec = [SELECT Id, Date_of_Birth__c, Is_a_US_citizen__c FROM Contact LIMIT 1];
        Child_Removal__c childRemovalRec = [SELECT Id FROM Child_Removal__c LIMIT 1];
        Court__c courtRec = [SELECT Id FROM Court__c LIMIT 1];
        Placement__c placementRec = [SELECT Id FROM Placement__c LIMIT 1];
            
        Title_Iv_E__c titleIvERec1 = [SELECT Id, Review_Period_Start_Date__c, Service_Case__c  FROM Title_Iv_E__c WHERE Period__c = 'Initial' LIMIT 1];
        titleIvERec1.Review_Period_Start_Date__c = Date.newInstance(2020, 12, 9);
        update titleIvERec1;
        titleIVEIdLst.add(titleIvERec1.Id);
        
        Deprivation__c deprivationRec = TestRecord.createDeprivation(titleIvERec1.Id, contactRec.Id);
        deprivationRec.Child_deprived_of_parental_support__c = 'Yes';
        insert deprivationRec;
        
        Asset__c assetRec = [SELECT Id FROM Asset__c LIMIT 1];
        assetRec.Market_Value__c = 200;
        update assetRec;
        
             
        contactRec.Date_of_Birth__c = null;
        contactRec.Is_a_US_citizen__c = 'No';
        update contactRec;
        
        childRemovalRec.Removal_Type__c = 'Time Limited Voluntary Placement';
        update childRemovalRec;
        
        courtRec.Court_Order_Date__c = DateTime.now();
        update courtRec;
        
        placementRec.Begin_Date__c = DateTime.newInstance(2022, 06, 8, 6, 32, 30);
        update placementRec;
        
        return titleIVEIdLst;
    }
    
    @isTest static void TestEligibilityWorksheetCalculationTestData1() {

        Title_Iv_E__c titleIvERec = [SELECT Id, Review_Period_Start_Date__c, Service_Case__c  FROM Title_Iv_E__c WHERE Period__c = 'Initial' LIMIT 1];        
       
        System.assertEquals(titleIvERec.Id != null, true);
        ApexPages.currentPage().getParameters().put('id',titleIvERec.Id);
        EligibilityWorksheetCalculation test = new EligibilityWorksheetCalculation(); 
    }    
    
    @isTest static void TestEligibilityWorksheetCalculationTestData2() {

        Case caseRec = TestRecord.createIntake();
        insert caseRec;
        
        
        Service_Case__c servicecaseRec = TestRecord.serviceCase('0000123');
        servicecaseRec.Intake__c = caseRec.Id;
        insert servicecaseRec;
        
        
        Account providerRec = TestRecord.createProvider('Test', 'User 1', 'TestUser1');
        providerRec.Placement__c = true;
        insert providerRec;
        
        Contact contactRec = TestRecord.contact('Demo','Test');
        contactRec.Date_of_Birth__c = Date.newInstance(2000, 12, 9);
        //contactRec.Service_Case__c = servicecaseRec.Id;
        contactRec.Intake_Person_Role__c = 'Biological Parent;Biological Child';
        insert contactRec;
                
        Child_Removal__c childRemovalRecord = TestRecord.childRemoval(contactRec.Id);
        childRemovalRecord.Service_Case__c = servicecaseRec.Id;
        childRemovalRecord.Removal_End_Date_Time__c = null;
        insert childRemovalRecord;
        
        Placement__c placementRec = TestRecord.placement(childRemovalRecord.Id);
        placementRec.Child__c = contactRec.Id;
        placementRec.Provider__c = providerRec.Id;
        placementRec.Service_Case__c = servicecaseRec.Id;
        placementRec.Is_Placement_Reimbursible__c = 'Yes';
        placementRec.Begin_Date__c = DateTime.newInstance(2022, 06, 8, 6, 32, 30);
        insert placementRec;
        
        Title_Iv_E__c titleIvERec = TestRecord.titleIvE(childRemovalRecord.Id, placementRec.Id, servicecaseRec.Id);
        titleIvERec.Period__c = 'Initial';
        titleIvERec.Eligible_Status__c = 'Pending';
        insert titleIvERec;
        
        Title_Iv_E__c titleIvERec1 = TestRecord.titleIvE(childRemovalRecord.Id, placementRec.Id, servicecaseRec.Id);
        titleIvERec1.Period__c = 'Redetermination';
        titleIvERec1.Title_Iv_E__c = titleIvERec.Id;
        titleIvERec1.Eligible_Status__c = 'Pending';
        titleIvERec1.IsThe_Agency_TheRepresentativePayee__c = 'Yes';
        titleIvERec1.Agency_opted_to_suspend_SSI_claim_IV_E__c = '';
        titleIvERec1.child_receive_SSI_SSA_during_review__c = 'Yes';
        insert titleIvERec1;
        
        titleIvERec.Title_Iv_E__c = titleIvERec1.Id;
        update titleIvERec;
        
        Income_Summary__c incomeSummaryRec = TestRecord.createIncomeSummary(titleIvERec1.Id, childRemovalRecord.Child__c);
        incomeSummaryRec.In_AU__c = 'No';
        insert incomeSummaryRec;
        
        Person_Incomes__c personIncomeRec = TestRecord.createPersonIncome(contactRec.Id);
        personIncomeRec.Income_Summary__c = incomeSummaryRec.Id;
        insert personIncomeRec;
        
        Asset__c assetRec = new Asset__c();
        assetRec.Contact__c = childRemovalRecord.Child__c;
        insert assetRec;
 
        
        Court__c courtRec = TestRecord.createCourt();
        courtRec.Service_Case__c = servicecaseRec.Id;
        courtRec.Petition_for_Child__c = contactRec.Id;
        insert courtRec;
        
        Deprivation__c deprivationRec = TestRecord.createDeprivation(titleIvERec.Id, contactRec.Id);
        insert deprivationRec;
        
        System.assertEquals(titleIvERec.Id != null, true);
        ApexPages.currentPage().getParameters().put('id', titleIvERec1.Id);
        ApexPages.currentPage().getParameters().put('status', 'InEligible');
        EligibilityWorksheetCalculation test = new EligibilityWorksheetCalculation(); 
    }    
    
}