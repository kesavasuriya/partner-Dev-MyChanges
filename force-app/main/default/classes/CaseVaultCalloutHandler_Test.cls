@isTest
private class CaseVaultCalloutHandler_Test {
     
    @isTest static void testConfigMgmt() {
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        CaseVaultCalloutHandler.addConfig('Test Finance', 'Test Finance', '1');
        CaseVaultCalloutHandler.updateConfig(8, 'Finance', 'Testing', '1');
        
        System.assertEquals(CaseVaultCalloutHandler.getAllConfig() != null, true);
    }
    
    @isTest static void testVendorPaymentReq() {
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        System.assertEquals(CaseVaultCalloutHandler.getpaymentinputdetails() != null, true);
    }
    
    @isTest static void testPaymentMgmt() {
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        System.assertEquals(CaseVaultCalloutHandler.getSummarySearch(100) != null, true);
        System.assertEquals(CaseVaultCalloutHandler.getAllSummaryDetails(51) != null, true);        
    }
     
    @isTest static void testReceivableMgmt() {
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        System.assertEquals(CaseVaultCalloutHandler.getReceivableSummarySearch(100) != null, true);
        System.assertEquals(CaseVaultCalloutHandler.getAllReceivableSummaryDetails(127) != null, true);
    }
    
    @isTest static void testReceiptProcessing() {
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        System.assertEquals(CaseVaultCalloutHandler.getReceivableSummarySearch(300) != null, true);
        System.assertEquals(CaseVaultCalloutHandler.getAllReceivableSummaryDetails(213) != null, true);
        System.assertEquals(CaseVaultCalloutHandler.getAllReceiptSummary(90017) != null, true);
        CaseVaultCalloutHandler.createReceipt(0, Date.today(), 'Cash', '1', 90017, 'Test');
    }    
}