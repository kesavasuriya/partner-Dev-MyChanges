@isTest
private class GetProviderCommunityInfos_Test {

    @testSetup static void testData() {
        
        Account accountRec = TestRecord.createProvider('Test', 'Provider', 'Testuser');
        insert accountRec;
        
        Account providerRec = [SELECT Id FROM Account LIMIT 1];
        
        Organization__c orgName = new Organization__c();
        orgName.Name = 'TestOrg';
        insert orgName;
        
        Referral__c referralRec = new Referral__c();
        referralRec.Applicant_First_Name__c = 'Test';
        referralRec.Applicant_Last_Name__c = 'Referral';
        referralRec.Convert_Account_Contact__c = true;
        referralRec.Type__c = 'CPA Home';
        referralRec.CPA_Office_ID__c = accountRec.Id;
        referralRec.Applicant_Date_of_Birth__c = date.newInstance(2000,4,29);
        insert referralRec;  
        
        referralRec.Type__c = 'CPA Office';
        referralRec.Tax_Id_Type__c = 'FEIN';
        referralRec.Tax_Id__c = '00-2134567';
        referralRec.Organization_Site_Name__c = orgName.Id;
        referralRec.Administrative_Contact_First_Name__c = 'tEST1';
        referralRec.Administrative_Contact_Last_Name__c = 'LastName';
        update referralRec;
        
        referralRec.Tax_Id_Type__c = 'EIN';
        Database.update(referralRec, false);
        
        referralRec.Type__c = 'Local Department Home';
        referralRec.Tax_Id_Type__c = 'SSN';
        referralRec.Tax_Id__c = '000-21-3456';        
        Database.update(referralRec, false);
        
        referralRec.Type__c = 'CPA Home';
        referralRec.Tax_Id_Type__c = null;
        referralRec.Tax_Id__c = '00-2134567';
        update referralRec;
              
        
        Case intakeRec = TestRecord.createIntake();
        intakeRec.Origin = 'Request for services';
        insert intakeRec;
        
        
        Service_Case__c serviceCaseRec = TestRecord.serviceCase('');
        serviceCaseRec.Intake__c = intakeRec.Id;
        insert serviceCaseRec;
        
        Contact personRec = TestRecord.contact('Test', 'Person');
        //personRec.Service_Case__c = serviceCaseRec.Id;
        insert personRec;
        
        Child_Removal__c childRemovalRec = TestRecord.childRemoval(personRec.Id);
        childRemovalRec.Service_Case__c = serviceCaseRec.Id;
        insert childRemovalRec;
        
        Placement__c placementRec = TestRecord.placement(childRemovalRec.Id);
        placementRec.Provider__c = providerRec.Id;
        placementRec.Child__c = personRec.Id;
        placementRec.Service_Case__c = serviceCaseRec.Id;
        insert placementRec;

    }
    
    @isTest static void testProviderCommunity() {
        
        Account providerRec = [SELECT Id FROM Account LIMIT 1];
        Id providerId = providerRec.Id;
        
        System.assertEquals(GetProviderCommunityInfos.getProviderReferral(providerId) != null, true);
        
        System.assertEquals(GetProviderCommunityInfos.checkUserLogin(providerId,'1234567') != null, true);
        System.assertEquals(GetProviderCommunityInfos.checkUserLogin('','') == null, true);
        
        System.assertEquals(GetProviderCommunityInfos.getPlacementContacts(providerId) != null, true);
        
        System.assertEquals(GetProviderCommunityInfos.getPlacementRecord(providerId) != null, true);
        
        ContentVersion cv = new Contentversion();
        cv.title = 'ABC';
        cv.PathOnClient = 'test';
        cv.versiondata = EncodingUtil.base64Decode('This is version data');
        insert cv;
        
        ContentDocumentLink contentlink = new ContentDocumentLink();
        contentlink.LinkedEntityId = providerId;
        contentlink.contentdocumentid = [Select contentdocumentid from ContentVersion where Id =: cv.id].contentdocumentid;
        contentlink.ShareType = 'I';
        contentlink.Visibility = 'AllUsers';  
        insert contentlink;
        
        System.assertEquals(GetProviderCommunityInfos.getProviderFiles(providerId) != null, true);
   
        delete contentlink;
        
        System.assertEquals(GetProviderCommunityInfos.getProviderFiles(providerId) == null, true);  
    }
    
}