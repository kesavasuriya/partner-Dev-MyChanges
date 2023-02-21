@isTest
private class ContactNotesController_Test {

    @isTest static void testContactNotesController() {
        
        List<String> contentDocumentIds = new List<String>();
        
        Service_Case__c serviceCaseRec = TestRecord.serviceCase('');
        insert serviceCaseRec;
        
        Contact personRec = TestRecord.contact('Test', 'Person');
        //personRec.Service_Case__c = serviceCaseRec.Id;
        insert personRec;
        
        String contentDocumentId = ContactNotesController.createContentVersion('test', 'ABC');
        contentDocumentIds.add(contentDocumentId);
        
        Notes__c notesRec = TestRecord.createNotes('Test Person');
        notesRec.Contact_Type__c = 'Initial Face to Face';
        notesRec.Contact_Purpose__c = 'Case Consultation';
        notesRec.Contact_Date__c = Date.today();
        notesRec.Contact_was_initiated_received__c = 'Initiated';
        notesRec.Notes__c = 'Test';
        notesRec.Service_Case__c = serviceCaseRec.Id;
        
        String notesRecId = ContactNotesController.createNotesRecord(JSON.serialize(notesRec), new List<String>());
        notesRec.Id = notesRecId;
        notesRec.Contact_Purpose__c = 'Assessment';
        System.assertEquals(ContactNotesController.createNotesRecord(JSON.serialize(notesRec), contentDocumentIds) != null, true);
        System.assertEquals(ContactNotesController.createNotesRecord('', new List<String>()) == null, true);
        
        System.assertEquals(ContactNotesController.getNotesInitialInformation(serviceCaseRec.Id) != null, true);
        
        Quality_Of_Care__c qualityRec = new Quality_Of_Care__c();
        qualityRec.Notes__c = notesRecId;
        
        String qualityRecId = ContactNotesController.createQualityCareRecord(JSON.serialize(qualityRec));
        qualityRec.Id = qualityRecId;
        System.assertEquals(ContactNotesController.createQualityCareRecord(JSON.serialize(qualityRec)) != null, true);
        System.assertEquals(ContactNotesController.createQualityCareRecord('') == null, true);
        
        //System.assertEquals(ContactNotesController.getQualityOfCareRecord(notesRecId) != null, true);
        //System.assertEquals(ContactNotesController.getQualityOfCareRecord('') == null, true);
        
        System.assertEquals(ContactNotesController.getNotesHistories(notesRecId) != null, true);
        System.assertEquals(ContactNotesController.getNotesHistories('') == null, true);
        
        System.assertEquals(ContactNotesController.deleteNotesRecord(JSON.serialize(notesRec)) != null, true);
        System.assertEquals(ContactNotesController.deleteNotesRecord('') == null, true);        
    }
}