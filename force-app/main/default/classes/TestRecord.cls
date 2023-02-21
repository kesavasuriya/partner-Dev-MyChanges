public class TestRecord {
    
    public static Referral__c createPrivateReferral(Id providerName, String firstName, String lastName, Id orgName) {
        
        Referral__c createRefferralRec = new Referral__c();
        createRefferralRec.Type__c = 'CPA Home';
        createRefferralRec.Applicant_First_Name__c  = firstName;
        createRefferralRec.Applicant_Last_Name__c = lastName;
        createRefferralRec.CPA_Office_ID__c = providerName;
        createRefferralRec.Organization_Site_Name__c = orgName;
        return createRefferralRec;
        
    }
    
    public static Referral__c createPublicReferral(String firstName, String lastName) {
        
        Referral__c createRefferralRec = new Referral__c();
        createRefferralRec.Applicant_First_Name__c = firstName;
        createRefferralRec.Applicant_Last_Name__c = lastName;
        createRefferralRec.Type__c = 'Local Department Home';
        createRefferralRec.Applicant_Date_of_Birth__c = date.newInstance(2000,4,29);
        createRefferralRec.Tax_Id__c = '000-11-2222';
        createRefferralRec.Tax_Id_Type__c = 'SSN';
        return createRefferralRec;     
    }
    
    public static Account createProvider(String firstName, String lastName, String name) {
        
        Account providerRec = new Account();
        providerRec.Individual_First_Name__c = firstName;
        providerRec.Individual_Last_Name__c = lastName;
        providerRec.Local_Department__c = 'Baltimore City';
        providerRec.Name = name;
        providerRec.Child_Characteristics_Willing_To_Accept__c = 'Aggression - Cruelty To Animals';
        providerRec.Individual_Middle_Name__c = 'User';
        providerRec.Local_Department__c = 'Baltimore City';        
        return providerRec;
              
    }
    
    public static Contact contact(String firstName , String lastName) {
        
        Contact createContact = new Contact();
        createContact.LastName = lastName;
        createContact.FirstName = firstName;
        createContact.Date_of_Birth__c = date.newInstance(2000,4,29);
        createContact.Is_a_US_citizen__c = 'Yes';
        createContact.Gender__c = 'Male';
        createContact.Known_danger_at_address__c ='No';
        createContact.Intake_Person_Role__c = 'Biological Child'; 
        return createContact;
         
    }
    
    public static Assessment__c assessment(String AssessmentType, String SAFECHeadofHousehold) {
        
        Assessment__c assessment = new Assessment__c();
        assessment.SAFEC_Legal_Guardian_Name__c = 'Test Demo';
        assessment.Assessment_Type__c = AssessmentType;
        assessment.SAFEC_Head_of_Household__c = SAFECHeadofHousehold;
        return assessment;
    }
    
    public static Service_Case__c  serviceCase(string serviceCaseName) {
        
        Service_Case__c  createCase = new Service_Case__c ();
        return createCase;
           
    }
    
    public static Investigation__c investigation() {
        
        Investigation__c createInvestigation = new Investigation__c();
        return createInvestigation;
       
    }
    
    public static Child_Removal__c childRemoval(Id childName) {
        
        Child_Removal__c createChildRemoval = new Child_Removal__c();
        createChildRemoval.Child__c = childName;
        createChildRemoval.Removal_Type__c = 'Judicial Determination';
        createChildRemoval.Family_Structure__c = 'Single Male';
        createChildRemoval.Where_is_the_child_going_to__c = 'Agency Foster Home';
        createChildRemoval.Child_Home_Address_Same_as_Primary_Addre__c = 'Yes';
        createChildRemoval.Factor_At_Removal__c = 'Death of Parent(s)';
        createChildRemoval.Reasonable_efforts_made_to_prevent_child__c = 'Day Care';
        return createChildRemoval;
    }
    
    public static Placement__c placement(Id childRemoval) {
        
        Placement__c createPlacement = new Placement__c();
        createPlacement.Is_Placement_Reimbursible__c = 'Assigned dynamically';
        createPlacement.Child_Removal__c = childRemoval;
        return createPlacement;    
    }
    
    public static Title_Iv_E__c titleIvE(Id childremoval, Id placement, Id servicecase) {
        
        Title_Iv_E__c titleIVERec = new Title_Iv_E__c();
        titleIVERec.Eligible_Status__c = 'Pending';
        titleIVERec.Placement__c = placement;
        titleIVERec.Service_Case__c = servicecase;
        titleIVERec.Child_Removal__c = childremoval;
        return titleIVERec;   
    }
    
    public static Court__c petition(Id childId) {
        
        Court__c rec = new Court__c();
        rec.Type_of_Petition__c = 'Adoption';
        rec.Petition_for_Child__c = childId;
        rec.Petition_Date__c = date.newInstance(2021, 5, 5);
        return rec; 
    }
    
    public static Permanency_Plan__c permanencyPlan() {
        
        Permanency_Plan__c createPermanencyPlan = new Permanency_Plan__c();
        createPermanencyPlan.Name = 'test';
        return createPermanencyPlan;
        
    }
    
    public static Court_Petition_Hearing__c createCourtCase(string caseNo){
        
        Court_Petition_Hearing__c createCase = new Court_Petition_Hearing__c();
        createCase.Court_Case_Number__c = caseNo;
        createCase.Start_Date__c = date.newInstance(2021, 05, 05);
        return createCase;  
    }
    
    public static Court__c createPetition(string childName,string petitionId){
        
        Court__c createPetition = new Court__c();
        createPetition.Petition_for_Child__c = childName;
        createPetition.Type_of_Petition__c = 'Adoption';
        createPetition.Petition_Date__c = date.newInstance(2021, 05, 05);
        createPetition.Court_Petition_ID__c = petitionId;
        return createPetition;
    }
    
    public static Program_Assignment__c createprogramAssignment() {
        
        Program_Assignment__c programRec = new Program_Assignment__c();
        programRec.Is_Child_an_IFPS_At_Risk_child__c = 'None';
        programRec.Program_Area__c = 'Independent Living';
        programRec.Reason_for_End__c = 'None'; 
        programRec.Start_Date__c = date.newInstance(2021, 04, 05);
        programRec.End_Date__c = date.newInstance(2021, 05, 05);
        return programRec;
    }
    
    public static Case createIntake() {
        
        Case caseObj = new Case();
        caseObj.Origin = 'Child Protective Services';
        caseObj.Communication__c = 'Face to Face';
        caseObj.Jurisdiction__c = 'Anne Arundel';
        caseObj.Received_Date__c = Date.newInstance(2019, 12, 1);
        caseObj.Status = 'Open';
        caseObj.First_Name__c = 'test';
        caseObj.Last_Name__c = 'test';
        caseObj.Role__c = 'Child day care provider';
        caseObj.Description = 'test';
        caseObj.Comments__c = 'test';
        caseObj.Intake_Recommendations__c = 'Screen In';
        return caseObj;
    }
    
    public static Relationship__c createRelationship() {
        
        Relationship__c relationship = new Relationship__c();
        relationship.Person_Involved_Relationship__c = 'Father';
        return relationship;
    }
    
    public static SDM__c createSDM() {
        
        SDM__c sdm = new SDM__c();
        sdm.The_unreasonable_delay__c = true;
        return sdm;
    }
    
    public static Legal_Custody__c createLegal() {
        
        Legal_Custody__c  legal = new Legal_Custody__c();
        legal.Begin_Date__c  = Date.newInstance(2019, 12, 1);
        return legal;
    }
    
    public static Suspension__c createSuspension() {
        
        Suspension__c suspension = new Suspension__c();
        suspension.Start_Date__c = System.today();
        return suspension;
    }
    
    public static Annual_Review__c createAnnualReview() {
        
        Annual_Review__c annualReview = new Annual_Review__c();
        annualReview.Review_Date__c = System.today();
        return annualReview;
        
    }
    
    public static Rate__c createRate() {
        
        Rate__c rate = new Rate__c();
        return rate;
    }
    
    public static Investigation_Findings__c createInvestigationFinding() {
        
        Investigation_Findings__c createRec = new Investigation_Findings__c();
        createRec.Victim_Name__c = 'test';
        createRec.Maltreatment_Type__c = 'demo';
        return createRec;   
        
    }
    
    public static Maltreatment_Allegation__c MaltreatmentRec(Id childId) {
        
        Maltreatment_Allegation__c rec = new Maltreatment_Allegation__c();
        rec.Child__c = childId;
        rec.Name = 'new';
        return rec;
    }
    
    public static Structure_Services__c createStructureService(Id accId) {
        
        Structure_Services__c rec = new Structure_Services__c ();
        rec.Placement_Structure_Service__c ='Placement Structure';
        rec.Provider__c = accId;
        rec.Start_Date__c = date.newInstance(2021, 05, 07);
        rec.Structure_Service_Name__c = '1_Independent Living Residential Program';
        return rec;
    }
    
    public static Home_Approval__c createHomeApproval(Id accId) {
        
        Home_Approval__c rec = new Home_Approval__c();
        rec.Client_ID__c='000123';
        rec.Provider__c = accId;
        return rec;
        
    }
    
    public static Assessment_Visit__c createassessmentVist(Id homeId) {
        
        Assessment_Visit__c rec = new Assessment_Visit__c();
        rec.Home_Approval__c = homeId;
        return rec;
    }
    
     
    public static Household__c createHouseHold(Id homeId) {
        
        Household__c rec = new Household__c();
        rec.Home_Approval__c = homeId;
        return rec;
    }
    
    public static Pet__c createPet(Id homeId) {
        
        Pet__c rec = new Pet__c();
        rec.Home_Approval__c = homeId;
        return rec;
    }
    
    public static Reference__c createReference(Id homeId) {
        
        Reference__c rec = new Reference__c();
        rec.Home_Approval__c = homeId;
        return rec;
    }
    
    public static Child_Evaluations__c createChildEvaluations(Id homeId) {
        
        Child_Evaluations__c rec = new Child_Evaluations__c();
        rec.Home_Approval__c = homeId;
        return rec;
    }
    
    public static Backup__c createBackup(Id homeId) {
        
        Backup__c rec = new Backup__c();
        rec.Home_Approval__c = homeId;
        return rec;
    }
    
    public static Relationship__c  createRelationship(String person,String personRelatedTo) {
        
        Relationship__c rec = new Relationship__c();
        rec.Person__c  = person;
        rec.Person_Related_To__c   = personRelatedTo;
        rec.Relationship_Values__c = 'Biological Child';
        return rec;
    }   
    
    public static Service_Case_History__c createServiceCaseHistory(Id serviceCaseId) {
        
        Service_Case_History__c historyRec = new Service_Case_History__c();
        historyRec.Service_Case__c = serviceCaseId;
        return historyRec;
    }
    
    public static CPA_home__c createCPAHome(Id providerId) {
        
        CPA_home__c cpaHomeRec = new CPA_home__c();
        cpaHomeRec.Provider__c = providerId;
        cpaHomeRec.Effective_End_Date__c = Date.today();
        return cpaHomeRec;
    }
    
    public static Collateral__c createCollateral() {
        
        Collateral__c collateralRec = new Collateral__c();
        collateralRec.First_Name__c = 'Test';
        collateralRec.Middle_Name__c = 'Person';
        collateralRec.Last_Name__c = 'Collateral';
        collateralRec.Date_of_Birth__c = Date.newInstance(2000,4,29);
        collateralRec.Role__c = 'Social Worker';
        return collateralRec;
    }
    
    public static Visitation_Log__c createVisitationLog() {
        
        Visitation_Log__c visitationLogRec = new Visitation_Log__c();
        visitationLogRec.Visit_Date__c = Date.newInstance(2022,4,29);
        return visitationLogRec;
    }
    
    public static Service_Plan__c createServicePlan() {
        
        Service_Plan__c servicePlanRec = new Service_Plan__c();
        servicePlanRec.Start_Date__c =  Date.newInstance(2022,4,29);
        servicePlanRec.Target_End_Date__c = Date.newInstance(2022,5,29);
        return servicePlanRec;
    }
    
    public static Visitation_Plan__c createVisitationPlan() {
        
        Visitation_Plan__c visitationPlanRec = new Visitation_Plan__c();
        visitationPlanRec.Established_Date__c = Date.newInstance(2022,4,29);
        return visitationPlanRec;
    }
    
    public static Goal__c createGoal() {
        
        Goal__c goalRec = new Goal__c();
        goalRec.Goals__c = 'Youth are first and foremost protected from abuse and neglect';
        goalRec.Status__c = 'In Progress';
        return goalRec;
    }
    
    public static Objective__c createObjective() {
        
        Objective__c objectiveRec = new Objective__c();
        objectiveRec.Objective__c = 'Test';
        objectiveRec.Status__c = 'Achieved';
        return objectiveRec;
    }
    
    public static Goal_Action__c createGoalAction() {
        
        Goal_Action__c goalActionRec = new Goal_Action__c();
        goalActionRec.Name = 'Test';
        goalActionRec.Status__c = 'In Progress';
        goalActionRec.Start_Date__c = Date.newInstance(2022,4,29);
        goalActionRec.End_Date__c =  Date.newInstance(2022,5,29);
        return goalActionRec;
    }
    
    public static Service_Plan_Version__c createServicePlanVersion() {
        
        Service_Plan_Version__c servicePlanReVersionRec = new Service_Plan_Version__c();
        servicePlanReVersionRec.Start_Date__c = Date.newInstance(2022,4,29);
        servicePlanReVersionRec.End_Date__c = Date.newInstance(2022,5,29);
        return servicePlanReVersionRec;
    }
    
    public static Case_Plan__c createCasePlan(string placementId) {
        
        Case_Plan__c casePlanRec = new Case_Plan__c();
        casePlanRec.Placement__c = placementId;
        return casePlanRec;
    }
    
    public static Medication_Including_Psychotropic__c createMedication(string personId) {
        
        Medication_Including_Psychotropic__c medicationRec = new Medication_Including_Psychotropic__c();
        medicationRec.Contact__c  = personId;
        return medicationRec;
    }
    
    public static Notes__c createNotes(string personInvolved) {
        
        Notes__c notesRec = new Notes__c();
        notesRec.Contact_Type__c = 'Face to Face';
        return notesRec;
    }
    
    public static Youth_Transition_Plan__c createYouthTransitionPlan(string personId) {
        
        Youth_Transition_Plan__c youthTransPlanRec = new Youth_Transition_Plan__c();
        youthTransPlanRec.Contact__c  = personId;
        return youthTransPlanRec;
    }
    
    public static Service_Plan__c createServicePlan(string servicecase) {
        
        Service_Plan__c  servicePlanRec = new Service_Plan__c ();
        servicePlanRec.Service_Case__c  = servicecase;
        return servicePlanRec;
    }
    
    public static Candidacy__c createCandidacy(string person, string servicePlan) {
        
        Candidacy__c candidacyRec = new Candidacy__c  ();
        candidacyRec.Child_Name__c  = person;
        candidacyRec.Service_Plan__c = servicePlan;
        return candidacyRec;
    }
    
    public static Person_Incomes__c createPersonIncome(string person) {
        
        Person_Incomes__c  personIncomeRec = new Person_Incomes__c   ();
        personIncomeRec.Contact__c  = person;
        personIncomeRec.Monthly_Income__c = 5000;
        personIncomeRec.Income_Source__c = 'Child Support';
        personIncomeRec.Verification__c = 'Benefits Statement';
        return personIncomeRec;
    }
    
    public static Asset__c createAsset(string person) {
        
        Asset__c  assetRec = new Asset__c   ();
        assetRec.Contact__c  = person;
        assetRec.Face_Value__c = 3000;
        assetRec.Market_Value__c = 100;
        return assetRec;
    }
    
    public static Examination__c createExamination(string person, string natureofExam) {
        
        Examination__c   examRec = new Examination__c    ();
        examRec.Contact__c  = person;
        examRec.Nature_of_Exam__c = natureofExam;
        examRec.Provider_Info_available__c = 'No';
        examRec.Appointment_Date__c = Date.today();
        return examRec;
    }
    
    public static Education__c createEducation(string person) {
        
        Education__c educationRec = new Education__c    ();
        educationRec.Contact__c  = person;
        return educationRec;
    }
    
    public static Meeting__c createMeeting() {
        
        Meeting__c meetingRec = new Meeting__c ();
        return meetingRec;
    }
    
    public static Court__c createCourt() {
        
        Court__c courtRec = new Court__c();
        courtRec.Child_s_Home_Is_Contrary__c = true;
        courtRec.Child_s_Home__c = true;
        courtRec.Hearing_Outcome__c = 'Adoption Denied';
        courtRec.Court_Order_Details__c = 'Test';
        return courtRec;
    }
    
    public static Income_Summary__c  createIncomeSummary(Id titleIVE, Id person) {
        
        Income_Summary__c incomeSummaryRec = new Income_Summary__c ();
        incomeSummaryRec.Contact__c = person;
        incomeSummaryRec.Title_Iv_E__c = titleIVE;
        return incomeSummaryRec;
    }
    
    public static Deprivation__c createDeprivation(Id titleIVE, Id person) {
        
        Deprivation__c  deprivationRec = new Deprivation__c  ();
        deprivationRec.Title_Iv_E__c = titleIVE;
        deprivationRec.Parent__c = person;
        return deprivationRec;
    }
   
}