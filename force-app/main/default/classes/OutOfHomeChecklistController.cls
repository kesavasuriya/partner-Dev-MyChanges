public with sharing class OutOfHomeChecklistController {
    
    @AuraEnabled
    Public static String getChildRecords(String recordId) {
        
        WrapperClass initWrap = new WrapperClass();
      
        List<String> contactFields = new List<String>{'Person__c','Person__r.Name'};
                                                          
        String contactCondition = '(Service_Case__c = \'' + String.escapeSingleQuotes(recordId) + '\'' + ' OR ' + 
                				  'Intake__c = \'' + String.escapeSingleQuotes(recordId) + '\'' +
                                  ' OR ' + 'Investigation__c = \'' + String.escapeSingleQuotes(recordId)+
                                  '\') AND Person__r.RecordType.Name ='+'\''+'Persons Involved'+'\' AND Person__r.Active_Program_Area__c LIKE\'%Out of Home%\'';
        
        List<SObject> sObjListcontact = DataService.performQueryOperation(contactFields, 'Person__c', contactCondition,
                                                                          Utility.queryLimit);   
        initWrap.personRecords = (List<Person__c>)sObjListcontact;
        
        return JSON.serialize(initWrap);
        
    }
    
    @AuraEnabled
    Public static String getTableDetails(String recordId, String personId) {
        
        DetailWrapper initWrap = new DetailWrapper();
        List<Child_Removal__c>  removalRecords = [SELECT Id, Removal_Date_of_DT_F__c  
                                                    FROM Child_Removal__c 
                                                    WHERE Removal_End_Date_Time__c = NULL 
                                                    AND Service_Case__c = :recordId 
                                                    AND Child__c =:personId];
        
        
        if(removalRecords.size() > 0) {
            initWrap.initialDueDate = removalRecords[0].Removal_Date_of_DT_F__c + 5;
            initWrap.nextDueDate = removalRecords[0].Removal_Date_of_DT_F__c + 60;
            Date firstDayOfMonth = System.today().toStartOfMonth();
			initWrap.lastDayOfMonth = firstDayOfMonth.addDays(Date.daysInMonth(firstDayOfMonth.year(), 
                                                                           firstDayOfMonth.month()) - 1);
            
        }
        
        List<Assessment__c> assessmentRecords = [SELECT Id, Assessment_Type__c, Case_Worker_Name__c, Supervisor_Name__c,
                                                  Safety_Assessment_Approval_Date_Time__c, Supervisor_Approver__r.Name,
                                                  Workers_Name__c, Submitted_Date__c 
                                                  FROM Assessment__c  
                                                  WHERE Assessment_Type__c ='SAFE-C-OHP' 
                                                  AND Service_Case__c = :recordId];
        
        if(assessmentRecords.size() > 0) {
            initWrap.assessmentRecord = assessmentRecords[0];
        }
        
        List<Examination__c> examinationRecords = [SELECT Id, CreatedBy.Name, CreatedDate, Nature_of_Exam__c
                                                    FROM Examination__c 
                                                    WHERE (Contact__c = :personId
                                                    AND Appoinment_Information__c ='Kept') AND (Nature_of_Exam__c = 'Initial Health Examination'
                                                    OR Nature_of_Exam__c = 'Comprehensive Health Examination' OR Nature_of_Exam__c ='Annual Health Examination')
                                                    ORDER BY CreatedDate DESC];
        
        if(examinationRecords.size() > 0) {
            
            for(Examination__c examRec : examinationRecords) {
                
                if(examRec.Nature_of_Exam__c == 'Initial Health Examination') {
                    initWrap.initialExamRecord = examRec;
                } else if(examRec.Nature_of_Exam__c == 'Comprehensive Health Examination') {
                    initWrap.comprehensiveExamRecord = examRec;
                } else if(examRec.Nature_of_Exam__c == 'Annual Health Examination') {
                    initWrap.annualExamRecord = examRec;
                }
            }
        }
        
        /*List<Notes__c> notesRecords = [SELECT Id, Contact_Type__c, CreatedBy.Name, Contact_Date__c 
                                       FROM Notes__c 
                                       WHERE Contact_Purpose__c INCLUDES('Monthly Visit') 
                                       AND (Contact_Type__c = 'Face to Face' 
                                       OR Contact_Type__c = 'Initial Face to Face')
                                       AND Service_Case__c = :recordId ORDER BY CreatedDate DESC
                                       LIMIT 1];*/
        
        List<Notes_Person_Involved__c> notesList = [SELECT Id, Notes__c, Notes__r.Contact_Type__c, Notes__r.CreatedBy.Name, Notes__r.Contact_Date__c 
                                       FROM Notes_Person_Involved__c 
                                       WHERE Notes__r.Contact_Purpose__c INCLUDES('Monthly Visit') 
                                       AND (Notes__r.Contact_Type__c = 'Face to Face' 
                                       OR Notes__r.Contact_Type__c = 'Initial Face to Face')
                                       AND Notes__r.Service_Case__c = :recordId AND Person__c =:personId ORDER BY CreatedDate DESC
                                       LIMIT 1];
        
        if(notesList.size() > 0) {
            initWrap.notesRecord = notesList[0];
            
        }
        
        return JSON.serialize(initWrap);
        
    }
    
    
    public class WrapperClass { 
        
        @AuraEnabled
        public List<Person__c> personRecords;
        
    }
    
    
    public class DetailWrapper {
        
        @AuraEnabled
        public date initialDueDate;
        @AuraEnabled
        public date nextDueDate;
        @AuraEnabled
        public date lastDayOfMonth;
        @AuraEnabled
        public Assessment__c assessmentRecord;
        @AuraEnabled
        public Examination__c initialExamRecord;
        @AuraEnabled
        public Examination__c comprehensiveExamRecord;
        @AuraEnabled
        public Examination__c annualExamRecord;
        @AuraEnabled
        public Notes_Person_Involved__c notesRecord;
    }

}