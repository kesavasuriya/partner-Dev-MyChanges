public class PaymentSummaryController {
    
    @AuraEnabled
    Public static string getPickvalues() {
        
        Wrapper initWrap = new Wrapper();
		initWrap.placementStructurePicklist = Utility.getPicklistinfo('CWS_Contract__c','Placement_Structure__c',false);
        return JSON.serialize(initWrap);
    }
    @AuraEnabled
    Public static string getRatevalues(String providerId, String structure) {
        
        Wrapper initWrap = new Wrapper();
        
		List<CWS_Contract__c> rateList = [SELECT Id, Estimated_Rate_Value__c , Per_Diem_Rate__c  FROM CWS_Contract__c WHERE Provider__c =:providerId AND Placement_Structure__c  =:structure LIMIT 1];
        if(rateList != null && rateList.size() >0) {
            initWrap.rateRecord = rateList[0];         
        }
       return JSON.serialize(initWrap);

    }
    
    public class Wrapper {
        @AuraEnabled
        public List<Utility.pickListWrap> placementStructurePicklist; 
        @AuraEnabled
        public CWS_Contract__c rateRecord;
    }

}