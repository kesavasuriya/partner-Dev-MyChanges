Public with sharing class CourtHearingController {
    
    @AuraEnabled 
    public static String getInitInfos(String recordId) {
        
        if (String.isnotBlank(recordId)) {   
            
            getInitialWrapper initWrap = new getInitialWrapper();
            Map<Id, Court__c> petitionMapList;
            
            
            FieldLevelSecurity.checkFieldAccessByCriteria('Court_Petition_ID__c,Service_Case__c,Investigation__c', 'view', 'Court__c',  Boolean.valueOf(Label.HasNamespace));
            petitionMapList = new Map<Id, Court__c>([SELECT Id, Court_Petition_ID__c FROM Court__c WHERE Service_Case__c = :recordId OR Investigation__c = :recordId LIMIT :Utility.queryLimit]);
            
            
            FieldLevelSecurity.checkFieldAccessByCriteria('Court_Case_Number__c, Client_Name_Case_Number__c, Court_Start_Date__c, Court_End_Date__c,Client_Name_Case_Number__c', 'view', 'Court__c',  Boolean.valueOf(Label.HasNamespace));
            FieldLevelSecurity.checkFieldAccessByCriteria('Name','view','Contact', Boolean.valueOf(Label.HasNamespace));           
            initWrap.courtCaseNumberList = [SELECT  Id, Court_Case_Number__c, Client_Name_Case_Number__c, Court_Start_Date__c, Court_End_Date__c,
                                            Client_Name_Case_Number__r.Name 
                                            FROM Court__c WHERE (Service_Case__c = :recordId OR Investigation__c = :recordId) AND
                                            Client_Name_Case_Number__c != NULL AND Court_Case_Number__c != NULL LIMIT :Utility.queryLimit];
            system.debug('fff '+initWrap.courtCaseNumberList);
            FieldLevelSecurity.checkFieldAccessByCriteria('CourtPetition_Id__c, Hearing_Date_and_Time__c, Scheduled_Hearing_Type__c, Client__c, Court_Case_Number__c, Start_Date__c, End_Date__c,'+
                                                          'Client_Name__c,Hearing_Type__c, Magistrate_s_Name__c, Judge_s_Name__c, Hearing_Notes__c, State__c, County__c, Hearing_Status__c,Court__c, Court_Case__c', 'view', 'Court_Petition_Hearing__c',  Boolean.valueOf(Label.HasNamespace));
            FieldLevelSecurity.checkFieldAccessByCriteria('Petition_for_Child__c,Other_Client_named_on_Petition__c','view','Court__c', Boolean.valueOf(Label.HasNamespace));
            FieldLevelSecurity.checkFieldAccessByCriteria('Name','view','Contact', Boolean.valueOf(Label.HasNamespace));
            
            List<Court_Petition_Hearing__c> petitionList = [SELECT Id, CourtPetition_Id__c, Hearing_Date_and_Time__c, Scheduled_Hearing_Type__c, Client__c, Court_Case_Number__c, Start_Date__c, End_Date__c,Court__r.Petition_for_Child__r.Name,
                                                            Client_Name__c,Hearing_Type__c, Magistrate_s_Name__c, Judge_s_Name__c, Hearing_Notes__c, State__c, County__c, Hearing_Status__c,Court__c, Court_Case__c,Court__r.Other_Client_named_on_Petition__r.Name 
                                                            FROM Court_Petition_Hearing__c WHERE Court__c IN :petitionMapList.keySet()  ORDER BY CreatedDate DESC LIMIT :Utility.queryLimit];

            for(Court_Petition_Hearing__c petition: petitionList) {
                
   
                if(petition.Hearing_Status__c == 'Concluded') {
                    initWrap.concludedRecords.add(petition);
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
            initWrap.scheduledHearingTypePicklist = Utility.getPicklistinfo('Court_Petition_Hearing__c','Scheduled_Hearing_Type__c',true);
            initwrap.hearingStatus = Utility.getPicklistinfo('Court_Petition_Hearing__c','Hearing_Status__c',false);
            initwrap.states = Utility.getPicklistinfo('Court_Petition_Hearing__c','State__c',false);
            initwrap.country = Utility.getPicklistinfo('Court_Petition_Hearing__c','County__c',false);
            FieldLevelSecurity.checkFieldAccessByCriteria('Name, Service_Case__c', 'view', 'Contact',  Boolean.valueOf(Label.HasNamespace));
            /*List<Contact> contactList = [SELECT Id, Name, Service_Case__c FROM Contact 
                                         WHERE (Service_Case__c = :recordId OR Investigation__c = :recordId) AND RecordTypeId = :Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Persons Involved').getRecordTypeId() LIMIT :Utility.queryLimit];
            
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
    public static Court__c getSelectCourtCaseNumberRec(Id courtId) {
        
        if (String.isNotBlank(courtId)) {
            FieldLevelSecurity.checkFieldAccessByCriteria('Court_Case_Number__c, Client_Name_Case_Number__c, Court_Start_Date__c, Court_End_Date__c,Client_Name_Case_Number__c', 'view', 'Court__c',  Boolean.valueOf(Label.HasNamespace));
            FieldLevelSecurity.checkFieldAccessByCriteria('Name','view','Contact', Boolean.valueOf(Label.HasNamespace));
            
            Court__c courtRecord = [SELECT Id, Court_Case_Number__c, Client_Name_Case_Number__c, Court_Start_Date__c, Court_End_Date__c,
                                    Client_Name_Case_Number__r.Name FROM Court__c WHERE Id =:courtId LIMIT 1 ];
            return courtRecord; 
            
        } else {
            return null;
        }
    }
    
    @AuraEnabled
    public static void deleteCourtCaseNumberRec(Id courtRec) {
        
        if (String.isNotBlank(courtRec)) {
            FieldLevelSecurity.checkObjectAccessByDelete('Court__c');            
            Court__c courtRecord = new Court__c( Id = courtRec);
            delete courtRecord;
        }
    }
    
    @AuraEnabled 
    public static String getHearingClientsInfos(String courtId) {
        
        if (String.isNotBlank(courtId)) {  
            
            clientsWrapper clientWrapperIns = new clientsWrapper();
            FieldLevelSecurity.checkFieldAccessByCriteria('Court_Petition_ID__c, Petition_for_Child__c, Petition_for_Child__c, Other_Client_named_on_Petition__c', 'view', 'Court__c',  Boolean.valueOf(Label.HasNamespace));
            FieldLevelSecurity.checkFieldAccessByCriteria('Name','view','Contact', Boolean.valueOf(Label.HasNamespace));
            
            List<Court__c> courtList = [SELECT Id, Court_Petition_ID__c, Petition_for_Child__c, Petition_for_Child__r.Name, Other_Client_named_on_Petition__c,Other_Client_named_on_Petition__r.Name FROM Court__c 
                                        WHERE Id = :courtId AND Petition_for_Child__c != null LIMIT :Utility.queryLimit];
            if (courtList != null && courtList.size() > 0) {
                
                clientWrapperIns.clientId = courtList[0].Petition_for_Child__c;
                clientWrapperIns.clientName = courtList[0].Petition_for_Child__r.Name;
                clientWrapperIns.OtherClientNames = courtList[0].Other_Client_named_on_Petition__r.Name;
                
            }
            return JSON.serialize(clientWrapperIns);
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
    public static String createScheduledHearingRec(String hearingRecJSON) {
        
        if (String.isNotBlank(hearingRecJSON)) {   
            
            Court_Petition_Hearing__c createScheduledHearingIns = (Court_Petition_Hearing__c) JSON.deserialize(hearingRecJSON, Court_Petition_Hearing__c.class);
            
            if (String.isBlank(createScheduledHearingIns.Id)) {
                FieldLevelSecurity.checkFieldAccessByCriteria('Court_Petition_ID__c,Scheduled_Hearing_Type__c,Hearing_Date_and_Time__c','create','Court_Petition_Hearing__c', Boolean.valueOf(Label.HasNamespace));
                insert createScheduledHearingIns;
            } else {
                FieldLevelSecurity.checkFieldAccessByCriteria('Court_Petition_ID__c,Scheduled_Hearing_Type__c,Hearing_Date_and_Time__c','update','Court_Petition_Hearing__c', Boolean.valueOf(Label.HasNamespace));
                update createScheduledHearingIns;
            }
            return createScheduledHearingIns.Id;
        } else {
            return null;
        }
    }
    
    @AuraEnabled
    public static Court_Petition_Hearing__c getHearingEditRec(Id recId) {
        
        if (String.isNotBlank(recId)) {
            
            FieldLevelSecurity.checkFieldAccessByCriteria('County__c,Hearing_Date_and_Time__c,Hearing_Notes__c,Hearing_Status__c,'
                                                          +'Hearing_Type__c,Is_There_Another_Court_Hearing_Scheduled__c,Judge_s_Name__c,Magistrate_s_Name__c,Exception_Appeal_Field__c,'
                                                          +'No_Further_Involvement_With_Court__c,Scheduled_Hearing_Type__c,State__c,Client_Name__c,CourtPetition_Id__c,Court__c','view','Court_Petition_Hearing__c',  Boolean.valueOf(Label.HasNamespace));
            FieldLevelSecurity.checkFieldAccessByCriteria('Other_Client_named_on_Petition__c,Petition_for_Child__c,Type_of_Petition__c','view','Court__c', Boolean.valueOf(Label.HasNamespace));
            FieldLevelSecurity.checkFieldAccessByCriteria('Name','view','Contact', Boolean.valueOf(Label.HasNamespace));  
            Court_Petition_Hearing__c hearingEditRec=[SELECT Id,County__c,Hearing_Date_and_Time__c,Hearing_Notes__c,Hearing_Status__c,
                                                      	Hearing_Type__c,Is_There_Another_Court_Hearing_Scheduled__c,Judge_s_Name__c,Magistrate_s_Name__c,Exception_Appeal_Field__c,
                                                      	No_Further_Involvement_With_Court__c,Scheduled_Hearing_Type__c,State__c,Client_Name__c,CourtPetition_Id__c,Court__r.Type_of_Petition__c,
                                                        Court__r.Other_Client_named_on_Petition__r.Name,Court__r.Petition_for_Child__r.Name
                                                      FROM Court_Petition_Hearing__c 
                                                      WHERE Id = :recId LIMIT :Utility.queryLimit];
            
            return hearingEditRec;
        } else {
            return null;
        }
    }
    
    @AuraEnabled
    public static List<Court_Petition_Hearing__c> getClientRec(Id recId) {
        
        if (String.isNotBlank(recId)) {    
            FieldLevelSecurity.checkFieldAccessByCriteria('Court__c', 'view', 'Court_Petition_Hearing__c',  Boolean.valueOf(Label.HasNamespace));        
            FieldLevelSecurity.checkFieldAccessByCriteria('Other_Client_named_on_Petition__c,Petition_for_Child__c','view','Court__c', Boolean.valueOf(Label.HasNamespace));       
            FieldLevelSecurity.checkFieldAccessByCriteria('Name','view','Contact', Boolean.valueOf(Label.HasNamespace));  
            
            List<Court_Petition_Hearing__c> clientNameRec = [SELECT Id,Court__r.Other_Client_named_on_Petition__r.Name,Court__r.Petition_for_Child__r.Name FROM Court_Petition_Hearing__c WHERE Id=:recId LIMIT :Utility.queryLimit];
            
            return clientNameRec;
        } else {
            return null;
        }
    }
    
    @AuraEnabled
    public static string upsertHearingRecord(String hearingDetailRecords) {
        
        if (String.isNotBlank(hearingDetailRecords)) {
            
            
            Court_Petition_Hearing__c createHearingRec = (Court_Petition_Hearing__c) JSON.deserialize(hearingDetailRecords, Court_Petition_Hearing__c.class);
            if (String.isBlank(createHearingRec.Id)) {
                FieldLevelSecurity.checkFieldAccessByCriteria('Court_Petition_ID__c,Scheduled_Hearing_Type__c,Hearing_Date_and_Time__c,Hearing_Status__c,Magistrate_s_Name__c,Judge_s_Name__c,Hearing_Notes__c,State__c,County__c,'+
                                                              'No_Further_Involvement_With_Court__c,Is_There_Another_Court_Hearing_Scheduled__c,Exception_Appeal_Field__c','create','Court_Petition_Hearing__c', Boolean.valueOf(Label.HasNamespace));
                insert createHearingRec;    
            } else {
                FieldLevelSecurity.checkFieldAccessByCriteria('Court_Petition_ID__c,Scheduled_Hearing_Type__c,Hearing_Date_and_Time__c,Hearing_Status__c,Magistrate_s_Name__c,Judge_s_Name__c,Hearing_Notes__c,State__c,County__c,'+
                                                              'No_Further_Involvement_With_Court__c,Is_There_Another_Court_Hearing_Scheduled__c,Exception_Appeal_Field__c','update','Court_Petition_Hearing__c', Boolean.valueOf(Label.HasNamespace));
                update createHearingRec;
            }
            upsert createHearingRec;
            return createHearingRec.Id;
        } else {
            return null;
        }     
    }
    
    public class getInitialWrapper {
        
        @AuraEnabled
        public List<Utility.pickListWrap> hearingPetitionIdList;
        @AuraEnabled
        public List<Utility.pickListWrap> scheduledHearingTypePicklist;
        @AuraEnabled
        public List<Utility.pickListWrap> hearingStatus;
        @AuraEnabled
        public List<Utility.pickListWrap> states;
        @AuraEnabled
        public List<Utility.pickListWrap> country;
        @AuraEnabled
        public List<Court_Petition_Hearing__c> petitionHearingList;
        
        @AuraEnabled
        public List<Court_Petition_Hearing__c> courtOrderLists;
        @AuraEnabled
        public List<Court__c> courtCaseNumberList; 
        @AuraEnabled
        public List<Court__c> clientName; 
        @AuraEnabled
        public List<Utility.pickListWrap> clientPickList;
        @AuraEnabled
        public Map<Id,String> formatteddateTime ;
        
        @AuraEnabled
        public List<Court_Petition_Hearing__c> scheduledRecords;
        @AuraEnabled
        public List<Court_Petition_Hearing__c> concludedRecords;
        
        public getInitialWrapper() {
            formatteddateTime = new Map<Id,String>();
            scheduledRecords = new List<Court_Petition_Hearing__c>();
            concludedRecords = new List<Court_Petition_Hearing__c>();
        }
    }
    
    public class clientsWrapper {
        
        @AuraEnabled
        public String clientId;
        @AuraEnabled
        public String clientName;
        @AuraEnabled
        public String OtherClientNames;
    }
}