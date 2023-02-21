@istest
private class CourtOrderController_Test {
    
    @testSetup static void setup() {
        
        Court__c courtRec = TestRecord.createCourt();
        insert courtRec;
        
        ContentVersion cv = new Contentversion();
        cv.title = 'ABC';
        cv.PathOnClient = 'test';
        cv.versiondata = EncodingUtil.base64Decode('This is version data');
        insert cv;
        
        List<ContentDocument> contentDocuments = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.LinkedEntityId = courtRec.Id;
        cdl.ContentDocumentId = contentDocuments[0].Id;
        cdl.ShareType = 'V';
        cdl.Visibility = 'AllUsers';
        insert cdl;
        
    }
    
    @isTest static void testCourtOrderRecord(){
        
        Court__c courtRec = [SELECT Id, Court_Order_Details__c FROM Court__c LIMIT 1 ];
        System.assertEquals(CourtOrderController.getCourtOrderRecord(courtRec.Id) != null, true);
        System.assertEquals(CourtOrderController.upsertCourtOrderRecord(JSON.serialize(courtRec)) != null, true);
        System.assertEquals(CourtOrderController.getPickList(courtRec.Id) != null, true);
        
        ContentVersion contentVersionFile = [SELECT Id, versiondata FROM ContentVersion LIMIT 1];
        System.assertEquals(CourtOrderController.uploadFile(EncodingUtil.base64Encode(contentVersionFile.versiondata), 'Test', courtRec.Id) != null, true);
        
        System.assertEquals(CourtOrderController.getRelatedFilesByRecordId(courtRec.Id) != null, true);
        
    }
    
}