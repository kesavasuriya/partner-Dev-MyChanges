public with sharing class ServiceCaseHistoryContorller {
    
    @AuraEnabled
    public static String getService(String recordId) {
        
        historyWrapper historyTableIns = new historyWrapper();
        historyTableIns.serviceCaseList= new List<ServiceWrapper>();
        Id serviceCaseId = recordId;
        String sObjectName = serviceCaseId.getSObjectType().getDescribe().getName();
        List<Service_Case_History__c> serviceCaseHistoryList = new List<Service_Case_History__c>();
        Service_Case__c serviceCaseIns = new Service_Case__c ();
        List<ProcessInstance> serviceCaseApprovalHistory = new List<ProcessInstance> ();
        FieldLevelSecurity.checkFieldAccessByCriteria('Name, Intake__c,Supervisor_Approver__c,Status__c, Approval_Status__c, Intake__c, LastModifiedDate','view','Service_Case__c', Boolean.valueOf(Label.HasNamespace));
        FieldLevelSecurity.checkFieldAccessByCriteria('Name','view','User', Boolean.valueOf(Label.HasNamespace));
        FieldLevelSecurity.checkFieldAccessByCriteria('Comments__c,Intake_Recommendations__c,Role__c','view','Case', Boolean.valueOf(Label.HasNamespace));

        if(sObjectName == 'Service_Case__c' ) {
            serviceCaseIns = [SELECT Id, Name, Intake__c, Owner.Name,Supervisor_Approver__r.Name,
                              Status__c, Approval_Status__c, Intake__r.Comments__c, Intake__r.Intake_Recommendations__c, Intake__r.Role__c, LastModifiedDate                                       
                              FROM Service_Case__c WHERE Id =:recordId LIMIT :Utility.queryLimit];

            FieldLevelSecurity.checkFieldAccessByCriteria('TargetObjectId,status,LastModifiedDate', 'view', 'ProcessInstance',  Boolean.valueOf(Label.HasNamespace));
            serviceCaseApprovalHistory = [SELECT Id, TargetObjectId,status,LastModifiedDate 
                                          FROM ProcessInstance WHERE TargetObjectId = :recordId LIMIT :Utility.queryLimit];
           FieldLevelSecurity.checkFieldAccessByCriteria('Service_Case__c, Service_Case_Approval_Status__c, Status__c, Intake_Role__c, Intake_Recommendations__c, Service_Case_Last_Modified_Date__c, Intake_Comments__c','view','Service_Case_History__c', Boolean.valueOf(Label.HasNamespace));

            serviceCaseHistoryList = [SELECT Id, Service_Case__c, Service_Case_Approval_Status__c, Status__c, Intake_Role__c, Intake_Recommendations__c, Service_Case_Last_Modified_Date__c, Intake_Comments__c
                                      FROM Service_Case_History__c WHERE Service_Case__c = :recordId ORDER BY Service_Case_Last_Modified_Date__c DESC LIMIT :Utility.queryLimit
                                     ];
        }
        
        if(serviceCaseHistoryList!= null && serviceCaseHistoryList.size() > 0) {
            ServiceWrapper serviceWrapperTableIns;
            for (Service_Case_History__c serviceCaseHistroy :serviceCaseHistoryList) {
                serviceWrapperTableIns = new ServiceWrapper();
                serviceWrapperTableIns.updatedDate = serviceCaseHistroy.Service_Case_Last_Modified_Date__c;
                serviceWrapperTableIns.user = serviceCaseIns.Owner.Name;
                serviceWrapperTableIns.status = serviceCaseHistroy.Status__c;
                serviceWrapperTableIns.recommendation = serviceCaseHistroy.Intake_Recommendations__c;
                serviceWrapperTableIns.role = serviceCaseHistroy.Intake_Role__c;
                serviceWrapperTableIns.reviewerComments = serviceCaseHistroy.Intake_Comments__c;
                serviceWrapperTableIns.approvalStatus = serviceCaseHistroy.Service_Case_Approval_Status__c;
                serviceWrapperTableIns.approvedBy = serviceCaseIns.Supervisor_Approver__r.Name;
                historyTableIns.serviceCaseList.add(serviceWrapperTableIns);
            }
        }
        
        return JSON.serialize(historyTableIns);
    }
    
    
    public class ServiceWrapper {
        @AuraEnabled
        public DateTime updatedDate;     
        @AuraEnabled
        public String status;
        @AuraEnabled
        public String recommendation;
        @AuraEnabled
        public String user;
        @AuraEnabled
        public String role;
        @AuraEnabled
        public String reviewerComments;
        @AuraEnabled
        public String approvalStatus;
        @AuraEnabled
        public String approvedBy;        
        public ServiceWrapper(){
            status ='';
            recommendation = '';
            user = '';
            role = '';
            reviewerComments = '';
            approvalStatus = '';
            approvedBy = '';
        }
    }    
    
    public class historyWrapper { 
        @AuraEnabled
        public List<ServiceWrapper> serviceCaseList;
    }
}