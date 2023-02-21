public with sharing class ApprovalInboxController {

    @AuraEnabled
    public static String allApprovedRecords() {
    
      AllApprovalWrapper allApprovalWrapperList = new AllApprovalWrapper();
      allApprovalWrapperList.approvedWrapperList   = new List<AllApprovalTableInstanceWrapper>();
      
      FieldLevelSecurity.checkFieldAccessByCriteria('TargetObjectId,Status,CompletedDate,CreatedDate', 'view', 'ProcessInstance',  Boolean.valueOf(Label.HasNamespace));
      FieldLevelSecurity.checkFieldAccessByCriteria('Name', 'view', 'ProcessDefinition',  Boolean.valueOf(Label.HasNamespace));  
      List<ProcessInstance> allApprovedList = [SELECT ProcessDefinition.Name,TargetObjectId, TargetObject.Name, Status, CompletedDate, SubmittedBy.Name, CreatedDate FROM ProcessInstance WHERE Status = 'Approved' LIMIT :Utility.queryLimit];
      List<String> targetObjectIdList = new List<String>(); 

      AllApprovalTableInstanceWrapper tableInstance;
      for(ProcessInstance process : allApprovedList ) {
      
          tableInstance = new AllApprovalTableInstanceWrapper ();
          tableInstance.caseNumber = process.TargetObject.Name;
          tableInstance.caseWorker = process.SubmittedBy.Name;
          tableInstance.receivedDateTime = process.CreatedDate; 
          tableInstance.submittedDateTime = process.CompletedDate;
          tableInstance.approvalStatus = process.Status;
          tableInstance.eventDescription = process.ProcessDefinition.Name;
          targetObjectIdList.add(process.TargetObjectId); 
          allApprovalWrapperList.approvedWrapperList.add(tableInstance);
      }
      
      /*FieldLevelSecurity.checkFieldAccessByCriteria('Name,HEAD_OF_HOUSEHOLD__c,Service_Case__c,Intake__c,Investigation__c', 'view', 'Contact',  Boolean.valueOf(Label.HasNamespace));
      
      List<Contact> headOfHousholdList = [SELECT Id, Name, HEAD_OF_HOUSEHOLD__c, Service_Case__c, Intake__c, Investigation__c FROM Contact WHERE HEAD_OF_HOUSEHOLD__c = true AND
                                          (Intake__c != NULL OR Investigation__c != NULL OR Service_Case__c != NULL OR Intake__c  IN :targetObjectIdList OR Investigation__c IN  :targetObjectIdList or Service_Case__c IN :targetObjectIdList) LIMIT :Utility.queryLimit ];*/
      return JSON.serialize(allApprovalWrapperList);
      
    }

    @AuraEnabled
    public static String allPendingRecords() {

      AllApprovalWrapper allApprovalWrapperList = new AllApprovalWrapper();
      allApprovalWrapperList.pendingWrapperList   = new List<AllPendingTableInstanceWrapper>();
      
      FieldLevelSecurity.checkFieldAccessByCriteria('TargetObjectId,Status,CompletedDate,CreatedDate', 'view', 'ProcessInstance',  Boolean.valueOf(Label.HasNamespace));
      FieldLevelSecurity.checkFieldAccessByCriteria('Name', 'view', 'ProcessDefinition',  Boolean.valueOf(Label.HasNamespace));
      List<ProcessInstance> allPendingList = [SELECT ProcessDefinition.Name,TargetObjectId, TargetObject.Name, Status, CompletedDate, SubmittedBy.Name, CreatedDate FROM ProcessInstance WHERE Status = 'Pending' LIMIT :Utility.queryLimit];
      List<String> targetObjectIdList = new List<String>(); 
           
      AllPendingTableInstanceWrapper tableInstance;
      for(ProcessInstance process : allPendingList ) {
      
          tableInstance = new AllPendingTableInstanceWrapper ();
          tableInstance.caseNumber = process.TargetObject.Name;
          tableInstance.caseWorker = process.SubmittedBy.Name;
          tableInstance.receivedDateTime = process.CreatedDate; 
          tableInstance.submittedDateTime = process.CompletedDate;
          tableInstance.approvalStatus = process.Status;
          tableInstance.eventDescription = process.ProcessDefinition.Name;
          targetObjectIdList.add(process.TargetObjectId); 
          allApprovalWrapperList.pendingWrapperList.add(tableInstance);
      }    
      return JSON.serialize(allApprovalWrapperList);
      
    }
    
    @AuraEnabled
    public static String allAssessmentRecords() {
    
      AllApprovalWrapper allApprovalWrapperList = new AllApprovalWrapper();
      allApprovalWrapperList.assessmentWrapperList   = new List<AllAssessmentTableInstanceWrapper>();
      
      FieldLevelSecurity.checkFieldAccessByCriteria('TargetObjectId,Status,CompletedDate,CreatedDate', 'view', 'ProcessInstance',  Boolean.valueOf(Label.HasNamespace));
      FieldLevelSecurity.checkFieldAccessByCriteria('Name', 'view', 'ProcessDefinition',  Boolean.valueOf(Label.HasNamespace));
      List<ProcessInstance> allAssessmentList = [SELECT ProcessDefinition.Name,TargetObjectId, TargetObject.Name, Status, CompletedDate, SubmittedBy.Name, CreatedDate FROM ProcessInstance LIMIT :Utility.queryLimit];
      List<String> targetObjectIdList = new List<String>();
        
      AllAssessmentTableInstanceWrapper tableInstance;     
      for(ProcessInstance process : allAssessmentList ) {
      
          tableInstance = new AllAssessmentTableInstanceWrapper ();
          tableInstance.caseNumber = process.TargetObject.Name;
          tableInstance.submittedBy = process.SubmittedBy.Name;
          tableInstance.submittedDateTime = process.CompletedDate;
          tableInstance.subType = '';
          tableInstance.comments = '';
          targetObjectIdList.add(process.TargetObjectId); 
          allApprovalWrapperList.assessmentWrapperList.add(tableInstance);
      }    
      return JSON.serialize(allApprovalWrapperList);     
    }

    public class AllAssessmentTableInstanceWrapper { 
        
        @AuraEnabled
        public String caseNumber;
        @AuraEnabled
        public String intakeNumber;
        @auraEnabled
        public String headOfHousehold;
        @AuraEnabled
        Public String submittedBy; 
        @AuraEnabled
        Public DateTime submittedDateTime;
        @AuraEnabled
        Public String type;
        @AuraEnabled
        Public String subType;
        @AuraEnabled
        Public String comments;
    }
    
    public class AllApprovalWrapper { 
    
        @AuraEnabled
        public List<AllApprovalTableInstanceWrapper> approvedWrapperList;
        @AuraEnabled
        public List<AllAssessmentTableInstanceWrapper> assessmentWrapperList;
        @AuraEnabled
        public List<AllPendingTableInstanceWrapper> pendingWrapperList; 
    }

    public class AllApprovalTableInstanceWrapper { 
        
        @AuraEnabled
        public String caseNumber;
        @AuraEnabled
        public String caseWorker;
        @auraEnabled
        public String headOfHousehold;
        @AuraEnabled
        Public DateTime receivedDateTime;
        @AuraEnabled
        Public DateTime submittedDateTime;
        @AuraEnabled
        Public String approvalStatus;
        @AuraEnabled
        Public String eventDescription;
    }

    public class AllPendingTableInstanceWrapper { 
        
        @AuraEnabled
        public String caseNumber;
        @AuraEnabled
        public String caseWorker;
        @auraEnabled
        public String headOfHousehold;
        @AuraEnabled
        Public DateTime receivedDateTime;
        @AuraEnabled
        Public DateTime submittedDateTime;
        @AuraEnabled
        Public String approvalStatus;
        @AuraEnabled
        Public String eventDescription;
    }
}