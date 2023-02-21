Public with sharing class IntakeCustomController {  
    
    public static String orgNamespacePrefix = Utility.getNamespacePrefix();

    @AuraEnabled
    public static void updateIntake(String updatingIntakeJSONStr) {
    
        if (String.isNotBlank(updatingIntakeJSONStr)) {   
            
            try {
                Case  caseRecIns = (Case)JSON.deserialize(updatingIntakeJSONStr, Case.class);
                FieldLevelSecurity.checkFieldAccessByCriteria('CPS_History_Clearance__c, In_Home_Services__c, Private_Adoption_Subsidy__c,'+
                                                                'ICPC__c, ASCRS_Adpotion_Search_Contact__c, ICAMA__c,'+ 
                                                                'Author__c, contact__c, Restrict_UnRestrict__c, Agency__c, Communication__c,'+
                                                                'Origin, Received_Date__c, Jurisdiction__c, Voluntary_Placement__c,Voluntary_Placement_Type__c,'+
                                                                'Job_Search__c,Environmental_Emergency_Ass__c,Environmental_Emergency_Assistance_Aged__c,'+
                                                                'Parental_Stress__c,Foster_Care_Provider_Interest__c,Other__c,I_R_Non_Aged__c,Worker_Assigned__c,'+
                                                                'Clothing__c,Rental_Assistance__c,Shelter__c,Custody_Issuses__c,I_R_Aged__c,Legal_Issues__c,'+
                                                                'Environmental_Emergency_Assistance_Non__c,Food__c,FIP_Family_Investment_Center__c,'+
                                                                'To_Be_A_Volunteer__c,Uncontrollable_Child__c,Kinship_Information__c,WIC__c,Crisis_Intervention__c,'+
                                                                'Child_Support__c,Housing__c,Health_Need__c,Substance_Abuse__c,Adaption_Interst__c,Day_Care__c,'+
                                                                'I_R_Family__c,MEAP__c,Domestic_Volence__c,Telephone_Number__c,Mental_Health_Need__c,'+
                                                                'Request_of_Other_Agency__c,Services_to_Family_and_Children__c,Interagency_Family_Preservation_Services__c,'+
                                                                'Independent_Living_After_Services__c,Consolidated_Services__c,Request_to_file_a_CINA_Petition__c','update','Case', Boolean.valueOf(Label.HasNamespace));
                update caseRecIns;
            } catch(Exception e) {
            
                throw new AuraHandledException(e.getMessage());
                
            }    
        }
    }    
       
    @AuraEnabled
    public static String getInitialInformation(String intakeId) {
        
        getInitialWrapper initWrap = new getInitialWrapper();
        
        initWrap.communicationPicklist = Utility.getPicklistinfo('Case', 'Communication__c',false);
        initWrap.originPicklist = Utility.getPicklistinfo('Case', 'Origin',false);
        initWrap.jurisdictionPicklist = Utility.getPicklistinfo('Case','Jurisdiction__c',false);
        initWrap.voluntaryPicklist = Utility.getPicklistinfo('Case','Voluntary_Placement_Type__c',false); 
        
        if (String.isNotBlank(intakeId)) {
        
            FieldLevelSecurity.checkFieldAccessByCriteria('CPS_History_Clearance__c, In_Home_Services__c, Private_Adoption_Subsidy__c,'+
                                                            'ICPC__c, ASCRS_Adpotion_Search_Contact__c, ICAMA__c, CaseNumber ,'+ 
                                                            'Author__c, contact__c, Restrict_UnRestrict__c, Agency__c, Communication__c,'+
                                                            'Origin, Received_Date__c, Jurisdiction__c, Voluntary_Placement__c,Voluntary_Placement_Type__c,'+
                                                            'Job_Search__c,Environmental_Emergency_Ass__c,Environmental_Emergency_Assistance_Aged__c,'+
                                                            'Parental_Stress__c,Foster_Care_Provider_Interest__c,Other__c,I_R_Non_Aged__c,Worker_Assigned__c,'+
                                                            'Clothing__c,Rental_Assistance__c,Shelter__c,Custody_Issuses__c,I_R_Aged__c,Legal_Issues__c,'+
                                                            'Environmental_Emergency_Assistance_Non__c,Food__c,FIP_Family_Investment_Center__c,'+
                                                            'To_Be_A_Volunteer__c,Uncontrollable_Child__c,Kinship_Information__c,WIC__c,Crisis_Intervention__c,'+
                                                            'Child_Support__c,Housing__c,Health_Need__c,Substance_Abuse__c,Adaption_Interst__c,Day_Care__c,'+
                                                            'I_R_Family__c,MEAP__c,Domestic_Volence__c,Telephone_Number__c,Mental_Health_Need__c,'+
                                                            'Request_of_Other_Agency__c,Services_to_Family_and_Children__c,Interagency_Family_Preservation_Services__c,'+
                                                            'Independent_Living_After_Services__c,Consolidated_Services__c,Request_to_file_a_CINA_Petition__c','view','Case', Boolean.valueOf(Label.HasNamespace));
            FieldLevelSecurity.checkFieldAccessByCriteria('Name','view','Contact', Boolean.valueOf(Label.HasNamespace));
            initWrap.caseRecIns = [SELECT Id, CPS_History_Clearance__c, In_Home_Services__c, Private_Adoption_Subsidy__c, 
                                    ICPC__c, ASCRS_Adpotion_Search_Contact__c, ICAMA__c, CaseNumber, CreatedDate, 
                                    Author__c,Owner.Name, contact__r.Name, Restrict_UnRestrict__c, Agency__c, Communication__c,
                                    Origin, Received_Date__c, Jurisdiction__c, Voluntary_Placement__c,Voluntary_Placement_Type__c,
                                    Job_Search__c,Environmental_Emergency_Ass__c,Environmental_Emergency_Assistance_Aged__c,
                                    Parental_Stress__c,Foster_Care_Provider_Interest__c,Other__c,I_R_Non_Aged__c,Worker_Assigned__c,
                                    Clothing__c,Rental_Assistance__c,Shelter__c,Custody_Issuses__c,I_R_Aged__c,Legal_Issues__c,
                                    Environmental_Emergency_Assistance_Non__c,Food__c,FIP_Family_Investment_Center__c,
                                    To_Be_A_Volunteer__c,Uncontrollable_Child__c,Kinship_Information__c,WIC__c,Crisis_Intervention__c,
                                    Child_Support__c,Housing__c,Health_Need__c,Substance_Abuse__c,Adaption_Interst__c,Day_Care__c,
                                    I_R_Family__c,MEAP__c,Domestic_Volence__c,Telephone_Number__c,Mental_Health_Need__c,
                                    Request_of_Other_Agency__c,Services_to_Family_and_Children__c,Interagency_Family_Preservation_Services__c,
                                    Independent_Living_After_Services__c,Consolidated_Services__c,Request_to_file_a_CINA_Petition__c
                                    FROM Case WHERE Id = :intakeId LIMIT :Utility.queryLimit];
        }
        return JSON.serialize(initWrap);
    }
    
    public class getInitialWrapper { 
        
        @AuraEnabled
        public List<Utility.pickListWrap> communicationPicklist;
        @AuraEnabled
        public List<Utility.pickListWrap> originPicklist;
        @AuraEnabled
        public List<Utility.pickListWrap> jurisdictionPicklist;
        @AuraEnabled
        public List<Utility.pickListWrap> voluntaryPicklist;  
        @AuraEnabled
        Public Case caseRecIns;     
        
        public getInitialWrapper() {
        
            communicationPicklist = new List<Utility.pickListWrap>();
            originPicklist = new List<Utility.pickListWrap>();
            jurisdictionPicklist = new List<Utility.pickListWrap>(); 
            voluntaryPicklist = new List<Utility.pickListWrap>();
        }
        
        
    }
}