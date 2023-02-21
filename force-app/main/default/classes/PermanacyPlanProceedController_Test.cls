@isTest
private class PermanacyPlanProceedController_Test {
    
    @testSetup static void setup() {
        
        List<Permanency_Plan__c> permanencyPlans = new List<Permanency_Plan__c>();
        List<Placement__c> placements = new List<Placement__c>();
        List<Account> providers = new List<Account>();
     
        Service_Case__c serviceCaseRec = TestRecord.serviceCase('');
        insert serviceCaseRec;
        
        Account publicProviderRec = TestRecord.createProvider('Test', 'Provider', 'Test Provider');
        publicProviderRec.BillingStreet = '6000 Pioneer St,Arlington,MD 21111';
        publicProviderRec.BillingCountry = 'India';
        publicProviderRec.BillingCity = 'Chennai';
        publicProviderRec.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Public Provider').getRecordTypeId();
        providers.add(publicProviderRec);
        
        Account privateProviderRec = TestRecord.createProvider('Test', 'SS', 'Test SS');
        privateProviderRec.BillingStreet = '6000 Pioneer St,Arlington,MD 21111';
        privateProviderRec.BillingCountry = 'India';
        privateProviderRec.BillingCity = 'Chennai';
        privateProviderRec.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Private Provider Org').getRecordTypeId();
        providers.add(privateProviderRec);
        insert providers;
        
        Contact personRec = TestRecord.contact('Test', 'Person');
        //personRec.Service_Case__c = serviceCaseRec.Id;
        insert personRec;
        
        Child_Removal__c childRemovalRec = TestRecord.childRemoval(personRec.Id);
        childRemovalRec.Service_Case__c = serviceCaseRec.Id;
        insert childRemovalRec;
               
        Placement__c placementRec1 = TestRecord.placement(childRemovalRec.Id);
        placementRec1.Provider__c = publicProviderRec.Id;
        placementRec1.Child__c = personRec.Id;
        placementRec1.Service_Case__c = serviceCaseRec.Id;
        placements.add(placementRec1);
        
        Placement__c placementRec2 = TestRecord.placement(childRemovalRec.Id);
        placementRec2.CPA_Home_Id__c = privateProviderRec.Id;
        placementRec2.Provider__c = privateProviderRec.Id;
        placementRec2.Child__c = personRec.Id;
        placementRec2.Service_Case__c = serviceCaseRec.Id;
        placements.add(placementRec2);
        insert placements;
              
        Permanency_Plan__c permanencyRec1 = TestRecord.permanencyPlan();
        permanencyRec1.Placement__c = placementRec1.Id;
        permanencyPlans.add(permanencyRec1);
        
        Permanency_Plan__c permanencyRec2 = TestRecord.permanencyPlan();
        permanencyRec2.Placement__c = placementRec2.Id;
        permanencyPlans.add(permanencyRec2);
        insert permanencyPlans;
        
        Rate__c rateRec = TestRecord.createRate();
        rateRec.Permanency_Plan__c = permanencyRec1.Id;
        rateRec.Provider__c = publicProviderRec.Id;
        rateRec.Rate_Begin_Date__c = System.today();
        rateRec.Rate_End_Date__c = System.today() + 365;
        insert rateRec;
               
    }
    
    @isTest static void testApplication_Disclosure_AgreementInitialInformation() {
        
        Permanency_Plan__c getPermanencyPlan = [SELECT Id,Guardianship_Planing__c FROM Permanency_Plan__c WHERE Placement__r.Provider__r.RecordType.Name = 'Public Provider' LIMIT 1];
        List<Contact> getPersons = [SELECT Id,Name,Date_of_Birth__c,SSN__c,Applicant_or_Co_Applicant__c,No_Co_Applicant__c  FROM Contact LIMIT 1];
        Account getPublicProvider = [SELECT Id,Casevault_ProID__c, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry  FROM Account WHERE RecordType.Name = 'Public Provider' LIMIT 1];
        
        String result = PermanacyPlanProceedController.getApplicationInitialInformation(getPermanencyPlan.Id);
        PermanacyPlanProceedController.getInitialWrapper obj = (PermanacyPlanProceedController.getInitialWrapper)JSON.deserialize(result, PermanacyPlanProceedController.getInitialWrapper.class);
        
        Permanency_Plan__c getPermanencyPlanRec2 = [SELECT Id FROM Permanency_Plan__c WHERE Placement__r.Provider__r.RecordType.Name != 'Public Provider' LIMIT 1];
        String result2 = PermanacyPlanProceedController.getApplicationInitialInformation(getPermanencyPlanRec2.Id);
        PermanacyPlanProceedController.getInitialWrapper obj2 = (PermanacyPlanProceedController.getInitialWrapper)JSON.deserialize(result2, PermanacyPlanProceedController.getInitialWrapper.class);
        
        //String result3 = PermanacyPlanProceedController.getDisclosureInitialInformation(getPermanencyPlan.Id);
        //String result4 = PermanacyPlanProceedController.getDisclosureInitialInformation(getPermanencyPlanRec2.Id);
        //PermanacyPlanProceedController.getInitialWrapper obj3 = (PermanacyPlanProceedController.getInitialWrapper)JSON.deserialize(result3, PermanacyPlanProceedController.getInitialWrapper.class);
        //PermanacyPlanProceedController.getInitialWrapper obj4 = (PermanacyPlanProceedController.getInitialWrapper)JSON.deserialize(result4, PermanacyPlanProceedController.getInitialWrapper.class);
        
        String result5 = PermanacyPlanProceedController.getAgreementInitialInformation(getPermanencyPlan.Id);
        String result6 = PermanacyPlanProceedController.getAgreementInitialInformation(getPermanencyPlanRec2.Id);
        PermanacyPlanProceedController.getInitialWrapper obj5 = (PermanacyPlanProceedController.getInitialWrapper)JSON.deserialize(result5, PermanacyPlanProceedController.getInitialWrapper.class);
        PermanacyPlanProceedController.getInitialWrapper obj6 = (PermanacyPlanProceedController.getInitialWrapper)JSON.deserialize(result6, PermanacyPlanProceedController.getInitialWrapper.class);
        
        String getAnnuvalReviewsResult = PermanacyPlanProceedController.getAnnuvalReviewsInitialInformation(getPermanencyPlan.Id);
        PermanacyPlanProceedController.getInitialWrapper responseIns = (PermanacyPlanProceedController.getInitialWrapper)JSON.deserialize(getAnnuvalReviewsResult, PermanacyPlanProceedController.getInitialWrapper.class);
       // System.assertEquals(responseIns.annualReviewsPicklist.size(), 3);
        System.assertEquals(responseIns.annualReviewsList.size(), 0);
        System.assertEquals(responseIns.existingAnnualReviewRec.size(), 0);
        
        String getSuspensionResult = PermanacyPlanProceedController.getSuspensionInitialInformation(getPermanencyPlan.Id);
        PermanacyPlanProceedController.getInitialWrapper getSuspensionResultIns = (PermanacyPlanProceedController.getInitialWrapper)JSON.deserialize(getSuspensionResult, PermanacyPlanProceedController.getInitialWrapper.class);
        System.assertEquals(getSuspensionResultIns.suspensionReasonPicklist.size(), 6);
        System.assertEquals(getSuspensionResultIns.existingSuspensionRec.size(), 0);
        
        String addRateAnnualResult = PermanacyPlanProceedController.addRateAnnualRec(getPermanencyPlan.Id);
        PermanacyPlanProceedController.RateAnnualWrapper addRateAnnualResultIns = (PermanacyPlanProceedController.RateAnnualWrapper)JSON.deserialize(addRateAnnualResult, PermanacyPlanProceedController.RateAnnualWrapper.class);
        List<Rate__c> ratelst = [SELECT Id, Rate_Type__c, Rate_Begin_Date__c, Rate_End_Date__c, Rate_Approval_Date__c, Approval_Status__c FROM Rate__c WHERE Permanency_Plan__c = :getPermanencyPlan.Id];
        System.assertEquals(addRateAnnualResultIns.rateRec,ratelst);
        System.assertEquals(addRateAnnualResultIns.annualReviewRec.size(), 0);
        
        Suspension__c suspensionRec = TestRecord.createSuspension();
        suspensionRec.Permanency_Plan__c = getPermanencyPlan.Id;
        
        String upsertSuspensionResult1 = PermanacyPlanProceedController.upsertSuspension(JSON.serialize(suspensionRec));
        System.assertEquals(upsertSuspensionResult1 != null, true); 
        
        Suspension__c getSuspensionRec = [SELECT Id, Permanency_Plan__c FROM Suspension__c LIMIT 1];
        String upsertSuspensionResult2 = PermanacyPlanProceedController.upsertSuspension(JSON.serialize(getSuspensionRec));
        System.assertEquals(upsertSuspensionResult2 != null, true); 
        
        String addSuspensionResult = PermanacyPlanProceedController.addSuspensionRec(getPermanencyPlan.Id);
        List<Suspension__c> suspensionlst =(List<Suspension__c>)JSON.deserialize(addSuspensionResult, List<Suspension__c>.class);
        
        Rate__c getRateRec = [SELECT Id, Permanency_Plan__c, Provider__c, Rate_Begin_Date__c, Rate_End_Date__c  FROM  Rate__c LIMIT 1];
        //String upsertAgreementResult = PermanacyPlanProceedController.upsertAgreement(JSON.serialize(getPermanencyPlan),JSON.serialize(getRateRec) , false);
        //System.assertEquals(upsertAgreementResult, getRateRec.Id);
        //String upsertAgreementResult2 = PermanacyPlanProceedController.upsertAgreement(JSON.serialize(TestRecord.permanencyPlan()),JSON.serialize(TestRecord.createRate()) , false);
       // System.assertEquals(PermanacyPlanProceedController.upsertAgreement(JSON.serialize(TestRecord.permanencyPlan()),'', false) == null, true);
        
        System.assertEquals(PermanacyPlanProceedController.deleteSuspensionRec(JSON.serialize(getSuspensionRec)) != null, true );
        System.assertEquals(PermanacyPlanProceedController.deleteSuspensionRec('') == null, true );
        
        //System.assertEquals(PermanacyPlanProceedController.upsertApplication(JSON.serialize(getPermanencyPlan)) != null, true);
       
        System.assertEquals(PermanacyPlanProceedController.addRateAnnualRec('') == null, true);
        System.assertEquals(PermanacyPlanProceedController.addSuspensionRec('') == null, true);
        System.assertEquals(PermanacyPlanProceedController.upsertSuspension('') == null, true);
        
        //Suspension Approval Process  
        Suspension__c approveSuspensionRec = TestRecord.createSuspension();
        approveSuspensionRec.Permanency_Plan__c = getPermanencyPlan.Id;
        User supervisor = [SELECT Id FROM User WHERE Profile.Name = 'Casevault Supervisor' LIMIT 1];
        approveSuspensionRec.Supervisor_Approval__c = supervisor.Id;      
        String suspensionId = PermanacyPlanProceedController.upsertSuspension(JSON.serialize(approveSuspensionRec));
        //User casevaultUser = [SELECT Id FROM User WHERE Profile.name = 'Casevault User' LIMIT 1];
        //System.runAs(casevaultUser){
            Approval.ProcessSubmitRequest approvalSubmitReq = new Approval.ProcessSubmitRequest();
        	approvalSubmitReq.setObjectId(suspensionId);
        	approvalSubmitReq.setSubmitterId(userinfo.getUserId());
            Approval.ProcessResult approvalResult = Approval.process(approvalSubmitReq); 
        //}
    }
       
    @isTest static void testupsertApplication() {
        
        //String result = PermanacyPlanProceedController.upsertApplication(JSON.serialize(TestRecord.permanencyPlan()));
        //System.assertEquals(result != null, true);
        //System.assertEquals(PermanacyPlanProceedController.upsertApplication('') == null, true);
    }
        
    @isTest static void testupsertAnnualReviews() {
        
        //String result = PermanacyPlanProceedController.upsertAnnualReviews(JSON.serialize(TestRecord.createAnnualReview()));
        //System.assertEquals(result != null, true);
        Annual_Review__c annualReviewRec = [SELECT Id FROM Annual_Review__c LIMIT 1];
        //System.assertEquals(PermanacyPlanProceedController.upsertAnnualReviews(JSON.serialize(annualReviewRec)) != null, true);
        //System.assertEquals(PermanacyPlanProceedController.upsertAnnualReviews('') == null, true);
    }
    
    @isTest static void testCheckUserProfile() {
        
        User supervisor = [SELECT Id FROM User WHERE Profile.Name = 'Casevault Supervisor' LIMIT 1];
        PermanacyPlanProceedController ins = new PermanacyPlanProceedController();
        System.runAs(supervisor){
            System.assertEquals( false , ins.checkUserProfile() );
        }
    }
    
}