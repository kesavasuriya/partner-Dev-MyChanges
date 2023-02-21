@isTest
private class PermanacyPlanController_Test {
    
    @testSetup static void setup() {
        
        List<Service_Case__c> serviceCaseIns = new List<Service_Case__c>();
        serviceCaseIns.add(new Service_Case__c(Status__c ='Open'));
        if(serviceCaseIns.size() > 0)
            insert serviceCaseIns;
        
        List<Contact> contactIns = new List<Contact>();
        Contact contact = new Contact();
        contact.LastName = 'Brown Max';
        contact.Gender__c = 'Male';
        //contact.Service_Case__c = serviceCaseIns[0].Id;
        contact.Intake_Person_Role__c = 'Biological Child';
        contactIns.add(contact);
        if(contactIns.size() > 0)
            insert contactIns;
        
        List<Permanency_Plan__c> permanencyPlanIns = new List<Permanency_Plan__c>();
        Permanency_Plan__c permanencyPlan = new Permanency_Plan__c();
        permanencyPlan.Service_Case__c = serviceCaseIns[0].Id;
        permanencyPlan.Primary_Permanency_Plan__c = 'Adoption by a non-relative';
        permanencyPlan.Concurrent_Permanency_Plan__c = 'Adoption by a relative';
        permanencyPlan.Contact__c = contactIns[0].Id;
        permanencyPlan.Guardianship_Planing__c = '1';
        permanencyPlanIns.add(permanencyPlan);
        if(permanencyPlanIns.size() > 0)
            insert permanencyPlanIns;
    }
    
    
    @isTest static void testPermanacyPlanController() {
        
        Permanency_Plan__c permanencyPlanRec = [SELECT Id, Name, Service_Case__c, Contact__c FROM Permanency_Plan__c LIMIT 1];
        
        System.assertEquals(PermanacyPlanController.getInitialInformation(permanencyPlanRec.Service_Case__c, permanencyPlanRec.Id) != null, true);
                
        //System.assertEquals(PermanacyPlanController.createPermanancyPlan(JSON.serialize(permanencyPlanRec)) != null, true);
        
        Permanency_Plan__c permanencyPlan = new Permanency_Plan__c();
        permanencyPlan.Service_Case__c = permanencyPlanRec.Service_Case__c;
        permanencyPlan.Primary_Permanency_Plan__c = 'Adoption by a non-relative';
        permanencyPlan.Concurrent_Permanency_Plan__c = 'Adoption by a relative';
        permanencyPlan.Contact__c = permanencyPlanRec.Contact__c;
        permanencyPlan.Guardianship_Planing__c = '1';
        //System.assertEquals(PermanacyPlanController.createPermanancyPlan(JSON.serialize(permanencyPlan)) != null, true);
       // System.assertEquals(PermanacyPlanController.createPermanancyPlan('') == null, true);
     
        String result = PermanacyPlanController.getInitialPermanancyDetails(permanencyPlanRec.Id);
        PermanacyPlanController.getInitialWrapper initWrap = new PermanacyPlanController.getInitialWrapper();
        initWrap =(PermanacyPlanController.getInitialWrapper)JSON.deserialize(result,PermanacyPlanController.getInitialWrapper.class);
        System.assertEquals(permanencyPlanRec.Id,initWrap.permanencyInst.Id);    
        
        permanencyPlanRec.Permanency_Plan_Status__c = 'Approved';
        update permanencyPlanRec;
        
        Database.delete(permanencyPlanRec.Id, false);
    }
    
}