public  with sharing class ServicePlanController {

    @AuraEnabled
    public static String getIntiVisitationInfo (String servicePlanId) {
    
        ServicePlanWrapper servicePlanWrap = new ServicePlanWrapper();
        servicePlanWrap.conditionsPicklist = Utility.getPicklistinfo('Visitation_Plan__c','Conditions__c',false);
        servicePlanWrap.frequencyPicklist = Utility.getPicklistinfo('Visitation_Plan__c','Frequency__c',false);
        servicePlanWrap.visitorTransportationPicklist = Utility.getPicklistinfo('Visitation_Plan__c','Visitor_Transportation__c',false);
        servicePlanWrap.childTransportationPicklist = Utility.getPicklistinfo('Visitation_Plan__c','Child_Transportation__c',false);
        servicePlanWrap.visitDurationPicklist = Utility.getPicklistinfo('Visitation_Plan__c','Visit_Duration__c',false);
        if(String.isNotBlank(servicePlanId)) {

            Service_Plan__c servicePlanRec = new Service_Plan__c();                                             
            List<String> servicePlanFields = new List<String>{'Service_Case__c'};
            String servicePlanCondition = 'Id = \''+ String.escapeSingleQuotes(servicePlanId) + '\'';
            List<SObject> sObjListservicePlan = DataService.performQueryOperation(servicePlanFields, 'Service_Plan__c', servicePlanCondition, Utility.queryLimit);
            
            if(sObjListservicePlan != null && sObjListservicePlan.size() > 0) {
                servicePlanRec = (Service_Plan__c)sObjListservicePlan[0];
            }

            List<Person__c> clientList = new List<Person__c>();                                             
            /*List<String> contactFields = new List<String>{'Name'};
            String contactCondition = 'Service_Case__c = \''+ String.escapeSingleQuotes(servicePlanRec.Service_Case__c) + '\'';
            List<SObject> sObjListContact = DataService.performQueryOperation(contactFields, 'Contact', contactCondition, Utility.queryLimit);
            clientList = (List<Contact>)sObjListContact;*/
            
            List<String> personJnFields = new List<String>{'Person__c','Person__r.Name','Person__r.Intake_Person_Role__c'};
            String personJncontactCondition = 'Service_Case__c = \''+ String.escapeSingleQuotes(servicePlanRec.Service_Case__c) + '\'';
            List<SObject> sObjListContact = DataService.performQueryOperation(personJnFields, 'Person__c', personJncontactCondition, Utility.queryLimit);
            clientList = (List<Person__c>)sObjListContact;

            
            List<Utility.pickListWrap> clientRecPickList = new List<Utility.pickListWrap>();
            List<Utility.pickListWrap> personInvolvedsPickList = new List<Utility.pickListWrap>();

            
            Utility.pickListWrap intialPick = new Utility.pickListWrap();
            intialPick.label = '--None--';
            intialPick.value = '';
            clientRecPickList.add(intialPick);
          	Utility.pickListWrap pick ;

            Utility.pickListWrap intialPick1 = new Utility.pickListWrap();
            intialPick1.label = '--None--';
            intialPick1.value = '';
            Utility.pickListWrap pick1;
            personInvolvedsPickList.add(intialPick1);
            
            for(Person__c personjn : clientList) {               
                
                if(String.isNotBlank(personjn.Id)) {
                        
                        pick = new Utility.pickListWrap();
                        pick.label = personjn.Person__r.Name;
                        pick.value = personjn.Person__c;
                        clientRecPickList.add(pick);
                    	String role = personjn.Person__r.Intake_Person_Role__c;
                    if(role.contains('Biological Child') || role.contains('Child') || role.contains('Other Child') 
                       || role.contains('Other Child (Not in Household)') ||role.contains('Private Adoptive Child')) {
                        pick1 = new Utility.pickListWrap();
                        pick1.label = personjn.Person__r.Name;
                        pick1.value = personjn.Person__r.Name;
                        personInvolvedsPickList.add(pick1);
                    }
                }
            }  
            servicePlanWrap.clientPicklist = clientRecPickList;
            
            /*List<Contact> personInvolveds = new List<Contact>();                                             
            List<String> personInvolvedsFields = new List<String>{'Name'};
            String personInvolvedsCondition = 'Service_Case__c = \''+ String.escapeSingleQuotes(servicePlanRec.Service_Case__c) + '\'' + 
            'AND Intake_Person_Role__c INCLUDES (\'Biological Child\',\'Child\',\'Other Child\',\'Other Child (Not in Household)\',\'Private Adoptive Child\')';
            List<SObject> sObjListpersonInvolved = DataService.performQueryOperation(personInvolvedsFields, 'Contact', personInvolvedsCondition, Utility.queryLimit);
            personInvolveds = (List<Contact>)sObjListpersonInvolved;*/
           
           
            servicePlanWrap.personInvolvedPicklist = personInvolvedsPickList;
            List<String> visitationPlanFields = new List<String>{'Id', 'Client__c', 'Client__r.Name', 'Established_Date__c', 'End_Date__c', 'Court_Ordered__c','Explain_Visitor__c',
                                                  'No_visits_allowed__c', 'Conditions__c', 'Comments__c', 'Explain_Visit_Plan__c', 'Frequency__c', 'Explain__c','Person_involved__c',
                                                  'Visit_Duration__c', 'Location__c', 'Child_Transportation__c', 'ExplainChild__c', 'Visitor_Transportation__c'};
            String visitationPlanCondition = 'Service_Plan__c = \''+ String.escapeSingleQuotes(servicePlanId) + '\'' ;
            List<SObject> sObjListVisitationPlan = DataService.performQueryOperation(visitationPlanFields, 'Visitation_Plan__c', visitationPlanCondition, Utility.queryLimit);
            if(sObjListVisitationPlan.size() > 0) {
                servicePlanWrap.visitationPlanList = (List<Visitation_Plan__c>)sObjListVisitationPlan;
            }


                                                  
        }
        return JSON.serialize(servicePlanWrap);
    }
    
    @AuraEnabled
    public static String createVisitationPlanRecord(String visitionPlanJSON) {
    
        if(String.isNotBlank(visitionPlanJSON)) {
            Visitation_Plan__c visitationRec = (Visitation_Plan__c)JSON.deserialize(visitionPlanJSON, Visitation_Plan__c.class);
            if (String.isBlank(visitationRec.Id)) {
                /*FieldLevelSecurity.checkFieldAccessByCriteria('Client__c, Established_Date__c, End_Date__c, Court_Ordered__c,Explain_Visitor__c,'+
                'No_visits_allowed__c, Conditions__c, Comments__c, Explain_Visit_Plan__c, Frequency__c, Explain__c,Person_involved__c,'+
                'Visit_Duration__c, Location__c, Child_Transportation__c, ExplainChild__c, Visitor_Transportation__c', 'create', 'Visitation_Plan__c', Boolean.valueOf(Label.HasNamespace));*/
                insert visitationRec;
            } else {
                /*FieldLevelSecurity.checkFieldAccessByCriteria('Client__c, Established_Date__c, End_Date__c, Court_Ordered__c,Explain_Visitor__c,'+
            'No_visits_allowed__c, Conditions__c, Comments__c, Explain_Visit_Plan__c, Frequency__c, Explain__c,Person_involved__c,'+
            'Visit_Duration__c, Location__c, Child_Transportation__c, ExplainChild__c, Visitor_Transportation__c', 'update', 'Visitation_Plan__c', Boolean.valueOf(Label.HasNamespace));*/
                update visitationRec;
            }
            return visitationRec.Id;
        } else {
            return null;
        }
        
    }
 
    @AuraEnabled
    public static String getVisitationPlanRec(String visitionId) {
    
        ServicePlanWrapper servicePlanWrap = new ServicePlanWrapper();
        List<String> visitationPlanFields = new List<String>{'Id', 'Client__c', 'Established_Date__c', 'End_Date__c', 'Person_involved__c', 'Court_Ordered__c',
                                           'No_visits_allowed__c', 'Conditions__c', 'Comments__c', 'Explain_Visit_Plan__c', 'Frequency__c', 'Explain__c',
                                           'Location__c', 'Child_Transportation__c', 'ExplainChild__c', 'Visitor_Transportation__c','Explain_Visitor__c'};
        String visitationPlanCondition = 'Id = \''+ String.escapeSingleQuotes(visitionId) + '\'' ;
        List<SObject> sObjListVisitationPlan = DataService.performQueryOperation(visitationPlanFields, 'Visitation_Plan__c', visitationPlanCondition, Utility.queryLimit);
        if(sObjListVisitationPlan.size() > 0) {
            servicePlanWrap.visitationPlanRec = (Visitation_Plan__c)sObjListVisitationPlan[0];
        }
        return JSON.serialize(servicePlanWrap);
    }
    
    @AuraEnabled
    public static void deleteVisitationPlanRec(String visitionPlanRec) {
        
        if (String.isNotBlank(visitionPlanRec)) {
            Visitation_Plan__c  visitationPlanRecord= (Visitation_Plan__c )JSON.deserialize(visitionPlanRec, Visitation_Plan__c.class);
            //FieldLevelSecurity.checkObjectAccessByDelete('Visitation_Plan__c');            
            delete visitationPlanRecord;
        }
        
    }

    @AuraEnabled
    public static String getActionsInitialInfo(String recordId) {
        
        ServicePlanWrapper servicePlanWrap = new ServicePlanWrapper();
        servicePlanWrap.statusPicklist = Utility.getPicklistinfo('Goal_Action__c','Status__c',false);
        //FieldLevelSecurity.checkFieldAccessByCriteria('Goal__c', 'view', 'Objective__c', Boolean.valueOf(Label.HasNamespace));
        //FieldLevelSecurity.checkFieldAccessByCriteria('Service_Plan__c', 'view', 'Goal__c', Boolean.valueOf(Label.HasNamespace));
        //FieldLevelSecurity.checkFieldAccessByCriteria('Name', 'view', 'Contact', Boolean.valueOf(Label.HasNamespace));
        
        Objective__c objectiveRec = new Objective__c();
        List<String> objectiveFields = new List<String>{'Goal__r.Service_Plan__r.Service_Case__c'};
        String objectiveCondition = 'Id = \'' + String.escapeSingleQuotes(recordId) + '\'';
        List<SObject> sObjListObjective = DataService.performQueryOperation(objectiveFields, 'Objective__c', objectiveCondition, Utility.queryLimit);
        
        if(sObjListObjective != null && sObjListObjective.size() > 0) {
            objectiveRec = (Objective__c)sObjListObjective[0];
        }
        
        List<Person__c> persons = new List<Person__c>();

        
        /*List<String> personBenefitingFields = new List<String>{'Name'};
        String personBenefitingCondition = 'Service_Case__c = \'' + String.escapeSingleQuotes(objectiveRec.Goal__r.Service_Plan__r.Service_Case__c) + '\'' +
                                            'AND Intake_Person_Role__c INCLUDES (\'Biological Child\',\'Child\',\'Other Child\',\'Other Child (Not in Household)\',\'Private Adoptive Child\',\'Legal Guardian\')';
        List<SObject> sObjListpersonBenefiting = DataService.performQueryOperation(personBenefitingFields, 'Contact', personBenefitingCondition, Utility.queryLimit);
        personBenefiting = (List<Contact>)sObjListpersonBenefiting;
        
        
        List<String> personResponsibleFields = new List<String>{'Name'};
        String personResponsibleCondition = 'Service_Case__c = \'' + String.escapeSingleQuotes(objectiveRec.Goal__r.Service_Plan__r.Service_Case__c) + '\'' ;
        List<SObject> sObjListpersonResponsible = DataService.performQueryOperation(personResponsibleFields, 'Contact', personResponsibleCondition, Utility.queryLimit);
        personResponsible = (List<Contact>)sObjListpersonResponsible;*/
        
            List<String> personJnFields = new List<String>{'Person__c','Person__r.Name','Person__r.Intake_Person_Role__c'};
            String personJncontactCondition = 'Service_Case__c = \''+ String.escapeSingleQuotes(objectiveRec.Goal__r.Service_Plan__r.Service_Case__c) + '\'';
            List<SObject> sObjListContact = DataService.performQueryOperation(personJnFields, 'Person__c', personJncontactCondition, Utility.queryLimit);
            persons = (List<Person__c>)sObjListContact;

            
            List<Utility.pickListWrap> personBenefitingPicklist = new List<Utility.pickListWrap>();
            List<Utility.pickListWrap> personResponsiblePicklist = new List<Utility.pickListWrap>();

            
            Utility.pickListWrap intialPick = new Utility.pickListWrap();
            intialPick.label = '--None--';
            intialPick.value = '';
            personBenefitingPicklist.add(intialPick);
          	Utility.pickListWrap pick ;

            Utility.pickListWrap intialPick1 = new Utility.pickListWrap();
            intialPick1.label = '--None--';
            intialPick1.value = '';
            Utility.pickListWrap pick1;
            personResponsiblePicklist.add(intialPick1);
            
            for(Person__c personjn : persons) {               
                
                if(String.isNotBlank(personjn.Id)) {
                        
                        pick = new Utility.pickListWrap();
                        pick.label = personjn.Person__r.Name;
                        pick.value = personjn.Person__r.Name;
                        personResponsiblePicklist.add(pick);
                    	String role = personjn.Person__r.Intake_Person_Role__c;
                    if(role.contains('Biological Child') || role.contains('Child') || role.contains('Other Child') 
                       || role.contains('Other Child (Not in Household)') ||role.contains('Private Adoptive Child')) {
                        pick1 = new Utility.pickListWrap();
                        pick1.label = personjn.Person__r.Name;
                        pick1.value = personjn.Person__r.Name;
                        personBenefitingPicklist.add(pick1);
                    }
                }
            }  
        servicePlanWrap.personBenefitingPicklist = personBenefitingPicklist;

        List<Collateral__c> collaterals = new List<Collateral__c>();
        List<String> collateralFields = new List<String>{'Name','First_Name__c','Middle_Name__c','Last_Name__c'};
        String collateralCondition = 'Service_Case__c = \'' + String.escapeSingleQuotes(objectiveRec.Goal__r.Service_Plan__r.Service_Case__c) + '\'' ;
        List<SObject> sObjListcollateral = DataService.performQueryOperation(collateralFields, 'Collateral__c', collateralCondition, Utility.queryLimit);
        collaterals = (List<Collateral__c>)sObjListcollateral; 
        
        /*List<Utility.pickListWrap> personBenefitingPicklist = new List<Utility.pickListWrap>();
        Utility.pickListWrap intialPick1 = new Utility.pickListWrap();
        intialPick1.label = '--None--';
        intialPick1.value = '';
        personBenefitingPicklist.add(intialPick1);
        Utility.pickListWrap pick;
        
        for(Contact con : personBenefiting) {
        
            if(String.isNotBlank(con.Id)) {
                
                pick = new Utility.pickListWrap();
                pick.label = con.Name;
                pick.value = con.Name;
                personBenefitingPicklist.add(pick);
            }
        }
        servicePlanWrap.personBenefitingPicklist = personBenefitingPicklist;*/
        
       
        for(Collateral__c collateralRec : collaterals) {
        
            if(String.isNotBlank(collateralRec.Id)) {
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
                pick1 = new Utility.pickListWrap();
                pick1.label = collateralName;
                pick1.value = collateralName;
                personResponsiblePicklist.add(pick);
            }
        }
        servicePlanWrap.personResponsiblePicklist = personResponsiblePicklist;
        return JSON.serialize(servicePlanWrap);
    }

    @AuraEnabled
    public static String upsertGoalActions(String goalActionJSON) {

        if(String.isNotBlank(goalActionJSON)) {
            Goal_Action__c goalActionRec = (Goal_Action__c)JSON.deserialize(goalActionJSON, Goal_Action__c.class);
           if (String.isBlank(goalActionRec.Id)) {
                //FieldLevelSecurity.checkFieldAccessByCriteria('Name, Person_Benefitizing__c, Person_Responsible__c, Start_Date__c, End_Date__c, Status__c, Comments__c ', 'create', 'Goal_Action__c', Boolean.valueOf(Label.HasNamespace));
               insert goalActionRec;
           } else {
                //FieldLevelSecurity.checkFieldAccessByCriteria('Name, Person_Benefitizing__c, Person_Responsible__c, Start_Date__c, End_Date__c, Status__c, Comments__c ', 'update', 'Goal_Action__c', Boolean.valueOf(Label.HasNamespace));
                update goalActionRec;
           }
           return goalActionRec.Id;
       } else {
           return null;
       }
       
    }



    @AuraEnabled
    public static String getServicePlanVersionsInitInfo(String recordId) {
       
        ServicePlanWrapper servicePlanWrap = new ServicePlanWrapper();
        //FieldLevelSecurity.checkFieldAccessByCriteria('Name, Persons_Benefitizing__c, Start_Date__c, End_Date__c', 'view', 'Service_Plan_Version__c', Boolean.valueOf(Label.HasNamespace));
        //FieldLevelSecurity.checkFieldAccessByCriteria('Service_Case__c', 'view', 'Service_Plan__c', Boolean.valueOf(Label.HasNamespace));
        //FieldLevelSecurity.checkFieldAccessByCriteria('Name', 'view', 'Contact', Boolean.valueOf(Label.HasNamespace));
        
        
        List<String> spVersionFields = new List<String>{'Id', 'Name', 'Persons_Benefitizing__c', 'Start_Date__c', 'End_Date__c'};
        String spVersionCondition = 'Service_Plan__c = \'' + String.escapeSingleQuotes(recordId) + '\'';
        List<SObject> sObjListspVersion = DataService.performQueryOperation(spVersionFields, 'Service_Plan_Version__c', spVersionCondition, Utility.queryLimit);
        
        if(sObjListspVersion != null && sObjListspVersion.size() > 0) {
            servicePlanWrap.servicePlanVersionList = (List<Service_Plan_Version__c>)sObjListspVersion;
        }
        Service_Plan__c servicePlanRec = new Service_Plan__c();
        List<String> spFields = new List<String>{'Name','Service_Case__c'};
        String spCondition = 'Id = \'' + String.escapeSingleQuotes(recordId) + '\'';
        List<SObject> sObjListsp = DataService.performQueryOperation(spFields, 'Service_Plan__c', spCondition, Utility.queryLimit);
        
        if(sObjListsp != null && sObjListsp.size() > 0) {
            servicePlanRec = (Service_Plan__c)sObjListsp[0];
        }

        List<Person__c> personBenefiting = new List<Person__c>();
        List<String> personBenefitingFields = new List<String>{'Person__r.Name'};
        String personBenefitingCondition = 'Service_Case__c = \'' + String.escapeSingleQuotes(servicePlanRec.Service_Case__c) + '\'' +
                                            'AND Person__r.Intake_Person_Role__c INCLUDES (\'Biological Child\',\'Child\',\'Other Child\',\'Other Child (Not in Household)\',\'Private Adoptive Child\',\'Legal Guardian\')';
        List<SObject> sObjListpersonBenefiting = DataService.performQueryOperation(personBenefitingFields, 'Person__c', personBenefitingCondition, Utility.queryLimit);
        personBenefiting = (List<Person__c>)sObjListpersonBenefiting;        
        List<Utility.pickListWrap> personBenefitingPicklist = new List<Utility.pickListWrap>();
        Utility.pickListWrap intialPick1 = new Utility.pickListWrap();
        intialPick1.label = '--None--';
        intialPick1.value = '';
        personBenefitingPicklist.add(intialPick1);
        Utility.pickListWrap pick;

        for(Person__c con : personBenefiting) {
        
            if(String.isNotBlank(con.Id)) {
                
                pick = new Utility.pickListWrap();
                pick.label = con.Person__r.Name;
                pick.value = con.Person__r.Name;
                personBenefitingPicklist.add(pick);
            }
        }
        servicePlanWrap.personBenefitingPicklist = personBenefitingPicklist;
        return JSON.serialize(servicePlanWrap);
        
    }

    @AuraEnabled
    public static String upsertServicePlanVersions(String servicePlanVersionJSON) {

        if(String.isNotBlank(servicePlanVersionJSON)) {
            Service_Plan_Version__c servicePlanVersionRec = (Service_Plan_Version__c)JSON.deserialize(servicePlanVersionJSON, Service_Plan_Version__c.class);
           if (String.isBlank(servicePlanVersionRec.Id)) {
                //FieldLevelSecurity.checkFieldAccessByCriteria('Persons_Benefitizing__c, Start_Date__c, End_Date__c', 'create', 'Service_Plan_Version__c', Boolean.valueOf(Label.HasNamespace));
               insert servicePlanVersionRec;
           } else {
                //FieldLevelSecurity.checkFieldAccessByCriteria('Persons_Benefitizing__c, Start_Date__c, End_Date__c', 'update', 'Service_Plan_Version__c', Boolean.valueOf(Label.HasNamespace));
               update servicePlanVersionRec;
           }
           return servicePlanVersionRec.Id;
       } else {
           return null;
       }
       
    }

    public class ServicePlanWrapper {
    
        @AuraEnabled
        public List<Utility.pickListWrap> clientPicklist;
        @AuraEnabled
        public List<Utility.pickListWrap> personInvolvedPicklist;
        @AuraEnabled
        public List<Utility.pickListWrap> conditionsPicklist;
        @AuraEnabled
        public List<Utility.pickListWrap> frequencyPicklist;
        @AuraEnabled
        public List<Utility.pickListWrap> visitorTransportationPicklist;
        @AuraEnabled
        public List<Utility.pickListWrap> childTransportationPicklist;
        @AuraEnabled
        public List<Utility.pickListWrap> visitDurationPicklist;
        @AuraEnabled
        public List<Visitation_Plan__c> visitationPlanList;
        @AuraEnabled
        public Visitation_Plan__c visitationPlanRec;

        @AuraEnabled
        public List<Utility.pickListWrap> statusPicklist;
        @AuraEnabled
        public List<Utility.pickListWrap> personBenefitingPicklist;
        @AuraEnabled
        public List<Utility.pickListWrap> personResponsiblePicklist;
        @AuraEnabled
        public List<Goal_Action__c> goalActionRecords;

        @AuraEnabled
        public List<Service_Plan_Version__c> servicePlanVersionList;      
    }
}