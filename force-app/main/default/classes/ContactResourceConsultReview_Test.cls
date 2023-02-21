@isTest
private class ContactResourceConsultReview_Test {

    @isTest static void testContactResourceConsultReview() {
        
        Service_Case__c serviceCaseRec = TestRecord.serviceCase('');
        insert serviceCaseRec;
        
        Resource_Consult_Review__c resourceRec = new Resource_Consult_Review__c();
        resourceRec.Service_Case__c = serviceCaseRec.Id;
        resourceRec.User_Name_Type__c = 'Test - Case Management Workers';
        resourceRec.Review_Date_Time__c = System.now();
        resourceRec.Meeting_Notes__c = 'Test'; 
        
        String resourceRecId = ContactResourceConsultReviewController.saveResource(JSON.serialize(resourceRec));
        resourceRec.Id = resourceRecId;
        System.assertEquals(ContactResourceConsultReviewController.saveResource(JSON.serialize(resourceRec)) != null, true);
        
        System.assertEquals(ContactResourceConsultReviewController.getResourceConsultReviewRecord(serviceCaseRec.Id) != null, true);
        System.assertEquals(ContactResourceConsultReviewController.getResourceConsultReviewRecord('') == null, true);
        
        System.assertEquals(ContactResourceConsultReviewController.deleteResource(resourceRecId) != null, true);
        System.assertEquals(ContactResourceConsultReviewController.deleteResource('') == null, true);        
    }
}