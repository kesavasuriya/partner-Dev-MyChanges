public with sharing class EligibilityApiCallout {
    
    public static Title_Iv_E__c makeCallout(String titleIveid, String orderType, String remDtEarlierThnCtOrderDt ,String spRelClIdsameAsCtw,String usCorQA ,Integer ageDuringAFDCmonth, String depParentalSupp,String deprivationFactor,Integer familySize ,Double totalAvailableIncome, Double assetValue,String placementReimbursable, String plcmntDtErlThnRemDtr, String childReceivingSSIOrSSADuringReviewPeriod, String hasTheAgencyOptedToSuspendTheSSIPAymentAndClaimIVE, String isTheAgencyTheRepresentativePayee) {
        
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('http://34.239.218.191:8081/cv/rules/api/fire-all');
        fromJSON eligibilityReqParam = new fromJSON();
        eligibilityReqParam.orderType = orderType;
        eligibilityReqParam.courtStatus.remDtEarlierThnCtOrderDt = remDtEarlierThnCtOrderDt;
        eligibilityReqParam.homeRemoval.spRelClIdsameAsCtw = spRelClIdsameAsCtw;
        eligibilityReqParam.demographics.usCorQA = usCorQA;
        eligibilityReqParam.demographics.ageDuringAFDCmonth = ageDuringAFDCmonth;
        eligibilityReqParam.demographics.childReceivingSSIOrSSADuringReviewPeriod = childReceivingSSIOrSSADuringReviewPeriod;
        eligibilityReqParam.demographics.isTheAgencyTheRepresentativePayee = isTheAgencyTheRepresentativePayee;
        eligibilityReqParam.demographics.hasTheAgencyOptedToSuspendTheSSIPAymentAndClaimIVE = hasTheAgencyOptedToSuspendTheSSIPAymentAndClaimIVE;
        eligibilityReqParam.deprivation.depParentalSupp =depParentalSupp;
        eligibilityReqParam.deprivation.deprivationFactor = deprivationFactor;
        eligibilityReqParam.familySizeAndSona.familySize = familySize;
        eligibilityReqParam.income.totalAvailableIncome = totalAvailableIncome;
        eligibilityReqParam.asset.assetValue = assetValue;
        eligibilityReqParam.placement.placementReimbursable = placementReimbursable;
        eligibilityReqParam.placement.plcmntDtErlThnRemDtr = plcmntDtErlThnRemDtr;
        
        request.setHeader('Content-Type','application/json');
        request.setBody(JSON.serialize(eligibilityReqParam));
        request.setMethod('POST');
        HttpResponse response = http.send(request);
        if(response.getStatusCode() == 200) {
            
            fromJSON eligibilityResponse = (fromJSON)JSON.deserialize(response.getBody(),fromJSON.class);
            return CreateTitleIveRecord(eligibilityResponse,titleIveid);
            
        } else {
            return null;
        }
    }
    
    public class fromJSON {
        public String orderType;    //courtorder
        public String finalStatus;
        public cls_courtStatus courtStatus;
        public cls_homeRemoval homeRemoval;
        public cls_demographics demographics;
        public cls_deprivation deprivation;
        public cls_familySizeAndSona familySizeAndSona;
        public cls_income income;
        public cls_asset asset;
        public cls_placement placement;
        public cls_removalType removalType; 
        public fromJSON(){
            courtStatus = new cls_courtStatus();    
            homeRemoval = new cls_homeRemoval();    
            demographics = new cls_demographics();    
            deprivation = new cls_deprivation();    
            familySizeAndSona = new cls_familySizeAndSona();    
            income = new cls_income();    
            asset = new cls_asset();    
            placement = new cls_placement();
            removalType = new cls_removalType();
            
        }
    }
    public class cls_courtStatus {
        public String remDtEarlierThnCtOrderDt; //Yes
        public String status;
        public Integer message;
        public String eligibility;
        
    }
    public class cls_homeRemoval {
        public String spRelClIdsameAsCtw;   //Yes
        public String status;
        public Integer message;
        public String eligibility;
        
    }
    
    public class cls_demographics {
        public String usCorQA;  //Yes
        public Integer ageDuringAFDCmonth;  //21
        public String childReceivingSSIOrSSADuringReviewPeriod;
        public String isTheAgencyTheRepresentativePayee;
        public String hasTheAgencyOptedToSuspendTheSSIPAymentAndClaimIVE;
        public String status;
        public Integer message;
        public String eligibility;  
        
    }
    
    public class cls_deprivation {
        public String depParentalSupp;  //Yes
        public String deprivationFactor;    //None
        public String status;
        public Integer message;
        public String eligibility;
          
    }
    
    public class cls_familySizeAndSona {
        public Integer familySize;  //3
        public Double sona;
        public String status;
    }
    
    public class cls_income {
        public Double totalAvailableIncome; //300
        public String status;
        public Integer message;
        public String eligibility;
        
    }
    
    public class cls_asset {
        public String eligibility;
        public Double assetValue;   //250
        public String status;
        public Integer message;
        
    }
    public class cls_placement {
        public String placementReimbursable;    //Yes
        public String plcmntDtErlThnRemDtr; //Yes
        public String status;
        public Integer message;
        public String eligibility;
           
    }
    
    public class cls_removalType {
        public String eligibility;
        public String status;
        public Integer message;
        
    }
    
    public static Title_Iv_E__c getTitleIveRec(Id titleiveId) {
        
        FieldLevelSecurity.checkFieldAccessByCriteria('Review_Period_End_Date__c,Placement__c,Child_Removal__c,Service_Case__c,Review_Period_Start_Date__c,Period__c',
                                                      'view','Title_Iv_E__c', Boolean.valueOf(Label.HasNamespace));
        Title_Iv_E__c titleIveList = [SELECT Id,Review_Period_End_Date__c,Placement__c,Child_Removal__c,Service_Case__c, Review_Period_Start_Date__c,Period__c FROM Title_Iv_E__c 
                                      WHERE Id =:titleiveId LIMIT :Utility.queryLimit];
        return(titleIveList);
    }
    
    public static Title_Iv_E__c CreateTitleIveRecord(fromJSON eligibilityResponse,Id titleIveid ) {
                
        FieldLevelSecurity.checkFieldAccessByCriteria('Order_Type__c,CourtStatus_RemDtEarlierThnCtOrderDt__c,CourtStatus_Status__c,CourtStatus_Message__c,'+
        'HomeRemoval_SpRelClIdsameAsCtw__c,HomeRemoval_Status__c,HomeRemoval_Message__c,Demographics_UsCorQA__c,Demographics_AgeDuringAFDCmonth__c,Demographics_ChildReceivingSSIOrSSA__c,Demographics_IsTheAgency__c,Demographics_HasTheAgencyOptedToSuspend__c,'+
        'Demographics_Status__c,Demographics_Message__c,Deprivation_DepParentalSupp__c,Deprivation_DeprivationFactor__c,Deprivation_Status__c,'+
        'Deprivation_Message__c,FamilySizeAndSona_FamilySize__c,FamilySizeAndSona_Sona__c,Income_TotalAvailableIncome__c,Income_Status__c,'+
        'Income_Message__c,Asset_AssetValue__c,Asset_Status__c,Asset_Message__c,Placement_PlacementReimbursable__c,Placement_PlcmntDtErlThnRemDtr__c,'+
        'Placement_Status__c,Placement_Message__c,RemovalType_Status__c,RemovalType_Message__c,FinalStatus__c,Service_Case__c,Placement__c,Child_Removal__c,CalloutDateTime__c,Title_Iv_E__c,'+
        'Review_Period_End_Date__c, Review_Period_Start_Date__c, Period__c', 'create','Title_Iv_E__c', Boolean.valueOf(Label.HasNamespace));
        Title_Iv_E__c titleIveRec = new Title_Iv_E__c();
        Title_Iv_E__c rec = getTitleIveRec(titleIveid);
        titleIveRec.Order_Type__c = eligibilityResponse.orderType;
        titleIveRec.CourtStatus_RemDtEarlierThnCtOrderDt__c = eligibilityResponse.courtStatus.remDtEarlierThnCtOrderDt;
        titleIveRec.CourtStatus_Status__c = eligibilityResponse.courtStatus.status;
        titleIveRec.CourtStatus_Message__c = eligibilityResponse.courtStatus.message;
        titleIveRec.HomeRemoval_SpRelClIdsameAsCtw__c  = eligibilityResponse.homeRemoval.spRelClIdsameAsCtw;
        titleIveRec.HomeRemoval_Status__c = eligibilityResponse.homeRemoval.status;
        titleIveRec.HomeRemoval_Message__c = eligibilityResponse.homeRemoval.message;
        titleIveRec.Demographics_UsCorQA__c = eligibilityResponse.demographics.usCorQA;
        titleIveRec.Demographics_AgeDuringAFDCmonth__c = eligibilityResponse.demographics.ageDuringAFDCmonth;
        titleIveRec.Demographics_ChildReceivingSSIOrSSA__c = eligibilityResponse.demographics.childReceivingSSIOrSSADuringReviewPeriod;
        titleIveRec.Demographics_IsTheAgency__c = eligibilityResponse.demographics.isTheAgencyTheRepresentativePayee;
        titleIveRec.Demographics_HasTheAgencyOptedToSuspend__c = eligibilityResponse.demographics.hasTheAgencyOptedToSuspendTheSSIPAymentAndClaimIVE;
        titleIveRec.Demographics_Status__c = eligibilityResponse.demographics.status;
        titleIveRec.Demographics_Message__c = eligibilityResponse.demographics.message;
        titleIveRec.Deprivation_DepParentalSupp__c = eligibilityResponse.deprivation.depParentalSupp;
        titleIveRec.Deprivation_DeprivationFactor__c = eligibilityResponse.deprivation.deprivationFactor;
        titleIveRec.Deprivation_Status__c = eligibilityResponse.deprivation.status;
        titleIveRec.Deprivation_Message__c = eligibilityResponse.deprivation.message;
        titleIveRec.FamilySizeAndSona_FamilySize__c = eligibilityResponse.familySizeAndSona.familySize;
        titleIveRec.FamilySizeAndSona_Sona__c = eligibilityResponse.familySizeAndSona.sona;
        titleIveRec.Income_TotalAvailableIncome__c = eligibilityResponse.income.totalAvailableIncome;
        titleIveRec.Income_Status__c = eligibilityResponse.income.status;
        titleIveRec.Income_Message__c = eligibilityResponse.income.message;
        titleIveRec.Asset_AssetValue__c = eligibilityResponse.asset.assetValue;
        titleIveRec.Asset_Status__c = eligibilityResponse.asset.status;
        titleIveRec.Asset_Message__c = eligibilityResponse.asset.message;
        titleIveRec.Placement_PlacementReimbursable__c = eligibilityResponse.placement.placementReimbursable;
        titleIveRec.Placement_PlcmntDtErlThnRemDtr__c = eligibilityResponse.placement.plcmntDtErlThnRemDtr; 
        titleIveRec.Placement_Status__c = eligibilityResponse.placement.status;
        titleIveRec.Placement_Message__c = eligibilityResponse.placement.message;
        titleIveRec.RemovalType_Status__c = eligibilityResponse.removalType.status;
        titleIveRec.RemovalType_Message__c = eligibilityResponse.removalType.message;
        titleIveRec.FinalStatus__c = eligibilityResponse.finalStatus;
        titleIveRec.Title_Iv_E__c = titleIveid;
        titleIveRec.Review_Period_End_Date__c = rec.Review_Period_End_Date__c;
        titleIveRec.Review_Period_Start_Date__c = rec.Review_Period_Start_Date__c;
        titleIveRec.CalloutDateTime__c = DateTime.now();
        titleIveRec.Period__c = rec.Period__c;
        if(rec.Placement__c != NULL) {
        	titleIveRec.Placement__c = rec.Placement__c;
        }
        titleIveRec.Service_Case__c = rec.Service_Case__c;
        titleIveRec.Child_Removal__c = rec.Child_Removal__c;
        return titleIveRec;
    }
}