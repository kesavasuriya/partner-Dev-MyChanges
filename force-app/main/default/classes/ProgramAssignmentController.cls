public with sharing class ProgramAssignmentController {
    
    @AuraEnabled
    public static String getProgramAssignments() {
    
        programAreaWrapper programAreaTableIns = new programAreaWrapper();
        programAreaTableIns.programAreaList = new List<programAreaAssignmentWrap>();
        
        FieldLevelSecurity.checkFieldAccessByCriteria('Name, End_Date__c, Is_Child_an_IFPS_At_Risk_child__c, Program_Area__c, Program_Sub_Area__c, Reason_for_End__c , Start_Date__c', 'view', 'Program_Assignment__c',  Boolean.valueOf(Label.HasNamespace));
        
        List<Program_Assignment__c> programAssignments = [SELECT Id,Name, End_Date__c, Is_Child_an_IFPS_At_Risk_child__c, 
                                                                Program_Area__c, Program_Sub_Area__c, Reason_for_End__c , Start_Date__c
                                                            FROM Program_Assignment__c LIMIT 2000];
        programAreaAssignmentWrap programAreaAssignmentWrapTableIns;
         if(programAssignments != null && programAssignments.size() > 0) {
            for (Program_Assignment__c programAreaIns :programAssignments) {
                programAreaAssignmentWrapTableIns = new programAreaAssignmentWrap();
                programAreaAssignmentWrapTableIns.CPSCaseId = programAreaIns.Name;
                programAreaAssignmentWrapTableIns.programArea = programAreaIns.Program_Area__c; 
                programAreaAssignmentWrapTableIns.subProgramArea = programAreaIns.Program_Sub_Area__c;
                programAreaAssignmentWrapTableIns.startDate = programAreaIns.Start_Date__c;
                programAreaAssignmentWrapTableIns.endDate = programAreaIns.End_Date__c;
                programAreaAssignmentWrapTableIns.resonForEnd = programAreaIns.Reason_for_End__c;
                programAreaTableIns.programAreaList.add(programAreaAssignmentWrapTableIns);
            }            
         }
        return JSON.serialize(programAreaTableIns);       
    }
    
     public class programAreaAssignmentWrap {
       @AuraEnabled
        public String CPSCaseId;
        @AuraEnabled
        public String programArea;
        @AuraEnabled
        public String subProgramArea;
        @AuraEnabled
        public Date startDate;
        @AuraEnabled
        public DateTime endDate;
        @AuraEnabled
        public String resonForEnd;
        public  programAreaAssignmentWrap(){
            CPSCaseId = '';
            programArea = '';
            subProgramArea= '';
            resonForEnd= '';
        }
    }
    
    public class programAreaWrapper { 
        @AuraEnabled
        public List<programAreaAssignmentWrap> programAreaList;
    }
}