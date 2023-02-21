Public with sharing class PlacementController {
    
    @AuraEnabled
    public static String upsertPlacementRec(String placementDataJSON) {
        
        if (String.isNotBlank(placementDataJSON)) {
            
            Placement__c upsertPlacementRec = (Placement__c) JSON.deserialize(placementDataJSON, Placement__c.class);
            if ((String.isNotBlank(upsertPlacementRec.Id))) {
                FieldLevelSecurity.checkFieldAccessByCriteria('Response_Accepted__c,Placement_Structure__c , Reason_for_Decline__c, COMAR_Rate_Category__c, Comments__c, Description__c, Begin_Date__c, Referral_Send_Date__c, Provider__c', 'update', 'Placement__c',  Boolean.valueOf(Label.HasNamespace));
                FieldLevelSecurity.checkFieldAccessByCriteria('Removal_Date_of_DT_F__c', 'view', 'Child_Removal__c',  Boolean.valueOf(Label.HasNamespace));
                Child_Removal__c childRemovalRec = [SELECT Id, Removal_Date_of_DT_F__c FROM Child_Removal__c WHERE Child__c =: upsertPlacementRec.Child__c Limit 1];
                if (upsertPlacementRec.Begin_Date__c <=  childRemovalRec.Removal_Date_of_DT_F__c  ) {
                    return null;
                }
                update upsertPlacementRec;
                Contact updatePerson = new Contact();
                updatePerson.Id = upsertPlacementRec.Child__c ;
                updatePerson.AccountId  =  upsertPlacementRec.Provider__c;
                update updatePerson;
            }
            return upsertPlacementRec.Id;
            
        } else {
            return null;
        }
    }
    
    @AuraEnabled
    public static String onSavePlacementCPAHome(String placementDataJSON) {
        
        if (String.isNotBlank(placementDataJSON)) { 
            
            Placement__c upsertPlacementRec = (Placement__c) JSON.deserialize(placementDataJSON, Placement__c.class);
            if ((String.isNotBlank(upsertPlacementRec.Id))) {
                FieldLevelSecurity.checkFieldAccessByCriteria('CPA_Home_Id__c, Entry_Date_and_Entry_Time__c, Exit_Type__c, Exit_Date_Time__c, Reason_for_Exit__c, Exit_Comments__c, Provider__c', 'update', 'Placement__c',  Boolean.valueOf(Label.HasNamespace));
                update upsertPlacementRec;
            }
            return upsertPlacementRec.Id;
        } else {
            return null;
        }
    }
    
    @AuraEnabled
    public static String fetchAccount(String searchInputJSON) {
        
        List<Account> accountList = new List<Account>();
        SearchInputWrapper inputWrap = (SearchInputWrapper) JSON.deserialize(searchInputJSON, SearchInputWrapper.class);
        FieldLevelSecurity.checkFieldAccessByCriteria('Individual_First_Name__c,Individual_Middle_Name__c,Individual_Last_Name__c,Placement_Structure__c, Placement_Service__c, Name,Type,Industry,Phone,Fax,Casevault_ProID__c,Child_Characteristics_Willing_To_Accept__c,Local_Department__c, Number_of_Beds__c, Type__c','view','Account', Boolean.valueOf(Label.HasNamespace));
        String accountJSON = 'SELECT Id , Individual_First_Name__c,Individual_Middle_Name__c,Individual_Last_Name__c,Placement_Structure__c, Placement_Service__c, Name,Type,Industry,Phone,Fax,Casevault_ProID__c,Child_Characteristics_Willing_To_Accept__c,Local_Department__c, Number_of_Beds__c, Type__c FROM Account';
        
        accountJSON += ' WHERE Name != null ';
        if(String.isNotBlank(inputWrap.providerName)){
            accountJSON +=  ' AND Name LIKE \''+ String.escapeSingleQuotes(inputWrap.providerName) +'%'+'\'';
        }  
        if(String.isNotBlank(inputWrap.providerType)){
            if (inputWrap.providerType == 'Public Provider') {
                Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(inputWrap.providerType).getRecordTypeId();
                accountJSON += ' AND RecordTypeId = \''+recordTypeId+'\'';
            } else if (inputWrap.providerType == 'Private Provider Org') {
                Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(inputWrap.providerType).getRecordTypeId();
                //Id recordTypeId2 = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Private Provide').getRecordTypeId();
                accountJSON += ' AND (RecordTypeId = :recordTypeId)'; //OR RecordTypeId = :recordTypeId2
            }
        }
        if(String.isNotBlank(inputWrap.firstName)){
            accountJSON += ' AND Individual_First_Name__c LIKE \''+ String.escapeSingleQuotes(inputWrap.firstName) +'%'+'\'';
        }  
        
        
        if(String.isNotBlank(inputWrap.middleName)){
            accountJSON += ' AND Individual_Middle_Name__c LIKE \''+ String.escapeSingleQuotes(inputWrap.middleName) +'%'+'\'';
        }
        
        if(String.isNotBlank(inputWrap.lastName)){
            accountJSON += ' AND Individual_Last_Name__c LIKE \''+ String.escapeSingleQuotes(inputWrap.lastName) +'%'+'\'';
        }
        
        if(String.isNotBlank(inputWrap.childCharacter)){
            accountJSON += ' AND Child_Characteristics_Willing_To_Accept__c = \''+ String.escapeSingleQuotes(inputWrap.childCharacter) +'\'';
        }
        
        if(String.isNotBlank(inputWrap.localDept)){
            accountJSON += ' AND Local_Department__c = \''+ String.escapeSingleQuotes(inputWrap.localDept) +'\'';
        }
        
        if(String.isNotBlank(inputWrap.placementStructure)){
            //accountJSON += ' AND Placement_Structure__c = \''+inputWrap.placementStructure+'\'';
            FieldLevelSecurity.checkFieldAccessByCriteria('Provider__c,Structure_Service_Name__c','view', 'Structure_Services__c',  Boolean.valueOf(Label.HasNamespace));
            String searchString = '%' + inputWrap.placementStructure;
            List<Structure_Services__c> structureServiceList = [SELECT Id, Provider__c FROM Structure_Services__c WHERE Structure_Service_Name__c LIKE :searchString 
                                                                AND Provider__c != Null LIMIT :Utility.queryLimit];
            set<Id> providerIds = new set<Id> ();
            if(structureServiceList != Null && structureServiceList.size() > 0){
                
                for(Structure_Services__c strut :structureServiceList ){
                    providerIds.add(strut.Provider__c);
                }
            }
            
            /*if(providerIds != Null && providerIds.size() > 0){
accountJSON += ' AND Id IN: providerIds';
}*/
            accountJSON += ' AND Id IN: providerIds';
        }
        
        if(String.isNotBlank(inputWrap.bundledService)){
            // accountJSON += 'AND Individual_First_Name__c LIKE \''+inputWrap.bundledService+'%'+'\'';
        }
        
        if(String.isNotBlank(inputWrap.providerId)){
            accountJSON += ' AND Casevault_ProID__c LIKE \''+ String.escapeSingleQuotes(inputWrap.providerId) +'%'+'\'';
        }
        
        accountJSON += ' LIMIT 500 ';
        accountList = Database.query(accountJSON);
        return JSON.serialize(accountList);
    } 
    
    @AuraEnabled
    public static String getInitialInformation(String placementRecordId) {
        
        getInitialWrapper initWrap = new getInitialWrapper();
        FieldLevelSecurity.checkFieldAccessByCriteria('Response_Accepted__c,Placement_Structure__c, Reason_for_Decline__c, COMAR_Rate_Category__c, Comments__c, Description__c, Begin_Date__c, Referral_Send_Date__c, Service_Case__c, Child__c', 'view', 'Placement__c',  Boolean.valueOf(Label.HasNamespace));
        initWrap.placementRecord = [SELECT Id, Response_Accepted__c,Placement_Structure__c, Reason_for_Decline__c, COMAR_Rate_Category__c, Comments__c, Description__c, Begin_Date__c, Referral_Send_Date__c, Service_Case__c, Child__c FROM Placement__c WHERE Id = :placementRecordId Limit 1];
        initWrap.placementStructurePicklist = Utility.getPicklistinfo('Account','Placement_Structure__c',false);
        initWrap.childCharPicklist = Utility.getPicklistinfo('Account','Child_Characteristics_Willing_To_Accept__c',true);
        initWrap.localDeptPicklist = Utility.getPicklistinfo('Account','Local_Department__c',false);
        initWrap.responseAcceptedPicklist = Utility.getPicklistinfo('Placement__c','Response_Accepted__c',false);
        initWrap.placementStructPicklist = Utility.getPicklistinfo('Placement__c','Placement_Structure__c',false);
        initWrap.reasonForDeclinePicklist = Utility.getPicklistinfo('Placement__c','Reason_for_Decline__c',false);
        initWrap.comarRateCategoryPicklist = Utility.getPicklistinfo('Placement__c','COMAR_Rate_Category__c',false);
        return JSON.serialize(initWrap);
    }
    
    @AuraEnabled
    public static String getInitialInfoCPAHome(String placementRecordId) {
        
        getInitialWrapper initWrap = new getInitialWrapper();
        Set<Id> contractIdSet = new Set<Id>();
        Set<Id> programIdSet = new Set<Id>();
        Set<Id> accountIdSet = new Set<Id>();
        FieldLevelSecurity.checkFieldAccessByCriteria('CPA_Home_Id__c, Provider__c, CPA_home__c, Entry_Date_and_Entry_Time__c,'+
                                                      'End_Date__c, Placement_Approval_Status__c, Exit_Approval_Status__c, Begin_Date__c, Reason_for_Exit__c, Exit_Date_Time__c', 'view', 'Placement__c',  Boolean.valueOf(Label.HasNamespace));
        FieldLevelSecurity.checkFieldAccessByCriteria('Name', 'view', 'Account',  Boolean.valueOf(Label.HasNamespace));
        initWrap.placementRecord = [SELECT Id, CPA_Home_Id__c, Provider__c, Provider__r.Name, CPA_home__c, Entry_Date_and_Entry_Time__c,
                                    End_Date__c, Placement_Approval_Status__c, Exit_Approval_Status__c, Begin_Date__c, Reason_for_Exit__c, Exit_Date_Time__c
                                    FROM Placement__c WHERE Id = :placementRecordId AND Provider__c != null Limit 1];
        initWrap.exitTypePickList =  Utility.getPicklistinfo('Placement__c','Exit_Type__c',false);
        initWrap.reasonForExitPickList =  Utility.getPicklistinfo('Placement__c','Reason_for_Exit__c',false);
        
        FieldLevelSecurity.checkFieldAccessByCriteria('Provider__c', 'view', 'CWS_Contract__c',  Boolean.valueOf(Label.HasNamespace));
        List<CWS_Contract__c> contractList = [SELECT Id, Provider__c FROM CWS_Contract__c WHERE Provider__c = :initWrap.placementRecord.Provider__c LIMIT :Utility.queryLimit];
        
        FieldLevelSecurity.checkFieldAccessByCriteria('Contracts__c', 'view', 'Program__c',  Boolean.valueOf(Label.HasNamespace));
        List<Program__c> programList = [SELECT Id, Contracts__c FROM Program__c WHERE Contracts__c IN :contractList LIMIT :Utility.queryLimit];
        
        FieldLevelSecurity.checkFieldAccessByCriteria('Name, Program__c,CPA_Home_Provider_Name__c,CPA_Home_Provider_Name__c', 'view', 'CPA_home__c',  Boolean.valueOf(Label.HasNamespace));
        FieldLevelSecurity.checkFieldAccessByCriteria('Name', 'view', 'Account',  Boolean.valueOf(Label.HasNamespace));
        List<CPA_home__c> cpaHomeList = [SELECT Id, Name, Program__c,CPA_Home_Provider_Name__c,CPA_Home_Provider_Name__r.Name FROM CPA_home__c WHERE Program__c IN :programList
                                         AND CPA_Home_Provider_Name__c != NULL LIMIT :Utility.queryLimit];
        Map<Id, String> cpaHomeProviders = new Map<Id, String>();
        for (CPA_home__c cpaHomeIns : cpaHomeList) {
            
            if (!cpaHomeProviders.containsKey(cpaHomeIns.CPA_Home_Provider_Name__c)) {
                cpaHomeProviders.put(cpaHomeIns.CPA_Home_Provider_Name__c, cpaHomeIns.CPA_Home_Provider_Name__r.Name);
            }
        }                                  
        List<Utility.pickListWrap> recPickList = new List<Utility.pickListWrap>();
        Utility.pickListWrap intialPick = new Utility.pickListWrap();
        intialPick.label = '--None--';
        intialPick.value = '';
        recPickList.add(intialPick);
        Utility.pickListWrap pick ;
        for(Id providerId : cpaHomeProviders.keySet()){
            pick = new Utility.pickListWrap();
            pick.label = cpaHomeProviders.get(providerId);
            pick.value = providerId;
            recPickList.add(pick);
        }
        initWrap.privateCPAHomes = recPickList; 
        return JSON.serialize(initWrap);
    }
    
    @AuraEnabled
    public static List<Placement__c> getCurrentCaseRecord(String placementRecordId){
        FieldLevelSecurity.checkFieldAccessByCriteria('Name, Service_Case__c,Provider__c', 'view', 'Placement__c',  Boolean.valueOf(Label.HasNamespace));                                         
        FieldLevelSecurity.checkFieldAccessByCriteria('Intake__c', 'view', 'Service_Case__c',  Boolean.valueOf(Label.HasNamespace));
        FieldLevelSecurity.checkFieldAccessByCriteria('Intake_Approval_Status__c,Start_Time__c,End_Time__c', 'view', 'Case',  Boolean.valueOf(Label.HasNamespace));
        FieldLevelSecurity.checkFieldAccessByCriteria('Individual_First_Name__c,Individual_Last_Name__c,BillingStreet,BillingState,BillingCity,BillingPostalCode,Casevault_ProID__c', 'view', 'Account',  Boolean.valueOf(Label.HasNamespace));
        
        
        
        return[SELECT Id,Name, Service_Case__r.Intake__r.Intake_Approval_Status__c,
               Service_Case__r.Intake__r.Start_Time__c, Service_Case__r.Intake__r.End_Time__c,Provider__r.Individual_First_Name__c,Provider__r.Individual_Last_Name__c,
               Provider__r.BillingStreet,Provider__r.BillingCity,Provider__r.BillingState,Provider__r.BillingPostalCode,Provider__r.Casevault_ProID__c
               FROM Placement__c where id = :placementRecordId LIMIT :Utility.queryLimit];
    }
    @AuraEnabled
    public static List<ProcessInstance> getCurrentPlacementApprovalDetails(String placementRecordId){
        //FieldLevelSecurity.checkFieldAccessByCriteria('argetObjectId, Status, CompletedDate,CreatedDate', 'view', 'ProcessInstance',  Boolean.valueOf(Label.HasNamespace));
        return[SELECT Id,  TargetObjectId, Status, CompletedDate, SubmittedBy.Name,
               CreatedDate FROM ProcessInstance where TargetObjectId = :placementRecordId  Limit 1];
    }
    
    @AuraEnabled
    public static String getChildRemovalRecords(String servicecaseId){
        
        //FieldLevelSecurity.checkFieldAccessByCriteria('argetObjectId, Status, CompletedDate,CreatedDate', 'view', 'ProcessInstance',  Boolean.valueOf(Label.HasNamespace));
        /*getInitialWrapper initWrap = new getInitialWrapper();
        Map<String,Placement__c> exitplacementRecord = new Map<String,Placement__c>();
        Map<String,Placement__c> nonExitplacementRecord = new Map<String,Placement__c>();
        Map<Id,String> newMap = new Map<Id,String>();
        List<Placement__c> placementRecords = new List<Placement__c>();
        List<Placement__c>  placementRecord =[SELECT Id, Child_Removal__c , Child__c, Child__r.Name, Child_Removal__r.Removal_End_Date_Time__c, Exit_Approval_Status__c , Service_Case__c FROM Placement__c WHERE Service_Case__c =: servicecaseId];
        List<Child_Removal__c>  childRemovalRecord =[SELECT Id , Child__c, Child__r.Name,Removal_End_Date_Time__c  FROM Child_Removal__c WHERE Service_Case__c =: servicecaseId AND Removal_End_Date_Time__c =NULL];
		system.debug('tt'+childRemovalRecord);
        if(placementRecord.size()>0) {
            
            /*for(Placement__c rec : placementRecord) {
                if(rec.Child_Removal__r.Removal_End_Date_Time__c == NULL && rec.Exit_Approval_Status__c == 'Approved') {
                    exitplacementRecord.put(rec.Child__c,rec);
                } else {
                    nonExitplacementRecord.put(rec.Child__c,rec);
                }
            }
            system.debug('exitplacementRecord '+exitplacementRecord);
system.debug('nonExitplacementRecord '+nonExitplacementRecord);
            for(Id exitRec : exitplacementRecord.keyset()) {
                if(!nonExitplacementRecord.containsKey(exitRec)) {
                    placementRecords.add(exitplacementRecord.get(exitRec));
                }
            }
            for(Placement__c rec : placementRecord) {
                if(rec.Child_Removal__r.Removal_End_Date_Time__c == NULL && rec.Exit_Approval_Status__c == 'Approved') {
                	newMap.put(rec.Child__c,rec.Child__r.Name);
                }
            }
            for(Child_Removal__c removalRec :childRemovalRecord) {
                if(!newMap.containsKey(removalRec.Child__c) && removalRec.Removal_End_Date_Time__c == NULL) {
                	newMap.put(removalRec.Child__c,removalRec.Child__r.Name);
                }
            }
        }
        system.debug('t'+newMap);
        initWrap.placementRecordList = placementRecord;
        for(Placement__c rec : placementRecords) {
            newMap.put(rec.Child__c,rec.Child__r.Name);
        }
        
        initWrap.childPicklist = new List<Utility.pickListWrap>();
        Utility.pickListWrap intialPick = new Utility.pickListWrap();
        intialPick.label = '--None--';
        intialPick.value = '';
        initWrap.childPicklist.add(intialPick);
        Utility.pickListWrap childRecordpick ;
        for(Id rec : newMap.keyset()){
            childRecordpick = new Utility.pickListWrap();
            childRecordpick.label = newMap.get(rec);
            childRecordpick.value = rec;
            initWrap.childPicklist.add(childRecordpick);
        }
        return JSON.serialize(initWrap); */
        
        
        getInitialWrapper initWrap = new getInitialWrapper();
        List<Child_Removal__c> openChildRemovals = [SELECT Id, Child__c, Child__r.Name  FROM Child_Removal__c WHERE 
                                                    Service_Case__c = :servicecaseId AND Removal_End_Date_Time__c = null AND Child__c != null];
        Utility.pickListWrap intialPick = new Utility.pickListWrap();
        initWrap.childPicklist = new List<Utility.pickListWrap>();
        intialPick.label = '--None--';
        intialPick.value = '';
        initWrap.childPicklist.add(intialPick);
        Map<Id, String> childDetails = new Map<Id, String>();
        
        for(Child_Removal__c remIns : openChildRemovals){
            
            childDetails.put(remIns.Child__c, remIns.Child__r.Name);
        }
        if(childDetails.keySet().size() > 0) {
             
            for(Placement__c placementIns : [SELECT Id, Child__c FROM Placement__c 
                                             WHERE Service_Case__c = :servicecaseId AND Child__c IN :childDetails.keySet() AND 
                                             (Exit_Approval_Status__c != 'Approved' OR Placement_Approval_Status__c != 'Approved')]) 
            {
                if(childDetails.keySet().contains(placementIns.Child__c)) {
                    childDetails.remove(placementIns.Child__c);
                }                                          
           	}
            Utility.pickListWrap childRecordpick ;
            for(Id childId : childDetails.keySet()) {
                
                childRecordpick = new Utility.pickListWrap();
                childRecordpick.label = childDetails.get(childId);
                childRecordpick.value = childId;
                initWrap.childPicklist.add(childRecordpick);
            }
                 
        }
           
        return JSON.serialize(initWrap);
        
    }

    @AuraEnabled
    public static String getPlacementUnderChildRemoval(Id servicecaseId){
       
        getInitialWrapper initWrap = new getInitialWrapper();
        Service_Case__c serviceCaseIns = [SELECT Id, Status__c FROM Service_Case__c WHERE Id = :servicecaseId];
        if(serviceCaseIns.Status__c != 'Close') {
            initWrap.isOpenServiceCase = true;
        } else {
            initWrap.isOpenServiceCase = false;
        }
        initWrap.childRemovalRecordList = [SELECT Id, Name, Child__c,Child__r.Name,Removal_DateF__c,
                                            (SELECT Id, Name, Child__c, Child__r.Name ,Provider__c, Provider__r.Name, Begin_Date__c, End_Date__c,
                                            Exit_Type__c,Placement_Approval_Status__c,Exit_Approval_Status__c,Placement_Structure__c
                                            FROM Placements__r WHERE Service_Case__c = :servicecaseId ORDER BY LastModifiedDate DESC) 
                                            FROM Child_Removal__c WHERE Service_Case__c = :servicecaseId 
                                           ORDER BY Child_Removal_Approval_Status__c ASC ,LastModifiedDate DESC];
        return JSON.serialize(initWrap);

    }

    
    public class SearchInputWrapper {
        
        Public String firstName; 
        Public String middleName;
        Public String lastName;
        Public String providerName;
        Public String childCharacter;
        Public String localDept;
        Public String bundledService;
        public String providerId;
        public String placementStructure;
        public String providerType;
    }
    
    public class lookupWrap {
        public String label; 
        public String value;
    }
    
    public class getInitialWrapper { 
        @AuraEnabled
        public List<Utility.pickListWrap> placementStructurePicklist;
        @AuraEnabled
        public List<Utility.pickListWrap> childCharPicklist;
        @AuraEnabled
        public List<Utility.pickListWrap> localDeptPicklist;
        @AuraEnabled
        public List<Utility.pickListWrap> responseAcceptedPicklist;
        @AuraEnabled
        public List<Utility.pickListWrap> placementStructPicklist;
        @AuraEnabled
        public List<Utility.pickListWrap> reasonForDeclinePicklist;
        @AuraEnabled
        public List<Utility.pickListWrap> comarRateCategoryPicklist; 
        @AuraEnabled
        public Placement__c placementRecord;
        @AuraEnabled
        public List<lookupWrap> cpaHomeList;
        @AuraEnabled
        public List<Utility.pickListWrap> privateCPAHomes;
        @AuraEnabled
        public List<Utility.pickListWrap> exitTypePickList;
        @AuraEnabled
        public List<Utility.pickListWrap> reasonForExitPickList;
        @AuraEnabled
        public List<Placement__c> placementRecordList;
        @AuraEnabled
        public List<Utility.pickListWrap> childPicklist;
        @AuraEnabled
        public List<Child_Removal__c> childRemovalRecordList;
        @AuraEnabled
        public Boolean isOpenServiceCase;

    }
}