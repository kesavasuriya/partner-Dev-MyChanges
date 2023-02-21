public with sharing class CourtTabController {
    
    @AuraEnabled 
    public static String getInitInfos(String recordId) {
        
        if (String.isnotBlank(recordId)) {   
            
            getInitialWrapper initWrap = new getInitialWrapper();
            Map<Id, Court__c> petitionMapList;
            
            
            FieldLevelSecurity.checkFieldAccessByCriteria('Court_Petition_ID__c,Service_Case__c,Investigation__c', 'view', 'Court__c',  Boolean.valueOf(Label.HasNamespace));
            petitionMapList = new Map<Id, Court__c>([SELECT Id, Court_Petition_ID__c 
                                                     FROM Court__c 
                                                     WHERE Service_Case__c = :recordId OR Investigation__c = :recordId LIMIT :Utility.queryLimit]);
            
            
            FieldLevelSecurity.checkFieldAccessByCriteria('Court_Case_Number__c, Client_Name_Case_Number__c, Court_Start_Date__c, Court_End_Date__c,Client_Name_Case_Number__c', 'view', 'Court__c',  Boolean.valueOf(Label.HasNamespace));
            FieldLevelSecurity.checkFieldAccessByCriteria('Name','view','Contact', Boolean.valueOf(Label.HasNamespace));           
            
            initWrap.courtCaseNumberList = [SELECT  Id, Court_Case_Number__c, Client_Name_Case_Number__c,
                                                Court_Start_Date__c, Court_End_Date__c,
                                                Client_Name_Case_Number__r.Name 
                                            FROM Court__c 
                                            WHERE (Service_Case__c = :recordId OR Investigation__c = :recordId) AND
                                            Client_Name_Case_Number__c != NULL AND Court_Case_Number__c != NULL LIMIT :Utility.queryLimit];
            
            FieldLevelSecurity.checkFieldAccessByCriteria('CourtPetition_Id__c, Hearing_Date_and_Time__c, Scheduled_Hearing_Type__c, Client__c, Court_Case_Number__c, Start_Date__c, End_Date__c,'+
                                                          'Client_Name__c,Hearing_Type__c, Magistrate_s_Name__c, Judge_s_Name__c, Hearing_Notes__c, State__c, County__c, Hearing_Status__c,Court__c, Court_Case__c', 'view', 'Court_Petition_Hearing__c',  Boolean.valueOf(Label.HasNamespace));
            FieldLevelSecurity.checkFieldAccessByCriteria('Petition_for_Child__c,Other_Client_named_on_Petition__c','view','Court__c', Boolean.valueOf(Label.HasNamespace));
            FieldLevelSecurity.checkFieldAccessByCriteria('Name','view','Contact', Boolean.valueOf(Label.HasNamespace));
            
            List<Court_Petition_Hearing__c> petitionList = [SELECT Id, CourtPetition_Id__c, Hearing_Date_and_Time__c, 
                                                                Scheduled_Hearing_Type__c, Client__c, Court_Case_Number__c,
                                                                Start_Date__c, End_Date__c,Court__r.Petition_for_Child__r.Name,
                                                                Client_Name__c,Hearing_Type__c, Magistrate_s_Name__c,
                                                                Judge_s_Name__c, Hearing_Notes__c, State__c, County__c, 
                                                                Hearing_Status__c,Court__c, Court_Case__c,
                                                                Court__r.Other_Client_named_on_Petition__r.Name 
                                                            FROM Court_Petition_Hearing__c 
                                                            WHERE Court__c IN :petitionMapList.keySet()  ORDER BY CreatedDate DESC LIMIT :Utility.queryLimit];
            
            for(Court_Petition_Hearing__c petition: petitionList) {
                                
                if(petition.Hearing_Status__c == 'Concluded') {
                    
                    initWrap.concludedRecords.add(petition);
                    //initWrap.scheduledRecords.add(petition);
                } else if(petition.Hearing_Status__c == 'Scheduled') {
                    
                    initWrap.scheduledRecords.add(petition);
                }
            }
            
            
            List<Utility.pickListWrap> recPickList = new List<Utility.pickListWrap>();
            Utility.pickListWrap intialPick = new Utility.pickListWrap();
            intialPick.label = '--None--';
            intialPick.value = '';
            recPickList.add(intialPick);
            Utility.pickListWrap pick;
            
            for(Court__c courtPetitionIns : petitionMapList.values()) {
                
                if (String.isNotBlank(courtPetitionIns.Court_Petition_ID__c)) {
                    
                    pick = new Utility.pickListWrap();
                    pick.label = courtPetitionIns.Court_Petition_ID__c;
                    pick.value = courtPetitionIns.Id;
                    recPickList.add(pick);
                }
            }
            
            initWrap.hearingPetitionIdList = recPickList;
            FieldLevelSecurity.checkFieldAccessByCriteria('Name, Service_Case__c', 'view', 'Contact',  Boolean.valueOf(Label.HasNamespace));
            /*List<Contact> contactList = [SELECT Id, Name, Service_Case__c 
                                         FROM Contact 
                                         WHERE (Service_Case__c = :recordId OR Investigation__c = :recordId) 
                                         AND RecordTypeId = :Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Persons Involved').getRecordTypeId()
                                         LIMIT :Utility.queryLimit];
            
            List<Utility.pickListWrap> conPickList = new List<Utility.pickListWrap>();
            Utility.pickListWrap intialConPick = new Utility.pickListWrap();
            intialConPick.label = '--None--';
            intialConPick.value = '';
            conPickList.add(intialConPick);
            
            if(contactList.size() > 0 && contactList != NULL) {
                
                for(Contact conIns :contactList) {
                    
                    pick = new Utility.pickListWrap();
                    pick.label = conIns.Name;
                    pick.value = conIns.Id;
                    conPickList.add(pick);
                    
                }
            }
            
            initWrap.clientPickList = conPickList;*/
            return JSON.serialize(initWrap);
            
        } else {
            
            return null;
        }
        
    }
    
    @AuraEnabled
    public static String createCourtCaseRec(String courtCaseNumberRecJSON) {
        
        if (String.isNotBlank(courtCaseNumberRecJSON)) {
            
            Court__c createCourtCasenumberIns = (Court__c) JSON.deserialize(courtCaseNumberRecJSON, Court__c.class);
            
            if (String.isBlank(createCourtCasenumberIns.Id)) {
                
                FieldLevelSecurity.checkFieldAccessByCriteria('Client_Name_Case_Number__c,Court_Case_Number__c,Court_Start_Date__c,Court_End_Date__c,','create','Court__c',  Boolean.valueOf(Label.HasNamespace));
                insert createCourtCasenumberIns;
            } else {
                
                FieldLevelSecurity.checkFieldAccessByCriteria('Client_Name_Case_Number__c,Court_Case_Number__c,Court_Start_Date__c,Court_End_Date__c,','update','Court__c',  Boolean.valueOf(Label.HasNamespace)); 
                update createCourtCasenumberIns;
            }
            return createCourtCasenumberIns.Id;
            
        } else {
            
            return null;
        }
    } 
    
    
    @AuraEnabled
    public static Court__c getCourtOrderRecord(Id CourtOrderId){
        
        FieldLevelSecurity.checkFieldAccessByCriteria('Child_s_Home_Is_Contrary__c,Child_s_Home__c,Reasonable_Efforts_Could_Not_Be_Made__c,'+
                                                      'Efforts_Were_Made_To_Prevent_Removal__c,Efforts_Were_Not_Made_To_Prevent_Removal__c,Waived_Reunification_Efforts__c,Child_s_permanency_plan_continues_to_be__c,'+
                                                      'Reasonable_efforts_were_made_to_finalize__c,Reasonable_efforts_were_not_made__c,Permanency_plan_of_reunification_may_be__c,Voluntary_placement_is_in_the_bet__c,'+
                                                      'Voluntary_placement_is_not_in_the_besti__c,Reasonable_efforts_were_unable_to_be__c,Court_order_specifies_who_the_child__c,Court_order_delay_removal__c,Court_Orders_are_not_signed_by_the_judge__c,'+
                                                      'Court_Order_Received_By_LDSS__c,The_Court_Order_Specifies_action_s__c,The_Court_Order_Specifies_a_Placement__c,Visitations_Court_Ordered__c,Services_Court_Ordered__c,'+
                                                      'Hearing_Outcome__c,Court_Order_Date__c,Removal_Episode__c,Court_Order_Details__c,Child_s_Home_Comments__c,Child_s_Home_Is_Contrary_Comments__c,Reasonable_Efforts_Could_Not_Be_Comments__c,'+
                                                      'Efforts_Were_Made_To_Prevent_Comments__c,Waived_Reunification_Efforts_Comments__c,Efforts_Were_Not_Made_Prevent_Comments__c,Reasonable_efforts_were_made_to_Comments__c,'+
                                                      'Reasonable_efforts_were_not_made_Comment__c,Permanency_plan_of_reunification_Comment__c,Voluntary_placement_the_bet_Comments__c,Voluntary_placement_is_not_best_Comments__c,'+
                                                      'Reasonable_efforts_were_unable_Comments__c,Court_order_specifies_who_child_Comments__c,Court_order_delay_removal_Comments__c,Court_Orders_are_not_signed_by_Comments__c,'+
                                                      'Court_Order_Received_By_LDSS_Comments__c,The_Court_Order_Specifies_action_Comment__c,Visitations_Court_Ordered_Comments__c,The_Court_Order_Placement_Comments__c,'+
                                                      'Services_Court_Ordered_Comments__c,Type_of_Petition__c,Other_Client_named_on_Petition__c', 'view', 'Court__c',  Boolean.valueOf(Label.HasNamespace));
       
        FieldLevelSecurity.checkFieldAccessByCriteria('Name','view','Contact', Boolean.valueOf(Label.HasNamespace));
        
        Court__c courtOrderRecord=[SELECT Child_s_Home_Is_Contrary__c,Child_s_Home__c,
                                       Efforts_Were_Made_To_Prevent_Removal__c,Efforts_Were_Not_Made_To_Prevent_Removal__c,
                                       Waived_Reunification_Efforts__c,Child_s_permanency_plan_continues_to_be__c,
                                       Reasonable_efforts_were_made_to_finalize__c,Reasonable_efforts_were_not_made__c,
                                       Permanency_plan_of_reunification_may_be__c,Voluntary_placement_is_in_the_bet__c,
                                       Voluntary_placement_is_not_in_the_besti__c,Reasonable_efforts_were_unable_to_be__c,
                                       Court_order_specifies_who_the_child__c,Court_order_delay_removal__c,
                                       Court_Orders_are_not_signed_by_the_judge__c,
                                       Court_Order_Received_By_LDSS__c,The_Court_Order_Specifies_action_s__c,
                                       The_Court_Order_Specifies_a_Placement__c,Visitations_Court_Ordered__c,
                                       Services_Court_Ordered__c,Reasonable_Efforts_Could_Not_Be_Made__c,
                                       Hearing_Outcome__c,Court_Order_Date__c,Removal_Episode__c,Court_Order_Details__c,
                                       Child_s_Home_Comments__c,Child_s_Home_Is_Contrary_Comments__c,
                                       Reasonable_Efforts_Could_Not_Be_Comments__c,Type_of_Petition__c,
                                       Efforts_Were_Made_To_Prevent_Comments__c,Waived_Reunification_Efforts_Comments__c,
                                       Efforts_Were_Not_Made_Prevent_Comments__c,Reasonable_efforts_were_made_to_Comments__c,
                                       Reasonable_efforts_were_not_made_Comment__c,Permanency_plan_of_reunification_Comment__c,
                                       Voluntary_placement_the_bet_Comments__c,Voluntary_placement_is_not_best_Comments__c,
                                       Reasonable_efforts_were_unable_Comments__c,Court_order_specifies_who_child_Comments__c,
                                       Court_order_delay_removal_Comments__c,Court_Orders_are_not_signed_by_Comments__c,
                                       Court_Order_Received_By_LDSS_Comments__c,The_Court_Order_Specifies_action_Comment__c,
                                       Visitations_Court_Ordered_Comments__c,The_Court_Order_Placement_Comments__c,
                                       Services_Court_Ordered_Comments__c,Other_Client_named_on_Petition__r.Name
                                   FROM Court__c 
                                   WHERE Id=:CourtOrderId LIMIT :Utility.queryLimit];
        return courtOrderRecord;
    }
    
    @AuraEnabled
    public static String getPickList() {
        
        getInitialWrapper initWrap = new getInitialWrapper();
        initWrap.Childspermanencyplancontinues= Utility.getPicklistinfo('Court__c','Child_s_permanency_plan_continues_to_be__c',false);
        initWrap.HearingOutcome= Utility.getPicklistinfo('Court__c','Hearing_Outcome__c',true);
        initWrap.RemovalEpisode= Utility.getPicklistinfo('Court__c','Removal_Episode__c',false);
        
        return  JSON.serialize(initWrap);
    }
    
    @AuraEnabled
    public static string upsertCourtOrderRecord(String CourtOrderRecords){
        
        FieldLevelSecurity.checkFieldAccessByCriteria('Child_s_Home__c,Child_s_Home_Is_Contrary__c,Reasonable_Efforts_Could_Not_Be_Made__c,Efforts_Were_Made_To_Prevent_Removal__c,'+
                                                      'Waived_Reunification_Efforts__c,Efforts_Were_Not_Made_To_Prevent_Removal__c,Reasonable_efforts_were_made_to_finalize__c,Reasonable_efforts_were_not_made__c,'+
                                                      'Permanency_plan_of_reunification_may_be__c,Voluntary_placement_is_in_the_bet__c,Voluntary_placement_is_not_in_the_besti__c,'+
                                                      'Reasonable_efforts_were_unable_to_be__c,Court_order_specifies_who_the_child__c,Court_order_delay_removal__c,Court_Orders_are_not_signed_by_the_judge__c,'+
                                                      'Court_Order_Received_By_LDSS__c,The_Court_Order_Specifies_action_s__c,Visitations_Court_Ordered__c,The_Court_Order_Specifies_a_Placement__c,'+
                                                      'Services_Court_Ordered__c,Child_s_Home_Comments__c,Child_s_Home_Is_Contrary_Comments__c,Reasonable_Efforts_Could_Not_Be_Comments__c,'+
                                                      'Efforts_Were_Made_To_Prevent_Comments__c,Waived_Reunification_Efforts_Comments__c,Efforts_Were_Not_Made_Prevent_Comments__c,'+
                                                      'Child_s_permanency_plan_continues_to_be__c,Reasonable_efforts_were_made_to_Comments__c,Reasonable_efforts_were_not_made_Comment__c,'+
                                                      'Permanency_plan_of_reunification_Comment__c,Voluntary_placement_the_bet_Comments__c,Voluntary_placement_is_not_best_Comments__c,'+
                                                      'Reasonable_efforts_were_unable_Comments__c,Court_order_specifies_who_child_Comments__c,Court_order_delay_removal_Comments__c,'+
                                                      'Hearing_Outcome__c,Court_Order_Date__c,Removal_Episode__c,Court_Orders_are_not_signed_by_Comments__c,Court_Order_Received_By_LDSS_Comments__c,'+
                                                      'The_Court_Order_Specifies_action_Comment__c,Visitations_Court_Ordered_Comments__c,The_Court_Order_Placement_Comments__c,'+
                                                      'Services_Court_Ordered_Comments__c,Court_Order_Details__c','create','Court__c',  Boolean.valueOf(Label.HasNamespace));
        
        FieldLevelSecurity.checkFieldAccessByCriteria('Child_s_Home__c,Child_s_Home_Is_Contrary__c,Reasonable_Efforts_Could_Not_Be_Made__c,Efforts_Were_Made_To_Prevent_Removal__c,'+
                                                      'Waived_Reunification_Efforts__c,Efforts_Were_Not_Made_To_Prevent_Removal__c,Reasonable_efforts_were_made_to_finalize__c,Reasonable_efforts_were_not_made__c,'+
                                                      'Permanency_plan_of_reunification_may_be__c,Voluntary_placement_is_in_the_bet__c,Voluntary_placement_is_not_in_the_besti__c,'+
                                                      'Reasonable_efforts_were_unable_to_be__c,Court_order_specifies_who_the_child__c,Court_order_delay_removal__c,Court_Orders_are_not_signed_by_the_judge__c,'+
                                                      'Court_Order_Received_By_LDSS__c,The_Court_Order_Specifies_action_s__c,Visitations_Court_Ordered__c,The_Court_Order_Specifies_a_Placement__c,'+
                                                      'Services_Court_Ordered__c,Child_s_Home_Comments__c,Child_s_Home_Is_Contrary_Comments__c,Reasonable_Efforts_Could_Not_Be_Comments__c,'+
                                                      'Efforts_Were_Made_To_Prevent_Comments__c,Waived_Reunification_Efforts_Comments__c,Efforts_Were_Not_Made_Prevent_Comments__c,'+
                                                      'Child_s_permanency_plan_continues_to_be__c,Reasonable_efforts_were_made_to_Comments__c,Reasonable_efforts_were_not_made_Comment__c,'+
                                                      'Permanency_plan_of_reunification_Comment__c,Voluntary_placement_the_bet_Comments__c,Voluntary_placement_is_not_best_Comments__c,'+
                                                      'Reasonable_efforts_were_unable_Comments__c,Court_order_specifies_who_child_Comments__c,Court_order_delay_removal_Comments__c,'+
                                                      'Hearing_Outcome__c,Court_Order_Date__c,Removal_Episode__c,Court_Orders_are_not_signed_by_Comments__c,Court_Order_Received_By_LDSS_Comments__c,'+
                                                      'The_Court_Order_Specifies_action_Comment__c,Visitations_Court_Ordered_Comments__c,The_Court_Order_Placement_Comments__c,'+
                                                      'Services_Court_Ordered_Comments__c,Court_Order_Details__c','update','Court__c',  Boolean.valueOf(Label.HasNamespace));
        
        Court__c createCourtOrder = (Court__c) JSON.deserialize(CourtOrderRecords, Court__c.class);
        upsert createCourtOrder;
        
        return createCourtOrder.Id;
        
    }
    
    public class getInitialWrapper {
        
        @AuraEnabled
        public List<Utility.pickListWrap> hearingPetitionIdList;
        @AuraEnabled
        public List<Court_Petition_Hearing__c> petitionHearingList;
        @AuraEnabled
        public List<Utility.pickListWrap> Childspermanencyplancontinues;
        @AuraEnabled
        public List<Utility.pickListWrap> HearingOutcome;
        @AuraEnabled
        public List<Utility.pickListWrap> RemovalEpisode;
        @AuraEnabled
        public List<Court_Petition_Hearing__c> courtOrderLists;
        @AuraEnabled
        public List<Court__c> courtCaseNumberList; 
        @AuraEnabled
        public List<Court_Petition_Hearing__c> scheduledRecords;
        @AuraEnabled
        public List<Court_Petition_Hearing__c> concludedRecords;
        @AuraEnabled
        public List<Utility.pickListWrap> clientPickList;        
        public getInitialWrapper() {
            scheduledRecords = new List<Court_Petition_Hearing__c>();
            concludedRecords = new List<Court_Petition_Hearing__c>();
        }
        
    }
    
}