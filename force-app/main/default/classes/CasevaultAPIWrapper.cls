public with sharing class CasevaultAPIWrapper {

    public class CasevaultAddSpecificConfigReq {

        public Integer configID;    //1
        public String configName;   //PmntPeriod
        public String activeSwitch; //Y
        public String configDesc;   //Job runs for defined month pay period PriorMonth | CurrentMonth
        public String configValue;  //PriorMonth
        public List<CasevaultConfigDetailWrapper> details;
    }
    
    public class CasevaultGetConfigAllRes {

        public String status;   //success
        public CasevaultConfigSuccessWrapper[] data;
        public CasevaultErrorRes error;
    }

    public class CasevaultGetSpecificConfigRes {

        public String status;   //success
        public CasevaultConfigSuccessWrapper data;
        public CasevaultErrorRes error;
    }

    public class CasevaultConfigSuccessWrapper {

        @AuraEnabled
        public Integer configID; //1
        @AuraEnabled
        public String configName;   //PmntPeriod
        @AuraEnabled
        public String activeSwitch; //Y
        @AuraEnabled
        public String configDesc;   //Job runs for defined month pay period PriorMonth | CurrentMonth
        @AuraEnabled
        public String configValue;  //PriorMonth
        public List<CasevaultConfigDetailWrapper> details;
    }

    public class CasevaultConfigWrapper {

        public Integer configID;    //1
        public String configName;   //PmntPeriod
        public String activeSwitch; //Y
        public String configDesc;   //Job runs for defined month pay period PriorMonth | CurrentMonth
        public String configValue;  //PriorMonth
    }

    public class CasevaultConfigDetailWrapper {

        public String activeSwitch; //Y
        public String configDetailDesc; //Job runs for defined month pay period PriorMonth | CurrentMonth
        public Integer configDetailID;  //1
        public String configDetailName; //PmntPeriod
        public String configDetailValue;    //PriorMonth
    }

    public class CasevaultErrorRes {

        public String code;
        public String message; 
    }
    
    public class ReceiptData {

        public String comments;
        public List<ReceiptDetail> details;
        public Integer receiptAmount;
        public Date receiptDate;
        public Integer receiptSummaryID;
        public String receiptType;
        public String referenceNo;
        public Integer vendorID;
    }
        
    public class ReceiptDetail {
    
        public Integer amount;
        public Integer paymentDetailID;
        public Integer paymentReceiptSummaryID;
        public Integer receiptDetailID;
        public Integer receiveableDetailID;
        public Integer vendorID;
    }
}