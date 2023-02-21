public with sharing class VisitationLogController {
    
    @AuraEnabled
    public static String getInitialInformation(String servicecaseId) {
        
        VisitationLogWrapper visitWrap = new VisitationLogWrapper();
        visitWrap.statusPicklist = Utility.getPicklistinfo('Visitation_Log__c','Status__c',false);
        visitWrap.conditionPicklist = Utility.getPicklistinfo('Visitation_Log__c','Conditions__c',false);
        
        if(String.isNotBlank(servicecaseId)) {
            
            FieldLevelSecurity.checkFieldAccessByCriteria('Name', 'view', 'Contact',  Boolean.valueOf(Label.HasNamespace));
            
            /*List<Contact> clientList = [SELECT Id, Name FROM Contact 
                                        WHERE (Service_Case__c = :servicecaseId OR Investigation__c = :servicecaseId OR Intake__c =:servicecaseId) AND RecordTypeId = :Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Persons Involved').getRecordTypeId() 
                                        LIMIT :Utility.queryLimit];*/
            
            List<String> personJnFields = new List<String>{'Id','Person__c','Person__r.Name'};
            String personJnCondition = '(Service_Case__c = \''+ String.escapeSingleQuotes(servicecaseId) +'\''+' OR ';
            personJnCondition +='Intake__c = \''+ String.escapeSingleQuotes(servicecaseId) +'\''+' OR ';
            personJnCondition +='Investigation__c = \''+ String.escapeSingleQuotes(servicecaseId) +'\') AND ';
            personJnCondition +='Person__r.RecordTypeId = \''+ Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Persons Involved').getRecordTypeId() +'\'';
                
            List<SObject> childsObjList = DataService.performQueryOperation(personJnFields, 'Person__c', personJnCondition, Utility.queryLimit);
            List<Person__c> clientList = (List<Person__c>)childsObjList;
            
            List<Utility.pickListWrap> clientRecPickList = new List<Utility.pickListWrap>();
            Utility.pickListWrap picklist = new Utility.pickListWrap();
            picklist.label = '--None--';
            picklist.value = '';
            clientRecPickList.add(picklist);

            for(Person__c con : clientList) {
                
                if (String.isNotBlank(con.Id)) {
                    picklist = new Utility.pickListWrap();
                    picklist.label = con.Person__r.Name;
                    picklist.value = con.Person__c;
                    clientRecPickList.add(picklist);
                }
            }  
            visitWrap.clientPicklist = clientRecPickList;
            visitWrap.personInvolvedPicklist = clientRecPickList;
            
            FieldLevelSecurity.checkFieldAccessByCriteria('Name, First_Name__c, Middle_Name__c, Last_Name__c, Service_Case__c, Investigation__c, Intake__c', 'view', 'Collateral__c',  Boolean.valueOf(Label.HasNamespace));
            
            List<Collateral__c> collaterals = [SELECT Id, Name, First_Name__c, Middle_Name__c, Last_Name__c
                                               FROM Collateral__c WHERE Service_Case__c = :servicecaseId OR Investigation__c = :servicecaseId OR Intake__c =:servicecaseId LIMIT :Utility.queryLimit];
            
            List<Utility.pickListWrap> collateralVisitParticipantsPick = new List<Utility.pickListWrap>();
            Utility.pickListWrap collateralPickList = new Utility.pickListWrap();
            for(Collateral__c collateralRec : collaterals) {
                
                if (String.isNotBlank(collateralRec.Id)) {
                    String collateralName = '';
                    if(collateralRec.First_Name__c != null) {
                        collateralName = collateralName + collateralRec.First_Name__c + ' ' ;
                    }
                    if(collateralRec.Middle_Name__c != null) {
                        collateralName = collateralName + collateralRec.Middle_Name__c + ' ' ;
                    }
                    if(collateralRec.Last_Name__c != null) {
                        collateralName = collateralName + collateralRec.Last_Name__c ;
                    }
                    collateralPickList = new Utility.pickListWrap();
                    collateralPickList.label = collateralName;
                    collateralPickList.value = collateralRec.Name;
                    collateralVisitParticipantsPick.add(collateralPickList);
                }
            }
            visitWrap.collateralVisitParticipantsPicklist = collateralVisitParticipantsPick;
            
            FieldLevelSecurity.checkFieldAccessByCriteria('Client__c,Status__c, Court_Ordered__c,Visit_Date__c,'
                                                          +'Persons_Involved__c, Collateral_Visit_Participants__c, Comments__c, Location__c,'
                                                          +'Specify_any_other_participants_that_are__c, Conditions__c, Conditions_Comments__c,Investigation__c,'
                                                          +'Service_Case__c,Intake__c', 'view', 'Visitation_Log__c',  Boolean.valueOf(Label.HasNamespace));
            FieldLevelSecurity.checkFieldAccessByCriteria('Name', 'view', 'Contact',  Boolean.valueOf(Label.HasNamespace));
            
            visitWrap.visitationLogList = [SELECT Id, Client__c, Client__r.Name, Visit_Date__c, Status__c, Court_Ordered__c,
                                           Persons_Involved__c, Collateral_Visit_Participants__c, Comments__c, Location__c,
                                           Specify_any_other_participants_that_are__c, Conditions__c, Conditions_Comments__c,Investigation__c,
                                           Service_Case__c,Intake__c FROM Visitation_Log__c WHERE Service_Case__c =:servicecaseId OR Investigation__c = :servicecaseId OR Intake__c =:servicecaseId
                                           LIMIT :Utility.queryLimit];
            
        }
        return JSON.serialize(visitWrap);
    }
    
    @AuraEnabled
    public static String createVisitationLogRecord(String visitionLogJOSN) {
        
        if(String.isNotBlank(visitionLogJOSN)) {
            
            Visitation_Log__c visitationRec = (Visitation_Log__c)JSON.deserialize(visitionLogJOSN, Visitation_Log__c.class);
            
            if (String.isBlank(visitationRec.Id)) {
                FieldLevelSecurity.checkFieldAccessByCriteria('Client__c,Visit_Date__c,Status__c,Court_Ordered__c,Persons_Involved__c,'
                                                              +'Collateral_Visit_Participants__c,Comments__c,Location__c,Specify_any_other_participants_that_are__c,'
                                                              +'Conditions__c,Conditions_Comments__c','create','Visitation_Log__c', Boolean.valueOf(Label.HasNamespace));
                
                insert visitationRec;
            
            } else {
                
                FieldLevelSecurity.checkFieldAccessByCriteria('Client__c,Visit_Date__c,Status__c,Court_Ordered__c,Persons_Involved__c,'
                                                              +'Collateral_Visit_Participants__c,Comments__c,Location__c,Specify_any_other_participants_that_are__c,'
                                                              +'Conditions__c,Conditions_Comments__c','update','Visitation_Log__c', Boolean.valueOf(Label.HasNamespace));
                
                update visitationRec;
            }
            return visitationRec.Id;
       
        } else {
            return null;
        }
        
    }
    @AuraEnabled
    public static String deleteVisitationRec(String delVisitationLogJSON) {
        
        if(String.isNotBlank(delVisitationLogJSON)) {
           
            FieldLevelSecurity.checkObjectAccessByDelete('Visitation_Log__c');            
            Visitation_Log__c deleteVisitationLogRecord = (Visitation_Log__c)JSON.deserialize(delVisitationLogJSON, Visitation_Log__c.class);
            delete deleteVisitationLogRecord;
            
            return deleteVisitationLogRecord.Id;
        } else {
            return null;
        }
    }
    
    
    public class VisitationLogWrapper{
        
        @AuraEnabled
        public List<Utility.pickListWrap> clientPicklist;
        @AuraEnabled
        public List<Utility.pickListWrap> personInvolvedPicklist;
        @AuraEnabled
        public List<Utility.pickListWrap> collateralVisitParticipantsPicklist;
        @AuraEnabled
        public List<Utility.pickListWrap> statusPicklist;
        @AuraEnabled
        public List<Utility.pickListWrap> conditionPicklist;
        @AuraEnabled
        public List<Visitation_Log__c> visitationLogList;
        
    }
}