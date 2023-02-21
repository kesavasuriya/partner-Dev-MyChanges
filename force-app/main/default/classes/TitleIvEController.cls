public without sharing class TitleIvEController {
    
    @AuraEnabled
    public static String getTitleIveRecords() {
        
        List<titleIvETableInstance > titleTableInstaceList = new List<titleIvETableInstance>();
        FieldLevelSecurity.checkFieldAccessByCriteria('Name, Child_Removal__c,Placement__c,Assignment_Status__c,Eligible_Status__c,Assigned_To__c,Review_Period__c, Title_Iv_E__c, Period__c,Service_Case__c, Is_Living_Arrangement_same_as_Placement__c, Is_Placement_Reimbursible__c, Is_IV_E_agency_responsible_for_placement__c  ', 'view', 'Title_Iv_E__c',  Boolean.valueOf(Label.HasNamespace));
        FieldLevelSecurity.checkFieldAccessByCriteria('Child__c,Removal_Date_of_DT_F__c,Removal_Type__c,Physical_Address_From_Where_Child__c,Removal_Age__c','view','Child_Removal__c', Boolean.valueOf(Label.HasNamespace));
        FieldLevelSecurity.checkFieldAccessByCriteria('Begin_Date__c,End_Date__c,Child__c','view','Placement__c', Boolean.valueOf(Label.HasNamespace));
        FieldLevelSecurity.checkFieldAccessByCriteria('Name,Date_of_Birth__c,Age__c,Is_a_US_citizen__c','view','Contact', Boolean.valueOf(Label.HasNamespace));
        FieldLevelSecurity.checkFieldAccessByCriteria('Intake__c,Name','view','Service_Case__c', Boolean.valueOf(Label.HasNamespace));
        FieldLevelSecurity.checkFieldAccessByCriteria('CaseNumber','view','Case', Boolean.valueOf(Label.HasNamespace));
        FieldLevelSecurity.checkFieldAccessByCriteria('Name','view','User', Boolean.valueOf(Label.HasNamespace));
        
        List<Title_Iv_E__c> titleIvList = [SELECT Id, Name, Child_Removal__c, Child_Removal__r.Child__r.Name, Child_Removal__r.Removal_End_Date_Time__c,Child_Removal__r.Child__r.Casevault_PID__c,Is_IV_E_agency_responsible_for_placement__c ,
                                           Child_Removal__r.Removal_Date_of_DT_F__c, Child_Removal__r.Removal_Type__c, Child_Removal__r.Physical_Address_From_Where_Child__c, Child_Removal__r.Removal_Age__c, Child_Removal__r.Child__r.Date_of_Birth__c, Placement__r.Child__r.Date_of_Birth__c,
                                           Assigned_To__c,Assigned_To__r.Name, Assignment_Status__c, Eligible_Status__c, Review_Period__c, Placement__r.Begin_Date__c,  Placement__r.End_Date__c,
                                           Placement__r.Child__r.Age__c, Placement__r.Child__r.Is_a_US_citizen__c, Title_Iv_E__c, Period__c, Service_Case__r.Intake__r.CaseNumber, Service_Case__r.Name, 
                                           Is_Placement_Reimbursible__c, Is_Living_Arrangement_same_as_Placement__c
                                           FROM Title_Iv_E__c 
                                           WHERE Child_Removal__c != Null  AND Child_Removal__r.Child__c != Null AND Title_Iv_E__c = Null
                                           ORDER BY CreatedDate DESC LIMIT :Utility.queryLimit];
        
        if (titleIvList != null && titleIvList.size() > 0) {
            
            titleIvETableInstance titleTableInstace = new titleIvETableInstance();
            for(Title_Iv_E__c titleRec : titleIvList) {
                
                titleTableInstace = new titleIvETableInstance();
                titleTableInstace.titleIVEId = titleRec.Id;
                titleTableInstace.childName = titleRec.Child_Removal__r.Child__r.Name;
                //titleTableInstace.clientId = titleRec.Name;
                titleTableInstace.clientId = titleRec.Child_Removal__r.Child__r.Casevault_PID__c;
                //titleTableInstace.childJurisdication = titleRec.Child_Removal__r.Child__r.JURISDICTION__c;
                Datetime output = titleRec.Child_Removal__r.Removal_Date_of_DT_F__c;
                titleTableInstace.removalDate = output;
                Datetime output1 = titleRec.Child_Removal__r.Child__r.Date_of_Birth__c;
                titleTableInstace.DOB = output1;
                titleTableInstace.removalAge = titleRec.Child_Removal__r.Removal_Age__c;
                titleTableInstace.assignedTo = titleRec.Assigned_To__r.Name;
                titleTableInstace.physicalAddress = titleRec.Child_Removal__r.Physical_Address_From_Where_Child__c;
                titleTableInstace.assignmentStatus = titleRec.Assignment_Status__c ;
                titleTableInstace.eligibleStatus = titleRec.Eligible_Status__c;
                titleTableInstace.reviewPeriod = titleRec.Review_Period__c;
                titleTableInstace.placementStartDate = titleRec.Placement__r.Begin_Date__c;
                titleTableInstace.placementEndDate = titleRec.Placement__r.End_Date__c;
                titleTableInstace.childAge = titleRec.Placement__r.Child__r.Age__c;
                titleTableInstace.usCitizen= titleRec.Placement__r.Child__r.Is_a_US_citizen__c;
                //titleTableInstace.caseNumber = titleRec.Service_Case__r.Intake__r.CaseNumber;
                titleTableInstace.caseNumber = titleRec.Service_Case__r.Name;
                titleTableInstaceList.add(titleTableInstace);
            }
        }
        return JSON.serialize(titleTableInstaceList);
    }
    
    @AuraEnabled
    public static String getSearchTitles(String searchInsString) {
        
        FieldLevelSecurity.checkFieldAccessByCriteria('Name, Child_Removal__c,Placement__c,Assignment_Status__c,Eligible_Status__c,Assigned_To__c,Assigned_To__c,Review_Period__c,Title_Iv_E__c, Period__c,Service_Case__c', 'view', 'Title_Iv_E__c',  Boolean.valueOf(Label.HasNamespace));
        FieldLevelSecurity.checkFieldAccessByCriteria('Child__c,Removal_Date_of_DT_F__c,Removal_Type__c,Physical_Address_From_Where_Child__c,Removal_Age__c','view','Child_Removal__c', Boolean.valueOf(Label.HasNamespace));
        FieldLevelSecurity.checkFieldAccessByCriteria('Begin_Date__c,End_Date__c,Child__c','view','Placement__c', Boolean.valueOf(Label.HasNamespace));
        FieldLevelSecurity.checkFieldAccessByCriteria('Name,Date_of_Birth__c,FirstName,LastName,Age__c,Is_a_US_citizen__c','view','Contact', Boolean.valueOf(Label.HasNamespace));
        FieldLevelSecurity.checkFieldAccessByCriteria('Intake__c','view','Service_Case__c', Boolean.valueOf(Label.HasNamespace));
        FieldLevelSecurity.checkFieldAccessByCriteria('CaseNumber','view','Case', Boolean.valueOf(Label.HasNamespace));
        FieldLevelSecurity.checkFieldAccessByCriteria('Name','view','User', Boolean.valueOf(Label.HasNamespace));
        
        searchTitleIVEIns searchTitleIns = (searchTitleIVEIns) JSON.deserialize(searchInsString, searchTitleIVEIns.class);
        Date removalDate = searchTitleIns.removalDate;
        String searchJSON ='SELECT Id, Name, Child_Removal__c, Child_Removal__r.Child__r.Name,Child_Removal__r.Child__r.FirstName,Child_Removal__r.Child__r.LastName,Child_Removal__r.Child__r.Casevault_PID__c,'
            +'Child_Removal__r.Removal_Date_of_DT_F__c, Child_Removal__r.Removal_Type__c, Child_Removal__r.Physical_Address_From_Where_Child__c, Child_Removal__r.Removal_Age__c, Child_Removal__r.Child__r.Date_of_Birth__c,'
            +'Assigned_To__c,Assigned_To__r.Name, Assignment_Status__c, Eligible_Status__c, Review_Period__c, Placement__r.Begin_Date__c,  Placement__r.End_Date__c,Service_Case__r.Intake__r.CaseNumber, Service_Case__r.Name '
            +' FROM Title_Iv_E__c' 
            +' WHERE Child_Removal__c != Null AND Placement__c != null AND Child_Removal__r.Child__c != Null AND Title_Iv_E__c = Null';
        if(String.isNotBlank(searchTitleIns.clientId)) {
            searchJSON += ' AND Child_Removal__r.Child__r.Casevault_PID__c = \''+ String.escapeSingleQuotes(searchTitleIns.clientId)+'\'';
            
        }
        if(String.isNotBlank(searchTitleIns.firstName)) {
            searchJSON += ' AND Child_Removal__r.Child__r.FirstName = \''+ String.escapeSingleQuotes(searchTitleIns.firstName) +'\'';
        }
        if(String.isNotBlank(searchTitleIns.lastName)) {
            searchJSON += ' AND Child_Removal__r.Child__r.LastName = \''+ String.escapeSingleQuotes(searchTitleIns.lastName) +'\'';
        }
        if(String.isNotBlank(searchTitleIns.eligibleStatus)) {
            searchJSON += ' AND Eligible_Status__c = \''+ String.escapeSingleQuotes(searchTitleIns.eligibleStatus) +'\'';
        }
        if(searchTitleIns.removalDate != null) {
            searchJSON +=' AND Child_Removal__r.Removal_Date_of_DT_F__c = :removalDate';
        }
        Integer queryLimit = Utility.queryLimit;
        searchJSON +=' ORDER BY CreatedDate DESC';
        
        List<Title_Iv_E__c> titleIvSearchList = Database.query(searchJSON);
        List<titleIvETableInstance > titleTableInstaceList = new List<titleIvETableInstance>();
        titleIvETableInstance titleTableInstace = new titleIvETableInstance();
        
        if (titleIvSearchList != null && titleIvSearchList .size() > 0) {
            
            for(Title_Iv_E__c titleRec : titleIvSearchList) {
                
                titleTableInstace = new titleIvETableInstance();
                titleTableInstace.titleIVEId = titleRec.Id;
                titleTableInstace.childName = titleRec.Child_Removal__r.Child__r.Name;
                //titleTableInstace.clientId = titleRec.Name;
                titleTableInstace.clientId = titleRec.Child_Removal__r.Child__r.Casevault_PID__c;
                //titleTableInstace.childJurisdication = titleRec.Child_Removal__r.Child__r.JURISDICTION__c;
                Datetime output = titleRec.Child_Removal__r.Removal_Date_of_DT_F__c;
                titleTableInstace.removalDate = output;
                Datetime output1 = titleRec.Child_Removal__r.Child__r.Date_of_Birth__c;
                titleTableInstace.DOB = output1;
                titleTableInstace.removalAge = titleRec.Child_Removal__r.Removal_Age__c;
                titleTableInstace.assignedTo = titleRec.Assigned_To__r.Name;
                titleTableInstace.assignmentStatus = titleRec.Assignment_Status__c ;
                titleTableInstace.eligibleStatus = titleRec.Eligible_Status__c;
                titleTableInstace.reviewPeriod = titleRec.Review_Period__c;
                titleTableInstace.placementStartDate = titleRec.Placement__r.Begin_Date__c;
                titleTableInstace.placementEndDate = titleRec.Placement__r.End_Date__c;
                //titleTableInstace.caseNumber = titleRec.Service_Case__r.Intake__r.CaseNumber;
                titleTableInstace.caseNumber = titleRec.Service_Case__r.Name;
                titleTableInstaceList.add(titleTableInstace);
            }
        }
        return JSON.serialize(titleTableInstaceList);
    }
    
    @AuraEnabled
    public static String getInitialInfo() {
        
        titleIvETableInstance titleTableInstaceWrap = new titleIvETableInstance();
        titleTableInstaceWrap.childReceiveSSIPickList = Utility.getPicklistinfo('Title_Iv_E__c','child_receive_SSI_SSA_during_review__c',false);
        titleTableInstaceWrap.financialInformationPickList = Utility.getPicklistinfo('Title_Iv_E__c','IV_E_case_has_income_assets_of_AU_member__c',false);
        titleTableInstaceWrap.eligibleStatusPicklist = Utility.getPicklistinfo('Title_Iv_E__c','Eligible_Status__c',false);
        return JSON.serialize(titleTableInstaceWrap);        
    }
    
    @AuraEnabled
    public static String getTitleIVERec(String titleIVEId) {
        
        titleIvETableInstance titleTableInstaceWrap = new titleIvETableInstance();
        FieldLevelSecurity.checkFieldAccessByCriteria('Name,Placement__c,Child_Removal__c,Service_Case__c,child_receive_SSI_SSA_during_review__c,Agency_opted_to_suspend_SSI_claim_IV_E__c, IsThe_Agency_TheRepresentativePayee__c,'+
                                                      'Citizenship_How_verified__c,Age_How_verified__c,Asset_Information_How_verified__c, IV_E_Specialist_Signature__c, IV_E_Specialist_Signature_Date__c,Status__c,Review_Period_End_Date__c, Review_Period_Start_Date__c, Period__c,'+
                                                      'SSI_SSA_Information_How_verified__c,IV_E_case_has_income_assets_of_AU_member__c,Narrative__c,Is_Living_Arrangement_same_as_Placement__c, Is_Placement_Reimbursible__c','view','Title_Iv_E__c', Boolean.valueOf(Label.HasNamespace));
        
        FieldLevelSecurity.checkFieldAccessByCriteria('Removal_Date_of_DT_F__c,Child__c,Removal_Type__c,Removal_Age__c,Physical_Address_From_Where_Child__c,Primary_Caregiver__c,Address_Of_Primary_Caregiver__c,Relationship_of_Person_Involved__c,Primary_Address_Verified__c,Child_Home_Address_Same_as_Primary_Addre__c','view','Child_Removal__c', Boolean.valueOf(Label.HasNamespace));
        FieldLevelSecurity.checkFieldAccessByCriteria('Begin_Date__c,End_Date__c,Provider__c,Child__c,Is_Living_Arrangement_same_as_Placement__c,Is_Placement_Reimbursible__c,Name','view','Placement__c', Boolean.valueOf(Label.HasNamespace));
        FieldLevelSecurity.checkFieldAccessByCriteria('Date_of_Birth__c,Age__c,Alien_Status__c,Allien_Registartion_Number__c,Is_a_US_citizen__c,Safe_haven_baby__c','view','Contact', Boolean.valueOf(Label.HasNamespace));
        FieldLevelSecurity.checkFieldAccessByCriteria('Id','view','Service_Case__c', Boolean.valueOf(Label.HasNamespace));
        FieldLevelSecurity.checkFieldAccessByCriteria('Name','view','Contact', Boolean.valueOf(Label.HasNamespace));
        FieldLevelSecurity.checkFieldAccessByCriteria('Name,BillingStreet,BillingCity,BillingState,Placement__c,Type__c,BillingPostalCode,BillingCountry,BillingAddress','view','Account', Boolean.valueOf(Label.HasNamespace));
        
        titleTableInstaceWrap.titleIVERec = [SELECT Id, Child_Removal__r.Removal_Date_of_DT_F__c, Placement__c, Placement__r.Begin_Date__c,
                                             Placement__r.End_Date__c, Placement__r.Provider__r.Name, Child_Removal__c, Name,Placement__r.Name,
                                             Placement__r.Child__r.Date_of_Birth__c, Placement__r.Provider__r.BillingStreet,
                                             Placement__r.Provider__r.BillingCity, Placement__r.Provider__r.BillingState, 
                                             Placement__r.Provider__r.BillingPostalCode, Placement__r.Provider__r.BillingCountry,
                                             Child_Removal__r.Child__r.Date_of_Birth__c, Child_Removal__r.Removal_Age__c, IsThe_Agency_TheRepresentativePayee__c,
                                             Placement__r.Child__r.Age__c, Placement__r.Child__r.Is_a_US_citizen__c, Child_Removal__r.Removal_Type__c,
                                             Placement__r.Child__r.Safe_haven_baby__c,Child_Removal__r.Physical_Address_From_Where_Child__c,Is_Living_Arrangement_same_as_Placement__c, Is_Placement_Reimbursible__c,
                                             Placement__r.Provider__r.BillingAddress,Placement__r.Provider__r.Placement__c,Placement__r.Provider__r.Type__c,
                                             Child_Removal__r.Child__r.Alien_Status__c,Child_Removal__r.Child__r.Allien_Registartion_Number__c,Child_Removal__r.Child__r.Name,
                                             Placement__r.Is_Living_Arrangement_same_as_Placement__c,Placement__r.Is_Placement_Reimbursible__c,Service_Case__c,child_receive_SSI_SSA_during_review__c,
                                             Agency_opted_to_suspend_SSI_claim_IV_E__c,Citizenship_How_verified__c,Age_How_verified__c,Asset_Information_How_verified__c,Child_Removal__r.Primary_Caregiver__r.Name,Placement__r.PlacementReimbursable__c,
                                             Child_Removal__r.Address_Of_Primary_Caregiver__c,Child_Removal__r.Child_Home_Address_Same_as_Primary_Addre__c,Child_Removal__r.Primary_Address_Verified__c, Review_Period_End_Date__c, Review_Period_Start_Date__c,
                                             SSI_SSA_Information_How_verified__c,IV_E_case_has_income_assets_of_AU_member__c,Child_Removal__r.Relationship_of_Person_Involved__c, IV_E_Specialist_Signature__c, IV_E_Specialist_Signature_Date__c,Status__c,Narrative__c, 
                                             Period__c, Child_Removal__r.Child__c
                                             FROM Title_Iv_E__c
                                             WHERE Id = :titleIVEId  LIMIT :Utility.queryLimit];
        return JSON.serialize(titleTableInstaceWrap);                                              
    }
    
    @AuraEnabled
    public static String getIncomeSummaries(String titleIVEId) {
        
        titleIvETableInstance titleTableInstaceWrap = new titleIvETableInstance();
        FieldLevelSecurity.checkFieldAccessByCriteria('Contact__c,In_AU__c, Is_income_deemed__c, Disregard__c, Title_Iv_E__c','view','Income_Summary__c', Boolean.valueOf(Label.HasNamespace));
        FieldLevelSecurity.checkFieldAccessByCriteria('Name','view','Contact', Boolean.valueOf(Label.HasNamespace));
        
        titleTableInstaceWrap.incomeSummaryList = [SELECT Id, Contact__c, Contact__r.Name, In_AU__c, Is_income_deemed__c, 
                                                   Disregard__c, Title_Iv_E__c FROM Income_Summary__c WHERE Title_Iv_E__c =:titleIVEId LIMIT :Utility.queryLimit];
        titleTableInstaceWrap.inAu = Utility.getPicklistinfo('Income_Summary__c','In_AU__c',false);
        return JSON.serialize(titleTableInstaceWrap);
        
    }
    
    @AuraEnabled
    public static String getPersonIncomes(String childId) {
        
        titleIvETableInstance titleTableInstaceWrap = new titleIvETableInstance();
        FieldLevelSecurity.checkFieldAccessByCriteria('Contact__c, End_Date__c, Entry_Date__c,'+
                                                      'Monthly_Income__c, Start_Date__c, Amount__c','view','Person_Incomes__c', Boolean.valueOf(Label.HasNamespace));
        
        titleTableInstaceWrap.personIncomeList = [SELECT Id, Contact__c, End_Date__c, Entry_Date__c,
                                                  Monthly_Income__c, Start_Date__c, Amount__c FROM Person_Incomes__c
                                                  WHERE Contact__c =:childId LIMIT :Utility.queryLimit];  
        return JSON.serialize(titleTableInstaceWrap); 
    }
    
    @AuraEnabled
    public static void updateIncomeSummaryRec(String incomeSummaryRec) {
        
        List<Income_Summary__c> updateIncomeSummary = (List<Income_Summary__c>) JSON.deserialize(incomeSummaryRec, List<Income_Summary__c>.class);
        if (String.isNotBlank(incomeSummaryRec)) {
            FieldLevelSecurity.checkFieldAccessByCriteria('In_AU__c, Is_income_deemed__c, Disregard__c','update','Income_Summary__c', Boolean.valueOf(Label.HasNamespace));
            update updateIncomeSummary;
        }
    }
    
    @AuraEnabled
    public static String getAllPeriodTitleIVERec(String titleIVId) {
        
        Integer queryLimit = Utility.queryLimit;
        titleIvETableInstance titleTableInstaceWrap = new titleIvETableInstance();
        
        if (String.isNotBlank(titleIVId)) {
            FieldLevelSecurity.checkFieldAccessByCriteria('Review_Period_Start_Date__c, Review_Period_End_Date__c, Title_Iv_E__c, First_Time_Redetermination__c','view','Title_Iv_E__c', Boolean.valueOf(Label.HasNamespace));
            
            String period = 'Redetermination';
            String titleQueryString = 'SELECT Id, Review_Period_Start_Date__c, Review_Period_End_Date__c, Title_Iv_E__c, First_Time_Redetermination__c';
            
            for(Schema.FieldSetMember fld :SObjectType.Title_Iv_E__c.FieldSets.TitlePeriodFields.getFields()) {
                titleQueryString += ', ' + fld.getFieldPath();
            }
            titleQueryString += ' FROM Title_Iv_E__c WHERE Id = \''+ String.escapeSingleQuotes(titleIVId) +'\'';
            titleQueryString += ' OR (Period__c = \''+ period +'\'' + ' AND Title_Iv_E__c = \''+ String.escapeSingleQuotes(titleIVId) +'\'' + ')';
            titleQueryString += ' ORDER BY Review_Period_End_Date__c DESC NULLS LAST, Review_Period_Start_Date__c DESC, CreatedDate DESC LIMIT :queryLimit';
            titleTableInstaceWrap.titleIVERecList =  Database.query(titleQueryString);
        }   
        return JSON.serialize(titleTableInstaceWrap); 
    }
    
    @AuraEnabled
    public static String upserttitleIVE(String titleIVEDataJSON) {
        
        if (String.isNotBlank(titleIVEDataJSON)) {
            
            Title_Iv_E__c createtitleIVERec = (Title_Iv_E__c) JSON.deserialize(titleIVEDataJSON, Title_Iv_E__c.class);
            if (String.isBlank(createtitleIVERec.Id)) {
                FieldLevelSecurity.checkFieldAccessByCriteria('child_receive_SSI_SSA_during_review__c,Agency_opted_to_suspend_SSI_claim_IV_E__c,Citizenship_How_verified__c,Age_How_verified__c,Asset_Information_How_verified__c,SSI_SSA_Information_How_verified__c,IV_E_case_has_income_assets_of_AU_member__c, Is_IV_E_agency_responsible_for_placement__c ','create','Title_Iv_E__c', Boolean.valueOf(Label.HasNamespace));
                insert createtitleIVERec;
            } else {
                FieldLevelSecurity.checkFieldAccessByCriteria('child_receive_SSI_SSA_during_review__c,Agency_opted_to_suspend_SSI_claim_IV_E__c,Citizenship_How_verified__c,Age_How_verified__c,Asset_Information_How_verified__c,SSI_SSA_Information_How_verified__c,IV_E_case_has_income_assets_of_AU_member__c, Is_IV_E_agency_responsible_for_placement__c ','update','Title_Iv_E__c', Boolean.valueOf(Label.HasNamespace));
                update createtitleIVERec;
            }
            return createtitleIVERec.Id;
        } else {
            return null;
        }
    }
    
    @AuraEnabled
    public static String upsertPlacement(String placementDataJSON) {
        if (String.isNotBlank(placementDataJSON)) {
            Title_Iv_E__c updatePlacementRec = (Title_Iv_E__c) JSON.deserialize(placementDataJSON, Title_Iv_E__c.class);
            if (String.isBlank(updatePlacementRec.Id)) {
                FieldLevelSecurity.checkFieldAccessByCriteria('Is_Living_Arrangement_same_as_Placement__c,Is_Placement_Reimbursible__c','create','Title_Iv_E__c', Boolean.valueOf(Label.HasNamespace));
                insert updatePlacementRec;
            } else {
                FieldLevelSecurity.checkFieldAccessByCriteria('Is_Living_Arrangement_same_as_Placement__c,Is_Placement_Reimbursible__c','update','Title_Iv_E__c', Boolean.valueOf(Label.HasNamespace));    
                update updatePlacementRec;
            }
            return updatePlacementRec.Id;
        } else { 
            return null;
        }
    }
    
    @AuraEnabled
    public static void deleteIncomeSummaryRec(String contactId) {
        
        if (String.isNotBlank(contactId)) {
            
            List<Person_Incomes__c > personIncomeList = [SELECT Id FROM Person_Incomes__c  WHERE Contact__c =: contactId];
            List<Asset__c> assetList = [SELECT Id FROM Asset__c  WHERE Contact__c =: contactId];
            
            delete personIncomeList;
            delete assetList;
        }
        
    }
    
   /* @AuraEnabled
    public static String getCourtRecord(String serviceCaseRecord, String childId) {
        
        List<Court__c>  courtRecord = new List<Court__c>();
        if(String.isNotBlank(serviceCaseRecord) && String.isNotBlank(childId) ) {
            
            FieldLevelSecurity.checkFieldAccessByCriteria('Id, Name,Reasonable_efforts_were_made_to_finalize__c,'+
                                                          'D_Were_reasonable_efforts_not_made__c,Service_Case__c,'+
                                                          'Date_Of_Next_Hearing__c,Date_Of_Court_Hearing__c,Court_Orders_are_not_signed_by_the_judge__c,Efforts_Were_Made_To_Prevent_Removal__c,'+
                                                          'Is_IV_E_agency_responsible_for_placement__c,Reasonable_Efforts_Could_Not_Be_Made__c,'+
                                                          'Court_order_delay_removal__c,Child_s_Home_Is_Contrary__c,Child_s_Home__c,Judge_s_Name__c,Court_Order_Date__c','view','Court__c', Boolean.valueOf(Label.HasNamespace));
            
            courtRecord = [SELECT Id, Name,Reasonable_efforts_were_made_to_finalize__c,
                           D_Were_reasonable_efforts_not_made__c,Service_Case__c,
                           Date_Of_Next_Hearing__c,Date_Of_Court_Hearing__c,Court_Orders_are_not_signed_by_the_judge__c,Efforts_Were_Made_To_Prevent_Removal__c,
                           Is_IV_E_agency_responsible_for_placement__c,Reasonable_Efforts_Could_Not_Be_Made__c,
                           Court_order_delay_removal__c,Child_s_Home_Is_Contrary__c,Child_s_Home__c,Court_Order_Date__c,
                           (SELECT Id,Judge_s_Name__c,Hearing_Date_and_Time__c FROM Court__r),Hearing_Outcome__c
                           FROM Court__c WHERE Service_Case__c =: serviceCaseRecord AND Petition_for_Child__c =:childId ORDER BY createdDate DESC LIMIT 1]; 
            
        }
        return JSON.serialize(courtRecord);
        
    }*/

    @AuraEnabled
    public static String getCourtRecord(String serviceCaseRecord, String childId) {
        
        titleIvELegalDetails initWrap = new titleIvELegalDetails();
        
        if(String.isNotBlank(serviceCaseRecord) && String.isNotBlank(childId) ) {
            
            List<String> courtFields = new List<String>{'Id', 'Name','Reasonable_efforts_were_made_to_finalize__c',
                'D_Were_reasonable_efforts_not_made__c','Service_Case__c',
                'Date_Of_Next_Hearing__c','Date_Of_Court_Hearing__c','Court_Orders_are_not_signed_by_the_judge__c','Efforts_Were_Made_To_Prevent_Removal__c',
                'Is_IV_E_agency_responsible_for_placement__c','Reasonable_Efforts_Could_Not_Be_Made__c',
                'Court_order_delay_removal__c','Child_s_Home_Is_Contrary__c','Child_s_Home__c','Court_Order_Date__c','Hearing_Outcome__c'};
                    
            String  courtCondition = 'Service_Case__c = \''+ String.escapeSingleQuotes(serviceCaseRecord) +'\' AND Petition_for_Child__c='+'\''+ String.escapeSingleQuotes(childId) +'\' ORDER BY createdDate DESC';
            List<SObject>  courtsObjList = DataService.performQueryOperation(courtFields, 'Court__c', courtCondition, Utility.queryLimit);
            
            if(courtsObjList != null && courtsObjList.size() >0) {
                initWrap.courtRecord = (Court__c)courtsObjList[0];
                List<String> petitionHearingFields = new List<String>{'Id','Judge_s_Name__c','Hearing_Date_and_Time__c'};
                    
                String  petitionHearingCondition = 'Court__c = \''+ String.escapeSingleQuotes(initWrap.courtRecord.Id) +'\' ORDER BY createdDate DESC';
                List<SObject>  petitionHearingsObjList = DataService.performQueryOperation(petitionHearingFields, 'Court_Petition_Hearing__c', petitionHearingCondition, Utility.queryLimit);
                initWrap.courtPetitionHearingList = (List<Court_Petition_Hearing__c>)petitionHearingsObjList;
            }
                   
        }
        return JSON.serialize(initWrap);
        
    }
    
    @AuraEnabled
    public static String getDeprivationRecord(Id titleIVEId) {
        
        if(String.isNotBlank(titleIVEId)) {
            FieldLevelSecurity.checkFieldAccessByCriteria('Parent__c,Child_deprived_of_parental_support__c,Deprivation_factor__c,'+
                                                          'Reason_for_absence__c,Date_of_parent_death__c,Incarceration_date__c', 'view', 'Deprivation__c', Boolean.valueOf(Label.HasNamespace));
            
            List<Deprivation__c > deprivationRecord = [SELECT Id,Parent__c,Child_deprived_of_parental_support__c,Deprivation_factor__c, Parent__r.Name,
                                                       Reason_for_absence__c,Date_of_parent_death__c,Incarceration_date__c FROM Deprivation__c WHERE Title_Iv_E__c =:titleIVEId LIMIT :Utility.queryLimit];
            
            return JSON.serialize(deprivationRecord);     
        } else {
            return null;
        }
    }
    
    @AuraEnabled
    public static String getDeprivationPicklist(String titleiveId) {
        
        List<String> personRole = new List<String>();
        personRole.add('Adoptive Parent');
        personRole.add('Biological Parent');
        personRole.add('Foster Parent');
        
        titleIvEDeprivationPicklist pickValue = new titleIvEDeprivationPicklist();
        pickValue.deprivationFactor = Utility.getPicklistinfo('Deprivation__c','Deprivation_factor__c',false);
        pickValue.childdeprivedpicklist = Utility.getPicklistinfo('Deprivation__c','Child_deprived_of_parental_support__c',false);
        pickValue.reasonforAbsence = Utility.getPicklistinfo('Deprivation__c','Reason_for_absence__c',false);
        
        FieldLevelSecurity.checkFieldAccessByCriteria('Service_Case__c','view','Title_Iv_E__c',Boolean.valueOf(Label.HasNamespace));
        FieldLevelSecurity.checkFieldAccessByCriteria('Name, Intake_Person_Role__c','view','Contact',Boolean.valueOf(Label.HasNamespace));       
        Title_Iv_E__c serviceCaseId = [SELECT Service_Case__c FROM Title_Iv_E__c WHERE Id =:titleiveId LIMIT :Utility.queryLimit];
        pickValue.parentPicklist = [SELECT Id, Person__r.Name, Person__c FROM Person__c WHERE Service_Case__c =:serviceCaseId.Service_Case__c AND Person_Role__c  EXCLUDES('Biological Child','Child','Other Child','Other Child (Not in Household)','Private Adoptive Child') LIMIT :Utility.queryLimit];
        return JSON.serialize(pickValue);     
    }
    
    @AuraEnabled
    public static String upsertDeprivationRecord(string deprivationRec) {
        if(String.isNotBlank(deprivationRec)) {                  
            Deprivation__c upsertDeprivation = (Deprivation__c) JSON.deserialize(deprivationRec, Deprivation__c.class);
            if(String.isBlank(upsertDeprivation.Id)) {
                FieldLevelSecurity.checkFieldAccessByCriteria('Parent__c,Child_deprived_of_parental_support__c,Deprivation_factor__c,'+
                                                              'Reason_for_absence__c,Date_of_parent_death__c,Incarceration_date__c', 'create', 'Deprivation__c', Boolean.valueOf(Label.HasNamespace));
                insert upsertDeprivation;
            } else {
                FieldLevelSecurity.checkFieldAccessByCriteria('Parent__c,Child_deprived_of_parental_support__c,Deprivation_factor__c,'+
                                                              'Reason_for_absence__c,Date_of_parent_death__c,Incarceration_date__c', 'update', 'Deprivation__c', Boolean.valueOf(Label.HasNamespace));
                update upsertDeprivation;
            }
            return upsertDeprivation.Id;
        }
        return null;    
    }
    @AuraEnabled
    public static void deleteDeprivationRecord(Id deprivationRec) {
        
        if(String.isNotBlank(deprivationRec)) {
            Deprivation__c  deprivationRecord= new Deprivation__c();
            deprivationRecord.Id = deprivationRec;
            FieldLevelSecurity.checkObjectAccessByDelete('Deprivation__c');
            delete deprivationRecord;
        } 
    }
    
    @AuraEnabled
    public static String onSubmitForApproval(String titleIVERecId, Id selectedSupervisorUserId){        
        
        if (String.isNotBlank(titleIVERecId) && String.isNotBlank(selectedSupervisorUserId)) {
            Title_Iv_E__c titleIVERec =  new Title_Iv_E__c ();
            titleIVERec.Id = titleIVERecId;
            titleIVERec.Supervisor_Approval__c  = selectedSupervisorUserId;
            FieldLevelSecurity.checkFieldAccessByCriteria('Supervisor_Approval__c','update','Title_Iv_E__c', Boolean.valueOf(Label.HasNamespace));
            update titleIVERec;
            Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest(); 
            req.setComments('Submit For Approval');        
            req.setObjectId(titleIVERec.Id);
            Approval.ProcessResult approvalResult = Approval.process(req);
            return JSON.serialize(approvalResult);
        } else {
            return null;
        }   
        
    }
    
    @AuraEnabled
    public static String updateNattrive(String updateNarrativeJSON){
        if(String.isNotBlank(updateNarrativeJSON)) {
            Title_Iv_E__c iveNarrativeRec = (Title_Iv_E__c) JSON.deserialize(updateNarrativeJSON, Title_Iv_E__c.class);
            if (String.isNotBlank(iveNarrativeRec.Id)) {
                FieldLevelSecurity.checkFieldAccessByCriteria('Narrative__c','update','Title_Iv_E__c', Boolean.valueOf(Label.HasNamespace));
                update iveNarrativeRec;
            }
            return iveNarrativeRec.Id;
        } else {
            return null;
        } 
        
    }
    
    @AuraEnabled
    public static String updateSignature(String updateSignJSON, String updateTitleIVEJSON) {
        if(String.isNotBlank(updateSignJSON) && String.isNotBlank(updateTitleIVEJSON)) {
            
            Title_Iv_E__c iveRec = (Title_Iv_E__c) JSON.deserialize(updateTitleIVEJSON, Title_Iv_E__c.class);
            Title_Iv_E__c updateIveSignRec = new Title_Iv_E__c();
            if(String.isNotBlank(iveRec.Id)) {
                FieldLevelSecurity.checkFieldAccessByCriteria('IV_E_Specialist_Signature__c, IV_E_Specialist_Signature_Date__c','update','Title_Iv_E__c', Boolean.valueOf(Label.HasNamespace));
                updateIveSignRec.Id = iveRec.Id;
                updateIveSignRec.IV_E_Specialist_Signature__c = updateSignJSON;
                updateIveSignRec.IV_E_Specialist_Signature_Date__c = iveRec.IV_E_Specialist_Signature_Date__c;
                update updateIveSignRec;
            }
            return updateIveSignRec.IV_E_Specialist_Signature__c;
        } else {
            return null;
        }
    }
    @AuraEnabled
    public static String getPlacementPickList() {
        
        List<Utility.pickListWrap> PlacementReimbursible = Utility.getPicklistinfo('Placement__c','Is_Placement_Reimbursible__c',false);        
        return JSON.serialize(PlacementReimbursible);
        
    }
    
    @AuraEnabled
    public static String getEligibilityDetailRec(String titleIVEId) {
        
        FieldLevelSecurity.checkFieldAccessByCriteria('Order_Type__c,CourtStatus_RemDtEarlierThnCtOrderDt__c,CourtStatus_Status__c,CourtStatus_Message__c,'
                                                      +'HomeRemoval_SpRelClIdsameAsCtw__c,HomeRemoval_Status__c,HomeRemoval_Message__c,Demographics_UsCorQA__c,Demographics_AgeDuringAFDCmonth__c,'
                                                      +'Demographics_Status__c,Demographics_Message__c,Deprivation_DepParentalSupp__c,Deprivation_DeprivationFactor__c,Deprivation_Status__c,'
                                                      +'Deprivation_Message__c,FamilySizeAndSona_FamilySize__c,FamilySizeAndSona_Sona__c,Income_TotalAvailableIncome__c,Income_Status__c,'
                                                      +'Income_Message__c,Asset_AssetValue__c,Asset_Status__c,Asset_Message__c,Placement_PlacementReimbursable__c,Placement_PlcmntDtErlThnRemDtr__c,'
                                                      +'Placement_Status__c,Placement_Message__c,FinalStatus__c,IV_E_Specialist_Signature__c, IV_E_Specialist_Signature_Date__c,Status__c,'
                                                      +'Review_Period_End_Date__c, Review_Period_Start_Date__c,CreatedDate, Period__c, RemovalType_Status__c, RemovalType_Message__c','view','Title_Iv_E__c', Boolean.valueOf(Label.HasNamespace));
        
        Title_Iv_E__c eligibilityDetailList = [SELECT Id,Order_Type__c,CourtStatus_RemDtEarlierThnCtOrderDt__c,CourtStatus_Status__c,CourtStatus_Message__c,
                                               HomeRemoval_SpRelClIdsameAsCtw__c,HomeRemoval_Status__c,HomeRemoval_Message__c,Demographics_UsCorQA__c,Demographics_AgeDuringAFDCmonth__c,
                                               Demographics_Status__c,Demographics_Message__c,Deprivation_DepParentalSupp__c,Deprivation_DeprivationFactor__c,Deprivation_Status__c,
                                               Deprivation_Message__c,FamilySizeAndSona_FamilySize__c,FamilySizeAndSona_Sona__c,Income_TotalAvailableIncome__c,Income_Status__c,
                                               Income_Message__c,Asset_AssetValue__c,Asset_Status__c,Asset_Message__c,Placement_PlacementReimbursable__c,Placement_PlcmntDtErlThnRemDtr__c,
                                               Placement_Status__c,Placement_Message__c,FinalStatus__c,IV_E_Specialist_Signature__c, IV_E_Specialist_Signature_Date__c,Status__c, 
                                               Review_Period_End_Date__c, Review_Period_Start_Date__c,CreatedDate, Period__c, RemovalType_Status__c, RemovalType_Message__c FROM Title_Iv_E__c WHERE Title_Iv_E__c =:titleIVEId OR Id =:titleIVEId LIMIT :Utility.queryLimit];
        return JSON.serialize(eligibilityDetailList);
    }
    
    @AuraEnabled 
    public static String getRelatedTitleRecs(String titleIVEId, String latestTitleIVEId, String titlePeriod) {
        
        List<Title_Iv_E__c> titleIveList = new List<Title_Iv_E__c>();
        FieldLevelSecurity.checkFieldAccessByCriteria('Title_Iv_E__c, Review_Period_End_Date__c,IV_E_Specialist_Signature__c, Review_Period_Start_Date__c,'
                                                      +'CreatedDate, Status__c, Narrative__c, ApprovalButton__c, Period__c, FinalStatus__c, Title_Iv_E__c ','view','Title_Iv_E__c',Boolean.valueOf(Label.HasNamespace));
        
        if (titlePeriod == 'Initial') {
            titleIveList = [SELECT Id, Title_Iv_E__c, Review_Period_End_Date__c,IV_E_Specialist_Signature__c, Review_Period_Start_Date__c, CreatedDate, Status__c, Narrative__c, ApprovalButton__c, Period__c, FinalStatus__c 
                            FROM Title_Iv_E__c 
                            WHERE Id != :latestTitleIVEId AND Title_Iv_E__c = :titleIVEId AND Period__c != 'Redetermination' ORDER BY CreatedDate DESC, Period__c DESC LIMIT :Utility.queryLimit];
        } else if (titlePeriod == 'Redetermination') {
            titleIveList = [SELECT Id, Title_Iv_E__c, Review_Period_End_Date__c,IV_E_Specialist_Signature__c, Review_Period_Start_Date__c, CreatedDate, Status__c, Narrative__c, ApprovalButton__c, Period__c, FinalStatus__c 
                            FROM Title_Iv_E__c 
                            WHERE Id != :latestTitleIVEId AND Title_Iv_E__c = :titleIVEId ORDER BY CreatedDate DESC, Period__c DESC LIMIT :Utility.queryLimit];
        }                                    
        return JSON.serialize(titleIveList);  
    }
    
    @AuraEnabled
    public static String getEligibilityDetailRecords(List<String> titleIVEIdList) {
        
        List<Title_Iv_E__c> determineTitleIveList = new List<Title_Iv_E__c>();
        FieldLevelSecurity.checkFieldAccessByCriteria('Title_Iv_E__c, Review_Period_End_Date__c,IV_E_Specialist_Signature__c, Review_Period_Start_Date__c,'
                                                      +'CreatedDate, Status__c, Narrative__c, ApprovalButton__c, Period__c, FinalStatus__c, Title_Iv_E__c ','view','Title_Iv_E__c',Boolean.valueOf(Label.HasNamespace));
        
        List<Title_Iv_E__c> titleIveList = [SELECT Id, (SELECT Id, Review_Period_End_Date__c, Review_Period_Start_Date__c,IV_E_Specialist_Signature__c, CreatedDate, Status__c, Narrative__c, ApprovalButton__c, Period__c, FinalStatus__c FROM Title_Iv_E_S__r ORDER By CreatedDate DESC,Period__c DESC LIMIT 1) FROM Title_Iv_E__c WHERE Id IN : titleIVEIdList ORDER By Review_Period_Start_Date__c DESC, Period__c DESC LIMIT :Utility.queryLimit];      
        for (Title_Iv_E__c titleIveRec : titleIveList) {
            if (titleIveRec.Title_Iv_E_S__r != null && titleIveRec.Title_Iv_E_S__r.size() > 0) {
                determineTitleIveList.add(titleIveRec.Title_Iv_E_S__r[0]);
            }
        }
        return JSON.serialize(determineTitleIveList);
        
    }
    
    @AuraEnabled
    public static void submitDetermineEligibleAPI(List<String> titleIveIdList) {
        
        if (titleIveIdList != null && titleIveIdList.size() > 0) {
            
            Set<Id> servicecaseIdList = new Set<Id>();
            Map<Id, Court__c> titleCourtMap = new Map<Id, Court__c>();
            List<Contact> titleChild = new List<Contact>();
            List<Id> contactId = new List<Id>();
            Map<Id,Person_Incomes__c> incomeSummary = new Map<Id,Person_Incomes__c>();
            List<Asset__c> assetRec = new List<Asset__c>();
            
            FieldLevelSecurity.checkFieldAccessByCriteria('Name,Placement__c,Child_Removal__c,Service_Case__c,child_receive_SSI_SSA_during_review__c,Agency_opted_to_suspend_SSI_claim_IV_E__c, IsThe_Agency_TheRepresentativePayee__c,'+
                                                          'Citizenship_How_verified__c,Age_How_verified__c,Asset_Information_How_verified__c, IV_E_Specialist_Signature__c, IV_E_Specialist_Signature_Date__c,Status__c,Review_Period_End_Date__c, Review_Period_Start_Date__c, Period__c,'+
                                                          'SSI_SSA_Information_How_verified__c,IV_E_case_has_income_assets_of_AU_member__c,Narrative__c,Is_Living_Arrangement_same_as_Placement__c, Is_Placement_Reimbursible__c','view','Title_Iv_E__c', Boolean.valueOf(Label.HasNamespace));
            
            FieldLevelSecurity.checkFieldAccessByCriteria('Removal_Date_of_DT_F__c,Child__c,Removal_Type__c,Removal_Age__c,Physical_Address_From_Where_Child__c,Primary_Caregiver__c,Address_Of_Primary_Caregiver__c,Relationship_of_Person_Involved__c,Primary_Address_Verified__c,Child_Home_Address_Same_as_Primary_Addre__c','view','Child_Removal__c', Boolean.valueOf(Label.HasNamespace));
            FieldLevelSecurity.checkFieldAccessByCriteria('Begin_Date__c,End_Date__c,Provider__c,Child__c,Is_Living_Arrangement_same_as_Placement__c,Is_Placement_Reimbursible__c,Name','view','Placement__c', Boolean.valueOf(Label.HasNamespace));
            FieldLevelSecurity.checkFieldAccessByCriteria('Date_of_Birth__c,Age__c,Alien_Status__c,Allien_Registartion_Number__c,Is_a_US_citizen__c,Safe_haven_baby__c','view','Contact', Boolean.valueOf(Label.HasNamespace));
            FieldLevelSecurity.checkFieldAccessByCriteria('Id','view','Service_Case__c', Boolean.valueOf(Label.HasNamespace));
            FieldLevelSecurity.checkFieldAccessByCriteria('Name','view','Contact', Boolean.valueOf(Label.HasNamespace));
            FieldLevelSecurity.checkFieldAccessByCriteria('Name,BillingStreet,BillingCity,BillingState,Placement__c,Type__c,BillingPostalCode,BillingCountry,BillingAddress','view','Account', Boolean.valueOf(Label.HasNamespace));            
            
            List<Title_Iv_E__c> titleIvERecList = [SELECT Id, Child_Removal__r.Removal_Date_of_DT_F__c, Placement__c, Placement__r.Begin_Date__c,
                                                   Placement__r.End_Date__c, Placement__r.Provider__r.Name, Child_Removal__c, Name,
                                                   Placement__r.Child__r.Date_of_Birth__c, Placement__r.Provider__r.BillingStreet,
                                                   Placement__r.Provider__r.BillingCity, Placement__r.Provider__r.BillingState, 
                                                   Placement__r.Provider__r.BillingPostalCode, Placement__r.Provider__r.BillingCountry,
                                                   Child_Removal__r.Child__r.Date_of_Birth__c, Child_Removal__r.Removal_Age__c,Placement__r.PlacementReimbursable__c,
                                                   Placement__r.Child__r.Age__c, Placement__r.Child__r.Is_a_US_citizen__c, Child_Removal__r.Removal_Type__c,
                                                   Placement__r.Child__r.Safe_haven_baby__c,Child_Removal__r.Physical_Address_From_Where_Child__c,IsThe_Agency_TheRepresentativePayee__c,
                                                   Placement__r.Provider__r.BillingAddress,Placement__r.Provider__r.Placement__c,Placement__r.Provider__r.Type__c,
                                                   Placement__r.Child__r.Alien_Status__c,Child_Removal__r.Child__r.Allien_Registartion_Number__c,Child_Removal__r.Child__r.Name,
                                                   Placement__r.Is_Living_Arrangement_same_as_Placement__c,Is_Placement_Reimbursible__c,Service_Case__c,child_receive_SSI_SSA_during_review__c,
                                                   Agency_opted_to_suspend_SSI_claim_IV_E__c,Citizenship_How_verified__c,Age_How_verified__c,Asset_Information_How_verified__c,Child_Removal__r.Primary_Caregiver__r.Name,
                                                   Child_Removal__r.Address_Of_Primary_Caregiver__c,Child_Removal__r.Child_Home_Address_Same_as_Primary_Addre__c,Child_Removal__r.Primary_Address_Verified__c, Review_Period_End_Date__c, Review_Period_Start_Date__c,
                                                   SSI_SSA_Information_How_verified__c,IV_E_case_has_income_assets_of_AU_member__c,Child_Removal__r.Relationship_of_Person_Involved__c, IV_E_Specialist_Signature__c, IV_E_Specialist_Signature_Date__c,Status__c,Narrative__c, Period__c,
                                                   (SELECT Id, Child_deprived_of_parental_support__c ,Deprivation_factor__c  
                                                    FROM Deprivations__r ORDER BY CreatedDate DESC LIMIT 1)
                                                   FROM Title_Iv_E__c
                                                   WHERE Id IN :titleIveIdList AND  Child_Removal__c != NULL LIMIT :Utility.queryLimit];
            for (Title_Iv_E__c titleIvERec : titleIvERecList) {
                
                servicecaseIdList.add(titleIvERec.Service_Case__c);
                
            }
            if (servicecaseIdList != null && servicecaseIdList.size() > 0) {
                //FieldLevelSecurity.checkFieldAccessByCriteria('Name, Service_Case__c','view','Contact', Boolean.valueOf(Label.HasNamespace));
                
                /*for (Contact childRec : [SELECT Id, Name, Service_Case__c FROM Contact WHERE Service_Case__c IN :servicecaseIdList LIMIT :Utility.queryLimit]) {
              
                    titleChild.add(childRec);
                    contactId.add(childRec.Id);
                }*/
            } 
            
            if (contactId != null && contactId.size() > 0) {
                FieldLevelSecurity.checkFieldAccessByCriteria(' Monthly_Income__c, Contact__c','view','Person_Incomes__c', Boolean.valueOf(Label.HasNamespace));
                
                for (Person_Incomes__c incomeRec : [SELECT Id, Monthly_Income__c, Contact__c FROM Person_Incomes__c WHERE Contact__c IN :contactId  AND Income_Summary__r.In_AU__c = 'Yes' LIMIT :Utility.queryLimit]) {
                    incomeSummary.put(incomeRec.Contact__c,incomeRec);
                }
            }
            if (contactId != null && contactId.size() > 0) {
                FieldLevelSecurity.checkFieldAccessByCriteria(' Market_Value__c, Contact__c','view','Asset__c', Boolean.valueOf(Label.HasNamespace));
                
                for (Asset__c asset : [SELECT Id, Market_Value__c, Contact__c FROM Asset__c WHERE Contact__c IN :contactId LIMIT :Utility.queryLimit]) {
                    assetRec.add(asset);
                }
            }
            
            if (servicecaseIdList != null && servicecaseIdList.size() > 0) {
                FieldLevelSecurity.checkFieldAccessByCriteria(' Name, Service_Case__c, Court_Order_Date__c','view','Court__c', Boolean.valueOf(Label.HasNamespace));
                
                for (Court__c courtRec : [SELECT Id, Name, Service_Case__c, Court_Order_Date__c
                                          FROM Court__c WHERE  Petition_for_Child__c =: titleIvERecList[0].Placement__r.Child__c AND Service_Case__c IN :servicecaseIdList ORDER BY createdDate DESC LIMIT :Utility.queryLimit]) {
                                              if (!titleCourtMap.containsKey(courtRec.Service_Case__c)) {
                                                  titleCourtMap.put(courtRec.Service_Case__c, courtRec);
                                              }
                                          }
            } 
            List<Title_Iv_E__c> reqTitleEligibleRecList = new List<Title_Iv_E__c>();
            List<Api_Request__c> apiRequestRecList = new List<Api_Request__c>();
            
            for (Title_Iv_E__c titleIvERec : titleIvERecList) {
                
                String orderType;
                String depParentalSupp='';
                String deprivationFactor='';
                Integer familySize =0;
                Double totalAvailableIncome =0;
                Double assetValue =0;
                
                String placementReimbursable;
                if(titleIVERec.Placement__c != NULL) {
                	placementReimbursable = titleIVERec.Placement__r.PlacementReimbursable__c ;
                } else {
                    placementReimbursable = NULL;
                }
                String remDtEarlierThnCtOrderDt;
                String spRelClIdsameAsCtw = 'Yes';
                
                String usCorQA;
                if(titleIVERec.Placement__c != NULL) {
                	usCorQA = titleIvERec.Placement__r.Child__r.Is_a_US_citizen__c;
                } else {
                    usCorQA = NULL;
                }
                String plcmntDtErlThnRemDtr;
                String childReceivingSSIOrSSADuringReviewPeriod = titleIvERec.child_receive_SSI_SSA_during_review__c;
                String hasTheAgencyOptedToSuspendTheSSIPAymentAndClaimIVE = titleIvERec.Agency_opted_to_suspend_SSI_claim_IV_E__c;
                String isTheAgencyTheRepresentativePayee = titleIvERec.IsThe_Agency_TheRepresentativePayee__c;
                Integer ageDuringAFDCmonth;
                
                if(titleIvERec.Placement__c != NULL && titleIvERec.Placement__r.Child__r.Date_of_Birth__c != NULL) {
                        
                        Integer days = titleIvERec.Placement__r.Child__r.Date_of_Birth__c.daysBetween(titleIvERec.Review_Period_Start_Date__c);
        				ageDuringAFDCmonth = Integer.valueOf(days/365);
                } else {
                    	ageDuringAFDCmonth=null;
                }
                if (titleIvERec.Placement__c != NULL && (titleIvERec.Placement__r.Child__r.Is_a_US_citizen__c =='Yes' || titleIvERec.Placement__r.Child__r.Alien_Status__c =='Yes')) {
                    usCorQA = 'Yes';
                } else {
                    usCorQA = 'No';
                }
                
                if (titleIvERec.Child_Removal__r.Removal_Type__c == 'Judicial Determination') {
                    orderType = 'courtorder';
                } else {
                    orderType = 'vpa';
                }
                
                List<Id>Ids = new List<Id>();
                /*for(Contact Rec : titleChild) {
                    
                    if (Rec.Service_Case__c == titleIvERec.Service_Case__c) {
                        
                        familySize = familySize + 1;
                        Ids.add(Rec.Id);
                    }
                }*/
                
                for( Id recId : Ids) {
                    if(incomeSummary.get(recId) != NULL) {
                        if(incomeSummary.get(recId).Monthly_Income__c != NULL) {
                            totalAvailableIncome+=incomeSummary.get(recId).Monthly_Income__c;
                        }
                    }
                }
                
                for( Id recId : Ids) {
                    for(Asset__c asset : assetRec) {
                        if(asset.Contact__c == recId) {
                            assetValue+=asset.Market_Value__c;
                        }
                    }
                }
                
                if(titleIvERec.Deprivations__r.size() > 0){
                    
                    depParentalSupp = titleIvERec.Deprivations__r[0].Child_deprived_of_parental_support__c;
                } 
                
                if(titleIvERec.Deprivations__r.size() > 0){
                    
                    deprivationFactor = titleIvERec.Deprivations__r[0].Deprivation_factor__c;
                } 
                if (titleCourtMap.containsKey(titleIvERec.Service_Case__c) && titleCourtMap.get(titleIvERec.Service_Case__c) != null) {
                    Court__c courtRec = titleCourtMap.get(titleIvERec.Service_Case__c);
                    if (courtRec.Court_Order_Date__c > Date.valueOf(titleIvERec.Child_Removal__r.Removal_Date_of_DT_F__c)) {
                        remDtEarlierThnCtOrderDt = 'Yes';
                    } else {
                        remDtEarlierThnCtOrderDt = 'No';
                    }
                } 
                
                if (titleIvERec.Placement__c != NULL && (Date.valueOf(titleIVERec.Placement__r.Begin_Date__c) < Date.valueOf(titleIVERec.Child_Removal__r.Removal_Date_of_DT_F__c))) {
                    plcmntDtErlThnRemDtr = 'Yes';
                } else {
                    plcmntDtErlThnRemDtr = 'No';
                }      
                Title_Iv_E__c reqTitleEligibleRec = EligibilityApiCallout.makeCallout(titleIvERec.Id, orderType, remDtEarlierThnCtOrderDt, spRelClIdsameAsCtw, usCorQA, ageDuringAFDCmonth, depParentalSupp, deprivationFactor, familySize, totalAvailableIncome, assetValue, placementReimbursable, plcmntDtErlThnRemDtr, childReceivingSSIOrSSADuringReviewPeriod, hasTheAgencyOptedToSuspendTheSSIPAymentAndClaimIVE ,isTheAgencyTheRepresentativePayee);
                Api_Request__c apiEligibleRequestRec = createApiRequest(titleIvERec.Id, orderType, remDtEarlierThnCtOrderDt, spRelClIdsameAsCtw, usCorQA, ageDuringAFDCmonth, depParentalSupp, deprivationFactor, familySize, totalAvailableIncome, assetValue, placementReimbursable, plcmntDtErlThnRemDtr, childReceivingSSIOrSSADuringReviewPeriod, hasTheAgencyOptedToSuspendTheSSIPAymentAndClaimIVE ,isTheAgencyTheRepresentativePayee);
                if(apiEligibleRequestRec != NULL){
                    apiRequestRecList.add(apiEligibleRequestRec);

                }
                if (reqTitleEligibleRec != NULL) {
                    reqTitleEligibleRecList.add(reqTitleEligibleRec);
                }
            	}
            if(reqTitleEligibleRecList != NULL && reqTitleEligibleRecList.size() > 0) {
                insert reqTitleEligibleRecList;
            }
            if(apiRequestRecList != NULL && apiRequestRecList.size() > 0) {
                insert apiRequestRecList;
            }
            
        }          
    }
    @AuraEnabled
    public static Void updateTitleIveRec(string titleIVId) {
        
        if(String.isNotBlank(titleIVId)) {
            
            FieldLevelSecurity.checkFieldAccessByCriteria('First_Time_Redetermination__c','update','Title_Iv_E__c', Boolean.valueOf(Label.HasNamespace));
            
            Title_Iv_E__c titleIveRec = new Title_Iv_E__c();
            titleIveRec.Id = titleIVId;
            titleIveRec.First_Time_Redetermination__c = '';
            update titleIveRec;
            
        }
    }
    
    public static Api_Request__c  createApiRequest(String titleIveid, String orderType, String remDtEarlierThnCtOrderDt ,String spRelClIdsameAsCtw,String usCorQA ,Integer ageDuringAFDCmonth, String depParentalSupp,String deprivationFactor,Integer familySize ,Double totalAvailableIncome, Double assetValue,String placementReimbursable, String plcmntDtErlThnRemDtr, String childReceivingSSIOrSSADuringReviewPeriod, String hasTheAgencyOptedToSuspendTheSSIPAymentAndClaimIVE, String isTheAgencyTheRepresentativePayee) {
        
	    Api_Request__c  apiRequestRec = new Api_Request__c ();
        
        apiRequestRec.AgeDuringAFDCmonth__c  = ageDuringAFDCmonth;
        apiRequestRec.AssetValue__c   = assetValue;
        apiRequestRec.ChildReceivingSSIOrSSADuringReviewPeriod__c   = childReceivingSSIOrSSADuringReviewPeriod;
        apiRequestRec.DepParentalSupp__c   = depParentalSupp;
        apiRequestRec.DeprivationFactor__c   = deprivationFactor;
        apiRequestRec.FamilySize__c   = familySize;
        apiRequestRec.HasTheAgencyOptedToSuspendTheSSIPAymentA__c   = hasTheAgencyOptedToSuspendTheSSIPAymentAndClaimIVE;
        apiRequestRec.IsTheAgencyTheRepresentativePayee__c   = isTheAgencyTheRepresentativePayee;
        apiRequestRec.Order_Type__c   = orderType;
        apiRequestRec.Placement_Reimbursable__c   = placementReimbursable;
        apiRequestRec.PlcmntDtErlThnRemDtr__c   = plcmntDtErlThnRemDtr;
        apiRequestRec.RemDtEarlierThnCtOrderDt__c   = remDtEarlierThnCtOrderDt;
        apiRequestRec.Title_Iv_E__c    = titleIveid;
        apiRequestRec.TotalAvailableIncome__c   = totalAvailableIncome;
        apiRequestRec.UsCorQA__c   = usCorQA;
        
        return apiRequestRec;
    }
    
    
    
    public class searchTitleIVEIns {
        
        @AuraEnabled
        public String clientId;
        @AuraEnabled
        public String firstName;
        @AuraEnabled
        public String lastName;           
        @AuraEnabled
        public Date removalDate;
        @AuraEnabled
        public String eligibleStatus;
        @AuraEnabled 
        public String country;
    }
    
    public class titleIvETableInstance {
        @AuraEnabled
        public String titleIVEId;
        @AuraEnabled
        public String childName;
        @AuraEnabled
        public String clientId;
        @AuraEnabled
        public String caseNumber;
        @AuraEnabled 
        public String childAgency;
        @AuraEnabled
        public String childJurisdication;
        @AuraEnabled
        public DateTime removalDate;
        @AuraEnabled
        public String physicalAddress;
        @AuraEnabled
        public String provider;
        @AuraEnabled 
        public String address;
        @AuraEnabled
        public String placement;
        @AuraEnabled
        public String providerType;
        @AuraEnabled
        public DateTime DOB;
        @AuraEnabled
        public String removalAge;
        @AuraEnabled
        public String assignedTo;
        @AuraEnabled
        public String assignmentStatus;
        @AuraEnabled
        public String eligibleStatus;
        @AuraEnabled
        public Decimal reviewPeriod;
        @AuraEnabled
        public List<Utility.pickListWrap> childReceiveSSIPickList;
        @AuraEnabled
        public List<Utility.pickListWrap> financialInformationPickList;
        @AuraEnabled
        public Title_Iv_E__c titleIVERec;
        @AuraEnabled
        public DateTime placementStartDate;
        @AuraEnabled
        public Date placementEndDate;
        @AuraEnabled
        public List<Income_Summary__c> incomeSummaryList;
        @AuraEnabled
        public List<Person_Incomes__c> personIncomeList;
        @AuraEnabled
        public List<Utility.pickListWrap> inAu;
        @AuraEnabled
        public Decimal childAge;
        @AuraEnabled
        public String usCitizen;
        @AuraEnabled
        public List<Utility.pickListWrap> eligibleStatusPicklist;
        @AuraEnabled
        public List<Title_Iv_E__c> titleIVERecList;
        @AuraEnabled 
        public String childId;
    }
    
    public class titleIvEDeprivationPicklist {
        @AuraEnabled
        public List<Utility.pickListWrap> deprivationFactor;
        @AuraEnabled
        public List<Utility.pickListWrap> childdeprivedpicklist;
        @AuraEnabled
        public List<Utility.pickListWrap> reasonforAbsence;
        @AuraEnabled
        public List<Person__c> parentPicklist;
    }

    public class titleIvELegalDetails {
        @AuraEnabled
        public Court__c courtRecord;
        @AuraEnabled
        public List<Court_Petition_Hearing__c> courtPetitionHearingList;
        
    }
    
}