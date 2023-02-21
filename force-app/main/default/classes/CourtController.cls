public with sharing class CourtController {

    @AuraEnabled
    public static String getCourtChildDetails(String petitionId) {
        
        GetInitialWrapper initWrap = new GetInitialWrapper();
        FieldLevelSecurity.checkFieldAccessByCriteria('Siblings_Name__c, is_Sibling_is_in_Child_Care__c, is_Abuse_Neglect__c, Other__c,'+
                                 'CPS__c, Child_welfare_Services__c, CINA_TPR_respondent_Siblings__c,'+
                                 'C_Status_of_sibling_s_relationship__c, D_Narrative__c, Court__c','view','Sibling__c', Boolean.valueOf(Label.HasNamespace));
        initWrap.siblingsList = [SELECT Id,Siblings_Name__c, is_Sibling_is_in_Child_Care__c, is_Abuse_Neglect__c, Other__c,
                                 CPS__c, Child_welfare_Services__c, CINA_TPR_respondent_Siblings__c,
                                 C_Status_of_sibling_s_relationship__c, D_Narrative__c, Court__c FROM Sibling__c
                                 WHERE Court__c = :petitionId LIMIT :Utility.queryLimit];
        
        FieldLevelSecurity.checkFieldAccessByCriteria('Institution__c, Supoenaed_Name__c, Subpoenaed_Address__c,Subpoenaed_Person__c,For_each_subpoena__c, Court__c, Type_of_Records__c','view','Subpoenaed__c', Boolean.valueOf(Label.HasNamespace));

        initWrap.subpoenaedList = [ SELECT Id, Institution__c, Supoenaed_Name__c, Subpoenaed_Address__c, 
                                    Subpoenaed_Person__c,
                                    For_each_subpoena__c, Court__c, Type_of_Records__c FROM Subpoenaed__c
                                    WHERE Court__c = :petitionId LIMIT :Utility.queryLimit];     
        
        return JSON.serialize(initWrap);
    }
    
    @AuraEnabled(cacheable=true)
    public static String getInitialInfos(Id recordId) {
        
        GetInitialWrapper initWrap = new GetInitialWrapper();
        Utility.pickListWrap childPick;
        
        Id getRecordId;
        String sObjName = recordId.getSObjectType().getDescribe().getName();
        Court__c courtRec = new Court__c();
        
        if(sObjName == 'Court__c') {
            
            List<String> courtFields = new List<String>{'Service_Case__c', 'Investigation__c'};
            String courtCondition = 'Id = \''+ String.escapeSingleQuotes(recordId) +'\'';
            List<SObject> courtsObjList = DataService.performQueryOperation(courtFields, 'Court__c ', courtCondition, Utility.queryLimit);
            courtRec = (Court__c)courtsObjList[0];
            if(courtRec.Service_Case__c != null) {
                getRecordId = courtRec.Service_Case__c;
            } else if(courtRec.Investigation__c != null){
                getRecordId = courtRec.Investigation__c;
            }
        } else {
            getRecordId = recordId;
        }
        
        
        /*List<String> contactFields = new List<String>{'Id', 'Name'};
        String contactCondition = 'Service_Case__c = \''+ getRecordId +'\''+' OR ';
        contactCondition +='Investigation__c = \''+ getRecordId +'\'';
        List<SObject> contactsObjList = DataService.performQueryOperation(contactFields, 'Contact', contactCondition, Utility.queryLimit);
        List<Contact> personList = (List<Contact>)contactsObjList;*/

        List<String> personJnFields = new List<String>{'Person__c', 'Person__r.Name'};
        String personCondition = 'Service_Case__c = \''+getRecordId+'\''+' OR ';
        personCondition += 'Investigation__c = \''+ getRecordId +'\'';
        List<SObject> personsObjsList = DataService.performQueryOperation(personJNFields, 'Person__c', personCondition, Utility.queryLimit);
        List<Person__c> personJnList = (List<Person__c>) personsObjsList;

       /* for(Contact contactIns : personList) {
            childPick = new Utility.pickListWrap();
            childPick.label = contactIns.Name;
            childPick.value = contactIns.Id;
            initWrap.petitionForChildPicklist.add(childPick);
        } */
         for(Person__c personIns : personJnList) {
            childPick = new Utility.pickListWrap();
            childPick.label = personIns.Person__r.Name;
            childPick.value = personIns.Person__c;
            initWrap.petitionForChildPicklist.add(childPick);
        }
        
        
        Utility.pickListWrap childPickAttorney;
        List<String> collateralFields = new List<String>{'Id', 'Collateral_Full_Name__c'};
        String collateralCondition = '(Service_Case__c = \''+ getRecordId +'\''+' OR ';
        collateralCondition +='Investigation__c = \''+ getRecordId +'\' )AND Role__c INCLUDES (';
        collateralCondition +='\'APGRB Attorney\', '+'\'Attorney\', '+'\'Attorney General\', '+'\'Client Attorney\', '+'\'Prosecuting Attorney\', '+'\'Child Advocate - CASA\')';
        List<SObject> collateralsObjList = DataService.performQueryOperation(collateralFields, 'Collateral__c', collateralCondition, Utility.queryLimit);
        List<Collateral__c>  collateralList = (List<Collateral__c>)collateralsObjList;
        
        for(Collateral__c collateralIns : collateralList) {
            childPickAttorney = new Utility.pickListWrap();
            childPickAttorney.label = collateralIns.Collateral_Full_Name__c;
            childPickAttorney.value = collateralIns.Id;
            initWrap.childAttorneyPicklist.add(childPickAttorney);
        }
        
        Utility.pickListWrap obj;
        List<String> contactsFields = new List<String>{'Id', 'Name','Person__c','Person__r.Name','Person_Role__c'};
        String contactsCondition = '(Service_Case__c = \''+ getRecordId +'\''+' OR ';
        contactsCondition +='Investigation__c = \''+ getRecordId +'\') AND Person_Role__c  Excludes (';
        contactsCondition +='\'Child Attorney\', '+'\'Biological Child\', '+'\'Other Child (Not in Household)\', '+'\'Private Adoptive Child\', '+'\'Advocate\') ';
        List<SObject> contactsObjList1 = DataService.performQueryOperation(contactsFields, 'Person__c', contactsCondition, Utility.queryLimit);
        List<Person__c> contactList = (List<Person__c>)contactsObjList1;
        
        for (Person__c contactIns : contactList) {
            
            obj = new Utility.pickListWrap();
            obj.label = contactIns.Person__r.Name;
            obj.value = contactIns.Person__c;
            initWrap.otherClientsNamedOnPetitionPicklist.add(obj);
            
        }
        List<String> childFields = new List<String>{'Person__r.Name', 'Id', 'Service_Case__c','Person__c', 'Person_Role__c', 'Person__r.Age__c', 'Person__r.Date_of_Birth__c'};
            String childCondition = '(Service_Case__c = \''+ getRecordId +'\''+' OR ';
        childCondition +='Investigation__c = \''+ getRecordId +'\' )AND Person_Role__c Excludes (';
        childCondition +='\'Biological Child\', '+'\'Other Child (Not in Household)\', '+'\'Private Adoptive Child\') ';
        List<SObject> personsObjList = DataService.performQueryOperation(childFields, 'Person__c', childCondition, Utility.queryLimit);
        initWrap.childList = (List<Person__c>)personsObjList;
        
        Utility.pickListWrap parentName; 
        if(initWrap.childList !=Null && initWrap.childList.size() > 0) {
            for(Person__c con:initWrap.childList) {
                parentName = new Utility.pickListWrap();
                parentName.label = con.Person__r.Name;
                parentName.value = con.Person__c;
                initWrap.parentNamePicklist.add(parentName);
            }
        }
        
        return JSON.serialize(initWrap);
    }
    
    /*@AuraEnabled
    public static String getInitialInfos(String recordId) {
    
        GetInitialWrapper initWrap = new GetInitialWrapper();
        Utility.pickListWrap intialPick = new Utility.pickListWrap();
        intialPick.label = '--None--';
        intialPick.value = '';
        initWrap.petitionForChildPicklist.add(intialPick);
        FieldLevelSecurity.checkFieldAccessByCriteria('Name', 'view', 'Contact',  Boolean.valueOf(Label.HasNamespace));
        Utility.pickListWrap childPick;
        for (Contact contactIns : [SELECT Id, Name FROM Contact WHERE (Service_Case__c = :recordId OR Investigation__c  =:recordId) AND RecordTypeId = :Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Persons Involved').getRecordTypeId() LIMIT :Utility.queryLimit]) {
            childPick = new Utility.pickListWrap();
            childPick.label = contactIns.Name;
            childPick.value = contactIns.Id;
            initWrap.petitionForChildPicklist.add(childPick);
        }
        FieldLevelSecurity.checkFieldAccessByCriteria('Name,Intake_Person_Role__c', 'view', 'Contact',  Boolean.valueOf(Label.HasNamespace));
        Utility.pickListWrap childPickAttorney;
        for (Contact contactIns : [SELECT Id, Name,Intake_Person_Role__c FROM Contact WHERE (Service_Case__c = :recordId OR Investigation__c  =:recordId) LIMIT :Utility.queryLimit]) {
            if(String.isNotBlank(contactIns.Intake_Person_Role__c) && contactIns.Intake_Person_Role__c.contains('Advocate')){
            childPickAttorney = new Utility.pickListWrap();
            childPickAttorney.label = contactIns.Name;
            childPickAttorney.value = contactIns.Id;
            initWrap.childAttorneyPicklist.add(childPickAttorney);
		}
       

        Utility.pickListWrap childPickAttorney;
        initWrap.childAttorneyPicklist.add(intialPick);
        FieldLevelSecurity.checkFieldAccessByCriteria('Collateral_Full_Name__c', 'view', 'Collateral__c',  Boolean.valueOf(Label.HasNamespace));
        for (Collateral__c collateralIns : [SELECT Id, Collateral_Full_Name__c FROM Collateral__c WHERE (Service_Case__c = :recordId OR Investigation__c  =:recordId) AND
                                            Role__c INCLUDES ('APGRB Attorney','Attorney','Attorney General','Client Attorney','Prosecuting Attorney','Child Advocate - CASA')
                                            LIMIT :Utility.queryLimit]) {
            childPickAttorney = new Utility.pickListWrap();
            childPickAttorney.label = collateralIns.Collateral_Full_Name__c;
            childPickAttorney.value = collateralIns.Id;
            initWrap.childAttorneyPicklist.add(childPickAttorney);
        }

        FieldLevelSecurity.checkFieldAccessByCriteria('Name,Intake_Person_Role__c', 'view', 'Contact',  Boolean.valueOf(Label.HasNamespace));
        Utility.pickListWrap obj;
        initWrap.otherClientsNamedOnPetitionPicklist.add(intialPick);
        for (Contact contactIns : [SELECT Id, Name,Intake_Person_Role__c FROM Contact 
                                   WHERE (Service_Case__c = :recordId OR Investigation__c  =:recordId) AND Intake_Person_Role__c Excludes('Child Attorney','Biological Child','Other Child (Not in Household)',
                              'Private Adoptive Child','Advocate') AND RecordTypeId = :Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Persons Involved').getRecordTypeId() LIMIT :Utility.queryLimit]) {
            
            obj = new Utility.pickListWrap();
            obj.label = contactIns.Name;
            obj.value = contactIns.Id;
            initWrap.otherClientsNamedOnPetitionPicklist.add(obj);
            
        }
        initWrap.typeOfPetitionPicklist = Utility.getPicklistinfo('Court__c','Type_of_Petition__c',false);
        FieldLevelSecurity.checkFieldAccessByCriteria('Name, Type_of_Petition__c, Petition_for_Child__c,Petition_Date__c, Other_Client_named_on_Petition__c, Child_Attorney__c , Child_s_Attorney__c, Name_of_LDSS_Attorney__c,Witness_Name__c, Court_Petition_ID__c, Service_Case__c,'+
                                                'New_Review__c, Emergency_Non_Emergency__c, Police_Complaint_No_if_not_foster_home__c, Kin_Placement_Name__c, Address_ZipCode__c,'+
                                                'Plaement_Relationship__c, The_person_s_with_Legacy_Custody_is__c, The_person_s_whom_has_had_Physical__c, The_child_s_relationship_to_the_Legal__c,'+
                                                'Parent_1_Name__c, The_Parent_1_has_been_notified__c, Reason_for_not_notifying__c, Parent_2_Name__c, The_Parent_2_has_been_notified__c,'+ 
                                                'Parent2_Reason_for_not_notifying__c, Case_Worker_Name__c, Case_Worker_Phone_Number__c, Supervisor_Name__c, Supervisor_Phone_Number__c,'+ 
                                                'Date_Request_Completed__c, Child_in_Shelter_Care_on__c, Date_of_Emergency_Shelter_Care__c, X10_Previous_Juvenile_Court__c,'+ 
                                                'Nature_of_Physical_Abuse__c, Medical_Exam_Where__c, Documentation_of_injury__c, Failed_to_protect_mother_father__c, Respondent_disclosed_to_Disclosed_what__c,'+ 
                                                'Nature_of_Sexual_Abuse_mother_father__c, Sexual_Medical_Exam_Where__c, Sexual_Documentation_of_injury__c, Sexual_Failed_to_protect_mother_father__c,'+ 
                                                'Sexual_Respondent_disclosed_to__c, Nature_of_neglect_mother_father__c, Neglect_Medical_Exam_Where__c, Document_of_Neglect__c,'+
                                                'Neglect_Failed_to_protect_mother_father__c, Neglect_Respondent_disclosed__c, Within_the_first_12_month_of_the_child_s__c, Severe_chronic_development_disability__c,'+
                                                'Mental_health_disorder__c, A_Physical_mental_issues_of_the_Respond__c, B_Was_Respondent_born_substance_exposed__c, C_Current_location_of_the_Respondent__c,'+ 
                                                'D_Special_needs_of_Respondent__c, E_Status_of_child_s_relationship_with_p__c, F_Legal_status_of_Respondent__c, A_Detailed_Description_of_Home__c,'+
                                                'B_Inadequate_Housing__c, PARENT_S_CIRCUMSTANCE__c, CPS__c, Child_Welfare_Services__c, Criminal__c, CINA_TPR_respondent_siblings__c,'+ 
                                                'A_Was_there_an_active_Child_Welfare__c, B_What_services_were_offered_efforts__c, C_What_Services_were_offered_prior__c,'+
                                                'D_Were_reasonable_efforts_not_made__c, Resonable_Date__c, Participants__c, Outcome__c, Removal_Date__c, Removal_Time__c, Type_of_Placement__c, notes__c, Does_this_information_exist__c','view','Court__c',  Boolean.valueOf(Label.HasNamespace));        
        FieldLevelSecurity.checkFieldAccessByCriteria('Name','view','Contact', Boolean.valueOf(Label.HasNamespace));
        
        initWrap.serviceCourtList = [SELECT Id,Name, Type_of_Petition__c, Petition_for_Child__c,Petition_for_Child__r.Name, Child_s_Attorney__c, Child_s_Attorney__r.Collateral_Full_Name__c,
                                                Petition_Date__c, Other_Client_named_on_Petition__c, Child_Attorney__c ,Child_Attorney__r.Name, Name_of_LDSS_Attorney__c,
                                                Witness_Name__c, Court_Petition_ID__c, Service_Case__c,
                                                New_Review__c, Emergency_Non_Emergency__c, Police_Complaint_No_if_not_foster_home__c, Kin_Placement_Name__c, Address_ZipCode__c,
                                                Plaement_Relationship__c, The_person_s_with_Legacy_Custody_is__c, The_person_s_whom_has_had_Physical__c, The_child_s_relationship_to_the_Legal__c,
                                                Parent_1_Name__c, The_Parent_1_has_been_notified__c, Reason_for_not_notifying__c, Parent_2_Name__c, The_Parent_2_has_been_notified__c, 
                                                Parent2_Reason_for_not_notifying__c, Case_Worker_Name__c, Case_Worker_Phone_Number__c, Supervisor_Name__c, Supervisor_Phone_Number__c, 
                                                Date_Request_Completed__c, Child_in_Shelter_Care_on__c, Date_of_Emergency_Shelter_Care__c, X10_Previous_Juvenile_Court__c, 
                                                Nature_of_Physical_Abuse__c, Medical_Exam_Where__c, Documentation_of_injury__c, Failed_to_protect_mother_father__c, Respondent_disclosed_to_Disclosed_what__c, 
                                                Nature_of_Sexual_Abuse_mother_father__c, Sexual_Medical_Exam_Where__c, Sexual_Documentation_of_injury__c, Sexual_Failed_to_protect_mother_father__c, 
                                                Sexual_Respondent_disclosed_to__c, Nature_of_neglect_mother_father__c, Neglect_Medical_Exam_Where__c, Document_of_Neglect__c,
                                                Neglect_Failed_to_protect_mother_father__c, Neglect_Respondent_disclosed__c, Within_the_first_12_month_of_the_child_s__c, Severe_chronic_development_disability__c,
                                                Mental_health_disorder__c, A_Physical_mental_issues_of_the_Respond__c, B_Was_Respondent_born_substance_exposed__c, C_Current_location_of_the_Respondent__c, 
                                                D_Special_needs_of_Respondent__c, E_Status_of_child_s_relationship_with_p__c, F_Legal_status_of_Respondent__c, A_Detailed_Description_of_Home__c,
                                                B_Inadequate_Housing__c, PARENT_S_CIRCUMSTANCE__c, CPS__c, Child_Welfare_Services__c, Criminal__c, CINA_TPR_respondent_siblings__c, 
                                                A_Was_there_an_active_Child_Welfare__c, B_What_services_were_offered_efforts__c, C_What_Services_were_offered_prior__c,
                                                D_Were_reasonable_efforts_not_made__c, Resonable_Date__c, Participants__c, Outcome__c, Removal_Date__c, Removal_Time__c, Type_of_Placement__c, notes__c, Does_this_information_exist__c
                                                FROM Court__c WHERE (Service_Case__c = :recordId OR Investigation__c  =:recordId) AND Client_Name_Case_Number__c = NULL ORDER BY CreatedDate DESC LIMIT :Utility.queryLimit];
        initWrap.newReviewPickList = Utility.getPicklistinfo('Court__c','New_Review__c',false);
        initWrap.emergencyPickList = Utility.getPicklistinfo('Court__c','Emergency_Non_Emergency__c',false);
        initWrap.childCurrentPlacementPicklist = Utility.getPicklistinfo('Court__c','Child_s_Current_placement_if_not_foster__c',false);
        FieldLevelSecurity.checkFieldAccessByCriteria('Name,Service_Case__c, Intake_Person_Role__c, Age__c, Date_of_Birth__c','view','Contact', Boolean.valueOf(Label.HasNamespace));

        initWrap.childList = [SELECT Name, Id, Service_Case__c, Intake_Person_Role__c, Age__c, Date_of_Birth__c  
                              FROM Contact WHERE (Service_Case__c =:recordId OR Investigation__c  =:recordId)
                              AND Intake_Person_Role__c Excludes ('Biological Child','Other Child (Not in Household)',
                              'Private Adoptive Child') AND RecordTypeId = :Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Persons Involved').getRecordTypeId() LIMIT :Utility.queryLimit
                             ];
   		Utility.pickListWrap parentName; 
        if(initWrap.childList !=Null && initWrap.childList.size() > 0) {
            for(contact con:initWrap.childList) {
                parentName = new Utility.pickListWrap();
                parentName.label = con.Name;
                parentName.value = con.Id;
                initWrap.parentNamePicklist.add(parentName);
            }
        }
        initWrap.previousJuvenileCourtPicklist = Utility.getPicklistinfo('Court__c','X10_Previous_Juvenile_Court__c',false);
        initWrap.parentsCircumstancePicklist = Utility.getPicklistinfo('Court__c','PARENT_S_CIRCUMSTANCE__c',false);
        initWrap.specialneedsofRespondentPicklist = Utility.getPicklistinfo('Court__c','D_Special_needs_of_Respondent__c',false);
        initWrap.whatServicesWereOfferedPicklist = Utility.getPicklistinfo('Court__c','C_What_Services_were_offered_prior__c',false);
        initWrap.wereReasonableEffortsNotMadePicklist = Utility.getPicklistinfo('Court__c','D_Were_reasonable_efforts_not_made__c',false);
        initWrap.familyInvolvementMeetingPickList = Utility.getPicklistinfo('Court__c','E_A_Family_Involvement_Meeting__c',false);
        
        return JSON.serialize(initWrap);
    }*/
    
    @AuraEnabled 
    public static String upsertPetition(String petitionJSONStr, String siblingsJSONStr, String subpoenedJSONStr) {
    
        if (String.isNotBlank(petitionJSONStr)) {
            Court__c upsertCourtIns = (Court__c)System.JSON.deserialize(petitionJSONStr, Court__c.class);
            if (String.isBlank(upsertCourtIns.Id)) {
                  FieldLevelSecurity.checkFieldAccessByCriteria('Petition_for_Child__c,Type_of_Petition__c,Petition_Date__c,Other_Client_named_on_Petition__c,Child_Attorney__c,Child_s_Attorney__c,Name_of_LDSS_Attorney__c,Witness_Name__c,Court_Petition_ID__c,New_Review__c,'+
                                                         'Emergency_Non_Emergency__c,Police_Complaint_No_if_not_foster_home__c,Kin_Placement_Name__c,Address_ZipCode__c,Plaement_Relationship__c,The_person_s_with_Legacy_Custody_is__c,The_person_s_whom_has_had_Physical__c,The_child_s_relationship_to_the_Legal__c,'+
                                                         'Parent_1_Name__c,The_Parent_1_has_been_notified__c,Reason_for_not_notifying__c,Parent_2_Name__c,The_Parent_2_has_been_notified__c,Parent2_Reason_for_not_notifying__c,Case_Worker_Name__c,Case_Worker_Phone_Number__c,Supervisor_Name__c,Supervisor_Phone_Number__c,'+
                                                         'Date_Request_Completed__c,Child_in_Shelter_Care_on__c,Date_of_Emergency_Shelter_Care__c,X10_Previous_Juvenile_Court__c,Nature_of_Physical_Abuse__c,Medical_Exam_Where__c,Documentation_of_injury__c,Failed_to_protect_mother_father__c,Respondent_disclosed_to_Disclosed_what__c,'+
                                                         'Nature_of_Sexual_Abuse_mother_father__c,Sexual_Medical_Exam_Where__c,Sexual_Documentation_of_injury__c,Sexual_Failed_to_protect_mother_father__c,Sexual_Respondent_disclosed_to__c,Nature_of_neglect_mother_father__c,Neglect_Medical_Exam_Where__c,Document_of_Neglect__c,'+
                                                         'Neglect_Failed_to_protect_mother_father__c,Neglect_Respondent_disclosed__c,Within_the_first_12_month_of_the_child_s__c,Severe_chronic_development_disability__c,Mental_health_disorder__c,A_Physical_mental_issues_of_the_Respond__c,B_Was_Respondent_born_substance_exposed__c,'+
                                                         'C_Current_location_of_the_Respondent__c,E_Status_of_child_s_relationship_with_p__c,F_Legal_status_of_Respondent__c,A_Detailed_Description_of_Home__c,B_Inadequate_Housing__c,CPS__c,Child_Welfare_Services__c,Criminal__c,CINA_TPR_respondent_siblings__c,A_Was_there_an_active_Child_Welfare__c,'+
                                                         'B_What_services_were_offered_efforts__c,D_Were_reasonable_efforts_not_made__c,Resonable_Date__c,Outcome__c,Removal_Date__c,Removal_Time__c,Does_this_information_exist__c,Does_this_information_exist__c','create','Court__c',  Boolean.valueOf(Label.HasNamespace));
                  insert upsertCourtIns;
                
            } else {
                FieldLevelSecurity.checkFieldAccessByCriteria('Petition_for_Child__c,Type_of_Petition__c,Petition_Date__c,Other_Client_named_on_Petition__c,Child_Attorney__c,Child_s_Attorney__c,Name_of_LDSS_Attorney__c,Witness_Name__c,Court_Petition_ID__c,New_Review__c,'+
                                                         'Emergency_Non_Emergency__c,Police_Complaint_No_if_not_foster_home__c,Kin_Placement_Name__c,Address_ZipCode__c,Plaement_Relationship__c,The_person_s_with_Legacy_Custody_is__c,The_person_s_whom_has_had_Physical__c,The_child_s_relationship_to_the_Legal__c,'+
                                                         'Parent_1_Name__c,The_Parent_1_has_been_notified__c,Reason_for_not_notifying__c,Parent_2_Name__c,The_Parent_2_has_been_notified__c,Parent2_Reason_for_not_notifying__c,Case_Worker_Name__c,Case_Worker_Phone_Number__c,Supervisor_Name__c,Supervisor_Phone_Number__c,'+
                                                         'Date_Request_Completed__c,Child_in_Shelter_Care_on__c,Date_of_Emergency_Shelter_Care__c,X10_Previous_Juvenile_Court__c,Nature_of_Physical_Abuse__c,Medical_Exam_Where__c,Documentation_of_injury__c,Failed_to_protect_mother_father__c,Respondent_disclosed_to_Disclosed_what__c,'+
                                                         'Nature_of_Sexual_Abuse_mother_father__c,Sexual_Medical_Exam_Where__c,Sexual_Documentation_of_injury__c,Sexual_Failed_to_protect_mother_father__c,Sexual_Respondent_disclosed_to__c,Nature_of_neglect_mother_father__c,Neglect_Medical_Exam_Where__c,Document_of_Neglect__c,'+
                                                         'Neglect_Failed_to_protect_mother_father__c,Neglect_Respondent_disclosed__c,Within_the_first_12_month_of_the_child_s__c,Severe_chronic_development_disability__c,Mental_health_disorder__c,A_Physical_mental_issues_of_the_Respond__c,B_Was_Respondent_born_substance_exposed__c,'+
                                                         'C_Current_location_of_the_Respondent__c,E_Status_of_child_s_relationship_with_p__c,F_Legal_status_of_Respondent__c,A_Detailed_Description_of_Home__c,B_Inadequate_Housing__c,CPS__c,Child_Welfare_Services__c,Criminal__c,CINA_TPR_respondent_siblings__c,A_Was_there_an_active_Child_Welfare__c,'+
                                                         'B_What_services_were_offered_efforts__c,D_Were_reasonable_efforts_not_made__c,Resonable_Date__c,Outcome__c,Removal_Date__c,Removal_Time__c,Does_this_information_exist__c,Does_this_information_exist__c','update','Court__c',  Boolean.valueOf(Label.HasNamespace));
                update upsertCourtIns;
            }
        
            if (String.isNotBlank(siblingsJSONStr)) {
                
                List<Sibling__c> insertingSiblingList = new List<Sibling__c>();
                List<Sibling__c> updatingSiblingList = new List<Sibling__c>();
                List<Sibling__c> siblingList = (List<Sibling__c>)System.JSON.deserialize(siblingsJSONStr, List<Sibling__c>.class);
                for (Sibling__c siblings :siblingList) {
                    if (String.isBlank(siblings.Id)) {
                        insertingSiblingList.add(siblings);
                    } else {
                        updatingSiblingList.add(siblings);
                    }
                }
                
                if (insertingSiblingList != null && insertingSiblingList.size() > 0) {
                    FieldLevelSecurity.checkFieldAccessByCriteria('Siblings_Name__c, is_Sibling_is_in_Child_Care__c, is_Abuse_Neglect__c, Other__c,'+
                                                                  'CPS__c, Child_welfare_Services__c, CINA_TPR_respondent_Siblings__c, C_Status_of_sibling_s_relationship__c,'+
                                                                  ' D_Narrative__c' , 'create', 'Sibling__c' ,  Boolean.valueOf(Label.HasNamespace));
                    insert insertingSiblingList;
                }
                if (updatingSiblingList != null && updatingSiblingList.size() > 0) {
                    FieldLevelSecurity.checkFieldAccessByCriteria('Siblings_Name__c, is_Sibling_is_in_Child_Care__c, is_Abuse_Neglect__c, Other__c,'+
                                                                  'CPS__c, Child_welfare_Services__c, CINA_TPR_respondent_Siblings__c, C_Status_of_sibling_s_relationship__c,'+
                                                                  ' D_Narrative__c' , 'update', 'Sibling__c' ,  Boolean.valueOf(Label.HasNamespace));
                   update updatingSiblingList;
                }
            }
            if (String.isNotBlank(subpoenedJSONStr)) {
            
                List<Subpoenaed__c> subpoenaedList = (List<Subpoenaed__c>)System.JSON.deserialize(subpoenedJSONStr, List<Subpoenaed__c>.class);
                List<Subpoenaed__c> insertingSubpoenaedList = new List<Subpoenaed__c>();
                List<Subpoenaed__c> updatingSubpoenaedList = new List<Subpoenaed__c>();
                
                for (Subpoenaed__c subpoenaeds :subpoenaedList) {
                    if (String.isBlank(subpoenaeds.Id)) { 
                        insertingSubpoenaedList.add(subpoenaeds);
                    } else {
                        updatingSubpoenaedList.add(subpoenaeds);
                    }
                }
                if (insertingSubpoenaedList != null && insertingSubpoenaedList.size() > 0) {
                    FieldLevelSecurity.checkFieldAccessByCriteria('Institution__c, Supoenaed_Name__c, Type_of_Records__c, Subpoenaed_Address__c, Subpoenaed_Person__c, For_each_subpoena__c', 'create', 'Subpoenaed__c',  Boolean.valueOf(Label.HasNamespace));
                    insert insertingSubpoenaedList;
                }
                if (updatingSubpoenaedList != null && updatingSubpoenaedList.size() > 0) {
                    FieldLevelSecurity.checkFieldAccessByCriteria('Institution__c, Supoenaed_Name__c, Type_of_Records__c, Subpoenaed_Address__c, Subpoenaed_Person__c, For_each_subpoena__c', 'update', 'Subpoenaed__c',  Boolean.valueOf(Label.HasNamespace));
                    update updatingSubpoenaedList;
                }
            }         
            return upsertCourtIns.Id;
        }
        return null;
    }
    
    @AuraEnabled
    public static String deleteSiblingRec(String siblingRec) {
    
        if(String.isNotBlank(siblingRec)) {
          FieldLevelSecurity.checkObjectAccessByDelete('Sibling__c');
          Sibling__c deleteSiblingIns = (Sibling__c) System.JSON.deserialize(siblingRec, Sibling__c.class);
          delete deleteSiblingIns;
          return deleteSiblingIns.Id;
        }
        return null;
    }
    
    @AuraEnabled
    public static String deleteSubpoenaed(String subpoenaedRec) {
    
        if(String.isNotBlank(subpoenaedRec)) {
          FieldLevelSecurity.checkObjectAccessByDelete('Subpoenaed__c');            
          Subpoenaed__c deleteSubpoenaedIns = (Subpoenaed__c) System.JSON.deserialize(subpoenaedRec, Subpoenaed__c.class);
          delete deleteSubpoenaedIns;
          return deleteSubpoenaedIns.Id;
        }
        return null;
    }
     
    @AuraEnabled
    public static String deletePetition(String petitionJSONStr) {
    
        if (String.isNotBlank(petitionJSONStr)) {
           
            FieldLevelSecurity.checkObjectAccessByDelete('Court__c');
            Court__c deleteCourtIns = (Court__c)System.JSON.deserialize(petitionJSONStr, Court__c.class);
            delete deleteCourtIns;
            return deleteCourtIns.Id;
        }
        return null;
    }
        

     public class petitionWrap {
       @AuraEnabled
        public String clientName;
        @AuraEnabled
        public String typeOfPetition;
        @AuraEnabled
        public String childAttorney;
        @AuraEnabled
        public String LDSSAttorney;
        @AuraEnabled
        public String courtPetitionId;       
    }
    
    public class petitionWrapper { 
        @AuraEnabled
        public List<petitionWrap> petitionList;
    }
    
    public class GetInitialWrapper { 
        @AuraEnabled
        public List<Utility.pickListWrap> petitionForChildPicklist;
        @AuraEnabled
        public List<Utility.pickListWrap> otherClientsNamedOnPetitionPicklist;
        @AuraEnabled
        public List<Utility.pickListWrap> typeOfPetitionPicklist; 
        @AuraEnabled
        public List<Utility.pickListWrap> childAttorneyPicklist; 
        @AuraEnabled
        public List<Utility.pickListWrap> childCurrentPlacementPicklist;
        @AuraEnabled
        public List<Utility.pickListWrap> newReviewPickList;
        @AuraEnabled
        public List<Utility.pickListWrap> emergencyPickList;
        @AuraEnabled
        public List<Utility.pickListWrap> previousJuvenileCourtPicklist;
        @AuraEnabled
        public List<Utility.pickListWrap> parentsCircumstancePicklist;
        @AuraEnabled
        public List<Utility.pickListWrap> specialneedsofRespondentPicklist;
        @AuraEnabled
        public List<Court__c> serviceCourtList;
        @AuraEnabled
        public List<Person__c>  childList; 
        @AuraEnabled
        public List<Utility.pickListWrap> parentNamePicklist;
        @AuraEnabled
        public List<Utility.pickListWrap> whatServicesWereOfferedPicklist;
        @AuraEnabled
        public List<Utility.pickListWrap> wereReasonableEffortsNotMadePicklist;
        @AuraEnabled
        public List<Utility.pickListWrap> familyInvolvementMeetingPickList;
        @AuraEnabled
        public List<Sibling__c> siblingsList;
        @AuraEnabled
        public List<Subpoenaed__c> subpoenaedList;
        public GetInitialWrapper() {
        
            petitionForChildPicklist = new List<Utility.pickListWrap>();
            otherClientsNamedOnPetitionPicklist = new List<Utility.pickListWrap>();
            typeOfPetitionPicklist = new List<Utility.pickListWrap>();
            childAttorneyPicklist = new List<Utility.pickListWrap>();
            serviceCourtList = new List<Court__c>();
            childCurrentPlacementPicklist = new List<Utility.pickListWrap>();
            newReviewPickList = new List<Utility.pickListWrap>();
            emergencyPickList = new List<Utility.pickListWrap>();
            parentNamePicklist = new List<Utility.pickListWrap>();
            previousJuvenileCourtPicklist = new List<Utility.pickListWrap>();
            parentsCircumstancePicklist = new List<Utility.pickListWrap>();
            specialneedsofRespondentPicklist = new List<Utility.pickListWrap>();
            whatServicesWereOfferedPicklist = new List<Utility.pickListWrap>();
            wereReasonableEffortsNotMadePicklist = new List<Utility.pickListWrap>();
            familyInvolvementMeetingPickList = new List<Utility.pickListWrap>();
        }  
    }
}