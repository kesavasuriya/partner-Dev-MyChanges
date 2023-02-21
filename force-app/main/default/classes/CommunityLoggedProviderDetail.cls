public  with sharing class CommunityLoggedProviderDetail {
    
    @AuraEnabled
    public static Id getCurrentProvider() {
    	List<User> u = [SELECT Name, AccountId FROM User WHERE Id = :UserInfo.getUserId() LIMIT :Utility.queryLimit];
    	if(!u.isEmpty()) {
            Id accountId = u[0].AccountId;
            //AccountId is populated if you run this as a community user /portal users .For admin Users this value is null ((((
       	 return accountId;
        } else{
            return null;
        }
    }
    
    @AuraEnabled
    public static String getProviderReferral() {
		String providerId = getCurrentProvider();
        String ProviderDetails = getProviderDetails();
        CommunityWrapper wrapperObj = new CommunityWrapper();
        wrapperObj = (CommunityWrapper)JSON.deserialize(ProviderDetails,CommunityWrapper.class);
        if (wrapperObj.referralId != Null && wrapperObj.referralId.size() > 0) {
        	return JSON.serialize([SELECT Id, Name, Converted__c, Referal_status__c, CreatedBy.Name, CreatedDate
                FROM Referral__c WHERE Id =:wrapperObj.referralId LIMIT :Utility.queryLimit]);
        } else {
            return null;
        }
    }

    @AuraEnabled
    public static String getProviderDetails() {
        
        CommunityWrapper wrapperObj = new CommunityWrapper();
        String providerId = getCurrentProvider();
        if(String.isNotBlank(ProviderId)){
           wrapperObj.providers = [SELECT Id, Name, Casevault_ProID__c, 
                                   Individual_First_Name__c, Provider_Status__c, Tax_ID__c, Referral_ID__c, 
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
    public static String getPlacementContacts() {
        communityWrapper communityWrap = new communityWrapper();
        
        String childIds = getProviderPlacement();
        communityWrap = (CommunityWrapper)JSON.deserialize(childIds,CommunityWrapper.class);
        return JSON.serialize([SELECT Id, Name, Email, Intake_Person_Role__c, Date_of_Birth__c
                               FROM Contact WHERE Id IN :communityWrap.placementContactIds LIMIT :Utility.queryLimit]);
    }
    
    @AuraEnabled
    public static String getProviderPlacement() {
        
        communityWrapper communityWrap = new communityWrapper();
        Id ProviderId = getCurrentProvider();
        Set<Id> contactIds = new Set<Id>();
        
        List<Placement__c> placementRecord = [SELECT Id, Name, Child__c, Child__r.Name, Exit_Approval_Status__c,
										 Provider__r.Name, Begin_Date__c 
                                     	 FROM Placement__c
                                    	 WHERE Exit_Approval_Status__c !='Approved' AND Child__c !=null
           	                        	 AND Provider__c = :ProviderId LIMIT :Utility.queryLimit];
        communityWrap.placementList = placementRecord ;
        List<String> contactId = new List<String>();
        if(placementRecord != Null &&placementRecord.size() > 0 ) {
        	for(Placement__c placement:placementRecord) {
                	string childId = placement.Child__c;
                	contactId.add(placement.Child__c);
        	}
            communityWrap.placementContactIds = contactId;
        }
        communityWrap.contactList = [SELECT Id, Name, Email, Intake_Person_Role__c, Date_of_Birth__c
                               FROM Contact WHERE Id IN :contactId LIMIT :Utility.queryLimit];
        return JSON.serialize(communityWrap);
        
    }
    
    public class communityWrapper {
        List<Placement__c> placementList;
        @AuraEnabled
        public List<String> placementContactIds;
        @AuraEnabled
        public List<Account> providers;
         @AuraEnabled
        public List<Contact> contactList;
        @AuraEnabled
        public List<String> providerTaxId = new List<String>();
        @AuraEnabled
        public List<String> referralId = new List<String>();
    }
}