public with sharing class FinanceController {
    
    @AuraEnabled
    Public static string getAllProviders() {
        
        List<Account> providers = [SELECT Id, Name, Provider_Name__c, Type__c, Casevault_ProID__c 
                                   FROM Account
                                   WHERE Provider_Status__c =: 'Active'];
        return JSON.serialize(providers);
    }
    
    @AuraEnabled
    Public static string getProvidersPayments(String providerId) {
        
        List<Provider_Payment_Summary__c> providerPayments = [SELECT Id, Name, Provider_Name__c, Start_Date__c,End_Date__c,CreatedDate,
                                                               Payment_Amount__c,Payment_Date__c,Provider_Type__c,Provider__c
                                                               FROM Provider_Payment_Summary__c
                                                               WHERE  Provider__c =: providerId ORDER BY CreatedDate DESC];
        return JSON.serialize(providerPayments);
    }
    
    @AuraEnabled
    Public static string getPayments(String providerId, Date startDate, Date endDate) {
        
        List<Payment_Summary__c> paymentSummary = [SELECT Id, Casevault_PID__c, Child__c, Start_Date__c,End_Date__c,
                                                       Payment_Amount__c,Payment_Date__c,Days_of_Service__c,
                                                       Per_Diem_Rate__c,Service_Type__c, Generated_DateTime__c 
                                                       FROM Payment_Summary__c  
                                                       WHERE  Provider__c =: providerId AND Start_Date__c >=: startDate AND 
                                                       End_Date__c <=: endDate];
        return JSON.serialize(paymentSummary);
    }
    
    @AuraEnabled
    Public static string getAllPlacement() {
        
        ValidationWrapper initWrap = new ValidationWrapper();
        
        Set<Id> providerIds = new Set<Id>();
        Set<Id> personIds = new Set<Id>();
        initWrap.placements = [SELECT Id, Name, Provider__r.Name, Provider__c, Child__r.Name, Begin_Date__c,
                                         Exit_End_Date__c, Child__c, Placement_Approval_Status__c, Placement_Structure__c 
                                         FROM Placement__c
                                         WHERE Provider__c != NULL AND Child__c != NULL];
        for(Placement__c rec : initWrap.placements) {
            
            providerIds.add(rec.Provider__c);
            personIds.add(rec.Child__c);
        }
        initWrap.paymentSummaryRecords = [SELECT Id, Supervisor_Approval__r.Name, Approved_Date_Time__c , Status__c, Days_of_Service__c, Payment_Amount__c ,Provider__c, Person__c,Person__r.Name,
                                          Provider__r.Name, Start_Date__c, End_Date__c 
                                         FROM Payment_Summary__c WHERE Provider__c IN:providerIds AND Person__c IN:personIds AND Payment_Generated__c=true ORDER BY CreatedDate DESC];
                                       
        initWrap.currentTime = DateTime.now();
        return JSON.serialize(initWrap);
    }
    
    @AuraEnabled
    Public static string getFlowVersion() {
        
        FlowDefinitionView flowDef = [SELECT ApiName, Label, ActiveVersionId FROM FlowDefinitionView WHERE IsActive=true AND ApiName='Payment_Generation_Schedule_Flow' LIMIT 1];
        return flowDef.ActiveVersionId;
    }
    
    @AuraEnabled
    public static String onSubmitForApproval(String paymentSummaryId, Id selectedSupervisorUserId){        
        
        if (String.isNotBlank(paymentSummaryId) && String.isNotBlank(selectedSupervisorUserId)) {
            Payment_Summary__c paymentSummaryRec =  new Payment_Summary__c ();
            paymentSummaryRec.Id = paymentSummaryId;
            paymentSummaryRec.Supervisor_Approval__c  = selectedSupervisorUserId;
            update paymentSummaryRec;
            Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest(); 
            req.setComments('Submit For Approval');        
            req.setObjectId(paymentSummaryId);
            Approval.ProcessResult approvalResult = Approval.process(req);
            return JSON.serialize(approvalResult);
        } else {
            return null;
        }   
        
    }
    
    Public class ValidationWrapper {
        @AuraEnabled
        Public List<Placement__c> placements;
		@AuraEnabled
        Public DateTime currentTime;
        @AuraEnabled
        Public List<Payment_Summary__c> paymentSummaryRecords;
    }
    
}