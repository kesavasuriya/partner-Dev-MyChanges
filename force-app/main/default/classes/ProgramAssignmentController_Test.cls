@isTest
private class ProgramAssignmentController_Test {
    
    @isTest static void TestgetProgramAssignments() {
        
        List<Program_Assignment__c> programAssignments = new List<Program_Assignment__c>();
        Program_Assignment__c programAssignmentRec1 = TestRecord.createprogramAssignment();
        programAssignments.add(programAssignmentRec1);
        Program_Assignment__c programAssignmentRec2 = TestRecord.createprogramAssignment();
        programAssignments.add(programAssignmentRec2);
        insert programAssignments;
        String actualOutput = ProgramAssignmentController.getProgramAssignments();
        
        List<Program_Assignment__c> programAssignmentList = [SELECT Id,Name, End_Date__c, Is_Child_an_IFPS_At_Risk_child__c, 
                                                                Program_Area__c, Program_Sub_Area__c, Reason_for_End__c , Start_Date__c
                                                            FROM Program_Assignment__c];
        ProgramAssignmentController.programAreaWrapper programAreaTableIns = new ProgramAssignmentController.programAreaWrapper();
        programAreaTableIns.programAreaList = new List<ProgramAssignmentController.programAreaAssignmentWrap>();
        for (Program_Assignment__c programAreaIns :programAssignmentList) {
                ProgramAssignmentController.programAreaAssignmentWrap programAreaAssignmentWrapTableIns = new ProgramAssignmentController.programAreaAssignmentWrap();
                programAreaAssignmentWrapTableIns.CPSCaseId = programAreaIns.Name;
                programAreaAssignmentWrapTableIns.programArea = programAreaIns.Program_Area__c; 
                programAreaAssignmentWrapTableIns.subProgramArea = programAreaIns.Program_Sub_Area__c;
                programAreaAssignmentWrapTableIns.startDate = programAreaIns.Start_Date__c;
                programAreaAssignmentWrapTableIns.endDate = programAreaIns.End_Date__c;
                programAreaAssignmentWrapTableIns.resonForEnd = programAreaIns.Reason_for_End__c;
                programAreaTableIns.programAreaList.add(programAreaAssignmentWrapTableIns);
         }  
        String expectedOutput = JSON.serialize(programAreaTableIns);
        System.assertEquals(expectedOutput, actualOutput);
    }

}