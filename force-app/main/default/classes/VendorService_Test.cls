@isTest
private class VendorService_Test {
    
    @testSetup static void setup() {
         
        List<Service_Case__c> serviceCaseRecords = new List<Service_Case__c>();
        List<Contact> personRecords = new List<Contact>();
        List<Account> providerRecords = new List<Account>();
        List<Structure_Services__c> structureServiceRecords = new List<Structure_Services__c>();
        List<ServiceLog__c> serviceLogRecords = new List<ServiceLog__c>();
        List<Purchase_Authorization__c> purchaseAuthorizationRecords = new List<Purchase_Authorization__c>();
        
        Service_Case__c serviceCaseRecord = new Service_Case__c();
        Contact personRecord = new Contact();
        Account providerRecord = new Account();
        Structure_Services__c structureServiceRecord = new Structure_Services__c();
        ServiceLog__c vendorServiceRecord = new ServiceLog__c();
        ServiceLog__c agencyServiceRecord = new ServiceLog__c();
        Purchase_Authorization__c purchaseAuthorizationRecord = new Purchase_Authorization__c();

        serviceCaseRecords.add(serviceCaseRecord);
        insert serviceCaseRecords;
        
        personRecord.LastName = 'Test Person';
        personRecord.Date_of_Birth__c = Date.newInstance(2000,4,29);
        personRecord.Is_a_US_citizen__c = 'Yes';
        personRecord.Gender__c = 'Male';
        personRecord.Intake_Person_Role__c = 'Biological Child';
        //personRecord.Service_Case__c = serviceCaseRecords[0].Id;
        //personRecord.Program_Area__c = 'Out of Home';
        personRecords.add(personRecord);
        insert personRecords;
        
        providerRecord.Name = 'Test Provider';
        providerRecord.Local_Department__c = 'Baltimore City';
        providerRecord.Individual_First_Name__c = 'Test';
        providerRecord.Individual_Last_Name__c = 'Provider';
        providerRecord.Tax_ID__c = '123-56-0987';
        providerRecord.BillingPostalCode = '20735';
        providerRecord.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Public Provider').getRecordTypeId();
        providerRecords.add(providerRecord);
        insert providerRecords;
        
        structureServiceRecord.Structure_Service_Name__c = 'Child Development (Paid)';
        structureServiceRecord.Placement_Structure_Service__c = 'Services';
        structureServiceRecord.Provider__c = providerRecords[0].Id;
        structureServiceRecord.Start_Date__c = Date.newInstance(2022,4,29);
        structureServiceRecords.add(structureServiceRecord);
        insert structureServiceRecords;
        
        vendorServiceRecord.Client__c = personRecords[0].Id;
        vendorServiceRecord.Provider__c = providerRecords[0].Id;
        vendorServiceRecord.Client_Program_Name__c = 'Out of Home';
        vendorServiceRecord.Date_Referred__c = Date.newInstance(2022,4,29);
        vendorServiceRecord.Frequency__c = 'Daily';
        vendorServiceRecord.Duration__c = '2 hour per visit';
        vendorServiceRecord.Estimated_Begin_Date__c = Date.newInstance(2022,4,29);
        vendorServiceRecord.Estimated_End_Date__c = Date.newInstance(2022,5,29);
        vendorServiceRecord.Structure_Services__c =  structureServiceRecords[0].Id;
        vendorServiceRecord.Type__c = 'Vendor Services';
        serviceLogRecords.add(vendorServiceRecord);
        
        agencyServiceRecord.Client__c = personRecords[0].Id;
        agencyServiceRecord.Client_Program_Name__c = 'Out of Home';
        agencyServiceRecord.AgencyServices__c = 'Adult literacy services (Agency)';
        agencyServiceRecord.Frequency__c = 'Daily';
        agencyServiceRecord.Duration__c = '2 hour per visit';
        agencyServiceRecord.Estimated_Begin_Date__c = Date.newInstance(2022,4,29);
        agencyServiceRecord.Estimated_End_Date__c = Date.newInstance(2022,5,29);
        agencyServiceRecord.Type__c = 'Agency Provided Services';
		serviceLogRecords.add(agencyServiceRecord); 
        insert serviceLogRecords;
        
        for( ServiceLog__c serviceLogRecord : serviceLogRecords) {
            if(serviceLogRecord.Type__c == 'Vendor Services') {
                purchaseAuthorizationRecord.Service__c = serviceLogRecord.Id;
            }
        }
        purchaseAuthorizationRecord.Fiscal_Category_Description__c = '7502 - Disbursements from Conserved Accounts';
        purchaseAuthorizationRecord.Start_Date__c = Date.newInstance(2022,4,29);
        purchaseAuthorizationRecord.End_Date__c = Date.newInstance(2022,5,29);
        purchaseAuthorizationRecord.Voucher_Requested__c = 'Yes';
        purchaseAuthorizationRecord.Cost_not_be_exceed__c = 250;
        purchaseAuthorizationRecord.Justification__c = 'Test';
        purchaseAuthorizationRecord.Final_Amount__c = 250;
        purchaseAuthorizationRecords.add(purchaseAuthorizationRecord);
        insert purchaseAuthorizationRecords;
            
    }
    
    static List<Service_Case__c> getServiceCaseRecords() {
        return [SELECT Id FROM Service_Case__c LIMIT 1];
    }
    
    static List<Account> getProviders() {
        return [SELECT Id,Casevault_ProID__c FROM Account LIMIT 1];
    }
    
    static List<Contact> getPersons() {
        return [SELECT Id FROM Contact LIMIT 1];
    }
    
    static List<Structure_Services__c> getStructureServiceRecords() {
        return [SELECT Id FROM Structure_Services__c LIMIT 1];
    }
    
    static List<ServiceLog__c> getServiceLogRecords(String serviceLogType) {
        return [SELECT Id,Client__c,Provider__c,Client_Program_Name__c,Date_Referred__c,Frequency__c,Duration__c,Estimated_Begin_Date__c,
                Estimated_End_Date__c,Structure_Services__c,Type__c FROM ServiceLog__c WHERE Type__c = :serviceLogType LIMIT 1 ];
    }
    
    static List<Purchase_Authorization__c> getPurchaseAuthorizationRecords() {
        return [SELECT Id,Final_Amount__c,Cost_not_be_exceed__c,Service__c,Fiscal_Category_Description__c,Start_Date__c,End_Date__c,Voucher_Requested__c,Justification__c,Funding_Approval_Status__c,Payment_Approval_Status__c,Approval_Date__c,
                Forwarded_From__c,Role__c,Select_Approver__c,Status__c FROM Purchase_Authorization__c LIMIT 1];
    }
     
    @isTest static void testServiceLogAndSearchList() {
        
        List<ServiceLog__c> getServiceLogRecords = getServiceLogRecords('Vendor Services');
        VendorService.SearchItem searchItemIns = new VendorService.SearchItem();
        ServiceLog__c createServiceLogRecord = new ServiceLog__c();

        if(getServiceLogRecords.size() > 0) {
            System.assertEquals(VendorService.createService(JSON.serialize(getServiceLogRecords[0])) != null, true );
            System.assertEquals(VendorService.getService(getServiceLogRecords[0].Id) != null, true);
            System.assertEquals(VendorService.getAllPurchaseAuthorization(getServiceLogRecords[0].Id) != null, true);
            System.assertEquals(VendorService.deleteService(getServiceLogRecords[0].Id) != null, true);
        }
        List<Account> getProvider = getProviders();
        if(getProvider.size() > 0)  {
            searchItemIns.ProviderID = getProvider[0].Casevault_ProID__c;
            searchItemIns.ProviderName = 'Test Provider';
            searchItemIns.Services = 'Child Development (Paid)';
            searchItemIns.TaxID = '123-56-0987';
            searchItemIns.Zipcode = '20735';
            System.assertEquals(VendorService.getSearchList(JSON.serialize(searchItemIns)) != null, true);
            createServiceLogRecord.Provider__c = getProvider[0].Id;
        }
        
        List<Contact> getPerson = getPersons();
        if(getPerson.size() > 0) {
            createServiceLogRecord.Client__c = getPerson[0].Id;
        } 
        createServiceLogRecord.Client_Program_Name__c = 'Out of Home';
        createServiceLogRecord.Date_Referred__c = Date.newInstance(2022,4,29);
        createServiceLogRecord.Frequency__c = 'Daily';
        createServiceLogRecord.Duration__c = '2 hour per visit';
        createServiceLogRecord.Estimated_Begin_Date__c = Date.newInstance(2022,4,29); 
        createServiceLogRecord.Estimated_End_Date__c = Date.newInstance(2022,5,29);
        List<Structure_Services__c> getStructureServiceRecords = getStructureServiceRecords();
        if( getStructureServiceRecords.size() > 0) {
            createServiceLogRecord.Structure_Services__c =  getStructureServiceRecords[0].Id;
        }
        createServiceLogRecord.Type__c = 'Vendor Services';
        System.assertEquals(VendorService.createService(JSON.serialize(createServiceLogRecord)) != null, true);
        System.assertEquals(VendorService.createService('') != null, false);
        
    }
    
    @isTest static void testgetAllService() {
        
        List<Service_Case__c> getServiceCaseRecords = getServiceCaseRecords();
        if(getServiceCaseRecords.size() > 0) {
            System.assertEquals(VendorService.getClient(getServiceCaseRecords[0].Id) != null, true);   
            System.assertEquals(VendorService.getAllService(getServiceCaseRecords[0].Id) != null, true);
            System.assertEquals(VendorService.getAllAgencyService(getServiceCaseRecords[0].Id) != null, true);
        }
        
    }
    
    @isTest static void testBlankId() {
        
        Id emptyId;
        System.assertEquals(VendorService.getAllService(emptyId) != null, false);
        System.assertEquals(VendorService.getAllAgencyService(emptyId) != null, false);
        System.assertEquals(VendorService.getService(emptyId) != null, false);
        System.assertEquals(VendorService.getPurchase(emptyId) != null, false);
        System.assertEquals(VendorService.getAllPurchaseAuthorization(emptyId) != null, false);
        System.assertEquals(VendorService.deleteService(emptyId) != null, false);
        System.assertEquals(VendorService.onSubmitForApproval(emptyId, emptyId) != null, false);
        System.assertEquals(VendorService.getClient(emptyId) != null, true);      
    }
    
    @isTest static void testPurchaseAuthorization() {
        
        List<Purchase_Authorization__c> getpurchaseAuthorizationRecords = getPurchaseAuthorizationRecords();
        VendorService.downloadPurchaseRecord();
        if(getPurchaseAuthorizationRecords.size() > 0) {
            ApexPages.currentPage().getParameters().put('id', getpurchaseAuthorizationRecords[0].Id);
            VendorService vendorServiceIns = new VendorService();
            System.assertEquals(VendorService.createPurchase(JSON.serialize(getPurchaseAuthorizationRecords[0])) != null, true);
            System.assertEquals( VendorService.getPurchase(getpurchaseAuthorizationRecords[0].Id) != null, true);
            List<User> supervisorUsers = [SELECT Id FROM User WHERE Profile.Name = 'Casevault Supervisor' LIMIT 1];
            if(supervisorUsers.size() > 0) {
                System.assertEquals( VendorService.onSubmitForApproval(getpurchaseAuthorizationRecords[0].Id, supervisorUsers[0].Id) != null, true);
            }
        }
        System.assertEquals(VendorService.createPurchase('') != null, false);
        Purchase_Authorization__c testPurchaseAuthorizationData = new Purchase_Authorization__c();
        testPurchaseAuthorizationData.Fiscal_Category_Description__c = '7502 - Disbursements from Conserved Accounts';
        testPurchaseAuthorizationData.Start_Date__c = Date.newInstance(2022,4,29);
        testPurchaseAuthorizationData.End_Date__c = Date.newInstance(2022,5,29);
        testPurchaseAuthorizationData.Voucher_Requested__c = 'Yes';
        testPurchaseAuthorizationData.Cost_not_be_exceed__c = 250;
        testPurchaseAuthorizationData.Justification__c = 'Test';
        testPurchaseAuthorizationData.Final_Amount__c = 250;
        List<ServiceLog__c> getServiceLogRecords = getServiceLogRecords('Vendor Services');
        if(getServiceLogRecords.size() > 0) {
            testPurchaseAuthorizationData.Service__c = getServiceLogRecords[0].Id;
        }
        System.assertEquals(VendorService.createPurchase(JSON.serialize(testPurchaseAuthorizationData)) != null, true);
    }
    
      
}