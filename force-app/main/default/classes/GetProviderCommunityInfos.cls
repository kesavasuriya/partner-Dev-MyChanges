Global class GetProviderCommunityInfos {
    
    @AuraEnabled
    global static String getProviderDetails(String providerId) {
        
        CommunityWrapper wrapperObj = new CommunityWrapper();
        if(String.isNotBlank(ProviderId)){
           wrapperObj.providers = [SELECT Id, Name, Casevault_ProID__c, 
                                   Individual_First_Name__c, Provider_Status__c, Referral_ID__c,
                                   Number_of_Beds__c, CreatedDate, RecordType.Name
                                   FROM Account WHERE Id = :providerId LIMIT :Utility.queryLimit];
           if(wrapperObj.providers.size() > 0) {
                for (Account acc :wrapperObj.providers){
                    wrapperObj.referralId.add(acc.Referral_ID__c);
                }
            } else {
                wrapperObj.referralId = null;
            }
            return JSON.serialize(wrapperObj);
        } else {
            return null;
        }
    }
    
    @AuraEnabled
    global static String getProviderReferral(String providerId) {

        String ProviderDetails = getProviderDetails(providerId);
        CommunityWrapper wrapperObj = new CommunityWrapper();
        wrapperObj = (CommunityWrapper)JSON.deserialize(ProviderDetails,CommunityWrapper.class);
     
        if(wrapperObj.referralId != Null && wrapperObj.referralId.size() > 0) {
            return JSON.serialize([SELECT Id, Name, Converted__c, Referal_status__c, CreatedBy.Name, CreatedDate
                FROM Referral__c WHERE Id  =:wrapperObj.referralId LIMIT :Utility.queryLimit]);
        } else {
            return null;
        }
    }
    
    @AuraEnabled
    public static String checkUserLogin(String providerId, String taxId) {
        CommunityWrapper wrapperObj = new CommunityWrapper();
        
        if(String.isNotBlank(providerId) && String.isNotBlank(taxId)) {
        return JSON.serialize([SELECT Id, Name FROM Account WHERE Casevault_ProID__c = :providerId AND Tax_ID__c = :taxId LIMIT :Utility.queryLimit
                              ]);
        } else {
            return null;
        }
    }
    
    @AuraEnabled
    public static String getPlacementContacts(String providerId) {
        
        String childIds = getPlacementRecord(providerId);
        CommunityWrapper communityWrap = new CommunityWrapper ();
        communityWrap = (CommunityWrapper)JSON.deserialize(childIds,CommunityWrapper.class);
        return JSON.serialize([SELECT Id, Name, Email, Intake_Person_Role__c, Date_of_Birth__c
                               FROM Contact WHERE Id IN : communityWrap.placementContactIds LIMIT :Utility.queryLimit] );
    }
    
    @AuraEnabled
    public static string getPlacementRecord(String providerId) {
        
        set<Id> serviceCaseIds = new set<Id>();
        List<Id> contactIds = new List<Id>();
        Set<Id> IntakeIds = new Set<Id>();
        CommunityWrapper wrapperObj = new CommunityWrapper();
        List<Placement__c> placementRecord = [SELECT Id, Name, Child__c, Child__r.Id, Child__r.Name, Child__r.Intake_Person_Role__c, 
                                     Child__r.Date_of_Birth__c, Child__r.AccountId,
                                    Exit_Approval_Status__c, Provider__r.Name, Begin_Date__c, Service_Case__c, 
                                     Service_Case__r.Intake__r.CaseNumber,                                                                  // Arun 12/1/2022
                                     Service_Case__r.Intake__r.contact__r.Name,  Service_Case__r.Intake__r.Origin, 
                                    Service_Case__r.Intake__r.Status  FROM Placement__c
                                    WHERE Exit_Approval_Status__c !='Approved' AND Child__c !=null
                                    AND Provider__c = :providerId LIMIT :Utility.queryLimit];
        wrapperObj.placementList = placementRecord;
        
        for(Placement__c p : placementRecord) {
            if(p.Service_Case__c != null) {
                serviceCaseIds.add(p.Service_Case__c);
                
            }
            contactIds.add(p.Child__c);
        }
        wrapperObj.placementContactIds = contactIds;
        
        if(contactIds.size() > 0) {
        
            wrapperObj.contactList = [SELECT Id, Name, Email, Intake_Person_Role__c, Date_of_Birth__c FROM Contact 
                                      WHERE Id IN :contactIds ORDER BY CreatedDate DESC LIMIT :Utility.queryLimit];
        }
        
        if(serviceCaseIds.size() > 0) {
        
            List<Service_Case__c> serviceCaseRecord = [SELECT Id, Name, Head_of_Household__c, Number_of_days__c ,
                                                   Status__c,Intake__r.CaseNumber,Intake__c, Intake__r.Contact.Name,
                                      Intake__r.Origin, Intake__r.Status FROM Service_Case__c WHERE Id IN :serviceCaseIds LIMIT :Utility.queryLimit];
 
            wrapperObj.ServiceCaseList = serviceCaseRecord;
        }
        
        if (wrapperObj.ServiceCaseList != null && wrapperObj.ServiceCaseList.size() > 0 ) {
             for(Service_Case__c serviceCase : wrapperObj.ServiceCaseList) {
                if(serviceCase.Intake__c != null) {
                    IntakeIds.add(serviceCase.Intake__c);
                }
            }
        }
        if(IntakeIds.size() > 0) {
        
            List<Case> caseRecord = [SELECT Id, CaseNumber, Origin, Subject, Status FROM Case  WHERE Id IN :IntakeIds LIMIT :Utility.queryLimit];
            wrapperObj.Intakes  = caseRecord;
        }
        
        
        return JSON.serialize(wrapperObj);
    }
    
    @AuraEnabled
    global static String getProviderFiles(String providerId) {
        
        List<ContentDocumentLink> contentDocumentList = [SELECT Id,ContentDocumentId,ContentDocument.Title FROM ContentDocumentLink WHERE LinkedEntityId = :providerId LIMIT :Utility.queryLimit];
        if(contentDocumentList.size() > 0) {
            
            Set<Id> contentDocumentId = new Set<Id>();
            Set<Id> contentVersionId = new Set<Id>();
                
            for(ContentDocumentLink cdl : contentDocumentList){
                contentDocumentId.add(cdl.ContentDocumentId);
            }
                
            List<ContentVersion> contentVersionList = [SELECT Id, Title, ContentDocumentId FROM   ContentVersion 
                                                        WHERE  ContentDocumentId IN : contentDocumentId ORDER BY CreatedDate DESC LIMIT :Utility.queryLimit];
            return JSON.serialize(contentVersionList);
        } else {
            return null;
        }
            
    }
    
    public class CommunityWrapper{
        
        @AuraEnabled
        public List<Placement__c> placementList;
        @AuraEnabled
        public List<Service_Case__c> ServiceCaseList;
        @AuraEnabled
        public List<Contact> contactList;
        @AuraEnabled
        public List<Account> providers;
        @AuraEnabled
        public List<Case> Intakes;
        @AuraEnabled
        public List<Account> account;
        @AuraEnabled
        public List<String> providerTaxId = new List<String>();
        @AuraEnabled
        public List<String> referralId = new List<String>();
         @AuraEnabled
        public List<String> placementContactIds;
        
    }
}