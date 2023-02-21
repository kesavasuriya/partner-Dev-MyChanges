public class PaymentGenerationDailyRuns Implements Schedulable {
    
    public void execute(SchedulableContext sc) {
        
        generatePayment();
    }
    
    public void generatePayment() {
        
        //initialization of publicProviderRateMap list; 
        Map<String,Decimal> publicProviderRateMap = new Map<String,Decimal>();
        //initialization of paymentSummaryList list; 
        List<Payment_Summary__c > paymentSummaryList = new List<Payment_Summary__c >();
        //Query publicProviderRate; 
        List<Public_Provider_Rate__mdt> publicProviderRate = [SELECT Id, Estimated_Rate_Value__c, Placement_Structure__c 
                                                              FROM Public_Provider_Rate__mdt];
        
        //Iterate public provider and put in map placementstructure,ratevalue;
        for(Public_Provider_Rate__mdt publicRate : publicProviderRate) {
            
            publicProviderRateMap.put(publicRate.Placement_Structure__c,publicRate.Estimated_Rate_Value__c);
        }
        
        //initialization of beginDateChangedRecord list;
        List<Placement__History> beginDateChangedRecord = new List<Placement__History>();
        //initialization of endDateChangedRecord list;
        List<Placement__History> endDateChangedRecord = new List<Placement__History>();
        //initialization of placementIds set;
        Set<Id> placementIds = new Set<Id>();
        //Query placementHistoryRecords;
        List<Placement__History> placementHistoryRecord =  [SELECT Id, ParentId, OldValue, NewValue, Field 
                                                            FROM Placement__History 
                                                            WHERE CreatedDate = TODAY]; 
        
        //Iterate placement History Record to separate begin date or end date changed record;
        for(Placement__History ph : placementHistoryRecord) {
            
            //Check for begin date changed;
            IF(ph.OldValue != NULL && ph.Field == 'Begin_Date__c') {
                
                beginDateChangedRecord.add(ph);
                placementIds.add(ph.ParentId);
            
            //Check for end date changed;
            } ELSE IF(ph.OldValue != NULL && ph.Field == 'Exit_Date_Time__c') {
                
                endDateChangedRecord.add(ph);
                placementIds.add(ph.ParentId);
            }
        }
        
        //Query placement record and put in map Id,Placement
        Map<Id,Placement__c> placementMap = new Map<Id,Placement__c>([SELECT Id, Provider__r.RecordType.DeveloperName, Placement_Approval_Status__c, 
                                                                      Child__c, Placement_Structure__c, Provider__c
                                                                      FROM Placement__c WHERE Id IN:placementIds ORDER BY CreatedDate DESC]);
        
        //initialization paymentRec object
        Payment_Summary__c paymentRec = new Payment_Summary__c();
        
        //Iterate beginDateChangedRecord
        for(Placement__History beginDateRec : beginDateChangedRecord){
            
            paymentRec = new Payment_Summary__c();
            
            //Check for Begin date added;
            IF(DATE.valueOf(beginDateRec.OldValue) > DATE.valueOf(beginDateRec.NewValue)) {
                
                paymentRec.End_Date__c = DATE.valueOf(beginDateRec.OldValue);
                paymentRec.Start_Date__c = DATE.valueOf(beginDateRec.NewValue);
                paymentRec.Person__c = placementMap.get(beginDateRec.ParentId).Child__c;
                paymentRec.Provider__c = placementMap.get(beginDateRec.ParentId).Provider__c;
                paymentRec.Payment_Generated__c = true;
                paymentRec.Service_Type__c = placementMap.get(beginDateRec.ParentId).Placement_Structure__c;
                paymentRec.Per_Diem_Rate__c = publicProviderRateMap.get(paymentRec.Service_Type__c);
            //Adding payment Record to Payment summary List;
                paymentSummaryList.add(paymentRec);
            }
        }
        
        for(Placement__History endDateRec : endDateChangedRecord){
            
            paymentRec = new Payment_Summary__c();
            
            //Check for Begin date added;
            IF(DATE.valueOf(endDateRec.OldValue) < DATE.valueOf(endDateRec.NewValue)) {
                
                paymentRec.End_Date__c = DATE.valueOf(endDateRec.NewValue);
                paymentRec.Start_Date__c = DATE.valueOf(endDateRec.OldValue);
                paymentRec.Person__c = placementMap.get(endDateRec.ParentId).Child__c;
                paymentRec.Provider__c = placementMap.get(endDateRec.ParentId).Provider__c;
                paymentRec.Payment_Generated__c = true;
                paymentRec.Service_Type__c = placementMap.get(endDateRec.ParentId).Placement_Structure__c;
                paymentRec.Per_Diem_Rate__c = publicProviderRateMap.get(paymentRec.Service_Type__c);
            //Adding payment Record to Payment summary List;
                paymentSummaryList.add(paymentRec);
            }
        }
        
        IF(paymentSummaryList.size() > 0) {
            insert paymentSummaryList;
        }
        
        
        
    }
    
}