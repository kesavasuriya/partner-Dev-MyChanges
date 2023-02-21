public with sharing class ServiceCaseController {
    
    
    @AuraEnabled
    public static String getChildRemovalRecord(Id childRemovalId) {
        
        getInitialWrapper intiWrapper = new getInitialWrapper();
        if (String.isNotBlank(childRemovalId)) {
            
            FieldLevelSecurity.checkFieldAccessByCriteria('Service_Case__c','view','Child_Removal__c', Boolean.valueOf(Label.HasNamespace));
            
            intiWrapper.childRemovalRec = [SELECT Id, Service_Case__c FROM Child_Removal__c WHERE Id=: childRemovalId LIMIT :Utility.queryLimit];
            return intiWrapper.childRemovalRec.Service_Case__c;
        
        } else {
            return null;    
        }
    }
    
    @AuraEnabled
    public static String getPlacementRecord(Id placementId) {
        getInitialWrapper intiWrapper = new getInitialWrapper();
        if (String.isNotBlank(placementId)) {
            
            FieldLevelSecurity.checkFieldAccessByCriteria('Service_Case__c','view','Placement__c', Boolean.valueOf(Label.HasNamespace));
            
            intiWrapper.placementRec = [SELECT Id, Service_Case__c FROM Placement__c WHERE Id=: placementId LIMIT :Utility.queryLimit];
            return intiWrapper.placementRec.Service_Case__c;
        
        } else {
            return null;    
        }
    }

    @AuraEnabled
    public static Boolean checkUserHasAccess(Id recordId) {

        UserRecordAccess userAccIns = [SELECT RecordId, HasAllAccess FROM UserRecordAccess WHERE RecordId = :recordId AND UserId = :UserInfo.getUserId() LIMIT 1];
        return userAccIns.HasAllAccess;

    }

    @AuraEnabled
    public static String getServicecaseRecord(Id ServicecaseId) {
        
        getInitialWrapper intiWrapper = new getInitialWrapper();
        //intiWrapper.assignTypePicklist =  Utility.getPicklistinfo('Service_Case__c','Assign_Type__c',false);
        //intiWrapper.selectUnitPicklist =  Utility.getPicklistinfo('Service_Case__c','Select_a_Unit__c',false);
        //intiWrapper.socialWorkerPicklist =  Utility.getPicklistinfo('Service_Case__c','Select_a_Social_Worker__c',false);
        //intiWrapper.responsibilityPicklist =  Utility.getPicklistinfo('Service_Case__c','Responsibility__c',false);
        
        FieldLevelSecurity.checkFieldAccessByCriteria('Number_of_days__c, CreatedDate, Status__c, Intake__c, Head_of_Household__c, Close_Date__c', 'view', 'Service_Case__c',  Boolean.valueOf(Label.HasNamespace));
        FieldLevelSecurity.checkFieldAccessByCriteria('CaseNumber,Origin,Restrict_UnRestrict__c, Supervisor_Approver__c', 'view', 'Case',  Boolean.valueOf(Label.HasNamespace));
        FieldLevelSecurity.checkFieldAccessByCriteria('Name', 'view', 'Contact',  Boolean.valueOf(Label.HasNamespace));
        
        if (String.isNotBlank(ServicecaseId)) {
            intiWrapper.serviceCaseRecord = [SELECT Id,Name, Number_of_days__c, CreatedDate, Status__c, Intake__c, Intake__r.Owner.Name, 
                                             Head_of_Household__r.Name,Intake__r.Restrict_UnRestrict__c,Intake__r.Origin, Intake__r.Supervisor_Approver__r.Name,
                                             Intake__r.CaseNumber, Close_Date__c ,Owner.Name, Restrict_Unrestrict__c
                                             FROM Service_Case__c WHERE Id = :ServicecaseId LIMIT :Utility.queryLimit];
        
            if(intiWrapper.serviceCaseRecord.Close_Date__c != null) {
                Date serviceCaseCloseDate = intiWrapper.serviceCaseRecord.Close_Date__c;
                intiWrapper.closeDate = serviceCaseCloseDate.format();
            }            
            FieldLevelSecurity.checkFieldAccessByCriteria('Status__c', 'view', 'Service_Case_History__c',  Boolean.valueOf(Label.HasNamespace));
            List<Service_Case_History__c>serviceCaseHistoryList = [SELECT Id, Status__c FROM Service_Case_History__c WHERE Service_Case__c = :ServicecaseId ORDER BY Service_Case_Last_Modified_Date__c DESC LIMIT :Utility.queryLimit]; 
            
            if(serviceCaseHistoryList.size() > 0) {
                intiWrapper.status = serviceCaseHistoryList[0].Status__c;
            } else {
                intiWrapper.status = intiWrapper.serviceCaseRecord.Status__c;
            }
            //FieldLevelSecurity.checkFieldAccessByCriteria(' Responsibility__c, Assign_Start_Date__c, Assign_End_Date__c, Child_List__c, Summary__c', 'view', 'Service_Case__c',  Boolean.valueOf(Label.HasNamespace));
            /*intiWrapper.assignServiceCaseRecord = [SELECT Id, Assign_Type__c, Select_a_Unit__c, Select_a_Social_Worker__c,
                                                   Responsibility__c, Assign_Start_Date__c, 
                                                   Child_List__c, Summary__c FROM Service_Case__c WHERE Id = :ServicecaseId LIMIT :Utility.queryLimit];*/
            FieldLevelSecurity.checkFieldAccessByCriteria('Select_a_Social_Worker__c', 'view', 'Assignment__c',  Boolean.valueOf(Label.HasNamespace));
            List<Assignment__c> administartiveWorkerList = [SELECT Id, Select_a_Social_Worker__r.Name FROM Assignment__c WHERE Service_Case__c =:ServicecaseId AND Responsibility__c ='Administrative' ORDER BY CreatedDate DESC LIMIT 1];
            List<Assignment__c> childWorkerList = [SELECT Id, Select_a_Social_Worker__r.Name FROM Assignment__c WHERE Service_Case__c =:ServicecaseId AND Responsibility__c ='Child' ORDER BY CreatedDate DESC LIMIT 1];
            List<Assignment__c> familyWorkerList = [SELECT Id, Select_a_Social_Worker__r.Name FROM Assignment__c WHERE Service_Case__c =:ServicecaseId AND Responsibility__c ='Family' ORDER BY CreatedDate DESC LIMIT 1];
            
            if(administartiveWorkerList.size()>0 && administartiveWorkerList!=null) {
                intiWrapper.administrativeWorker = administartiveWorkerList[0].Select_a_Social_Worker__r.Name;
            }
            
            if(childWorkerList.size()>0 && childWorkerList!=null) {
                intiWrapper.childWorker = childWorkerList[0].Select_a_Social_Worker__r.Name;
            }
            
            if(familyWorkerList.size()>0 && familyWorkerList!=null) {
                intiWrapper.familyWorker = familyWorkerList[0].Select_a_Social_Worker__r.Name;
            }
            FieldLevelSecurity.checkFieldAccessByCriteria('Name', 'view', 'Contact',  Boolean.valueOf(Label.HasNamespace));
            //List<contact> conLst = [SELECT Id, Name FROM Contact WHERE Service_Case__c = :ServicecaseId AND Intake_Person_Role__c INCLUDES ('Biological Child') LIMIT :Utility.queryLimit];
            Datetime createddate = intiWrapper.serviceCaseRecord.CreatedDate;
            intiWrapper.startDate = createddate.format('MM/dd/yyyy hh:mm a');
            
            /*if( conLst != Null && conLst.size() > 0) {
                
                for (Contact contactIns :conLst) {
                    Utility.pickListWrap childPick = new Utility.pickListWrap();
                    childPick.label = contactIns.Name;
                    childPick.value = contactIns.Id;
                    intiWrapper.childPicklist.add(childPick);
                }
            }*/
        }
        
        List<User> caseWorkerUserList = [SELECT Username, Id, Profile.Name FROM User WHERE Profile.Name ='Caseworker'];
        
        Utility.pickListWrap userPick = new Utility.pickListWrap();
        userPick.label = '--None--';
        userPick.value = '';
        intiWrapper.socialWorkerPicklist.add(userPick); 
        
        if(caseWorkerUserList != Null && caseWorkerUserList.size() > 0) {
            
            Utility.pickListWrap userPick1;
            for (User caseWorker :caseWorkerUserList) {
                userPick1 = new Utility.pickListWrap();
                userPick1.label = caseWorker.Username;
                userPick1.value = caseWorker.Id;
                intiWrapper.socialWorkerPicklist.add(userPick1);
            }
        }
        
        
        return JSON.serialize(intiWrapper);        
    }
    
    @AuraEnabled
    public static String getAssignmentRecords(String recordId, String objectName) {
        
        getInitialWrapper intiWrapper = new getInitialWrapper();
        if(String.isNotBlank(recordId)) {
            if(getAllAssignments(recordId).size() > 0) {
                intiWrapper.assignments = getAllAssignments(recordId);
            }
            intiWrapper.assignTypePicklist =  Utility.getPicklistinfo('Assignment__c','Assign_Type__c',false);
            intiWrapper.selectUnitPicklist =  Utility.getPicklistinfo('Assignment__c','Select_a_Unit__c',false);
            intiWrapper.responsibilityPicklist =  Utility.getPicklistinfo('Assignment__c','Responsibility__c',false);
            intiWrapper.selectLocalDepartmentPicklist =  Utility.getPicklistinfo('Assignment__c','Select_a_Local_Department__c',false);
            /*UserRecordAccess userAccIns = [SELECT RecordId, HasAllAccess FROM UserRecordAccess WHERE RecordId = :recordId AND UserId = :UserInfo.getUserId() LIMIT 1];
            if(userAccIns != null) {
                intiWrapper.hasShareAccess  = userAccIns.HasAllAccess;
            }*/
            /*if( objectName == 'Service_Case__c') {
                Service_Case__c servicecaseOwner = [SELECT Id, Owner.Id FROM Service_Case__c WHERE Id=:recordId LIMIT :Utility.queryLimit];
                intiWrapper.recordOwner = servicecaseOwner.Owner.Id;

            } else if( objectName == 'Investigation__c'){
                Investigation__c investigationOwner = [SELECT Id, Owner.Id FROM Investigation__c WHERE Id= :recordId LIMIT :Utility.queryLimit];
                intiWrapper.recordOwner = investigationOwner.Owner.Id;
            }*/
            intiWrapper.hasShareAccess  = checkUserHasAccess(recordId);
            FieldLevelSecurity.checkFieldAccessByCriteria('Name', 'view', 'Contact',  Boolean.valueOf(Label.HasNamespace));
            /*List<contact> contacts = [SELECT Id, Name FROM Contact WHERE (Service_Case__c = :recordId OR Investigation__c =:recordId) AND Intake_Person_Role__c INCLUDES ('Biological Child') LIMIT :Utility.queryLimit];
            if( contacts != Null && contacts.size() > 0) {
                Utility.pickListWrap childPick ;
                for (Contact contactIns :contacts) {
                    childPick = new Utility.pickListWrap();
                    childPick.label = contactIns.Name;
                    childPick.value = contactIns.Name;
                    intiWrapper.childPicklist.add(childPick);
                }
            }*/
            FieldLevelSecurity.checkFieldAccessByCriteria('Username', 'view', 'User',  Boolean.valueOf(Label.HasNamespace));
            //List<User> caseWorkerUserList = [SELECT Id, Name, Profile.Name FROM User WHERE Profile.Name ='Caseworker' OR Profile.Name = 'Casevault User'];
            /*PermissionSet permissionSetIns = [SELECT Id FROM PermissionSet WHERE Name = 'Case_Worker' LIMIT 1];
            if(permissionSetIns != null) {
                List<PermissionSetAssignment> permissionSetAssIns = [SELECT Id,AssigneeId FROM PermissionSetAssignment WHERE PermissionSetId = :permissionSetIns.Id AND Assignee.IsActive = true];
                Set<Id> userIDs = new Set<Id>();
                for(PermissionSetAssignment ins : permissionSetAssIns) {
                    userIDs.add(ins.AssigneeId);
                }   
            }*/
            List<User> caseWorkerUserList = [SELECT Id, Name, Profile.Name FROM User WHERE Profile.Name = 'Casevault User' AND IsActive = true];
            Utility.pickListWrap userPick = new Utility.pickListWrap();
            userPick.label = '--None--';
            userPick.value = '';
            intiWrapper.socialWorkerPicklist.add(userPick); 
            
            if(caseWorkerUserList != Null && caseWorkerUserList.size() > 0) {
                Utility.pickListWrap userPick1;
                for (User caseWorker :caseWorkerUserList) {
                    userPick1 = new Utility.pickListWrap();
                    userPick1.label = caseWorker.Name;
                    userPick1.value = caseWorker.Id;
                    intiWrapper.socialWorkerPicklist.add(userPick1);
                }
            }
            return JSON.serialize(intiWrapper);
        } else {
            return null;
        }
    }
    
    public static List<Assignment__c> getAllAssignments(String recordId) {
        FieldLevelSecurity.checkFieldAccessByCriteria('Assign_Type__c,Select_a_Unit__c,Select_a_Social_Worker__c,Responsibility__c,Assign_Start_Date__c,Assign_End_Date__c,Service_Case__c,Investigation__c,Assigned_By__c,Child_List__c, Summary__c', 'view', 'Assignment__c',  Boolean.valueOf(Label.HasNamespace));
        return [SELECT Id, Assign_Type__c, Select_a_Unit__c, Select_a_Social_Worker__c,Select_a_Social_Worker__r.Name,Select_a_Social_Worker__r.Email,Select_a_Social_Worker__r.Phone,
                Responsibility__c, Assign_Start_Date__c, Assign_End_Date__c,Service_Case__c,Investigation__c,Assigned_By__c,Assigned_By__r.Name, Assigned_By__r.Email, Assigned_By__r.Phone,
                Child_List__c, Summary__c FROM Assignment__c WHERE Service_Case__c = :recordId OR Investigation__c =:recordId ORDER BY CreatedDate DESC LIMIT :Utility.queryLimit];
    }
    
    @AuraEnabled
    public static void createAssignments(String assignmentJSON, String objectName) {
        if(String.isNotBlank(assignmentJSON)) {
            Assignment__c assignment = (Assignment__c)JSON.deserialize(assignmentJSON, Assignment__c.class);
            assignment.Assigned_By__c = UserInfo.getUserId();
            List<Assignment__c> assignments = new List<Assignment__c>();
            List<Assignment__c> assignmentList = new List<Assignment__c>();
            List<String> userIdList = new List<String>();
            List<String> objectNameList = new List<String>();
            String userId;
            if(String.isNotBlank(assignment.Service_Case__c)) {
                FieldLevelSecurity.checkFieldAccessByCriteria('Assign_Type__c,Select_a_Unit__c,Select_a_Social_Worker__c,Responsibility__c,Assign_Start_Date__c,Assign_End_Date__c,Service_Case__c,Investigation__c,Assigned_By__c,Child_List__c, Summary__c', 'view', 'Assignment__c',  Boolean.valueOf(Label.HasNamespace));
                assignments = [SELECT Id, Assign_Type__c, Select_a_Unit__c, Select_a_Social_Worker__c,Select_a_Social_Worker__r.Name,
                                Responsibility__c, Assign_Start_Date__c, Assign_End_Date__c,Service_Case__c,Investigation__c,Assigned_By__c,
                                Assigned_By__r.Name,Child_List__c, Summary__c FROM Assignment__c WHERE Service_Case__c = :assignment.Service_Case__c 
                                AND Responsibility__c =:assignment.Responsibility__c ORDER BY CreatedDate DESC LIMIT :Utility.queryLimit]; 
            } else if(String.isNotBlank(assignment.Investigation__c)) {
                FieldLevelSecurity.checkFieldAccessByCriteria('Assign_Type__c,Select_a_Unit__c,Select_a_Social_Worker__c,Responsibility__c,Assign_Start_Date__c,Assign_End_Date__c,Service_Case__c,Investigation__c,Assigned_By__c,Child_List__c, Summary__c', 'view', 'Assignment__c',  Boolean.valueOf(Label.HasNamespace));
                assignments = [SELECT Id, Assign_Type__c, Select_a_Unit__c, Select_a_Social_Worker__c,Select_a_Social_Worker__r.Name,
                                Responsibility__c, Assign_Start_Date__c, Assign_End_Date__c,Service_Case__c,Investigation__c,Assigned_By__c,
                                Assigned_By__r.Name,Child_List__c, Summary__c FROM Assignment__c WHERE Investigation__c =:assignment.Investigation__c
                                AND Responsibility__c =:assignment.Responsibility__c ORDER BY CreatedDate DESC LIMIT :Utility.queryLimit]; 
            }
            if(assignments.size() > 0) {
                userId = assignments[0].Select_a_Social_Worker__c;
            }
            if(String.isNotBlank(assignment.Id)){
                FieldLevelSecurity.checkFieldAccessByCriteria('Assign_Type__c,Select_a_Unit__c,Select_a_Social_Worker__c,Responsibility__c,Assign_Start_Date__c,Assign_End_Date__c,Service_Case__c,Investigation__c,Assigned_By__c,Child_List__c, Summary__c','update', 'Assignment__c',  Boolean.valueOf(Label.HasNamespace));
                update assignment;
                if(String.isNotBlank(userId) && userId != assignment.Select_a_Social_Worker__c) {
                    assignmentList.add(assignment);
                    userIdList.add(userId);
                    objectNameList.add(objectName);
                    recordSharing(assignmentList,userIdList,objectNameList);      
                }
            } else {
                FieldLevelSecurity.checkFieldAccessByCriteria('Assign_Type__c,Select_a_Unit__c,Select_a_Social_Worker__c,Responsibility__c,Assign_Start_Date__c,Assign_End_Date__c,Service_Case__c,Investigation__c,Assigned_By__c,Child_List__c, Summary__c','create', 'Assignment__c',  Boolean.valueOf(Label.HasNamespace));
                insert assignment;
                assignmentList.add(assignment);
                userIdList.add(userId);
                objectNameList.add(objectName);
                recordSharing(assignmentList,userIdList,objectNameList);       
            }
            
        }
    }
    
    public static void recordSharing(List<Assignment__c> assignmentList,List<String> userIdList,List<String> objectNameList) {
        
       
        /*if(assignmentList.size() > 0 && userIdList.size() > 0 && objectNameList.size() > 0 && String.isNotBlank(userIdList[0])) {
            List<Service_Case__Share> sharedRecords = [SELECT Id FROM Service_Case__Share WHERE (ParentId= :assignmentList[0].Service_Case__c OR ParentId =:assignmentList[0].Investigation__c)  AND UserOrGroupId =:userIdList[0] LIMIT :Utility.queryLimit];
            delete sharedRecords[0];
        }*/
        List<Service_Case__Share> alreadySharedRecord = [SELECT Id FROM Service_Case__Share WHERE (ParentId= :assignmentList[0].Service_Case__c OR ParentId =:assignmentList[0].Investigation__c)AND UserOrGroupId =:assignmentList[0].Select_a_Social_Worker__c
                                                        AND AccessLevel = 'Edit' LIMIT :Utility.queryLimit];
        if(!(alreadySharedRecord.size() > 0)) {
            if(objectNameList[0] == 'Service_Case__c') {
                Service_Case__Share shareRecord  = new Service_Case__Share();
                shareRecord.ParentId  = assignmentList[0].Service_Case__c;
                shareRecord.UserOrGroupId = assignmentList[0].Select_a_Social_Worker__c;
                shareRecord.AccessLevel = 'Edit';
                insert shareRecord;
            } else if(objectNameList[0] == 'Investigation__c'){
                Investigation__Share shareRecord  = new Investigation__Share();
                shareRecord.ParentId  = assignmentList[0].Investigation__c;
                shareRecord.UserOrGroupId = assignmentList[0].Select_a_Social_Worker__c;
                shareRecord.AccessLevel = 'Edit';
                insert shareRecord;
            }
            
        }
    }
    
    
    public class getInitialWrapper { 
        
        @AuraEnabled
        public Service_Case__c serviceCaseRecord;
        @AuraEnabled
        public Service_Case__c assignServiceCaseRecord;
        @AuraEnabled
        public List<Assignment__c> assignments;
        @AuraEnabled
        public List<Utility.pickListWrap> assignTypePicklist;
        @AuraEnabled
        public List<Utility.pickListWrap> selectUnitPicklist;
        @AuraEnabled
        public List<Utility.pickListWrap> socialWorkerPicklist;
        @AuraEnabled
        public List<Utility.pickListWrap> responsibilityPicklist;
        @AuraEnabled
        public List<Utility.pickListWrap> childPicklist;
        @AuraEnabled
        public List<Utility.pickListWrap> selectLocalDepartmentPicklist;
        @AuraEnabled
        public String startDate;
        @AuraEnabled
        public String administrativeWorker;
        @AuraEnabled
        public String childWorker;
        @AuraEnabled
        public String familyWorker;
        @AuraEnabled
        public Boolean hasShareAccess;
        @AuraEnabled
        public String status;
        @AuraEnabled
        public String closeDate;
        
        public getInitialWrapper() {
            serviceCaseRecord = new Service_Case__c();
            socialWorkerPicklist = new List<Utility.pickListWrap>();
            childPicklist = new List<Utility.pickListWrap>();
            assignments = new List<Assignment__c>();
        }
        @AuraEnabled
        public Child_Removal__c childRemovalRec;
        @AuraEnabled
        public Placement__c placementRec;
    }    
}