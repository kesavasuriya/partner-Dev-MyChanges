@isTest
private class CustomLookUpController_Test {
    
    @isTest static void testfetchLookUpValues() {
        
        List<sObject> lists = CustomLookUpController.fetchLookUpValues('User','C','ProfileId', 'Casevault User');
        System.assertEquals(lists.size() > 0, true);    
    }
    
    @isTest static void testfindRecords() {
        
        List<sObject> sObjectlists = CustomLookUpController.findRecords('C', 'User', 'Name');
        //System.assertEquals(sObjectlists.size() > 0, true);
        
    }

}