public  with sharing class InvestigationController {
    
    @AuraEnabled
    public static String getInvestigationRecord(Id investigationId, String objectApiName) {
        
        GetInitialWrapper intiWrapper = new GetInitialWrapper();
        if(String.isNotBlank(investigationId)) {
            
            if(objectApiName == 'Child_Removal__c') {
                List<String> childRemovalFields = new List<String>{'Id', 'Investigation__c'};
                String childRemovalCondition = 'Id = \''+ String.escapeSingleQuotes(investigationId) +'\'';
                List<SObject> childRemovalsObjList = DataService.performQueryOperation(childRemovalFields, 'Child_Removal__c', childRemovalCondition, Utility.queryLimit);
            
                if(childRemovalsObjList != null && childRemovalsObjList.size() > 0) {
                    investigationId = ((Child_Removal__c)childRemovalsObjList[0]).Investigation__c;
                }
            }
            
            List<String> assignMentFields = new List<String>{'Id', 'Investigation__c','Select_a_Social_Worker__r.Name','Responsibility__c'};
            String assignMentCondition = 'Investigation__c = \''+ String.escapeSingleQuotes(investigationId) +'\' ORDER BY CreatedDate DESC';
            List<SObject> assignmentsObjList = DataService.performQueryOperation(assignMentFields, 'Assignment__c', assignMentCondition, Utility.queryLimit);
            if(assignmentsObjList != null && assignmentsObjList.size() > 0) {
                List<Assignment__c> assignmentList = (List<Assignment__c>)assignmentsObjList;
                for(Assignment__c rec : assignmentList) {
                    if(String.isBlank(intiWrapper.childWorker) && rec.Responsibility__c == 'Child') {
                        intiWrapper.childWorker = rec.Select_a_Social_Worker__r.Name;
                    }
                    if(String.isBlank(intiWrapper.familyWorker) && rec.Responsibility__c == 'Family') {
                        intiWrapper.familyWorker = rec.Select_a_Social_Worker__r.Name;
                    }
                    if(String.isBlank(intiWrapper.adminWorker) && rec.Responsibility__c == 'Administrative') {
                        intiWrapper.adminWorker = rec.Select_a_Social_Worker__r.Name;
                    }
                }
            }
           
            
            List<String> investigationFields = new List<String>{'Name', 'Intake__c', 'Intake__r.CaseNumber', 'Due_On__c','Intake__r.Supervisor_Approver__r.Name', 
                                                            'Intake__r.Restrict_UnRestrict__c', 'Head_of_Household__r.Name', 'Head_of_Household__r.Casevault_PID__c', 'Response_Timer__c',
                                                            'Intake__r.Origin', 'CreatedDate', 'Number_of_days_created_date__c', 'Owner.Name', 'Intake__r.Status', 'Service_Case__c','Service_Case__r.Name'};

            String investigationCondition = 'Id = \''+ String.escapeSingleQuotes(investigationId) +'\'';
            List<SObject> sObjList = DataService.performQueryOperation(investigationFields, 'Investigation__c', investigationCondition, Utility.queryLimit);
            if(sObjList != null && sObjList.size() > 0) {

                intiWrapper.investigationRecord = (Investigation__c)sObjList[0];
                Datetime createddate = intiWrapper.investigationRecord.CreatedDate;
                intiWrapper.startDate = createddate.format('MM/dd/yyyy hh:mm a');
                intiWrapper = getReviewer(intiWrapper); 
            }
            //intiWrapper.searchLists = getCaseConnectSearchResults(investigationId);
            return JSON.serialize(intiWrapper);
            
        } else {
         
            return null;    
        }      
    }

    public static GetInitialWrapper getReviewer(GetInitialWrapper intiWrapper) {

        if(String.isNotBlank(intiWrapper.investigationRecord.Intake__c)) {
                
            List<String> caseFields = new List<String>{'Id', 'Owner.Name'};
            String caseCondition = 'Id = \''+ String.escapeSingleQuotes(intiWrapper.investigationRecord.Intake__c) +'\'';
            List<SObject> casesObjList = DataService.performQueryOperation(caseFields, 'Case', caseCondition, Utility.queryLimit);
            List<Case> intakeReviewerDetails = (List<Case>)casesObjList;
            if(intakeReviewerDetails != Null && intakeReviewerDetails.size() > 0) {
                intiWrapper.reviewer = intakeReviewerDetails[0].Owner.Name;
            }
        }
        return intiWrapper;
    }

    @AuraEnabled
    public static String getCaseConnectSearchResults(Id recordId) {

        Set<Id> personIDs = new Set<Id>();
        Set<Id> serviceCaseIDs = new Set<Id>();
        Set<Id> ids = new Set<Id>();
        Map<Id, CaseConnectWrapper> wrapperList = new Map<Id, CaseConnectWrapper>();

        for(Person__c person : [SELECT Id, Person__c FROM Person__c WHERE Investigation__c = :recordId]) {
            personIDs.add(person.Person__c);
        }

        for(Person__c personRec : [SELECT Id, Service_Case__c, Service_Case__r.Name, Service_Case__r.Head_of_Household__r.Name, Service_Case__r.Status__c, Service_Case__r.CreatedDate  FROM Person__c WHERE Person__c IN :personIDs AND Service_Case__c != NULL]) {

            if(!serviceCaseIDs.contains(personRec.Service_Case__c)) {

                serviceCaseIDs.add(personRec.Service_Case__c);
                CaseConnectWrapper wrapperIns = new CaseConnectWrapper();
                wrapperIns.caseId = personRec.Service_Case__c;
                wrapperIns.caseName = personRec.Service_Case__r.Name;
                wrapperIns.caseURL = '/lightning/r/'+personRec.Service_Case__c+'/view';
                wrapperIns.hohName = personRec.Service_Case__r.Head_of_Household__r.Name;
                wrapperIns.caseStatus = personRec.Service_Case__r.Status__c;
                wrapperIns.caseDate = personRec.Service_Case__r.CreatedDate.format('MM/dd/yyyy');
                wrapperList.put(personRec.Service_Case__c, wrapperIns);
            }
        }

        for(Service_Case_History__c sch : [SELECT Id, Status__c, Service_Case__c, Service_Case_Last_Modified_Date__c 
                                           FROM Service_Case_History__c 
                                           WHERE Service_Case__c IN :serviceCaseIDs ORDER BY Service_Case_Last_Modified_Date__c DESC]) {
            if(!ids.contains(sch.Service_Case__c)) {

                ids.add(sch.Service_Case__c);
                CaseConnectWrapper wrapperIns = wrapperList.get(sch.Service_Case__c);
                wrapperIns.caseStatus = sch.Status__c;
                wrapperIns.caseDate = sch.Service_Case_Last_Modified_Date__c.format('MM/dd/yyyy');
                wrapperList.put(sch.Service_Case__c, wrapperIns);                           
            }    
        }
        ids = new Set<Id>();

        for(Assignment__c assignment : [SELECT Id, Service_Case__c,  Select_a_Social_Worker__r.Name, Select_a_Local_Department__c FROM Assignment__c WHERE Service_Case__c IN :serviceCaseIDs AND Responsibility__c = 'Family' ORDER BY LastModifiedDate DESC]) {
            if(!ids.contains(assignment.Service_Case__c)) {

                ids.add(assignment.Service_Case__c);
                CaseConnectWrapper wrapperIns = wrapperList.get(assignment.Service_Case__c);
                wrapperIns.worker = assignment.Select_a_Social_Worker__r.Name;
                wrapperIns.localDpt = assignment.Select_a_Local_Department__c;
                wrapperList.put(assignment.Service_Case__c, wrapperIns); 
            }
        }
        return JSON.serialize(wrapperList.values());
       
    }

    @AuraEnabled
    public static void doCaseConnectApproval(Id recordId, Id supervisorId, String caseConnect) {
        
        Investigation__c invIns = new Investigation__c();
        invIns.Id = recordId;
        invIns.Case_Connect_ID__c = caseConnect;
        invIns.Supervisor_Approver__c = supervisorId;
        update invIns;

        Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest(); 
        req.setObjectId(recordId);
        Approval.ProcessResult approvalResult = Approval.process(req);

    }
    
    public class GetInitialWrapper { 

        @AuraEnabled
        public Investigation__c investigationRecord;
        @AuraEnabled
        public String startDate;
        @AuraEnabled
        public String reviewer; 
        @AuraEnabled
        public List<CaseConnectWrapper> searchLists;
        @AuraEnabled
        public string childWorker;
        @AuraEnabled
        public string familyWorker;
        @AuraEnabled
        public string adminWorker;
        
        
    }

    public class CaseConnectWrapper {

        public String caseId;
        public String caseName;
        public String caseURL;
        public String hohName;
        public String caseStatus;
        public String caseDate;
        public String worker;
        public String localDpt;

    }
}