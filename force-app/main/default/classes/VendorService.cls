public with sharing class VendorService {
    
    @AuraEnabled
    public static String getClient(Id clientId) {
    
        getInitialWrapper initWrap = new getInitialWrapper ();
        initWrap.structureServiceNamePicklist =  Utility.getPicklistinfo('Structure_Services__c','Structure_Service_Name__c',false);
        initWrap.clientProgramNamePicklist  = Utility.getPicklistinfo('ServiceLog__c','Client_Program_Name__c',false);
        initWrap.actionPicklist = Utility.getPicklistinfo('ServiceLog__c','Action__c',false);
        initWrap.durationPicklist = Utility.getPicklistinfo('ServiceLog__c','Duration__c',false);
        initWrap.frequencyPicklist = Utility.getPicklistinfo('ServiceLog__c','Frequency__c',false);
        initWrap.reasonServiceNotReceivedPicklist = Utility.getPicklistinfo('ServiceLog__c','Reason_Service_Not_Received__c',false);
        initWrap.serviceEndReasonPicklist = Utility.getPicklistinfo('ServiceLog__c','Service_End_Reason__c',false); 
        initWrap.fiscalCodePicklist = Utility.getPicklistinfo('Purchase_Authorization__c', 'Fiscal_Category_Description__c', false);
        initWrap.voucherRequestedPicklist = Utility.getPicklistinfo('Purchase_Authorization__c', 'Voucher_Requested__c', false);
        initWrap.agencyServicePicklist = Utility.getPicklistinfo('ServiceLog__c','AgencyServices__c',false);
        initWrap.vendorServicePicklist = Utility.getPicklistinfo('ServiceLog__c', 'Service__c', false);    
        
        if (String.isNotBlank(clientId)) { 
            
            FieldLevelSecurity.checkFieldAccessByCriteria('Name,Date_of_Birth__c,Gender__c,Age__c,Intake_Person_Role__c, Casevault_PID__c', 'view', 'Contact',  Boolean.valueOf(Label.HasNamespace));
            List<String> programAreaLst = new List<String>();
            programAreaLst.add('Guardianship Assistance Program');
            programAreaLst.add('Out of Home');
            programAreaLst.add('CPS/IR');
            
            /*List<Contact> conLst = [SELECT Id,Name,Date_of_Birth__c,Gender__c,Age__c,Intake_Person_Role__c,Program_Area__c,
                                    Service_Case__c, Casevault_PID__c 
                                    FROM Contact WHERE (Service_Case__c = :clientId
                                    AND Intake_Person_Role__c INCLUDES ('Biological Child') AND Program_Area__c IN :programAreaLst)  LIMIT :Utility.queryLimit];*/
            /*List<Contact> conLst = [SELECT Id,Name,Date_of_Birth__c,Gender__c,Age__c,Intake_Person_Role__c,Program_Area__c,
                                    Service_Case__c, Casevault_PID__c 
                                    FROM Contact WHERE (Service_Case__c = :clientId
                                    AND Intake_Person_Role__c INCLUDES ('Biological Child') )  LIMIT :Utility.queryLimit];
            if(conLst.size() > 0) {
                initWrap.contactList = conLst;
            }
            
            Utility.pickListWrap childPick = new Utility.pickListWrap();
            childPick.label = '--None--';
            childPick.value = '';
            initWrap.contactPicklist.add(childPick);
            FieldLevelSecurity.checkFieldAccessByCriteria('Name,Intake_Person_Role__c,Service_Case__c, Program_Area__c', 'view', 'Contact',  Boolean.valueOf(Label.HasNamespace));
            
            if(conLst.size() > 0) {
               
                for (Contact contactIns : [SELECT Id, Name FROM Contact WHERE Service_Case__c = :clientId AND Intake_Person_Role__c INCLUDES ('Biological Child')  LIMIT :Utility.queryLimit]) {
                childPick = new Utility.pickListWrap();
                childPick.label = contactIns.Name;
                childPick.value = contactIns.Id;
                initWrap.contactPicklist.add(childPick);
                }
            }*/
            return  JSON.serialize(initWrap);
        } else {
            return  JSON.serialize(initWrap);
        } 
    }
     
    @AuraEnabled
    public static String getSearchList(String searchString) {
              
        FieldLevelSecurity.checkFieldAccessByCriteria('ID,Name,Provider__c,Provider__c,Structure_Service_Name__c', 'view', 'Structure_Services__c',  Boolean.valueOf(Label.HasNamespace));
        FieldLevelSecurity.checkFieldAccessByCriteria('Name,Casevault_ProID__c,Tax_ID__c,BillingStreet,BillingCountry,BillingPostalCode','view','Account', Boolean.valueOf(Label.HasNamespace));
       
        SearchItem sobj = (SearchItem)JSON.deserialize(searchString, SearchItem.class);
        String searchJSON = 'SELECT ID,Name,Provider__c,Provider__r.Name,Provider__r.Casevault_ProID__c,Provider__r.Tax_ID__c,Provider__r.BillingStreet,Provider__r.BillingCountry,Provider__r.BillingPostalCode,Structure_Service_Name__c' 
                             + ' FROM Structure_Services__c WHERE Provider__c != null';
        if(String.isNotBlank(sobj.ProviderID)) {
            searchJSON += ' AND Provider__r.Casevault_ProID__c = \''+String.escapeSingleQuotes(sobj.ProviderID)+'\'';
        }
        if(String.isNotBlank(sobj.ProviderName)) {
            searchJSON += ' AND Provider__r.Name = \''+String.escapeSingleQuotes(sobj.ProviderName)+'\'';
        }
       	if(String.isNotBlank(sobj.TaxID)) {
            searchJSON += ' AND Provider__r.Tax_ID__c = \''+String.escapeSingleQuotes(sobj.TaxID)+'\'';
        }
        if(String.isNotBlank(sobj.Zipcode)) {
            searchJSON += ' AND Provider__r.BillingPostalCode = \''+String.escapeSingleQuotes(sobj.Zipcode)+'\'';
        }
        if(String.isNotBlank(sobj.Services)) {
            //searchJSON += ' AND Structure_Service_Name__c = \''+sobj.Services+'\'';
            searchJSON += ' AND Structure_Service_Name__c LIKE \''+'%'+String.escapeSingleQuotes(sobj.Services)+'\'';
        }
        Integer queryLimit = Utility.queryLimit;
		searchJSON += 'LIMIT :queryLimit';
        List<Structure_Services__c>  services = Database.query(searchJSON);
        return JSON.serialize(services);
    }
    
    @AuraEnabled
    public static String createService(String serviceJSON) {
        
        if (String.isNotBlank(serviceJSON)) {
            ServiceLog__c servicelog = (ServiceLog__c)JSON.deserialize(serviceJSON,ServiceLog__c.class);
            if (String.isBlank(servicelog.Id)) {
                FieldLevelSecurity.checkFieldAccessByCriteria('Client__c,Structure_Services__c,Provider__c,Type__c,Actual_Begin_DateTime__c,Actual_End_DateTime__c,AgencyServices__c,Client_Program_Name__c,Date_Referred__c,Actiontxt__c,Service_Plan__c,Frequency__c,Duration__c,Estimated_Begin_Date__c,Estimated_End_Date__c,Service_Received__c,Actual_Begin_Date__c,Actual_End_Date__c,Service_End_Reason__c,Court_Order__c,Notes__c,Service_Not_Received__c,Outcome__c','create', 'ServiceLog__c',  Boolean.valueOf(Label.HasNamespace));
                insert servicelog;
            } else {
                FieldLevelSecurity.checkFieldAccessByCriteria('Client__c,Structure_Services__c,Provider__c,Type__c,Actual_Begin_DateTime__c,Actual_End_DateTime__c,AgencyServices__c,Client_Program_Name__c,Date_Referred__c,Actiontxt__c,Service_Plan__c,Frequency__c,Duration__c,Estimated_Begin_Date__c,Estimated_End_Date__c,Service_Received__c,Actual_Begin_Date__c,Actual_End_Date__c,Service_End_Reason__c,Court_Order__c,Notes__c,Service_Not_Received__c,Outcome__c','update', 'ServiceLog__c',  Boolean.valueOf(Label.HasNamespace));
                update servicelog;
            }
          return 'Success';
       } else {
        return null;
       }
        
    }
    
    @AuraEnabled
    public static String getAllService(Id clientId) {
        
        if (String.isNotBlank(clientId)) {
            FieldLevelSecurity.checkFieldAccessByCriteria('Provider__c,Structure_Services__c,Actual_Begin_Date__c,Actual_End_Date__c,Client__c,Type__c', 'view', 'ServiceLog__c',  Boolean.valueOf(Label.HasNamespace)); 
            FieldLevelSecurity.checkFieldAccessByCriteria('Name,Casevault_ProID__c','view','Account', Boolean.valueOf(Label.HasNamespace));
            FieldLevelSecurity.checkFieldAccessByCriteria('Structure_Service_Name__c','view','Structure_Services__c', Boolean.valueOf(Label.HasNamespace));
            FieldLevelSecurity.checkFieldAccessByCriteria('Casevault_PID__c,Name,Date_of_Birth__c,Gender__c,Age__c','view','Contact', Boolean.valueOf(Label.HasNamespace));
           
            List<ServiceLog__c> servicelogs;
            /*List<ServiceLog__c> servicelogs = [SELECT Id,Provider__r.Casevault_ProID__c,Provider__r.Name,Structure_Services__r.Structure_Service_Name__c,Actual_Begin_Date__c,Actual_End_Date__c,
                                               Client__r.Casevault_PID__c,Client__r.Name,Client__r.Date_of_Birth__c,Client__r.Gender__c,Client__r.Age__c,Type__c
                                               FROM ServiceLog__c WHERE Client__r.Service_Case__c = :clientId AND Type__c = 'Vendor Services' ORDER BY CreatedDate DESC LIMIT :Utility.queryLimit];*/
            return JSON.serialize(servicelogs);
        } else {
            return null;
        }
        
    }
    
    @AuraEnabled
    public static String getAllAgencyService(Id serviceId) {
        
        if (String.isNotBlank(serviceId)) {
            FieldLevelSecurity.checkFieldAccessByCriteria('Client_Program_Name__c,AgencyServices__c,Duration__c,Frequency__c,Estimated_Begin_Date__c,Estimated_End_Date__c, Actiontxt__c, Service_Plan__c,  Actual_Begin_DateTime__c,'+
                                                          'Actual_End_DateTime__c, Notes__c, Type__c', 'view', 'ServiceLog__c',  Boolean.valueOf(Label.HasNamespace));        
            FieldLevelSecurity.checkFieldAccessByCriteria('Casevault_PID__c, Name, Date_of_Birth__c, Gender__c','view','Contact', Boolean.valueOf(Label.HasNamespace));
           
            List<ServiceLog__c> servicelogs;
            /*List<ServiceLog__c> servicelogs = [SELECT Id,Client__r.Casevault_PID__c,Client__r.Name,Client__r.Date_of_Birth__c,Client__r.Gender__c,Client_Program_Name__c,Actiontxt__c,Service_Plan__c,AgencyServices__c,Duration__c,Frequency__c,Estimated_Begin_Date__c,Estimated_End_Date__c,Actual_Begin_DateTime__c,Actual_End_DateTime__c,Notes__c
                                               FROM ServiceLog__c WHERE Client__r.Service_Case__c = :serviceId AND Type__c = 'Agency Provided Services' ORDER BY CreatedDate DESC LIMIT :Utility.queryLimit];*/
            return JSON.serialize(servicelogs);                
        } else {
            return null;
        }
    }
    
    @AuraEnabled
    public static String getService(Id serviceId) {
        
        if (String.isNotBlank(serviceId)) {
            FieldLevelSecurity.checkFieldAccessByCriteria('Provider__c,Structure_Services__c,Actual_Begin_Date__c,Actual_End_Date__c,'+
                                     'Client__c,Type__c,Client_Program_Name__c,Date_Referred__c,Action__c,Service_Plan__c,Frequency__c,Duration__c,Estimated_Begin_Date__c,Estimated_End_Date__c,Service_Received__c,Service_End_Reason__c,'+
                                     'Court_Order__c,Notes__c,Service_Not_Received__c,Reason_Service_Not_Received__c,Outcome__c,AgencyServices__c,Actual_Begin_DateTime__c,Actual_End_DateTime__c', 'view', 'ServiceLog__c',  Boolean.valueOf(Label.HasNamespace));
            FieldLevelSecurity.checkFieldAccessByCriteria('Casevault_PID__c,Name,Date_of_Birth__c,Gender__c,Age__c','view','Contact', Boolean.valueOf(Label.HasNamespace));
            FieldLevelSecurity.checkFieldAccessByCriteria('Structure_Service_Name__c','view','Structure_Services__c', Boolean.valueOf(Label.HasNamespace));
            FieldLevelSecurity.checkFieldAccessByCriteria('Name,Casevault_ProID__c,Tax_ID__c,BillingStreet,BillingCountry,BillingPostalCode','view','Account', Boolean.valueOf(Label.HasNamespace));
           
            ServiceLog__c servicelogs = [SELECT Id,Actual_Begin_Date__c,Actual_End_Date__c,
                                         Type__c,
                                         Client_Program_Name__c,Date_Referred__c,Actiontxt__c,Service_Plan__c,Frequency__c,Duration__c,Estimated_Begin_Date__c,Estimated_End_Date__c,Service_Received__c,Service_End_Reason__c,
                                         Court_Order__c,Notes__c,Service_Not_Received__c,Reason_Service_Not_Received__c,Outcome__c
                                         FROM ServiceLog__c WHERE Id = :serviceId LIMIT :Utility.queryLimit];
            return JSON.serialize(servicelogs);

        } else { 
            return null;
        }
    }
    
    @AuraEnabled
    public static String createPurchase(String purchaseJSON) {
        
        if (String.isNotBlank(purchaseJSON)) {
            Purchase_Authorization__c purchaseAuthorization = (Purchase_Authorization__c)JSON.deserialize(purchaseJSON,Purchase_Authorization__c.class);
            if (String.isBlank(purchaseAuthorization.Id)) {
                FieldLevelSecurity.checkFieldAccessByCriteria('Final_Amount__c,Cost_not_be_exceed__c,Service__c,Fiscal_Category_Description__c,Start_Date__c,End_Date__c,Voucher_Requested__c,Justification__c,Funding_Approval_Status__c,Payment_Approval_Status__c,Approval_Date__c,Forwarded_From__c,Role__c,Select_Approver__c,Status__c','create','Purchase_Authorization__c',  Boolean.valueOf(Label.HasNamespace));
                insert purchaseAuthorization;
            } else {
                FieldLevelSecurity.checkFieldAccessByCriteria('Final_Amount__c,Cost_not_be_exceed__c,Service__c,Fiscal_Category_Description__c,Start_Date__c,End_Date__c,Voucher_Requested__c,Justification__c,Funding_Approval_Status__c,Payment_Approval_Status__c,Approval_Date__c,Forwarded_From__c,Role__c,Select_Approver__c,Status__c','update','Purchase_Authorization__c',  Boolean.valueOf(Label.HasNamespace));
                update purchaseAuthorization;
            }
        return purchaseAuthorization.Id;
        } else {
            return null;    
        }
    }
    
    @AuraEnabled
    public static String getPurchase(Id purchaseId) {
        
        if (String.isNotBlank(purchaseId)) {
            FieldLevelSecurity.checkFieldAccessByCriteria('Name,Fiscal_Category_Code__c,Fiscal_Category_Description__c,Start_Date__c,End_Date__c,Voucher_Requested__c,Cost_not_be_exceed__c,Justification__c,Status__c,Approval_Date__c,Approver_Role__c,Select_Approver__c,Forwarded_From__c,Final_Amount__c', 'view', 'Purchase_Authorization__c',  Boolean.valueOf(Label.HasNamespace));
       		FieldLevelSecurity.checkFieldAccessByCriteria('Name','view','User',Boolean.valueOf(Label.HasNamespace));
            Purchase_Authorization__c purchaseAuthorization = [SELECT Id,Name,Fiscal_Category_Code__c,Fiscal_Category_Description__c,Start_Date__c,End_Date__c,Voucher_Requested__c,Cost_not_be_exceed__c,Justification__c,Status__c,
                                             					Approval_Date__c,Forwarded_From__c,Forwarded_From__r.Name,Approver_Role__c,Select_Approver__c,Select_Approver__r.Name,Role__c,Final_Amount__c
                                             					FROM Purchase_Authorization__c WHERE Id = :purchaseId LIMIT :Utility.queryLimit];
          
            return JSON.serialize(purchaseAuthorization); 
         } else {
            return null;
        }
    }
    
    @AuraEnabled
    public static String getAllPurchaseAuthorization(Id serviceId) {
        
        if (String.isNotBlank(serviceId)) {
            FieldLevelSecurity.checkFieldAccessByCriteria('Name,Fiscal_Category_Code__c,Start_Date__c,Fiscal_Category_Description__c,End_Date__c,Cost_not_be_exceed__c,Service__c,Status__c,Final_Amount__c', 'view', 'Purchase_Authorization__c',  Boolean.valueOf(Label.HasNamespace));
            List<Purchase_Authorization__c> authorizations = [SELECT Id,Name,Fiscal_Category_Code__c,Fiscal_Category_Description__c,Start_Date__c,End_Date__c,Cost_not_be_exceed__c,Service__c,Status__c,Final_Amount__c FROM Purchase_Authorization__c WHERE Service__c = :serviceId ORDER BY CreatedDate DESC LIMIT :Utility.queryLimit];
            return JSON.serialize(authorizations);
        } else {
            return null;
        }
        
    }
    
    @AuraEnabled
    public static String deleteService(Id serviceId) {
        if (String.isNotBlank(serviceId)) {
            FieldLevelSecurity.checkObjectAccessByDelete('ServiceLog__c');
            ServiceLog__c servicelog = new ServiceLog__c();
            servicelog.Id = serviceId;
            delete servicelog;
            return 'Success';
        } else {
            return null;
        }
        
    }
    
    @AuraEnabled
    public static String onSubmitForApproval(Id authorizationRecId, Id selectedSupervisorUserId){        
       
        if (String.isNotBlank(authorizationRecId) && String.isNotBlank(selectedSupervisorUserId)) {
            Id profileId = UserInfo.getProfileId();
            FieldLevelSecurity.checkFieldAccessByCriteria('Name','view','Profile', Boolean.valueOf(Label.HasNamespace));
            Profile profileObj = [SELECT Id,Name FROM Profile WHERE Id = :profileId];
            Purchase_Authorization__c authorization =  new Purchase_Authorization__c ();
            authorization.Id = authorizationRecId;
            authorization.Select_Approver__c = selectedSupervisorUserId;
            authorization.Forwarded_From__c = UserInfo.getUserId();
            authorization.Role__c = profileObj.Name;
            FieldLevelSecurity.checkFieldAccessByCriteria('Select_Approver__c,Forwarded_From__c,Role__c','update','Purchase_Authorization__c', Boolean.valueOf(Label.HasNamespace));
            update authorization;
            Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest(); 
            req.setComments('Submit For Approval');        
            req.setObjectId(authorization.Id);
            Approval.ProcessResult result = Approval.process(req);
            return JSON.serialize(result);  
        } else {
            return null;
        }
        
    } 
    
    @AuraEnabled
    public static void downloadPurchaseRecord(){
        
        Pagereference pg = Page.AuthorizationRecordDownload;
    }
    
    public String currentRecordId {get;set;}
    public Purchase_Authorization__c authorizationRecord { get; set; }
    public VendorService() {
        currentRecordId  = ApexPages.CurrentPage().getparameters().get('id');
        FieldLevelSecurity.checkFieldAccessByCriteria('Name,Service__c,Justification__c,Fiscal_Category_Description__c,Cost_not_be_exceed__c,Start_Date__c,End_Date__c,Voucher_Requested__c,Select_Approver__c', 'view', 'Purchase_Authorization__c',  Boolean.valueOf(Label.HasNamespace));
        FieldLevelSecurity.checkFieldAccessByCriteria('Name,Provider__c,Client__c,Structure_Services__c','view','ServiceLog__c', Boolean.valueOf(Label.HasNamespace));
        FieldLevelSecurity.checkFieldAccessByCriteria('Name,Casevault_ProID__c,Phone,Tax_ID__c,BillingStreet,BillingCountry,BillingPostalCode','view','Account', Boolean.valueOf(Label.HasNamespace));
        FieldLevelSecurity.checkFieldAccessByCriteria('Casevault_PID__c,Name,Date_of_Birth__c,Gender__c,Age__c','view','Contact', Boolean.valueOf(Label.HasNamespace));
        FieldLevelSecurity.checkFieldAccessByCriteria('Name','view','Service_Case__c', Boolean.valueOf(Label.HasNamespace));
        FieldLevelSecurity.checkFieldAccessByCriteria('Structure_Service_Name__c','view','Structure_Services__c', Boolean.valueOf(Label.HasNamespace));
        FieldLevelSecurity.checkFieldAccessByCriteria('Name','view','User', Boolean.valueOf(Label.HasNamespace));

        authorizationRecord = [SELECT Id,Name,Service__r.Name,Service__r.Provider__r.Casevault_ProID__c,Service__r.Provider__r.Tax_ID__c,
                               Service__r.Provider__r.Name,Service__r.Provider__r.Phone,Service__r.Provider__r.BillingStreet,
                               Service__r.Client__r.Name,Service__r.Client__r.Casevault_PID__c,Service__r.Structure_Services__r.Structure_Service_Name__c,
                               Justification__c,Fiscal_Category_Description__c,Cost_not_be_exceed__c,Start_Date__c,End_Date__c,Voucher_Requested__c,Select_Approver__r.Name
                               FROM Purchase_Authorization__c WHERE Id = :currentRecordId LIMIT :Utility.queryLimit];        
    }
    
    public class SearchItem {
        
        public String ProviderID;
        public String ProviderName;
        public String TaxID;
        public String Zipcode;
        public String Services;
    }
    
     public class getInitialWrapper { 
        @AuraEnabled
        public List<Utility.pickListWrap> structureServiceNamePicklist;
        @AuraEnabled
        public List<Utility.pickListWrap> clientProgramNamePicklist;
        @AuraEnabled
        public List<Utility.pickListWrap> actionPicklist;
        @AuraEnabled
        public List<Utility.pickListWrap> durationPicklist;
        @AuraEnabled
        public List<Utility.pickListWrap> frequencyPicklist;
        @AuraEnabled
        public List<Utility.pickListWrap> reasonServiceNotReceivedPicklist;
        @AuraEnabled
        public List<Utility.pickListWrap> serviceEndReasonPicklist;
        @AuraEnabled
        public List<Utility.pickListWrap> fiscalCodePicklist;
        @AuraEnabled
        public List<Utility.pickListWrap> voucherRequestedPicklist;
        @AuraEnabled
        public List<Utility.pickListWrap> agencyServicePicklist;
        @AuraEnabled
        public List<Utility.pickListWrap> vendorServicePicklist;
        @AuraEnabled
        public List<Contact> contactList ;
        
        @AuraEnabled
        public List<Utility.pickListWrap> contactPicklist;
        public getInitialWrapper() {
        
            contactPicklist = new List<Utility.pickListWrap>();
            contactList = new List<Contact>();
         }
    }
}