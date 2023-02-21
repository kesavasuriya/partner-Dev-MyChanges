@isTest
private class RelationshipController_Test {

    @isTest static void testRelationshipController() {
        
        Service_Case__c serviceCaseRec = TestRecord.serviceCase('');
        insert serviceCaseRec;
        
        List<Contact> persons = new List<Contact>();
        Contact personFatherRec = TestRecord.contact('Test', 'Father');
        personFatherRec.Intake_Person_Role__c = 'Biological Parent';
        //personFatherRec.Service_Case__c = serviceCaseRec.Id;
        persons.add(personFatherRec);
        
        Contact personChildRec = TestRecord.contact('Test', 'Child');
        //personChildRec.Service_Case__c = serviceCaseRec.Id;
        persons.add(personChildRec);
        insert persons;
        
        Relationship__c relationshipRec = new Relationship__c();
        relationshipRec.Service_Case__c = serviceCaseRec.Id;
        relationshipRec.Person__c = personFatherRec.Id;
        relationshipRec.Person_Related_To__c = personChildRec.Id;
        relationshipRec.Relationship_Values__c = 'Biological Father';
        //String relationshipId = RelationshipController.saveRelationship(JSON.serialize(relationshipRec));
        //relationshipRec.Id = relationshipId;
        //System.assertEquals(RelationshipController.saveRelationship(JSON.serialize(relationshipRec)) != null, true);
        //System.assertEquals(RelationshipController.saveRelationship('') == null, true);
        
		System.assertEquals(RelationshipController.getAllPersons(serviceCaseRec.Id) != null, true);
        System.assertEquals(RelationshipController.getRelationRecord(personFatherRec.Id) != null, true);
        System.assertEquals(RelationshipController.getRelationRecord('') == null, true);        
        
    }
}