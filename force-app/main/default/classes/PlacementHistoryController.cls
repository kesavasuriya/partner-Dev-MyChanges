public with sharing class PlacementHistoryController {
    @AuraEnabled
    public static String getCurrentRecordHistroy(String placementRecordId) {
        
        historyWrapper historyTableIns = new historyWrapper();
        historyTableIns.approvalCaseList = new List<historyApprovalCase>();
        historyTableIns.approvalPlacementList = new List<historyApprovalPlacement>();
        
        historyTableIns.exitTypePickList =  Utility.getPicklistinfo('Placement__c','Exit_Type__c',false);
        historyTableIns.reasonForExitPickList =  Utility.getPicklistinfo('Placement__c','Reason_for_Exit__c',false);
        FieldLevelSecurity.checkFieldAccessByCriteria('Name, End_Date__c, Placement_Approval_Status__c, Exit_Approval_Status__c, Begin_Date__c,Service_Case__c, Provider__c', 'view', 'Placement__c',  Boolean.valueOf(Label.HasNamespace));
        FieldLevelSecurity.checkFieldAccessByCriteria('Intake__c', 'view', 'Service_Case__c',  Boolean.valueOf(Label.HasNamespace));
        FieldLevelSecurity.checkFieldAccessByCriteria('Start_Time__c,End_Time__c,Intake_Approval_Status__c,AccountId,CaseNumber,', 'view', 'Case',  Boolean.valueOf(Label.HasNamespace));
        FieldLevelSecurity.checkFieldAccessByCriteria('Casevault_ProID__c,Name,BillingStreet,Individual_First_Name__c,Individual_Last_Name__c,BillingCity,BillingState,BillingPostalCode,BillingCountry', 'view', 'Account',  Boolean.valueOf(Label.HasNamespace));


        Placement__c  placementRec = [SELECT Id,Name, End_Date__c, Placement_Approval_Status__c, Exit_Approval_Status__c, Begin_Date__c, Service_Case__r.Intake__c, Service_Case__r.Intake__r.CaseNumber, Service_Case__r.Intake__r.AccountId, Service_Case__r.Intake__r.Intake_Approval_Status__c,
                                          Service_Case__r.Intake__r.Start_Time__c, Service_Case__r.Intake__r.End_Time__c,Provider__r.Individual_First_Name__c,Provider__r.Individual_Last_Name__c,
                                          Provider__r.BillingStreet,Provider__r.BillingCity,Provider__r.BillingState,Provider__r.BillingPostalCode,Provider__r.BillingCountry,Provider__r.Casevault_ProID__c,Provider__r.Name
                                          FROM Placement__c where id = :placementRecordId Limit 1];
        FieldLevelSecurity.checkFieldAccessByCriteria('Name, Begin_Date__c, Placement_Approval_Status__c, Exit_Approval_Status__c', 'view', 'Placement__c',  Boolean.valueOf(Label.HasNamespace));
        historyTableIns.currentPlacementRecord = [SELECT Id, Name, Begin_Date__c, Placement_Approval_Status__c, Exit_Approval_Status__c  FROM Placement__c
                                                   WHERE Id = :placementRecordId LIMIT :Utility.queryLimit
                                                 ]; 
        FieldLevelSecurity.checkFieldAccessByCriteria('TargetObjectId, Status, CompletedDate,CreatedDate', 'view', 'ProcessInstance',  Boolean.valueOf(Label.HasNamespace));
        List<ProcessInstance> processInstPlacementList = [SELECT Id, ProcessDefinition.Name, TargetObjectId, Status, CompletedDate, SubmittedBy.Name,LastActor.Name,
                                                          CreatedDate FROM ProcessInstance where TargetObjectId = :placementRecordId];
        FieldLevelSecurity.checkFieldAccessByCriteria('TargetObjectId, Status, CompletedDate,CreatedDate', 'view', 'ProcessInstance',  Boolean.valueOf(Label.HasNamespace));
        List<ProcessInstance> processInstcaseList = [SELECT Id,  TargetObjectId, Status, CompletedDate, SubmittedBy.Name,LastActor.Name,
                                                     CreatedDate FROM ProcessInstance where TargetObjectId = :placementRec.Service_Case__r.Intake__c];
        
        //Placement Approval List Construct
        historyApprovalPlacement historyApprovalTableIns;
        if (processInstPlacementList != null && processInstPlacementList.size() > 0) {
            
            for (ProcessInstance processInsPlacement: processInstPlacementList) {
                
                historyApprovalTableIns = new historyApprovalPlacement();
                historyApprovalTableIns.name = placementRec.Name;
                historyApprovalTableIns.Reson = processInsPlacement.ProcessDefinition.Name;
                historyApprovalTableIns.ProviderId = placementRec.Provider__r.Casevault_ProID__c;
                historyApprovalTableIns.ProviderName = placementRec.Provider__r.Name;
                historyApprovalTableIns.historyDate = placementRec.Begin_Date__c;
                historyApprovalTableIns.historyEndDate = placementRec.End_Date__c;
                historyApprovalTableIns.approvedOn = processInsPlacement.CompletedDate;
                historyApprovalTableIns.approvedBy = processInsPlacement.LastActor.Name;
                historyApprovalTableIns.requestOn = processInsPlacement.CreatedDate;
                historyApprovalTableIns.requestBy = processInsPlacement.SubmittedBy.Name;
                historyApprovalTableIns.voidString = 'No';
                historyTableIns.approvalPlacementList.add(historyApprovalTableIns);
                
            }
        } 
        
        //Intake Approval List construct
        historyApprovalCase historyApprovalCaseTableIns;
        if (processInstcaseList != null && processInstcaseList.size() > 0) {
            
            for (ProcessInstance processInsCase: processInstcaseList) {
                
                historyApprovalCaseTableIns = new historyApprovalCase();
                historyApprovalCaseTableIns.caseNumber = placementRec.Service_Case__r.Intake__r.CaseNumber;
                historyApprovalCaseTableIns.caseType = 'Provider Placement';
                historyApprovalCaseTableIns.caseProviderName = placementRec.Provider__r.Name;
                historyApprovalCaseTableIns.Address = (String.isBlank(placementRec.Provider__r.BillingStreet)?'':(placementRec.Provider__r.BillingStreet +','))+(String.isBlank(placementRec.Provider__r.BillingCity)?'':(placementRec.Provider__r.BillingCity+' '))+(String.isBlank(placementRec.Provider__r.BillingCountry)?'':(placementRec.Provider__r.BillingCountry+' '))+(String.isBlank(placementRec.Provider__r.BillingState)?'':(placementRec.Provider__r.BillingState+' '))+(String.isBlank(placementRec.Provider__r.BillingPostalCode)?'':(placementRec.Provider__r.BillingPostalCode+' '));
                historyApprovalCaseTableIns.historyStartDate = placementRec.Begin_Date__c;
                historyApprovalCaseTableIns.historyEndDate = placementRec.End_Date__c;
                historyApprovalCaseTableIns.caseStatus = processInsCase.Status;
                historyTableIns.approvalCaseList.add(historyApprovalCaseTableIns);
            }
        }
        
        return JSON.serialize(historyTableIns);
    }
   
    @AuraEnabled
    public static String upsertPlacementAndSubmitForApproval(String exitPlacementRec, String selectedSupervisorUserId){        
       
       if (String.isNotBlank(exitPlacementRec) && String.isNotBlank(selectedSupervisorUserId) ) { 
            
            Placement__c  upsertPlacement = (Placement__c)JSON.deserialize(exitPlacementRec, Placement__c.class);
            if (String.isNotBlank(upsertPlacement.Id)) {
                upsertPlacement.Supervisor_Approval__c = selectedSupervisorUserId;
                FieldLevelSecurity.checkFieldAccessByCriteria('Begin_Date__c, Supervisor_Approval__c, End_Date__c, Exit_Type__c, Exit_Date_Time__c, Reason_for_Exit__c, Exit_Comments__c', 'update', 'Placement__c',  Boolean.valueOf(Label.HasNamespace));
                update upsertPlacement;
                Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();          
                req.setProcessDefinitionNameOrId('Placement_Exit_Approval_Process');
                req.setComments('Submit For Approval');        
                req.setObjectId(upsertPlacement.id);        
                Approval.ProcessResult result = Approval.process(req);
            }
            return upsertPlacement.Id;
       } else {
           return null;
       }
                
        
        
    }     
       
    public class historyApprovalCase {
       
        @AuraEnabled
        public String caseNumber;
        @AuraEnabled
        public String caseType;
        @AuraEnabled
        public String caseProviderName;
        @AuraEnabled 
        public String Address;
        @AuraEnabled
        public DateTime historyStartDate;
        @AuraEnabled
        public DateTime historyEndDate;
        @AuraEnabled
        public String caseStatus;
        public  historyApprovalCase (){
            caseNumber = '';
            caseType = '';
            caseProviderName = '';
            Address = '';
            caseStatus = '';
        }
    }
    public class historyApprovalPlacement {
        @AuraEnabled
        public String name;
        @AuraEnabled
        public String ProviderId;
        @AuraEnabled
        public String ProviderName;
        @AuraEnabled
        public String Reson;
        @AuraEnabled
        public DateTime historyDate;
        @AuraEnabled
        Public DateTime historyEndDate;
        @AuraEnabled
        public DateTime approvedOn;
        @AuraEnabled
        public String approvedBy;
        @AuraEnabled
        public DateTime requestOn;
        @AuraEnabled
        public String requestBy;
        @AuraEnabled
        public String voidString;
        public historyApprovalPlacement (){
            name = '';
            ProviderId = '';
            ProviderName = '';
            approvedBy = '';
            requestBy = '';
            voidString = '';
            Reson = '';
        }
    }
    
    public class historyWrapper { 
        
        @AuraEnabled
        public List<historyApprovalCase> approvalCaseList;
        @AuraEnabled
        public List<historyApprovalPlacement> approvalPlacementList; 
        @AuraEnabled
        public List<Utility.pickListWrap> exitTypePickList;
        @AuraEnabled
        public List<Utility.pickListWrap> reasonForExitPickList;
        @AuraEnabled
        public Placement__c currentPlacementRecord;
    }
}