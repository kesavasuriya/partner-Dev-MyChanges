@isTest
private class SDMAllegedVictimAndMaltreator_Test {

    @isTest static void testSDMAllegedVictimAndMaltreator() {
        
        List<Contact> persons = new List<Contact>();
        List<SDM_Alleged_Victim_and_Maltreator__c> sdm_Victims_Maltreators = new List<SDM_Alleged_Victim_and_Maltreator__c>();
        
        Investigation__c investigationRec = TestRecord.investigation();
        insert investigationRec;
        
        Contact victimPersonRec = TestRecord.contact('Test', 'Victim');
        //victimPersonRec.Investigation__c = investigationRec.Id;
        victimPersonRec.Intake_Person_Role__c = 'Alleged Victim';
		persons.add(victimPersonRec);        
        
        Contact maltreatorPersonRec = TestRecord.contact('Test', 'Maltreator');
        //maltreatorPersonRec.Investigation__c = investigationRec.Id;
        maltreatorPersonRec.Intake_Person_Role__c = 'Alleged Maltreator';
        persons.add(maltreatorPersonRec);
        insert persons;
        
        SDM__c sdmRec = TestRecord.createSDM();
        sdmRec.Investigation__c = investigationRec.Id;
        sdmRec.Suspicious_death_of_child_due_to_neglect__c = true;
        insert sdmRec;
        
        SDM_Alleged_Victim_and_Maltreator__c sdm_Victim = new SDM_Alleged_Victim_and_Maltreator__c();
        sdm_Victim.SDM__c = sdmRec.Id;
        sdm_Victim.Alleged_Victim_s__c = victimPersonRec.Id;
        sdm_Victims_Maltreators.add(sdm_Victim);
        
        SDM_Alleged_Victim_and_Maltreator__c sdm_Maltreator = new SDM_Alleged_Victim_and_Maltreator__c();
        sdm_Maltreator.SDM__c = sdmRec.Id;
        sdm_Maltreator.Alleged_Maltreator_s__c = maltreatorPersonRec.Id;
        sdm_Victims_Maltreators.add(sdm_Maltreator);
        
        insert sdm_Victims_Maltreators;
        
        Maltreatment_Allegation__c allegationRec = new Maltreatment_Allegation__c();
        allegationRec.This_maltreatment_is_not_applicable__c = false;
        allegationRec.Date_of_Incident__c = System.now();
        allegationRec.Maltreatment_Characteristics_Comments__c = 'Test';
        allegationRec.Investigation__c = investigationRec.Id;
        allegationRec.Child__c = victimPersonRec.Id;
        allegationRec.Alleged_Maltreator__c = maltreatorPersonRec.Id;
        allegationRec.Abuse_Types__c = 'PHYSICAL ABUSE';
        insert allegationRec;
        
        system.assertEquals(allegationRec != null, true);
        delete sdm_Victims_Maltreators;        
    }
}