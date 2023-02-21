@isTest
public class ContactMeetingController_Test {

    /*@testSetup static void setup() {
        
        Service_Case__c servicecaseRec = TestRecord.serviceCase('0000123');
        insert servicecaseRec;
        
        Investigation__c investigationRec = TestRecord.investigation();
        insert investigationRec;
        
        
        Contact contactRec = TestRecord.contact('Demo','Test');
        contactRec.Service_Case__c = servicecaseRec.Id;
        contactRec.Intake_Person_Role__c = 'Biological Child';
        contactRec.Investigation__c = investigationRec.Id;
        insert contactRec;
        
        Meeting__c meetingRec = TestRecord.createMeeting();
        meetingRec.Service_Case__c = servicecaseRec.Id;
        insert meetingRec;
        
        Meeting_participants__c meetingPtpRec = new Meeting_participants__c();
        meetingPtpRec.Meeting__c = meetingRec.Id;
        insert meetingPtpRec;
        
        ContentVersion cv = new Contentversion();
        cv.title = 'ABC';
        cv.PathOnClient ='test';
        cv.versiondata = EncodingUtil.base64Decode('This is version data');
        insert cv;
        
                
    }
    
    @isTest static void TestgetMeetingInfo() {
        
        Service_Case__c servicecaseRec = [SELECT Id FROM Service_Case__c LIMIT 1];
        System.assertEquals(ContactMeetingController.getMeetingInfo('') == null, true);
        
    }
    
    @isTest static void TestgetParticipantsInit() {
        
        Contact contactRec = [SELECT Id FROM Contact LIMIT 1];
        System.assertEquals(ContactMeetingController.getParticipantsInit(contactRec.Id) != null, true);
        System.assertEquals(ContactMeetingController.getParticipantsInit('') == null, true);
        
    }
    
    @isTest static void TestgetMeetingParticipantsInit() {
        
        Meeting__c meetingRec = [SELECT Id FROM Meeting__c LIMIT 1];
        System.assertEquals(ContactMeetingController.getMeetingParticipantsInit(meetingRec.Id) != null, true);
        System.assertEquals(ContactMeetingController.getMeetingParticipantsInit('') == null, true);
        
    }
    
    
    @isTest static void TestsaveMeetingAndcreateContentVersion() {

        ContentVersion contentVersionFile = [SELECT Id, versiondata FROM ContentVersion LIMIT 1]; 
        String contentVersionLink = ContactMeetingController.createContentVersion(EncodingUtil.base64Encode(contentVersionFile.versiondata), 'Test');
        System.assertEquals(contentVersionLink != null, true);
        
        List<String> contentDocumentLinks = new List<String>();
        contentDocumentLinks.add(contentVersionLink);
        
        Contact contactRec = [SELECT Id FROM Contact LIMIT 1];
        Meeting__c meetingRec = [SELECT Id FROM Meeting__c LIMIT 1];
        
        List<Meeting_participants__c> updateMeetingParticipantsLst = [SELECT Id FROM Meeting_participants__c];
        Meeting_participants__c meetingPtpRec = [SELECT Id FROM Meeting_participants__c LIMIT 1];
        
        List<String> meetingPtpLst = new List<String>();
        meetingPtpLst.add(meetingPtpRec.Id);
        
        System.assertEquals(ContactMeetingController.saveMeeting(JSON.serialize(meetingRec), JSON.serialize(updateMeetingParticipantsLst), contentDocumentLinks, '', meetingPtpLst) != null, true);
       
        Meeting__c meetingInsertRec = TestRecord.createMeeting();
        Meeting_participants__c meetingPtpInsertRec = new Meeting_participants__c();
        
        meetingPtpInsertRec.Meeting__c = meetingInsertRec.Id;
        insert meetingPtpInsertRec;
        
        List<Meeting_participants__c> updateMeetingParticipantsLst1 = new List<Meeting_participants__c>();
        updateMeetingParticipantsLst1.add(meetingPtpInsertRec);
        
        List<String> meetingPtpLst1 = new List<String>();
        ContactMeetingController.SignatureClass signRec = new ContactMeetingController.SignatureClass();
        signRec.Id = meetingPtpInsertRec.Id;
        signRec.electronicSignature = 'Test';
        List<ContactMeetingController.SignatureClass> signLst = new List<ContactMeetingController.SignatureClass>();
        signLst.add(signRec);
        
        System.assertEquals(ContactMeetingController.saveMeeting(JSON.serialize(meetingInsertRec), JSON.serialize(updateMeetingParticipantsLst1), contentDocumentLinks, JSON.serialize(signLst), meetingPtpLst1) != null, true);

    }
    
    @isTest static void TestdeleteMeetingParticipant() {
        
        Meeting_participants__c meetinPtpRec = [SELECT Id FROM Meeting_participants__c LIMIT 1];        
        System.assertEquals(ContactMeetingController.deleteMeetingParticipant(meetinPtpRec.Id) != null, true);
        System.assertEquals(ContactMeetingController.deleteMeetingParticipant('') == null, true);
        
    }*/
    
}