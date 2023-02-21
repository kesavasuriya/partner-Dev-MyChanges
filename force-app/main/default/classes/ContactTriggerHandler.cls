public class ContactTriggerHandler {

    public static void onBeforeInsert(List<Contact> contacts) {
        
        Set<Id> homeApprovalIds = new Set<Id>();
   		Map<Id, Contact> conHomeApprovalMap = new Map<Id, Contact>(); 
        String recordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Unverified Person').getRecordTypeId();
        Casevault_Unique_Id__c  cvUniqueLstSettingIns = Casevault_Unique_Id__c.getValues('Person');
        Decimal casevaultPIDValue = 0;
        if (cvUniqueLstSettingIns == null) {
            cvUniqueLstSettingIns = new Casevault_Unique_Id__c( Name = 'Person');
        } else {
            casevaultPIDValue = cvUniqueLstSettingIns.Auto_Number__c ;
        }
        
        for(Contact con : contacts) {
            
            con = doSSNAutoFormat(con);
            if(con.Home_Approval__c != null) {
                
               homeApprovalIds.add(con.Home_Approval__c);
               conHomeApprovalMap.put(con.Home_Approval__c, con);                 
            }
            if(String.isNotBlank(con.FirstName)) {
                con.Firstname_soundex_keycode__c = Soundex_Algorithm.calculateSoundexCode(con.FirstName);
            }
            if(String.isNotBlank(con.LastName)) {
                con.Lastname_soundex_keycode__c = Soundex_Algorithm.calculateSoundexCode(con.LastName);
            }
            if(con.Approximate_Date__c) {
                con.Approximate_DOB_Changed_time__c = System.now();
            }
            system.debug(con.RecordTypeId);
            if(con.RecordTypeId != recordTypeId) {
                casevaultPIDValue++;
                 system.debug('in');
                con.Casevault_PID__c = 'PE-'+Integer.valueOf(casevaultPIDValue);  
            }
        } 
        system.debug(casevaultPIDValue);
        cvUniqueLstSettingIns.Auto_Number__c = casevaultPIDValue;
    	upsert cvUniqueLstSettingIns;
        
        FieldLevelSecurity.checkFieldAccessByCriteria('Home_Approval_Status__c,','view','Home_Approval__c', Boolean.valueOf(Label.HasNamespace));
        for(Home_Approval__c home : [SELECT Id, Home_Approval_Status__c FROM Home_Approval__c WHERE Id IN :homeApprovalIds 
                                AND Home_Approval_Status__c = 'Approved']) {
            
            if(conHomeApprovalMap != null && conHomeApprovalMap.containsKey(home.Id) && conHomeApprovalMap.get(home.Id) != null) {
                
                Contact con = conHomeApprovalMap.get(home.Id);
                
                if(con != null) {
                    con.addError('Not allowed to create or change the value once approved the home approval.');
                }             
            }
        }
    }
    
    public static void onBeforeUpdate(List<Contact> contacts, Map<Id, Contact> priorValueCon ) {

		Set<Id> homeApprovalIds = new Set<Id>();
   		Map<Id, Contact> conHomeApprovalMap = new Map<Id, Contact>();
        String recordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Persons Involved').getRecordTypeId();
        Casevault_Unique_Id__c  cvUniqueLstSettingIns = Casevault_Unique_Id__c.getValues('Person');
        Decimal casevaultPIDValue = 0;
        if (cvUniqueLstSettingIns == null) {
            cvUniqueLstSettingIns = new Casevault_Unique_Id__c( Name = 'Person');
        } else {
            casevaultPIDValue = cvUniqueLstSettingIns.Auto_Number__c ;
        }
        
        for(Contact con : contacts) {
             
            if(con.SSN__c != priorValueCon.get(con.Id).SSN__c) {
                con = doSSNAutoFormat(con);
            }
            if(con.Home_Approval__c != null) {
                
               homeApprovalIds.add(con.Home_Approval__c);
               conHomeApprovalMap.put(con.Home_Approval__c, con);                 
            }
            if(con.Approximate_Date__c != priorValueCon.get(con.Id).Approximate_Date__c) {
                con.Approximate_DOB_Changed_time__c = System.now();
            }
            if(String.isNotBlank(con.FirstName)) {
                con.Firstname_soundex_keycode__c = Soundex_Algorithm.calculateSoundexCode(con.FirstName);
            }
            if(String.isNotBlank(con.LastName)) {
                con.Lastname_soundex_keycode__c = Soundex_Algorithm.calculateSoundexCode(con.LastName);
            } 
            if(con.RecordTypeId == recordTypeId && con.Casevault_PID__c == null) {
                casevaultPIDValue++;
                con.Casevault_PID__c = 'PE-'+Integer.valueOf(casevaultPIDValue);  
            }
             
        } 
        cvUniqueLstSettingIns.Auto_Number__c = casevaultPIDValue;
    	upsert cvUniqueLstSettingIns;
        FieldLevelSecurity.checkFieldAccessByCriteria('Home_Approval_Status__c,','view','Home_Approval__c', Boolean.valueOf(Label.HasNamespace));
        for(Home_Approval__c home : [SELECT Id, Home_Approval_Status__c FROM Home_Approval__c WHERE Id IN :homeApprovalIds 
                                AND Home_Approval_Status__c = 'Approved']) {
            
            if(conHomeApprovalMap != null && conHomeApprovalMap.containsKey(home.Id) && conHomeApprovalMap.get(home.Id) != null) {
                
                Contact con = conHomeApprovalMap.get(home.Id);
                
                if(con != null) {
                    con.addError('Not allowed to create or change the value once approved the home approval.');
                }             
            }
        }
    }
    
    public static Contact doSSNAutoFormat(Contact con) {
        
		 if( String.isNotBlank(con.SSN__c) ) {
            
             if(con.SSN__c.contains('-')) {
                 con.SSN__c = con.SSN__c.remove('-');
             } 
             if( !(con.SSN__c.isNumeric())) {
            	con.addError('Do not enter characters');
             }
             Integer ssnLength = 9;
             if( con.SSN__c.length() > ssnLength) {
                 con.addError('SSN length should not be greater than 9');
             } else if(con.SSN__c.length() < ssnLength) {
                 
                 String leadingZeros = '';
                 for(Integer i = con.SSN__c.length(); i < ssnLength; i++) {
                     leadingZeros += '0';
                 }
                 con.SSN__c = leadingZeros + con.SSN__c;
             } 
             con.SSN__c = con.SSN__c.substring(0, 3) + '-' + con.SSN__c.substring(3, 5) + '-' + con.SSN__c.substring(5, 9);             
         }        
        
        return con;
    }
}