public with sharing class DocumentsCtrl {

    @AuraEnabled
    public static string getPersons(Id recordId) {
        
        //List<Person__c> persons = [SELECT Id , Person__c FROM Person__c WHERE Service_Case__c = :recordId];
        Set<Id> contactIDS = new Set<Id>();
        for(Person__c personIns : [SELECT Id , Person__c FROM Person__c WHERE Service_Case__c = :recordId]) {
            contactIDS.add(personIns.Person__c);
        }
        return JSON.serialize([SELECT Id, Name, Casevault_PID__c FROM Contact
                                WHERE Id IN :contactIDS ORDER BY Name ASC]);
    }

    @AuraEnabled
    public static string getDocuments(Id recordId) {
        
        DocumentsFolderWrapper initWrap = new DocumentsFolderWrapper();
        if(String.isNotBlank(recordId)) {

            /*if(folderType == 'Profile') {
                return getProfileDocuments(recordId);
            } else if( folderType == 'Health') {
                return getHealthDocuments(recordId);
            } else if( folderType == 'Education') {
                return getEducationDocuments(recordId);
            } else if( folderType == 'Employment') {
                return getEmploymentDocuments(recordId);
            } else if( folderType == 'Life Skills') {
                return getLifeSkillsDocuments(recordId);
            } else if( folderType == 'Finance') {
                return getFinanceDocuments(recordId);
            } else {
                return null;
            }*/
            initWrap.educationDocuments = getEducationDocuments(recordId);
            initWrap.healthDocuments = getHealthDocuments(recordId);
            initWrap.profileDocuments = getProfileDocuments(recordId);
            initWrap.employmentDocuments = getEmploymentDocuments(recordId);
            initWrap.lifeSkillsDocuments = getLifeSkillsDocuments(recordId);
            initWrap.financeDocuments = getFinanceDocuments(recordId);
            
            return 	JSON.serialize(initWrap);

        } else {
            return null;
        }     
        
    }

    public static List<DocumentsWrapper> getEducationDocuments(Id recordId) {

        Set<Id> educationRecordIds = new Set<Id>();
        Map<Id, Education__c> educations = new Map<Id, Education__c>([SELECT Id FROM Education__c WHERE Contact__c = :recordId]);
        educationRecordIds.addAll(educations.keySet());
        return getDocumentDetails(educationRecordIds);

    }

    public static List<DocumentsWrapper> getEmploymentDocuments(Id recordId) {

        Set<Id> employmentRecordIds = new Set<Id>();
        Map<Id, Employment__c> employments = new Map<Id, Employment__c>([SELECT Id FROM Employment__c WHERE Contact__c = :recordId]);
        employmentRecordIds.addAll(employments.keySet());
        return getDocumentDetails(employmentRecordIds);

    }

    public static List<DocumentsWrapper> getLifeSkillsDocuments(Id recordId) {

        Set<Id> lifeSkillRecordIds = new Set<Id>();
        Map<Id, Life_Skills__c> lifeskills = new Map<Id, Life_Skills__c>([SELECT Id FROM Life_Skills__c WHERE Contact__c = :recordId]);
        lifeSkillRecordIds.addAll(lifeskills.keySet());
        return getDocumentDetails(lifeSkillRecordIds);

    }

    public static List<DocumentsWrapper> getFinanceDocuments(Id recordId) {

        Set<Id> financeRecordIds = new Set<Id>();
        Map<Id, Person_Incomes__c> personIncomes = new Map<Id, Person_Incomes__c>([SELECT Id FROM Person_Incomes__c WHERE Contact__c = :recordId]);
        financeRecordIds.addAll(personIncomes.keySet());
        Map<Id, Asset__c> assets = new Map<Id, Asset__c>([SELECT Id FROM Asset__c WHERE Contact__c = :recordId]);
        financeRecordIds.addAll(assets.keySet());
        Map<Id, Child_Support__c> childSupports = new Map<Id, Child_Support__c>([SELECT Id FROM Child_Support__c WHERE Contact__c = :recordId]);
        financeRecordIds.addAll(childSupports.keySet());
        return getDocumentDetails(financeRecordIds);

    }

    public static List<DocumentsWrapper> getProfileDocuments(Id recordId) {

        List<DocumentsWrapper> wrapLst = new List<DocumentsWrapper>();
        for(ContentDocumentLink cdl : [SELECT ContentDocumentId, ContentDocument.FileType, ContentDocument.Title, ContentDocument.CreatedDate, 
                                       ContentDocument.CreatedBy.Name FROM ContentDocumentLink WHERE LinkedEntityId = :recordId ORDER BY ContentDocument.CreatedDate DESC]) {
            
            DocumentsWrapper wrapIns = new DocumentsWrapper();
            wrapIns.docUrl = '/lightning/r/'+cdl.ContentDocumentId + '/view';
            wrapIns.docName = cdl.ContentDocument.Title;
            wrapIns.docType = cdl.ContentDocument.FileType;
            wrapIns.docUploadedDate = cdl.ContentDocument.CreatedDate;
            wrapIns.docUploadedBy = cdl.ContentDocument.CreatedBy.Name;
            wrapLst.add(wrapIns);
        }
        return wrapLst;
    }

    public static List<DocumentsWrapper> getHealthDocuments(Id recordId) {
        
        Set<Id> healthRecordIds = new Set<Id>();
        Map<Id, Examination__c> examinations = new Map<Id, Examination__c>([SELECT Id FROM Examination__c WHERE Contact__c = :recordId]);
        healthRecordIds.addAll(examinations.keySet());
        Map<Id, Birth_NeoNatal_Information__c> birthInfos = new Map<Id, Birth_NeoNatal_Information__c>([SELECT Id FROM Birth_NeoNatal_Information__c WHERE Contact__c = :recordId]);
        healthRecordIds.addAll(birthInfos.keySet());
        Map<Id, Reproductive_Health__c> repHealths = new Map<Id, Reproductive_Health__c>([SELECT Id FROM Reproductive_Health__c WHERE Contact__c = :recordId]);
        healthRecordIds.addAll(repHealths.keySet());
        Map<Id, Hospitalization__c> hospitalizations = new Map<Id, Hospitalization__c>([SELECT Id FROM Hospitalization__c WHERE Contact__c = :recordId]);
        healthRecordIds.addAll(hospitalizations.keySet());
        Map<Id, Immunization__c> immunizations = new Map<Id, Immunization__c>([SELECT Id FROM Immunization__c WHERE Contact__c = :recordId]);
        healthRecordIds.addAll(immunizations.keySet());
        Map<Id, Behavioral_Health_Substance_Use__c> behaviours = new Map<Id, Behavioral_Health_Substance_Use__c>([SELECT Id FROM Behavioral_Health_Substance_Use__c WHERE Contact__c = :recordId]);
        healthRecordIds.addAll(behaviours.keySet());
        Map<Id, Family_History__c> familyHistories = new Map<Id, Family_History__c>([SELECT Id FROM Family_History__c WHERE Contact__c = :recordId]);
        healthRecordIds.addAll(familyHistories.keySet());
        Map<Id, Feeding_Information__c> feedingInfos = new Map<Id, Feeding_Information__c>([SELECT Id FROM Feeding_Information__c WHERE Contact__c = :recordId]);
        healthRecordIds.addAll(feedingInfos.keySet());
        Map<Id, Insurance__c> insurances = new Map<Id, Insurance__c>([SELECT Id FROM Insurance__c WHERE Contact__c = :recordId]);
        healthRecordIds.addAll(insurances.keySet());
        Map<Id, Disease_Conditions__c> diseases = new Map<Id, Disease_Conditions__c>([SELECT Id FROM Disease_Conditions__c WHERE Contact__c = :recordId]);
        healthRecordIds.addAll(diseases.keySet());
        Map<Id, Medication_Including_Psychotropic__c> medications = new Map<Id, Medication_Including_Psychotropic__c>([SELECT Id FROM Medication_Including_Psychotropic__c WHERE Contact__c = :recordId]);
        healthRecordIds.addAll(medications.keySet());
        Map<Id, Provider_Information__c> providerInfos = new Map<Id, Provider_Information__c>([SELECT Id FROM Provider_Information__c WHERE Contact__c = :recordId]);
        healthRecordIds.addAll(providerInfos.keySet());
        Map<Id, Mobility_Speech__c> mobilities = new Map<Id, Mobility_Speech__c>([SELECT Id FROM Mobility_Speech__c WHERE Contact__c = :recordId]);
        healthRecordIds.addAll(mobilities.keySet());
        Map<Id, Sleeping__c> sleepings = new Map<Id, Sleeping__c>([SELECT Id FROM Sleeping__c WHERE Contact__c = :recordId]);
        healthRecordIds.addAll(sleepings.keySet());
        Map<Id, Elimination__c> eliminations = new Map<Id, Elimination__c>([SELECT Id FROM Elimination__c WHERE Contact__c = :recordId]);
        healthRecordIds.addAll(eliminations.keySet());
        return getDocumentDetails(healthRecordIds);

    }

    public static List<DocumentsWrapper> getDocumentDetails(Set<Id> recordIds) {

        List<DocumentsWrapper> wrapLst = new List<DocumentsWrapper>();
        if(recordIds.size() > 0) {

            for(ContentDocumentLink cdl : [SELECT ContentDocumentId, ContentDocument.FileType, ContentDocument.Title, ContentDocument.CreatedDate, 
                                       ContentDocument.CreatedBy.Name FROM ContentDocumentLink WHERE LinkedEntityId IN :recordIds ORDER BY ContentDocument.CreatedDate DESC]) {
            
                DocumentsWrapper wrapIns = new DocumentsWrapper();
                wrapIns.docUrl = '/lightning/r/'+cdl.ContentDocumentId + '/view';
                wrapIns.docName = cdl.ContentDocument.Title;
                wrapIns.docType = cdl.ContentDocument.FileType;
                wrapIns.docUploadedDate = cdl.ContentDocument.CreatedDate;
                wrapIns.docUploadedBy = cdl.ContentDocument.CreatedBy.Name;
                wrapLst.add(wrapIns);
            }
        }
        
        return wrapLst;
    }

    @AuraEnabled
    public static String getCaseDocuments(Id recordId){

        CaseDocumentsWrapper initWrap = new CaseDocumentsWrapper();
        if(String.isNotBlank(recordId)) {

            Set<Id> contactIds = new Set<Id>();

 
                Map<Id, Notes__c> notes = new Map<Id, Notes__c>([SELECT Id FROM Notes__c WHERE Service_Case__c = :recordId]);
                contactIds.addAll(notes.keySet());
                Map<Id, Meeting__c> meetings = new Map<Id, Meeting__c>([SELECT Id FROM Meeting__c WHERE Service_Case__c = :recordId]);
                contactIds.addAll(meetings.keySet());
                initWrap.contactsDocuments =  getDocumentDetails(contactIds);


                Map<Id, Court__c> courts = new Map<Id, Court__c>([SELECT Id FROM Court__c WHERE Service_Case__c = :recordId]);
                initWrap.courtDocuments = getDocumentDetails(courts.keySet());


                Map<Id, Placement__c> placements = new Map<Id, Placement__c>([SELECT Id FROM Placement__c WHERE Service_Case__c = :recordId]);
                Map<Id, Case_Plan__c> casePlans = new Map<Id, Case_Plan__c>([SELECT Id FROM Case_Plan__c WHERE Placement__c IN :placements.keySet()]);
                initWrap.casePlanDocuments = getDocumentDetails(casePlans.keySet());


                Map<Id, Service_Plan__c> servicePlans = new Map<Id, Service_Plan__c>([SELECT Id FROM Service_Plan__c WHERE Service_Case__c = :recordId]);
                contactIds.addAll(servicePlans.keySet());
               /* Map<Id, ServiceLog__c>  serviceLogs= new Map<Id, ServiceLog__c>([SELECT Id FROM ServiceLog__c WHERE Service_Case__c = :recordId]);
                contactIds.addAll(serviceLogs.keySet());*/
                Map<Id, Youth_Transition_Plan__c> youthTransitionPlans = new Map<Id, Youth_Transition_Plan__c>([SELECT Id FROM Youth_Transition_Plan__c WHERE Service_Case__c = :recordId]);
                contactIds.addAll(youthTransitionPlans.keySet());
                initWrap.servicesDocuments = getDocumentDetails(contactIds);

                Map<Id, Child_Removal__c> removals = new Map<Id, Child_Removal__c>([SELECT Id FROM Child_Removal__c WHERE Service_Case__c = :recordId]);
                initWrap.removalDocuments = getDocumentDetails(removals.keySet());

            return JSON.serialize(initWrap);
        } else {
            return null;
        }
        
    }

    public class DocumentsWrapper {

        public String docUrl;
        public String docName;
        public String docType;
        public Datetime docUploadedDate;
        public String docUploadedBy;
    }
    
    public class DocumentsFolderWrapper {

        @AuraEnabled
        public List<DocumentsWrapper> educationDocuments;
        @AuraEnabled
        public List<DocumentsWrapper> healthDocuments;
        @AuraEnabled
        public List<DocumentsWrapper> profileDocuments;
        @AuraEnabled
        public List<DocumentsWrapper> employmentDocuments;
        @AuraEnabled
        public List<DocumentsWrapper> lifeSkillsDocuments;
        @AuraEnabled
        public List<DocumentsWrapper> financeDocuments;
       
    }
    
    public class CaseDocumentsWrapper {

        @AuraEnabled
        public List<DocumentsWrapper> contactsDocuments;
        @AuraEnabled
        public List<DocumentsWrapper> courtDocuments;
        @AuraEnabled
        public List<DocumentsWrapper> casePlanDocuments;
        @AuraEnabled
        public List<DocumentsWrapper> servicesDocuments;
        @AuraEnabled
        public List<DocumentsWrapper> removalDocuments;
       
       
    }
}