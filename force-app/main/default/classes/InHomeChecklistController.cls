public with sharing class InHomeChecklistController {

    @AuraEnabled
    Public static String getChildRecords(String recordId) {
        
        WrapperClass initWrap = new WrapperClass();
        List<String> contactFields = new List<String>{'Person__c','Person__r.Name'};
                                                          
        String contactCondition = '(Service_Case__c = \'' + String.escapeSingleQuotes(recordId) + '\'' + ' OR ' + 
                				  'Intake__c = \'' + String.escapeSingleQuotes(recordId) + '\'' +
                                  ' OR ' + 'Investigation__c = \'' + String.escapeSingleQuotes(recordId)+
                                  '\') AND Person__r.RecordType.Name ='+'\''+'Persons Involved'+'\' AND Person__r.Active_Program_Area__c LIKE\'%In Home%\'';
        
        List<SObject> sObjListcontact = DataService.performQueryOperation(contactFields, 'Person__c', contactCondition,
                                                                          Utility.queryLimit);        
        initWrap.personRecords = (List<Person__c>)sObjListcontact;
        
       
        
        return JSON.serialize(initWrap);
        
    }
    
    @AuraEnabled
    Public static String getTableDetails(String recordId, String personId) {
        
        DetailWrapper initWrap = new DetailWrapper();
        
        initWrap.serviceCaseRecord = [SELECT Id, CreatedDate
                                     	FROM Service_Case__c
                                     	WHERE Id = :recordId];
                                      
        initWrap.initialDate = initWrap.serviceCaseRecord.CreatedDate+7;
        List<Assessment__c> assessmentRecords = [SELECT Id, Assessment_Type__c, Case_Worker_Name__c, Supervisor_Name__c,
                                                  Safety_Assessment_Approval_Date_Time__c, Supervisor_Approver__r.Name,
                                                  Workers_Name__c 
                                                  FROM Assessment__c  
                                                  WHERE Assessment_Type__c ='SAFE-C'
                                                  AND Service_Case__c = :recordId];
        
        if(assessmentRecords.size() > 0) {
            initWrap.assessmentRecord = assessmentRecords[0];
        }
        
		List<Assessment__c> riskAssessmentRecords = [SELECT Id, Assessment_Type__c, Case_Worker_Name__c, Supervisor_Name__c,
                                                      Safety_Assessment_Approval_Date_Time__c, Supervisor_Approver__r.Name,
                                                      Workers_Name__c 
                                                      FROM Assessment__c  
                                                      WHERE Assessment_Type__c ='Family risk Reassessment'
                                                      AND Service_Case__c = :recordId];
        
        if(riskAssessmentRecords.size() > 0) {
            initWrap.riskAssessmentRecord = riskAssessmentRecords[0];
        }        
  		

		/*List<Notes__c> notesRecords = [SELECT Id, Contact_Type__c, CreatedBy.Name, Contact_Date__c 
                                       FROM Notes__c 
                                       WHERE Contact_Purpose__c INCLUDES('Worker Visit','Case Management','Family Assessment') 
                                       AND (Contact_Type__c = 'Face to Face' 
                                       OR Contact_Type__c = 'Initial Face to Face')
                                       AND Service_Case__c = :recordId ORDER BY CreatedDate DESC
                                       LIMIT 1];    */
        
		List<Notes_Person_Involved__c> notesList = [SELECT Id, Notes__c, Notes__r.Contact_Type__c, Notes__r.CreatedBy.Name, Notes__r.Contact_Date__c 
                                       FROM Notes_Person_Involved__c 
                                       WHERE Notes__r.Contact_Purpose__c INCLUDES('Worker Visit','Case Management','Family Assessment') 
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
        public Assessment__c assessmentRecord;
        @AuraEnabled
        public Assessment__c riskAssessmentRecord;
        @AuraEnabled
        public Notes_Person_Involved__c notesRecord;
        @AuraEnabled
        public Service_Case__c  serviceCaseRecord;
        @AuraEnabled
        public datetime  initialDate;
    }
}