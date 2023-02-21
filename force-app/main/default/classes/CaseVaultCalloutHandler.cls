public with sharing class CaseVaultCalloutHandler {
    
    public static final String requestEndpoint = 'http://casevault.bi-cloud.net:8080/pgps/api/';
    
    @AuraEnabled
    public static String getAllConfig() { 
         
        List<CaseVaultAPIWrapper.CasevaultGetConfigAllRes> casevaultGetConfigAllResList = new List<CaseVaultAPIWrapper.CasevaultGetConfigAllRes>();
        List<CaseVaultAPIWrapper.CasevaultConfigSuccessWrapper> casevaultConfigSuccessWrapperList = new List<CaseVaultAPIWrapper.CasevaultConfigSuccessWrapper>();
        CaseVaultAPIWrapper.CasevaultGetConfigAllRes casevaultGetConfigAllResObj = new CaseVaultAPIWrapper.CasevaultGetConfigAllRes();
        HttpResponse response = makeCallout( requestEndpoint+'config/all','GET');

        if(response.getStatusCode() == 200) {
            casevaultGetConfigAllResObj = (CaseVaultAPIWrapper.CasevaultGetConfigAllRes)JSON.deSerialize(response.getBody(),CaseVaultAPIWrapper.CasevaultGetConfigAllRes.class);
        }
        casevaultConfigSuccessWrapperList = casevaultGetConfigAllResObj.data;
        
        return JSON.serialize(casevaultConfigSuccessWrapperList);
    }
    
    @AuraEnabled
    public static void addConfig(String configName,string configDesc,string configValue) {
        
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(requestEndpoint+'config/');
        request.setHeader('Content-Type', 'application/json');
        request.setMethod('POST');
        CaseVaultAPIWrapper.CasevaultAddSpecificConfigReq casevaultAddSpecificConfigReqObj = new CaseVaultAPIWrapper.CasevaultAddSpecificConfigReq();
        casevaultAddSpecificConfigReqObj.activeSwitch = 'Y';
        casevaultAddSpecificConfigReqObj.configDesc = configDesc;
        casevaultAddSpecificConfigReqObj.configID = 0;
        casevaultAddSpecificConfigReqObj.configName = configName;
        casevaultAddSpecificConfigReqObj.configValue = configValue;
        List<CaseVaultAPIWrapper.CasevaultConfigDetailWrapper> casevaultConfigDetailWrapperlst = new List<CaseVaultAPIWrapper.CasevaultConfigDetailWrapper>();
        CaseVaultAPIWrapper.CasevaultConfigDetailWrapper casevaultConfigDetailWrapperObj = new CaseVaultAPIWrapper.CasevaultConfigDetailWrapper();
        casevaultConfigDetailWrapperObj.activeSwitch = 'Y';
        casevaultConfigDetailWrapperObj.configDetailDesc = configDesc;
        casevaultConfigDetailWrapperObj.configDetailID = 0;
        casevaultConfigDetailWrapperObj.configDetailName = configName;
        casevaultConfigDetailWrapperObj.configDetailValue = configValue;
        casevaultConfigDetailWrapperlst.add(casevaultConfigDetailWrapperObj);
        casevaultAddSpecificConfigReqObj.details = casevaultConfigDetailWrapperlst;
        
        request.setBody(JSON.serialize(casevaultAddSpecificConfigReqObj));
        HttpResponse response = http.send(request);
    }
    
    @AuraEnabled
    public static void updateConfig(Integer configID,String configName,string configDesc,string configValue) {
        
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(requestEndpoint+'config/'+configID);
        request.setHeader('Content-Type', 'application/json');
        request.setMethod('PATCH');
        CaseVaultAPIWrapper.CasevaultAddSpecificConfigReq casevaultAddSpecificConfigReqObj = new CaseVaultAPIWrapper.CasevaultAddSpecificConfigReq();
        casevaultAddSpecificConfigReqObj.activeSwitch = 'Y';
        casevaultAddSpecificConfigReqObj.configDesc = configDesc;
        casevaultAddSpecificConfigReqObj.configID = configID;
        casevaultAddSpecificConfigReqObj.configName = configName;
        casevaultAddSpecificConfigReqObj.configValue = configValue;
        List<CaseVaultAPIWrapper.CasevaultConfigDetailWrapper> casevaultConfigDetailWrapperlst = new List<CaseVaultAPIWrapper.CasevaultConfigDetailWrapper>();
        CaseVaultAPIWrapper.CasevaultConfigDetailWrapper casevaultConfigDetailWrapperObj = new CaseVaultAPIWrapper.CasevaultConfigDetailWrapper();
        casevaultConfigDetailWrapperObj.activeSwitch = 'Y';
        casevaultConfigDetailWrapperObj.configDetailDesc = configDesc;
        casevaultConfigDetailWrapperObj.configDetailID = configID;
        casevaultConfigDetailWrapperObj.configDetailName = configName;
        casevaultConfigDetailWrapperObj.configDetailValue = configValue;
        casevaultConfigDetailWrapperlst.add(casevaultConfigDetailWrapperObj);
        casevaultAddSpecificConfigReqObj.details = casevaultConfigDetailWrapperlst;
        
        request.setBody(JSON.serialize(casevaultAddSpecificConfigReqObj));
        HttpResponse response = http.send(request);
     
    }
    
    @AuraEnabled
    public static String getSummarySearch(Integer summaryId) {
        
        HttpResponse response = makeCallout(requestEndpoint+'payment/search?value='+summaryId,'GET');
        return response.getBody();
        
    }
    
    @AuraEnabled
    public static String getAllSummaryDetails(Integer summaryId) {
        
        HttpResponse response = makeCallout( requestEndpoint +'payment/summary/' + summaryId + '/details','GET');
        return response.getBody();
        
    }
          
    @AuraEnabled
    public static String getReceivableSummarySearch(Integer receivableSummaryId) {
        
        HttpResponse response = makeCallout( requestEndpoint +'receivable/search?value='+receivableSummaryId,'GET');

        
        return response.getBody();
    }
    
    @AuraEnabled
    public static String getAllReceivableSummaryDetails(Integer receivableSummaryId) {
        
        HttpResponse response = makeCallout( requestEndpoint +'receivable/summary/'+receivableSummaryId+'/details','GET');
        return response.getBody();
    } 
    
    @AuraEnabled
    public static String getAllReceiptSummary(Integer vendorId) {
        
        HttpResponse response = makeCallout( requestEndpoint +'receipt/search?vendor='+vendorId,'GET');
        return response.getBody();
    }
    
    @AuraEnabled
    public static String getpaymentinputdetails() {
        
        HttpResponse response = makeCallout( requestEndpoint +'input/payment/all','GET');        
        return response.getBody();
    }
    
    @AuraEnabled
     public static void createReceipt(Integer receiptAmount,Date receiptDate,String receiptType,String referenceNo,Integer vendorID,String comments) {
      
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint( requestEndpoint +'receipt/process');
        request.setHeader('Content-Type', 'application/json');
        request.setMethod('POST');
        CasevaultAPIWrapper.ReceiptData  casevaultCreateReceipt = new CasevaultAPIWrapper.ReceiptData();
        casevaultCreateReceipt.receiptAmount =receiptAmount;
        casevaultCreateReceipt.receiptDate=receiptDate;
        casevaultCreateReceipt.receiptSummaryID=0;
        casevaultCreateReceipt.receiptType=receiptType;
        casevaultCreateReceipt.referenceNo=referenceNo;
        casevaultCreateReceipt.vendorID=vendorID;
        casevaultCreateReceipt.comments=comments;
         List<CasevaultAPIWrapper.ReceiptDetail > casevaultReceiptDetailWrapperlst = new List<CasevaultAPIWrapper.ReceiptDetail>();
        CasevaultAPIWrapper.ReceiptDetail casevaultReceiptDetailWrapperObj = new CasevaultAPIWrapper.ReceiptDetail ();
        casevaultReceiptDetailWrapperObj.amount= 0;
        casevaultReceiptDetailWrapperObj.paymentDetailID= 0;
        casevaultReceiptDetailWrapperObj.paymentReceiptSummaryID= 0;
        casevaultReceiptDetailWrapperObj.receiptDetailID= 0;
        casevaultReceiptDetailWrapperObj.receiveableDetailID=0;
        casevaultReceiptDetailWrapperObj.vendorID=vendorID ;
        casevaultReceiptDetailWrapperlst.add(casevaultReceiptDetailWrapperObj);
        casevaultCreateReceipt.details=casevaultReceiptDetailWrapperlst;
        
        request.setBody(JSON.serialize(casevaultCreateReceipt));
        HttpResponse response = http.send(request);
            
    }
    
    
    public static HttpResponse makeCallout(String endpoint,String httpMethod) {
        
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpoint);
        request.setMethod(httpMethod);
        HttpResponse response = http.send(request);
        return response;
    }
}