public  with sharing class EligibilityWorksheetCalculation {
    
    @AuraEnabled
    public static void deemedIncomeWorksheet() {
        
        Pagereference pg = Page.Deemed_Income_Worksheet;
    }
    
    public String currentRecordId {get;set;}
    public Title_Iv_E__c titleIvERecord { get; set; }
    public Integer inAuCount { get; set; }
    public Integer notInAuCount{ get; set; }
    public Integer notInAuAmount{ get; set; }
    public Decimal inAuAmountHIII{ get; set; }
    public Decimal inAuAmountHIV{ get; set; }
    public Decimal disRegardAuAmount{ get; set; }
    public Decimal remainingAmountnotInAu{ get; set; }
    public Decimal monthlyGrossIncomeParent{ get; set; }
    public Decimal assetAllowance { get; set; }
    public Decimal marketValue { get; set; }
    public String compareAsset { get; set; }
    public Decimal earnedAsset { get; set; }
    public Decimal unearnedAsset { get; set; }
    public Decimal childSupportPayment { get; set; }
    public Decimal grossIncomeAsset { get; set; }
    public String  compareStepIIIC { get; set; }
    public String  compareStepIVC { get; set; }
    public Decimal stepVB { get; set; }
    public Decimal stepVC { get; set; }
    public Decimal totalAvailableIncome { get; set; }
    public String  compareStepVG { get; set; }
    public Boolean checkedvalue { get; set; }
    public Boolean readValue { get; set; }
    public Boolean SSIYes { get; set; }
    public Boolean SSINo { get; set; }
    public Boolean suspendSSIYes { get; set; }
    public Boolean suspendSSINo { get; set; }
    public Boolean suspendSSINone { get; set; }
    public Boolean PlacementReimbursibleYes { get; set; }
    public Boolean PlacementReimbursibleNo { get; set; }
    public String PlacementOrLiving { get; set; }
    public String providerName { get; set; }
    public String providerType { get; set; }
    public DateTime startDate { get; set; }
    public Date endDate { get; set; }
    public String address { get; set; }
    public Boolean ageYes { get; set; }
    public Boolean ageNo { get; set; }
    public Boolean legalresponsibilityYes { get; set; }
    public Boolean legalresponsibilityNo { get; set; }
    public Boolean ineligible { get; set; }
    public Date dateofBirth { get; set; }
    public Placement__c placementRecord { get; set; }
    public EligibilityWorksheetCalculation() {
        
        readValue = false;
        currentRecordId  = ApexPages.CurrentPage().getparameters().get('id');
        String Responsestatus  = ApexPages.CurrentPage().getparameters().get('status');
        FieldLevelSecurity.checkFieldAccessByCriteria('Name,Child_Removal__c,Service_Case__c, Review_Period_End_Date__c,Review_Period_Start_Date__c,Placement__c', 'view', 'Title_Iv_E__c',  Boolean.valueOf(Label.HasNamespace));
        FieldLevelSecurity.checkFieldAccessByCriteria('Child__c', 'view', 'Child_Removal__c',  Boolean.valueOf(Label.HasNamespace));
        FieldLevelSecurity.checkFieldAccessByCriteria('Name', 'view', 'Contact',  Boolean.valueOf(Label.HasNamespace));
        titleIvERecord   = [SELECT Id, Name, Child_Removal__c, Service_Case__c, Review_Period_End_Date__c, Review_Period_Start_Date__c, Child_Removal__r.Child__r.Name,Placement__c
                            FROM Title_Iv_E__c WHERE  Id=:currentRecordId LIMIT :Utility.queryLimit];
        List<Income_Summary__c>  incomeSummaryRecordInAu = [SELECT Id FROM Income_Summary__c WHERE In_AU__c='Yes' AND Title_Iv_E__c = :currentRecordId LIMIT :Utility.queryLimit];
        inAuCount = incomeSummaryRecordInAu.size();
        List<Income_Summary__c>  incomeSummaryRecordNotInAu = [SELECT ID FROM Income_Summary__c WHERE In_AU__c='No' AND Title_Iv_E__c = :currentRecordId LIMIT :Utility.queryLimit];
        notInAuCount = incomeSummaryRecordNotInAu.size();
        Map<Integer,Integer> scheduleHIII = new Map<Integer,Integer>();
        scheduleHIII.put(1,229);
        scheduleHIII.put(2,404);
        scheduleHIII.put(3,517);
        scheduleHIII.put(4,623);
        scheduleHIII.put(5,721);
        scheduleHIII.put(6,793);
        scheduleHIII.put(7,893);
        scheduleHIII.put(8,981);
        scheduleHIII.put(9,1060);
        scheduleHIII.put(10,1143);
        scheduleHIII.put(11,1226);
        scheduleHIII.put(12,1309);         
        scheduleHIII.put(13,1389);
        scheduleHIII.put(14,1471);
        scheduleHIII.put(15,1556);
        scheduleHIII.put(16,1638);
        
        if(notInAuCount >= 16 && notInAuCount != 0 ) {
            
            notInAuAmount = scheduleHIII.get(notInAuCount);
        } else if(notInAuCount != 0) {
            
            Integer Amount = scheduleHIII.get(16);
            Integer size = notInAuCount-16;
            notInAuAmount = (size*85)+Amount;
        } else {
            
            notInAuAmount = 0;
        }   
        FieldLevelSecurity.checkFieldAccessByCriteria('Contact__c', 'view', 'Income_Summary__c',  Boolean.valueOf(Label.HasNamespace));
        List<Income_Summary__c> ids = [SELECT Contact__c  FROM Income_Summary__c WHERE Title_Iv_E__c =:currentRecordId LIMIT :Utility.queryLimit];
        set<Id>contactIds = new set<Id>();
        
        for(Income_Summary__c a : ids) {
            
            contactIds.add(a.Contact__c);
        }
        FieldLevelSecurity.checkFieldAccessByCriteria('Monthly_Income__c', 'view', 'Person_Incomes__c',  Boolean.valueOf(Label.HasNamespace));
        List<Person_Incomes__c >monthlyIncomeList = [SELECT Id, Monthly_Income__c FROM Person_Incomes__c 
                                                     WHERE Contact__c = :contactIds AND Contact__r.Intake_Person_Role__c  INCLUDES('Adoptive Parent','Biological Parent','Foster Parent') LIMIT :Utility.queryLimit];
        monthlyGrossIncomeParent = 0;
        
        for(Person_Incomes__c a:monthlyIncomeList) {
            
            monthlyGrossIncomeParent+= a.Monthly_Income__c;
        }
        if(monthlyGrossIncomeParent !=0) {
            
            disRegardAuAmount = monthlyGrossIncomeParent - 75;
            remainingAmountnotInAu = disRegardAuAmount - notInAuAmount;
        } else {
            
            disRegardAuAmount = 0;
            remainingAmountnotInAu = 0;
        }
        assetAllowance = 10000;
        marketValue = 0;
        
        if(marketValue > assetAllowance) {
            
            compareAsset = 'Yes';  
        } else {
            
            compareAsset = 'No';  
        }
        earnedAsset = 0;
        unearnedAsset = 0;
        childSupportPayment = 50;
        
        if(earnedAsset != 0 || unearnedAsset !=0) {
            
            grossIncomeAsset = (earnedAsset + unearnedAsset) - childSupportPayment;
        } else {
            
            grossIncomeAsset = 0;
        }
        
        Map<Integer,Integer> scheduleHIV = new Map<Integer,Integer>();
        scheduleHIV.put(1,424);
        scheduleHIV.put(2,747);
        scheduleHIV.put(3,956);
        scheduleHIV.put(4,1153);
        scheduleHIV.put(5,1334);
        scheduleHIV.put(6,1467);
        scheduleHIV.put(7,1652);
        scheduleHIV.put(8,1815);
        scheduleHIV.put(9,1961);
        scheduleHIV.put(10,2115);
        scheduleHIV.put(11,2268);
        scheduleHIV.put(12,2422);         
        scheduleHIV.put(13,2570);
        scheduleHIV.put(14,2721);
        scheduleHIV.put(15,2879);
        scheduleHIV.put(16,3030);
        
        if(inAuCount >= 16 && inAuCount != 0 ) {
            
            inAuAmountHIV = scheduleHIV.get(inAuCount);
            inAuAmountHIII = scheduleHIII.get(inAuCount);
        } else if(inAuCount != 0) {
            
            Integer AuCountAmountHIV = scheduleHIV.get(16);
            Integer sizeAuCountHIV = inAuCount - 16;
            inAuAmountHIV = (sizeAuCountHIV * 157) + AuCountAmountHIV;
            Integer AuCountAmountHIII = scheduleHIII.get(16);
            Integer sizeAuCountHIII = inAuCount - 16;
            inAuAmountHIII = (sizeAuCountHIII * 85) + AuCountAmountHIII;
        } else {
            
            inAuAmountHIV = 0;
            inAuAmountHIII = 0;
        }   
        if(grossIncomeAsset > inAuAmountHIV) {
            
            compareStepIIIC = 'Yes';
        } else {
            
            compareStepIIIC = 'No';
            
        }
        if(grossIncomeAsset > inAuAmountHIII) {
            
            compareStepIVC = 'Yes';
        } else {
            
            compareStepIVC = 'No';
        }
        stepVB = 0;
        if(earnedAsset != 0) {
            
            stepVB = earnedAsset - 120;
        } 
        stepVC = 0;
        if(earnedAsset != 0) {
            
            stepVC = earnedAsset - (stepVB / 3);
        }
        if(unearnedAsset !=0) {
            
            totalAvailableIncome = (unearnedAsset - 50) + stepVC;
        } else {
            
            totalAvailableIncome = stepVC;
        }
        
        if(totalAvailableIncome > inAuAmountHIII) {
            
            compareStepVG = 'Yes';
        } else {
            
            compareStepVG = 'No';
        }
        FieldLevelSecurity.checkFieldAccessByCriteria('child_receive_SSI_SSA_during_review__c,Agency_opted_to_suspend_SSI_claim_IV_E__c,Placement__c', 'view', 'Title_Iv_E__c',  Boolean.valueOf(Label.HasNamespace));
        FieldLevelSecurity.checkFieldAccessByCriteria('Is_Placement_Reimbursible__c', 'view', 'Placement__c',  Boolean.valueOf(Label.HasNamespace));
        List<Title_Iv_E__c> ssiRecord = [SELECT Id, child_receive_SSI_SSA_during_review__c, Agency_opted_to_suspend_SSI_claim_IV_E__c, Placement__r.Is_Placement_Reimbursible__c  FROM Title_Iv_E__c 
                                         WHERE Id=:currentRecordId LIMIT :Utility.queryLimit];
        if(ssiRecord[0].child_receive_SSI_SSA_during_review__c == 'Yes') {
            SSIYes = true;  
            SSINo = false;   
        } else {
            SSINo = true; 
            SSIYes = false;   
        }
        if(ssiRecord[0].Agency_opted_to_suspend_SSI_claim_IV_E__c == 'Yes'){
            
            suspendSSIYes = true;
            suspendSSINone = false;
            suspendSSINo = false;
            
        } else if(ssiRecord[0].Agency_opted_to_suspend_SSI_claim_IV_E__c == ''){
            
            suspendSSIYes = false;
            suspendSSINone = true;
            suspendSSINo = false;        
        } else {
            
            suspendSSIYes = false;
            suspendSSINone = false;
            suspendSSINo = true;        
        }
        
        if(ssiRecord[0].Placement__r.Is_Placement_Reimbursible__c == 'Yes') {
            PlacementReimbursibleYes = true;  
            PlacementReimbursibleNo = false;   
        } else {
            PlacementReimbursibleNo = true; 
            PlacementReimbursibleYes = false;   
        }
        FieldLevelSecurity.checkFieldAccessByCriteria('Provider__c ,Begin_Date__c,End_Date__c', 'view', 'Placement__c',  Boolean.valueOf(Label.HasNamespace));
        FieldLevelSecurity.checkFieldAccessByCriteria('Name,Type__c,BillingStreet,BillingCity,BillingState,BillingPostalCode,BillingCountry', 'view', 'Account',  Boolean.valueOf(Label.HasNamespace));
        FieldLevelSecurity.checkFieldAccessByCriteria('Age__c,Date_of_Birth__c', 'view', 'Contact',  Boolean.valueOf(Label.HasNamespace));

        Placement__c placementRecord = [SELECT Id, Provider__r.Name, Provider__r.Placement__c,Provider__r.Type__c, Begin_Date__c,
                                        End_Date__c, Provider__r.BillingStreet,Provider__r.BillingCity, Provider__r.BillingState,                              
                                        Provider__r.BillingPostalCode, Provider__r.BillingCountry,Child__r.Age__c,Child__r.Date_of_Birth__c FROM Placement__c 
                                        WHERE Id= :titleIvERecord.Placement__c LIMIT :Utility.queryLimit];
        providerName = placementRecord.Provider__r.Name;
        providerType = placementRecord.Provider__r.Type__c;
        startDate = placementRecord.Begin_Date__c;
        endDate = placementRecord.End_Date__c;
        address = ((placementRecord.Provider__r.BillingStreet != null) ? address+placementRecord.Provider__r.BillingStreet : address);
        address = ((placementRecord.Provider__r.BillingCity != null) ? address+','+placementRecord.Provider__r.BillingCity : address);
        address = ((placementRecord.Provider__r.BillingState != null) ? address+','+placementRecord.Provider__r.BillingState : address);
        address = ((placementRecord.Provider__r.BillingCountry != null) ? address+','+placementRecord.Provider__r.BillingCountry : address);
        address = ((placementRecord.Provider__r.BillingPostalCode != null) ? address+','+placementRecord.Provider__r.BillingPostalCode : address);
        if(placementRecord.Provider__r.Placement__c == true) {
            PlacementOrLiving = 'Placement';
        } else {
            PlacementOrLiving = 'Living';
        }
        if(placementRecord.Child__r.Age__c <= 18) {
            ageYes = true;
            ageNo = false;
        } else {
            ageYes = false;
            ageNo = true;
        }
        List<Court__c> courtRecordList = new List<Court__c>();
        FieldLevelSecurity.checkFieldAccessByCriteria('Hearing_Outcome__c,Service_Case__c', 'view', 'Court__c',  Boolean.valueOf(Label.HasNamespace));
        courtRecordList = [SELECT Hearing_Outcome__c, Service_Case__c FROM Court__c 
                           WHERE Service_Case__c =: titleIvERecord.Service_Case__c LIMIT :Utility.queryLimit];
        Court__c courtRecord = new Court__c();
        if (courtRecordList.size() > 0 && courtRecordList.size() != null)  {
             Integer i = 0;
        	 courtRecord = courtRecordList[i];
        } 
        
        if (courtRecord.Hearing_Outcome__c != null) {
            if(courtRecord.Hearing_Outcome__c == 'Shelter Granted' || courtRecord.Hearing_Outcome__c == 'Commitment to the Agency' || courtRecord.Hearing_Outcome__c == ' Co-commitment to DSS and DHMH' || courtRecord.Hearing_Outcome__c == 'Co-commitment to DSS,DDA,DHMH' || courtRecord.Hearing_Outcome__c == 'Continued Co-Commitment'
               || courtRecord.Hearing_Outcome__c == 'Continued Commitment' || courtRecord.Hearing_Outcome__c == 'Continued Guardianship' || courtRecord.Hearing_Outcome__c == 'Co-commitment to DSS and DDA') {
                   
                   legalresponsibilityYes = true;
                   legalresponsibilityNo = false;
               } else {
                   
                   legalresponsibilityYes = false;
                   legalresponsibilityNo = true;
               }
        }
        if(Responsestatus == 'InEligible') {
            ineligible = true;
        } else {
            ineligible = false;
        }
        dateofBirth = placementRecord.Child__r.Date_of_Birth__c;
    }
}