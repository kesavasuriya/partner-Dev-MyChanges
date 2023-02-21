public with sharing class SDMController {

    @AuraEnabled
    public static String getExpenses(Id caseId) {
    
        SDMWrapper sdmWrapperIns = new SDMWrapper();
        for(CPS_Response_MD__mdt cpsResponse : CPS_Response_MD__mdt.getAll().values()) {
            sdmWrapperIns.CPSResponseMap.put(cpsResponse.Response_Id__c, JSON.Serialize(cpsResponse));
        }
       
        List<SDM__c> sdmRecord = new List<SDM__c>();
        List<String> sdmFields = new List<String>{'Id'};
        String sdmCondition = 'Intake__c = \'' + String.escapeSingleQuotes(caseId) + '\' OR Investigation__c = \'' + String.escapeSingleQuotes(caseId) + '\' OR Service_case__c = \'' + String.escapeSingleQuotes(caseId) + '\'';
        List<SObject> sObjListsdm = DataService.performQueryOperation(sdmFields, 'SDM__c', sdmCondition, 1);
        sdmRecord = (List<SDM__c>)sObjListsdm;

        if(sdmRecord.size() > 0) {
            sdmWrapperIns.sdmId = sdmRecord[0].Id;
        }
        return JSON.Serialize(sdmWrapperIns);
    }
    
    @AuraEnabled
    public static String getCPSResponse(String SDMId, Map<Decimal, String> responseIdMap) {
    
        if(String.isNotBlank(SDMId)) {

            ResponseWrapperObj responseWrapperObjIns = new ResponseWrapperObj();
            List<ResponseWrapper> responseWrapperList = new List<ResponseWrapper>();
            SDM__c sdmRecordIns = new SDM__c();
            List<String> sdmFields = new List<String>();            
            List<String> abuseNameList = new List<String>();


            for(Schema.FieldSetMember fld :SObjectType.SDM__c.FieldSets.AbuseFields.getFields()) {
                sdmFields.add(fld.getFieldPath());
            }

            for(Schema.FieldSetMember fld :SObjectType.SDM__c.FieldSets.CPSResponseFields.getFields()) {
                sdmFields.add(fld.getFieldPath());
            }
            String sdmCondition = 'Id = \'' + String.escapeSingleQuotes(SDMId) + '\'';
            List<SObject> sObjListsdm = DataService.performQueryOperation(sdmFields, 'SDM__c', sdmCondition, 1);
            
            if(sObjListsdm != null && sObjListsdm.size() > 0) {
                sdmRecordIns = (SDM__c)sObjListsdm[0];
            }


            for(Schema.FieldSetMember fld : SObjectType.SDM__c.FieldSets.AbuseFields.getFields()) {
                
                if(Boolean.valueof(sdmRecordIns.get(fld.getFieldPath()))) {
                    abuseNameList.add(fld.getLabel());
                }    
            }    
            if(abuseNameList.size() > 0) {

                String responseType = 'CPS-AR';
                for(SDM_Rule_MD__mdt sdmIns : SDM_Rule_MD__mdt.getAll().values()) {
                    
                    System.debug('Abuse Name:::'+sdmIns.Abuse_Name__c);
                    if(abuseNameList.contains(sdmIns.Abuse_Name__c) && sdmIns.CPS_Response_Type__c == 'CPS-IR') {
                        responseType = 'CPS-IR';
                        break;
                    }
                }
                /*String responseType = 'CPS-IR';
                for(SDM_Rule_MD__mdt sdmIns : SDM_Rule_MD__mdt.getAll().values()) {
                    
                    System.debug('Abuse Name:::'+sdmIns.Abuse_Name__c);
                    if(abuseNameList.contains(sdmIns.Abuse_Name__c) && sdmIns.CPS_Response_Type__c == 'CPS-AR') {
                        responseType = 'CPS-AR';
                        break;
                    }
                }*/
                SDM__c updateSdm = new SDM__c();
                updateSdm.Id=SDMId;
                updateSdm.CPS_Response_Type__c = responseType;
                //FieldLevelSecurity.checkFieldAccessByCriteria(updateSdm.getPopulatedFieldsAsMap().keySet(),'update','SDM__c');
                update updateSdm;
                responseWrapperObjIns.CPSResponseType = responseType;
                
                ResponseWrapper responseWrapperIns;
                Map<String,String> sdmRuleFields = new Map<String,String>();
                sdmRuleFields.put('X33446__c','33446.0');
                sdmRuleFields.put('X33447__c','33447.0');
                sdmRuleFields.put('X33448__c','33448.0');
                sdmRuleFields.put('X33449__c','33449.0');
                sdmRuleFields.put('X33451__c','33451.0');
                sdmRuleFields.put('X33452__c','33452.0');
                sdmRuleFields.put('X33453__c','33453.0');
                sdmRuleFields.put('X33454__c','33454.0');
                sdmRuleFields.put('X33455__c','33455.0');
                sdmRuleFields.put('X33456__c','33456.0');
                sdmRuleFields.put('X33457__c','33457.0');
                sdmRuleFields.put('X33458__c','33458.0');
                sdmRuleFields.put('X33459__c','33459.0');
                sdmRuleFields.put('X33460__c','33460.0');
                sdmRuleFields.put('X33461__c','33461.0');
                sdmRuleFields.put('X33462__c','33462.0');
                sdmRuleFields.put('X33463__c','33463.0');
                for(String fld : sdmRuleFields.keySet()) {
                        
                        responseWrapperIns = new ResponseWrapper();
                        for (SDM_Rule_MD__mdt sdmIns : SDM_Rule_MD__mdt.getAll().values()) {

                            if(abuseNameList.size() > 0 && abuseNameList.contains(sdmIns.Abuse_Name__c)) {

                                responseWrapperIns.SDMRuleId = sdmIns.Id;
                                responseWrapperIns.fieldAPIName = fld;
                                CPS_Response_MD__mdt cpsRes = (CPS_Response_MD__mdt)JSON.deserialize(responseIdMap.get(Decimal.valueof(sdmRuleFields.get(fld))),CPS_Response_MD__mdt.class);
                                responseWrapperIns.Name = cpsRes.Response__c;
                                responseWrapperIns.type = cpsRes.CPS_Response_Type__c ;
                                if(sdmIns.get(fld) == 'YES') {
                                    responseWrapperIns.checked = true;
                                    responseWrapperIns.disabled = true;
                                } else if (sdmIns.get(fld) == 'NO') {
                                    
                                    if(!(responseWrapperIns.checked)) {
                                        responseWrapperIns.checked = false;
                                    }
                                    responseWrapperIns.disabled = true;
                                } else if (sdmIns.get(fld) == 'EDITABLE') {
                                
                                    if(Boolean.valueof(sdmRecordIns.get(fld))) {
                                        responseWrapperIns.checked = true;    
                                    } else {
                                        responseWrapperIns.checked = false;
                                    }
                                    responseWrapperIns.disabled = false;
                                } else if (sdmIns.get(fld) == 'CLICK&EDIT') {
                                    responseWrapperIns.checked = true;
                                    responseWrapperIns.disabled = false;
                                }
                            }  
                        }    
                        responseWrapperObjIns.responseWrapperList.add(responseWrapperIns);           
                }
                
            } else {
                return null;
            }
            
            return JSON.Serialize(responseWrapperObjIns);
        } else {
            return null;
        }
    }
    
    @AuraEnabled
    public static void saveSDMRuleRecord(String SDMId, Map<String, Boolean> checkboxValueMap) {
    
        if(String.isNotBlank(SDMId) && checkboxValueMap != Null) {
        
            String flsSDMFields = '';
            SDM__c updatingSDMIns = new SDM__c();
            updatingSDMIns.Id = SDMId;
            
            for(String fieldAPIName : checkboxValueMap.keySet()) {
                
                flsSDMFields += String.isNotBlank(flsSDMFields) ? ', ' + fieldAPIName : fieldAPIName;
                updatingSDMIns.put(fieldAPIName, checkboxValueMap.get(fieldAPIName));  
            }
            //FieldLevelSecurity.checkFieldAccessByCriteria(updatingSDMIns.getPopulatedFieldsAsMap().keySet(), 'update', 'SDM__c');
            update updatingSDMIns;
        }
        
    }

    @AuraEnabled
    public static String getSDMRecords(Id recordId, String module) {
        
        List<SDM__c> sdmRecord = new List<SDM__c>();
        if (String.isNotBlank(recordId) && module =='investigation') {
            sdmRecord = [SELECT Id, Name  FROM SDM__c WHERE Investigation__c =: recordId LIMIT :Utility.queryLimit];
            
        } else if (String.isNotBlank(recordId) && module =='servicecase') {
            sdmRecord = [SELECT Id, Name  FROM SDM__c WHERE Service_Case__c =: recordId LIMIT :Utility.queryLimit];

        } else if (String.isNotBlank(recordId) && module =='intake') {
            sdmRecord = [SELECT Id, Name  FROM SDM__c WHERE Intake__c =: recordId LIMIT :Utility.queryLimit];
        }
        return JSON.Serialize(sdmRecord);
    }
    
    public class SDMWrapper {
    
        public Map<Decimal, String> CPSResponseMap;
        public String sdmId;
        public SDMWrapper() {
            CPSResponseMap = new Map<Decimal, String>();
        }
    }
    
    public class ResponseWrapperObj {
    
        public String CPSResponseType;
        public List<ResponseWrapper> responseWrapperList;
        
        public ResponseWrapperObj() {
            CPSResponseType = '';
            responseWrapperList = new List<ResponseWrapper>();
        }
    }
    
    public class ResponseWrapper {
    
        public String Name;
        public String SDMRuleId;
        public String fieldAPIName;
        public boolean checked;
        public boolean disabled;
        public String type;
        
        public ResponseWrapper() {
        
            Name = '';
            SDMRuleId = '';
            fieldAPIName = '';
            checked = false;
            disabled = false;
        }
    }
}